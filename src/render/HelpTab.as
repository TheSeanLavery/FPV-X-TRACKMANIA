[SettingsTab name="Help"]
void RenderHelpTabContents() {
    TextColored(UiGray, "FPV Drone ─────────────────────────────────────");
    UI::Text("");
    UI::TextWrapped("FPV Drone is a camera plugin that simulates FPV drone physics in acrobatics mode. It works as soon as Camera 7 (free cam) is active. A gamepad or FPV controller is required.");
    UI::Text("");
    UI::TextWrapped("Recording: short press on Record bind starts and stops recording. During recording, holding the Rewind bind makes the drone go back in time. Inputs can be kept active during rewind to smoothly resume the trajectory when released.");
    UI::Text("");
    UI::TextWrapped("Checkpoint: first press saves current position, next press returns to that position. Long press clears the checkpoint.");
    UI::Text("");
    TextColored(UiGray, "Controller setup ──────────────────────────────────────");
    UI::Text("");
    UI::TextWrapped("Any controller that appears as a USB gamepad/joystick will work, including dedicated FPV drone controllers:");
    UI::Text("");
    UI::TextWrapped("DJI FPV Controller 2 / DJI RC Pro: Connect via USB-C. Powers on automatically. Detected as a generic gamepad.");
    UI::TextWrapped("RadioMaster TX16S / Pocket / Zorro: Connect via USB-C, set radio to Joystick mode in the radio's system menu.");
    UI::TextWrapped("TBS Tango 2 / Mambo: Connect via USB-C. Appears as a standard HID joystick.");
    UI::TextWrapped("Other radios: If your radio lacks USB, use a USB simulator dongle (trainer port adapter).");
    UI::Text("");
    UI::TextWrapped("If your controller axes don't match the default layout, go to Settings > Axes and change the axis source for each control (Throttle, Yaw, Pitch, Roll). Use the stick overlay to verify correct mapping.");
    UI::TextWrapped("If you have multiple controllers connected, change the Pad index in Settings > Controller to select the correct one.");
    UI::TextWrapped("Use the Stick expo setting (1 = linear, 2-3 = typical FPV feel) for a more natural response curve.");
    UI::Text("");
    TextColored(UiGray, "How to render in mediatracker ──────────────────────────────────────");
    UI::Text("");
    UI::TextWrapped("Step 1: Record your flight with the plugin");
    auto storagePath = IO::FromStorageFolder("");
    UI::Text("Step 2: Export the recording to CSV with the dedicated button");
    
    UI::Text("Step 3: Open the web converter linked");
    UI::SameLine();
    UI::TextLinkOpenURL("here", "https://utils.tmtas.exchange/fpvclip.html");

    UI::TextWrapped("Step 4: Open the folder where the CSV was exported. Click the button below to open the folder directly. ");
    
    if (UI::Button("Open export folder##export")) {
        OpenExplorerPath(storagePath);
    }

    UI::TextWrapped("Step 5: Click on Generate Clip, and place the downloaded clip file in your game's replays folder");

    UI::TextWrapped("Step 6: Open a replay in MediaTracker, then import the clip. Voilà!");
}
