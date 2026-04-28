class ButtonState {
    bool wasDown = false; // previous frame state
    uint pressedAt = 0; // last time button was pressed
}

ButtonState recBtn; // state for the record button
ButtonState respBtn; // state for the relaunch button
ButtonState cpBtn; // state for the marker button
ButtonState rwBtn; // state for the rewind button

bool btnPressed(ButtonState@ state, bool down, uint now) {
    bool edge = down && !state.wasDown; //if we just went from not pressed to pressed
    if (edge) state.pressedAt = now; // then we record the time it was pressed for long-press detection
    return edge; // this function is called in the same frame as btnReleased always so that's why we only set wasDown in that function
}

bool btnReleased(ButtonState@ state, bool down, uint now, uint &out heldMs) {
    bool edge = !down && state.wasDown; //if we just went from pressed to not pressed
    heldMs = edge ? now - state.pressedAt : 0; // then we calculate how long it was held
    state.wasDown = down;
    return edge;
}

bool IsPadBtnDown(CInputScriptPad@ pad, int idx) {
    switch (idx) {
        case  1: return pad.A > 0;
        case  2: return pad.B > 0;
        case  3: return pad.X > 0;
        case  4: return pad.Y > 0;
        case  5: return pad.L1 > 0;
        case  6: return pad.R1 > 0;
        case  7: return pad.L2 >= 0.5f;
        case  8: return pad.R2 >= 0.5f;
        case  9: return pad.LeftStickBut > 0;
        case 10: return pad.RightStickBut > 0;
        case 11: return pad.Up > 0;
        case 12: return pad.Down > 0;
        case 13: return pad.Left > 0;
        case 14: return pad.Right > 0;
        case 15: return pad.Menu > 0;
        case 16: return pad.View > 0;
    }
    return false;
}

float ApplyDeadzone(float v) {
    return Math::Abs(v) < cfgDeadzone ? 0.0f : v;
}

float ApplyExpo(float v) {
    if (cfgStickExpo <= 1.0f) return v;
    float sign = v < 0.0f ? -1.0f : 1.0f;
    return sign * Math::Pow(Math::Abs(v), cfgStickExpo);
}

float ReadAxis(CInputScriptPad@ pad, AxisSource src) {
    switch (src) {
        case AxisSource::LeftX:  return pad.LeftStickX;
        case AxisSource::LeftY:  return pad.LeftStickY;
        case AxisSource::RightX: return pad.RightStickX;
        case AxisSource::RightY: return pad.RightStickY;
        case AxisSource::L2:     return pad.L2;
        case AxisSource::R2:     return pad.R2;
    }
    return 0.0f;
}

float ReadThrottleAxis(CInputScriptPad@ pad) {
    return ApplyDeadzone(ReadAxis(pad, cfgThrottleAxis));
}

float ReadYawAxis(CInputScriptPad@ pad) {
    return ApplyExpo(ApplyDeadzone(ReadAxis(pad, cfgYawAxis)));
}

float ReadPitchAxis(CInputScriptPad@ pad) {
    return ApplyExpo(ApplyDeadzone(ReadAxis(pad, cfgPitchAxis)));
}

float ReadRollAxis(CInputScriptPad@ pad) {
    return ApplyExpo(ApplyDeadzone(ReadAxis(pad, cfgRollAxis)));
}

//stored offsets
uint16 offRotSpd = 0;
uint16 offRotIn = 0;

uint16 gameSceneMemberOffset = 0;

CGameControlCameraFree@ GetFreeCam() {
    if (gameSceneMemberOffset == 0) {  
        gameSceneMemberOffset = LookupMemberOffset("CGameManiaPlanet", "GameScene");
    }

    auto app = GetApp();
    auto mgr = Dev::GetOffsetNod(app, gameSceneMemberOffset + offsetCameraMgrFromGameScene);

    if (mgr is null) return null;

    return cast<CGameControlCameraFree>(Dev::GetOffsetNod(mgr, offsetCameraNodeInMgr));
}

void suppressCamInput(CGameControlCameraFree@ cam) {
    if (offRotSpd == 0) {
        offRotSpd = LookupMemberOffset("CGameControlCameraFree", "m_RotateSpeed");
        offRotIn = LookupMemberOffset("CGameControlCameraFree", "m_RotateInertia");
    }

    Dev::SetOffset(cam, offRotSpd, 0.0f);
    Dev::SetOffset(cam, offRotIn, 0.0f);
    GetApp().SystemConfig.InputsDisableFreeCamPadControl = true;
}

uint16 LookupMemberOffset(const string &in cls, const string &in mem) {
    return Reflection::GetType(cls).GetMember(mem).Offset;
}

CInputScriptPad@ GetPrimaryPad() {
    auto port = GetApp().InputPort;

    if (port is null) return null;

    int padsSeen = 0;
    for (uint i = 0; i < port.Script_Pads.Length; i++) {
        auto p = port.Script_Pads[i];
        if (p is null) continue;
        if (p.Type == CInputScriptPad::EPadType::Keyboard || p.Type == CInputScriptPad::EPadType::Mouse) continue;
        if (padsSeen == cfgPadIndex) return p;
        padsSeen++;
    }
    return null;
}
