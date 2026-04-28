void ResetReplayBuffer() {
    replay.samples.Resize(0);
    replay.sampleTimes.Resize(0);
    replay.captureTime = 0.0f;
    replay.nextSampleAt = 0.0f;
    replay.scrubTime = 0.0f;
    replay.sampleCursor = 0;
}

void PushReplaySample(float t) {
    replay.samples.InsertLast(flightState);
    replay.sampleTimes.InsertLast(t);
}

void CropReplayTo(float cutoff) {
    while (replay.sampleTimes.Length > 0 && replay.sampleTimes[replay.sampleTimes.Length - 1] > cutoff) { // remove samples one by one from the end until we're at the cutoff
        replay.samples.Resize(replay.samples.Length - 1); 
        replay.sampleTimes.Resize(replay.sampleTimes.Length - 1);
    }
    replay.sampleCursor = 0;
    replay.captureTime = replay.sampleTimes.Length > 0 ? replay.sampleTimes[replay.sampleTimes.Length - 1] : 0.0f;
}

bool SampleReplayAt(float t, FlightState &out sample) {
    uint len = replay.samples.Length;
    if (len == 0) return false;
    if (len == 1 || t <= replay.sampleTimes[0]) {
        sample = replay.samples[0];
        return true;
    }

    while (replay.sampleCursor + 2 < len && t >= replay.sampleTimes[replay.sampleCursor + 1]) replay.sampleCursor++;
    while (replay.sampleCursor > 0 && t < replay.sampleTimes[replay.sampleCursor]) replay.sampleCursor--;

    uint aIx = replay.sampleCursor;
    uint bIx = (aIx + 1 < len) ? aIx + 1 : aIx;
    FlightState a = replay.samples[aIx];
    FlightState b = replay.samples[bIx];
    float span = replay.sampleTimes[bIx] - replay.sampleTimes[aIx];
    float alpha = span > epsilon ? Math::Clamp((t - replay.sampleTimes[aIx]) / span, 0.0f, 1.0f) : 0.0f;

    sample = a;
    sample.pos = a.pos + (b.pos - a.pos) * alpha;
    sample.fwd = FPVMath::VNorm(a.fwd + (b.fwd - a.fwd) * alpha);
    sample.up = FPVMath::VNorm(a.up + (b.up - a.up) * alpha);
    sample.vel = a.vel + (b.vel - a.vel) * alpha;
    sample.pitchRate = a.pitchRate + (b.pitchRate - a.pitchRate) * alpha;
    sample.rollRate = a.rollRate + (b.rollRate - a.rollRate) * alpha;
    sample.yawRate = a.yawRate + (b.yawRate - a.yawRate) * alpha;
    sample.throttle = a.throttle + (b.throttle - a.throttle) * alpha;
    sample.view.yaw = a.view.yaw + (b.view.yaw - a.view.yaw) * alpha;
    sample.view.pitch = a.view.pitch + (b.view.pitch - a.view.pitch) * alpha;
    sample.view.roll = a.view.roll + (b.view.roll - a.view.roll) * alpha;
    return true;
}

void ApplyViewToCamera(CGameControlCameraFree@ cam) {
    cam.m_FreeVal_Loc_Translation = flightState.pos;
    cam.m_Yaw = flightState.view.yaw;
    cam.m_Pitch = flightState.view.pitch;
    cam.m_Roll = flightState.view.roll;
}

void SaveReturnPoint() { // save cp
    returnPoint.snapshot = flightState;
    returnPoint.captureTime = replay.captureTime;
    returnPoint.isSet = true;
}

void JumpToReturnPoint(CGameControlCameraFree@ cam) {
    flightState = returnPoint.snapshot;
    ApplyViewToCamera(cam);

    if (session.mode == FlightMode::Recording) {
        CropReplayTo(returnPoint.captureTime);  // remove all states after respawn (wiping so they don't show in export, as if it also went back in time)
        replay.captureTime = returnPoint.captureTime;
    }
}

void HandleReturnPointRelease(CGameControlCameraFree@ cam, uint durationMs) {
    if (durationMs >= cpLongPressMs) {
        returnPoint.isSet = false;
    } else if (returnPoint.isSet) {
        JumpToReturnPoint(cam);
    } else {
        SaveReturnPoint();
    }
}

void RelaunchFromStart(CGameControlCameraFree@ cam) {
    flightState = launchState;
    flightState.ResetMotion();
    ApplyViewToCamera(cam);

    if (session.mode == FlightMode::Recording && returnPoint.isSet) {
        CropReplayTo(returnPoint.captureTime);  // remove all states after respawn (wiping so they don't show in export, as if it also went back in time)
        replay.captureTime = returnPoint.captureTime;
    }
}

void RefreshViewAngles() {
    // apply camera tilt to the craft's orientation
    vec3 cameraRight = FPVMath::VCross(flightState.fwd, flightState.up);
    float tiltRad = cfgCameraTilt * DEG2RAD;
    vec3 cameraForward = FPVMath::VNorm(FPVMath::RotAround(flightState.fwd, cameraRight, -tiltRad));
    vec3 cameraUp = FPVMath::VNorm(FPVMath::RotAround(flightState.up, cameraRight, -tiltRad));

    // convert to yaw/pitch for the game camera
    flightState.view.yaw = Math::Atan2(cameraForward.x, cameraForward.z);
    flightState.view.pitch = -Math::Asin(Math::Clamp(cameraForward.y, -1.0f, 1.0f));

    if (!cfgVisualRoll) {
        flightState.view.roll = 0.0f;
        return;
    }

    // calculate roll by comparing camera up with world up
    vec3 worldUp = vec3(0, 1, 0);
    float projectedDot = FPVMath::VDot(worldUp, cameraForward);
    vec3 projectedUpRaw = vec3(
        worldUp.x - cameraForward.x * projectedDot,
        worldUp.y - cameraForward.y * projectedDot,
        worldUp.z - cameraForward.z * projectedDot
    );
    
    float projectedLen = Math::Sqrt(projectedUpRaw.x * projectedUpRaw.x + projectedUpRaw.y * projectedUpRaw.y + projectedUpRaw.z * projectedUpRaw.z);
    if (projectedLen <= epsilon) {
        flightState.view.roll = 0.0f;
        return;
    }

    vec3 projectedUp = vec3(projectedUpRaw.x / projectedLen, projectedUpRaw.y / projectedLen, projectedUpRaw.z / projectedLen);
    flightState.view.roll = Math::Atan2(
        FPVMath::VDot(FPVMath::VCross(projectedUp, cameraUp), cameraForward),
        FPVMath::VDot(projectedUp, cameraUp)
    ) * (cfgInvVisualRoll ? -1.0f : 1.0f);
}

bool BeginRewindIfRequested(bool rewindHeld) {
    if (!rewindHeld) return false;
    if (session.mode != FlightMode::Recording) return false; // can't rewind if we're not even recording (no states stored)
    if (replay.samples.Length < 2) return false; // need at least 2 samples or there's nothing to scrub through

    session.mode = FlightMode::Rewinding;
    replay.scrubTime = replay.captureTime; // start from the end cause we just hit rewind
    replay.sampleCursor = uint(Math::Max(0, int(replay.samples.Length) - 2)); // start near the end to not walk the whole thing
    while (replay.sampleCursor > 0 && replay.scrubTime < replay.sampleTimes[replay.sampleCursor]) {
        replay.sampleCursor--;
    }
    return true;
}

bool AdvanceRewind(CGameControlCameraFree@ cam, bool rewindHeld) {
    if (rewindHeld) {
        return true;
    }

    session.mode = FlightMode::Recording;
    CropReplayTo(replay.scrubTime);
    if (replay.samples.Length > 0) {
        flightState = replay.samples[replay.samples.Length - 1];
        flightState.pitchRate = 0.0f;
        flightState.rollRate = 0.0f;
        flightState.yawRate = 0.0f;
        flightState.throttle = 0.0f;
    }
    replay.captureTime = replay.scrubTime;
    replay.nextSampleAt = replay.scrubTime;
    ApplyViewToCamera(cam);
    return false;
}

void EnsureFlightInitialized(CGameControlCameraFree@ cam) { // just a global init of the base state from default cam 7 to ours
    if (session.active) return;

    float yaw = cam.m_Yaw;
    flightState.pos = cam.m_FreeVal_Loc_Translation;
    flightState.fwd = FPVMath::VNorm(vec3(Math::Sin(yaw), 0.0f, Math::Cos(yaw)));
    flightState.up = vec3(0, 1, 0);
    flightState.ResetMotion();
    RefreshViewAngles();
    launchState = flightState;
    session.active = true;
    session.mode = FlightMode::FreeFlight;
}

void UpdateFlightInputs(CGameControlCameraFree@ cam, CInputScriptPad@ pad, uint now) {
    bool captureHeld = IsPadBtnDown(pad, btnRecord);
    bool relaunchHeld = IsPadBtnDown(pad, btnRespawn);
    bool markerHeld = IsPadBtnDown(pad, btnCp);
    uint heldMs = 0;

    if (btnPressed(recBtn, captureHeld, now)) { //state transition from not pressed to pressed (this button acts as a toggle)
        if (session.mode == FlightMode::Recording) {
            session.mode = FlightMode::FreeFlight;
        } else {
            ResetReplayBuffer();
            session.mode = FlightMode::Recording;
        }
    }
    btnReleased(recBtn, captureHeld, now, heldMs);

    if (btnPressed(respBtn, relaunchHeld, now)) RelaunchFromStart(cam);
    btnReleased(respBtn, relaunchHeld, now, heldMs);

    btnPressed(cpBtn, markerHeld, now);
    if (btnReleased(cpBtn, markerHeld, now, heldMs)) HandleReturnPointRelease(cam, heldMs);
}

void UpdateThrottle(CInputScriptPad@ pad) {
    float stickY = ReadThrottleAxis(pad);
    float stickThrottle = Math::Clamp((-stickY * (cfgInvThrottle ? -1.0f : 1.0f) + 1.0f) * 0.5f, 0.0f, 1.0f);
    float minimumThrottle = Math::Clamp(cfgMinThrottlePct / 100.0f, 0.0f, 0.95f);
    flightState.throttle = stickThrottle < 0.001f ? 0.0f : (minimumThrottle + (1.0f - minimumThrottle) * Math::Pow(stickThrottle, cfgThrottleCurve)) * cfgThrottleMax;
}

void UpdateAngularRates(CInputScriptPad@ pad, float dt) {
    float yawInput = ReadYawAxis(pad) * (cfgInvYaw ? -1.0f : 1.0f);
    float pitchInput = -ReadPitchAxis(pad) * (cfgInvPitch ? -1.0f : 1.0f);
    float rollInput = ReadRollAxis(pad) * (cfgInvRoll ? -1.0f : 1.0f);

    float inertiaBlend = 1.0f - Math::Pow(cfgAngInertia, dt * 60.0f);
    flightState.pitchRate += (pitchInput * cfgTiltRate - flightState.pitchRate) * inertiaBlend;
    flightState.rollRate += (rollInput * cfgTiltRate - flightState.rollRate) * inertiaBlend;
    flightState.yawRate += (yawInput * cfgYawRate - flightState.yawRate) * inertiaBlend;
}

void RotateCraft(float dt) {
    vec3 bodyRight = FPVMath::VCross(flightState.fwd, flightState.up);

    // every body axis is updated with axis-angle rotation (Rodrigues' formula)
    // see FPVMath::RotAround
    flightState.fwd = FPVMath::VNorm(FPVMath::RotAround(flightState.fwd, bodyRight, -flightState.pitchRate * dt));
    flightState.up = FPVMath::VNorm(FPVMath::RotAround(flightState.up, bodyRight, -flightState.pitchRate * dt));
    flightState.up = FPVMath::VNorm(FPVMath::RotAround(flightState.up, flightState.fwd, -flightState.rollRate * dt));
    flightState.fwd = FPVMath::VNorm(FPVMath::RotAround(flightState.fwd, flightState.up, -flightState.yawRate * dt));

    // reorthonormalize to prevent drift
    flightState.fwd = FPVMath::VNorm(flightState.fwd);
    flightState.up = FPVMath::VNorm(flightState.up - flightState.fwd * FPVMath::VDot(flightState.up, flightState.fwd));
}

void IntegrateVelocity(float dt) {
    // semi-implicit Euler: update velocity from acceleration first, then integrate position from the new velocity
    vec3 acceleration = flightState.up * (flightState.throttle * flightState.throttle) * cfgThrust;
    if (cfgGravityEnabled) acceleration.y -= cfgGravity;

    flightState.vel += acceleration * dt;

    float horizontalDrag = Math::Pow(1.0f - cfgDrag, dt * 60.0f);
    float verticalDrag = Math::Pow(1.0f - cfgDragY, dt * 60.0f);

    flightState.vel.x *= horizontalDrag;
    flightState.vel.z *= horizontalDrag;
    flightState.vel.y *= verticalDrag;

    flightState.pos += flightState.vel * dt;

    if (cfgUseMinHeight && flightState.pos.y < cfgMinHeight) {
        flightState.pos.y = cfgMinHeight;
        if (flightState.vel.y < 0.0f) flightState.vel.y = 0.0f;
    }
}

void SimulateFlight(CInputScriptPad@ pad, float dt) { 
    //applying settings and inputs to the state
    UpdateThrottle(pad);
    UpdateAngularRates(pad, dt);
    
    //applying the state to move the drone
    RotateCraft(dt);
    IntegrateVelocity(dt);
}

void CaptureReplaySample(float dt) {
    if (session.mode != FlightMode::Recording) return;

    float interval = 1.0f / float(cfgKfFreq);
    while (replay.captureTime >= replay.nextSampleAt) {
        PushReplaySample(replay.nextSampleAt);
        replay.nextSampleAt += interval;
    }
    replay.captureTime += dt;
}

void StepFlightModel(CGameControlCameraFree@ cam, CInputScriptPad@ pad, float dt) {
    suppressCamInput(cam); // Used to avoid conflicts between cam 7 movement and our physics (causes jitters otherwise). Inspired from https://github.com/ezio416/tm-pad-freecam

    uint now = GetApp().TimeSinceInitMs;
    bool rewindHeld = IsPadBtnDown(pad, btnRewind);
    uint heldMs = 0;

    if (btnPressed(rwBtn, rewindHeld, now)) {
        BeginRewindIfRequested(rewindHeld);
    }

    if (session.mode == FlightMode::Rewinding) {
        replay.scrubTime = Math::Max(0.0f, replay.scrubTime - dt);

        FlightState sampled;
        if (SampleReplayAt(replay.scrubTime, sampled)) {
            flightState = sampled; // restore the sampled state
            ApplyViewToCamera(cam); //udpate cam with new state
        }
        btnReleased(rwBtn, rewindHeld, now, heldMs);
        if (AdvanceRewind(cam, rewindHeld)) { //exit rewind mode cleanly
            return;
        }
    } else {
        btnReleased(rwBtn, rewindHeld, now, heldMs);
    }

    if (!GetApp().InputPort.IsFocused) return;

    EnsureFlightInitialized(cam);
    UpdateFlightInputs(cam, pad, now);
    SimulateFlight(pad, dt);
    RefreshViewAngles();
    ApplyViewToCamera(cam);
    CaptureReplaySample(dt);
}
