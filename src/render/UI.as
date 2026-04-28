vec4 UiGreen = vec4(0.20f, 0.95f, 0.20f, 1.0f);
vec4 UiRed = vec4(0.95f, 0.25f, 0.25f, 1.0f);
vec4 UiOrange = vec4(1.00f, 0.60f, 0.20f, 1.0f);
vec4 UiYellow = vec4(0.95f, 0.90f, 0.25f, 1.0f);
vec4 UiGray = vec4(0.60f, 0.60f, 0.60f, 1.0f);

void TextColored(const vec4 &in color, const string &in text) {
    UI::PushStyleColor(UI::Col::Text, color);
    UI::Text(text);
    UI::PopStyleColor();
}

void ShutdownFlight(bool releaseTmPadInput) {
    if (session.active) { // active -> idle mode
        flightState.ResetAll();
        returnPoint.isSet = false;
        returnPoint.captureTime = 0.0f;
        session.active = false;
        session.mode = FlightMode::Idle;
    }
    lastUpdateMs = 0;
    if (releaseTmPadInput) GetApp().SystemConfig.InputsDisableFreeCamPadControl = false;
}

void OnDisabled() {
    ShutdownFlight(true);
}

void Render() {
    if (!cfgEnabled || !session.active || !cfgShowInputOverlay) return;

    auto pad = GetPrimaryPad();
    if (pad is null) return;

    float bx = float(cfgOverlayX);
    float by = float(cfgOverlayY);

    DrawStickWidget(bx, by, ReadAxis(pad, cfgYawAxis),  ReadAxis(pad, cfgThrottleAxis));
    DrawStickWidget(bx + cfgOverlaySize + cfgOverlayGap, by, ReadAxis(pad, cfgRollAxis), ReadAxis(pad, cfgPitchAxis));

}

void RenderMenu() {
    if (UI::MenuItem("FPV Drone" + (cfgEnabled ? " active" : " inactive"), "", cfgEnabled)) {
        cfgEnabled = !cfgEnabled;
    }
}

string exportMessage = "";
bool exportHadError = false;

void RenderInterface() {
    if (!cfgEnabled) return;

    int wf = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoBackground;

    if (session.active) {
        UI::SetNextWindowPos(hudX, hudY);
        UI::SetNextWindowSize(hudW, hudH);
        UI::Begin("##fpvhud", wf);

        float speed = Math::Sqrt(flightState.vel.x * flightState.vel.x + flightState.vel.y * flightState.vel.y + flightState.vel.z * flightState.vel.z);
        int thr = int(flightState.throttle * 100.0f);
        float pitchDeg = -Math::Asin(Math::Clamp(flightState.fwd.y, -1.0f, 1.0f)) / DEG2RAD;

        uint sampleCount = replay.samples.Length;
        float replayDuration = sampleCount > 0 ? replay.sampleTimes[sampleCount - 1] : 0.0f;

        string modeLabel = "READY";
        string timelineLabel = "";
        vec4 modeColor = UiGray;

        if (session.mode == FlightMode::Rewinding && sampleCount > 0) {
            
            modeLabel = "REWINDING";
            timelineLabel = Text::Format("%.1f", replay.scrubTime) + "s / " + Text::Format("%.1f", replayDuration) + "s";
            modeColor = UiOrange;
        
        } else if (session.mode == FlightMode::Recording) {
        
            modeLabel = "RECORDING";
            timelineLabel = sampleCount + " frames (" + Text::Format("%.1f", replay.captureTime) + "s)";
            modeColor = UiRed;
        
        } else if (sampleCount > 0) {
        
            timelineLabel = sampleCount + " frames buffered";
        
        }

        TextColored(UiGreen, "FPV Flight active");
        UI::SameLine();
        TextColored(UiGray, "(Camera 7 required)");
        UI::SameLine();
        TextColored(modeColor, modeLabel);

        if (timelineLabel != "") {
            UI::SameLine();
            TextColored(UiGray, timelineLabel);
        }
        if (returnPoint.isSet) {
            UI::SameLine();
            TextColored(UiYellow, "Checkpoint set");
        }

        UI::Text("Speed: " + Text::Format("%.1f", speed) + " m/s" + "   Throttle: " + thr + "%" + "   Grav:");
        UI::SameLine();
        TextColored(cfgGravityEnabled ? UiOrange : UiGray, cfgGravityEnabled ? "ON" : "OFF");

        UI::Text("Pitch " + Text::Format("%+.1f", pitchDeg) + "°"
               + "   ↑" + Text::Format("%.1f", flightState.vel.y) + " m/s"
               + "   Tilt cam: " + Text::Format("%.0f", cfgCameraTilt) + "°");
        UI::End();
    }

    float yPos = session.active ? exportYActive : exportYIdle;
    UI::SetNextWindowPos(exportX, int(yPos));
    UI::SetNextWindowSize(exportW, exportH);
    UI::Begin("##fpvwindow", wf); //empty title

    if (UI::Button("Export recording to CSV"))
        exportMessage = ExportReplayCsv(exportHadError);

    if (exportMessage != ""){
        TextColored(exportHadError ? UiRed : UiGreen, (exportHadError ? "✗ " : "✓ ") + exportMessage);
    }

    UI::End();
}
