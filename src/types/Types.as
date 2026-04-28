enum FlightMode {
    Idle,
    FreeFlight,
    Recording,
    Rewinding,
}

enum AxisSource {
    LeftX,
    LeftY,
    RightX,
    RightY,
    L2,
    R2,
}

class ViewAngles {
    float yaw = 0.0f;
    float pitch = 0.0f;
    float roll = 0.0f;
}

class FlightState {
    vec3 pos = vec3(0, 0, 0);
    vec3 fwd = vec3(0, 0, 1); // forward dir of the drone
    vec3 up = vec3(0, 1, 0); // up dir
    vec3 vel = vec3(0, 0, 0);

    //angular vel
    float pitchRate = 0.0f;
    float rollRate = 0.0f;
    float yawRate = 0.0f;

    float throttle = 0.0f; //throttle [0;1]
    ViewAngles view; //angles used for the game cam

    void ResetMotion() {
        vel = vec3(0, 0, 0);
        pitchRate = 0.0f;
        rollRate = 0.0f;
        yawRate = 0.0f;
        throttle = 0.0f;
    }

    void ResetAll() {
        pos = vec3(0, 0, 0);
        fwd = vec3(0, 0, 1);
        up = vec3(0, 1, 0);
        view.yaw = 0.0f;
        view.pitch = 0.0f;
        view.roll = 0.0f;
        ResetMotion();
    }
}

class ReplayBuffer {
    array<FlightState> samples; // states recorded during Recording mode, for both rewinding and export
    array<float> sampleTimes; // the time at which each was recorded
    float captureTime = 0.0f; // total duration so far
    float nextSampleAt = 0.0f; // next timestamp that should be sampled (determined by cfgSampleRate)
    float scrubTime = 0.0f; // current rewind position
    uint sampleCursor = 0; // index for interpolation during rewind
}

class ReturnPoint {
    FlightState snapshot; // state to rewind to
    bool isSet = false;
    float captureTime = 0.0f; // time at which it was taken (since respawn behaves like going back in time)
}

class SessionState {
    bool active = false; 
    FlightMode mode = FlightMode::Idle;
}
