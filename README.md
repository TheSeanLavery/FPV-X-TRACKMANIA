**FPV Drone** is an Openplanet plugin for Trackmania 2020 that simulates acrobatic FPV drone physics, replacing the standard cam 7.

## Requirements

* **Controller**: A gamepad or FPV drone controller is mandatory to pilot the drone.
* **Camera 7**: The physics engine activates automatically when switching to camera 7.

## Supported Controllers

Any controller recognized as a USB gamepad/joystick will work. This includes standard gamepads and dedicated FPV drone controllers:

| Controller | Connection | Notes |
|---|---|---|
| **Xbox / PlayStation / Generic gamepads** | USB or Bluetooth | Plug-and-play, detected automatically |
| **DJI FPV Controller 2** | USB-C | Powers on automatically when connected, appears as a generic gamepad |
| **DJI RC Pro** | USB-C | Same as DJI FPV Controller 2 |
| **RadioMaster TX16S / Pocket / Zorro** | USB-C | Set the radio to **Joystick mode** in its system menu |
| **TBS Tango 2 / Mambo** | USB-C | Appears as a standard HID joystick |
| **FrSky / Jumper / other radios** | USB-C or sim dongle | Most modern radios have USB joystick mode; older radios need a USB simulator dongle |

If your controller's stick axes don't match the default layout, open Settings → Axes and remap the axis source for Throttle, Yaw, Pitch, and Roll. Use the on-screen stick overlay to verify correct mapping.

If you have multiple controllers connected, adjust the **Pad index** in Settings → Controller to select the right one.

## Controls

The plugin uses the standard FPV configuration by default:
* **Left Stick**: Throttle (Y-axis) and Yaw (X-axis).
* **Right Stick**: Pitch (Y-axis) and Roll (X-axis).

*Note: All axes can be remapped, inverted, and deadzones/expo adjusted in the plugin settings.*

## Key Features

### Advanced Physics Engine
The simulation includes adjustable parameters for motor thrust, gravity, linear drag and more.

### Practice & Recovery Tools
* **Record & Rewind**: Record your flight in real-time. Hold the Rewind key to go back in time. You can maintain stick inputs during the rewind to seamlessly resume your trajectory upon release.
* **Checkpoint System**: Save your current position with a press and return to it with another press. A long press clears the checkpoint.
* **Respawn**: Instantly reset the drone to its starting position.

### CSV Export for Rendering

1. Record a flight and stop the recording.
2. Click the **"Export recording to CSV"** button in the HUD.
3. The file is saved to `users/name/OpenplanetNext/PluginStorage/FPVDrone/trajectory.csv`.
4. Use [FPV Clip](https://utils.tmtas.exchange/fpvclip.html) to convert the data for use in MediaTracker.
5. Move the downloaded `.clip` file to your Replays folder, then open the Replay Editor, select an existing replay on the map, and click **Import a Clip** at the bottom.

## Configuration

Access all settings via the Openplanet menu (`F3`)- > "Openplanet" button -> "Settings" button -> "FPV Drone Camera" tab:
* **Physics**: Adjust flight behavior
* **Axes**: Invert axes and set stick deadzone
* **Overlay**: Toggle and customize the stick movement display
* **Help**: General info and guide to recording and rendering FPV flights.

## To Do List
- quaternion slerp
- presets
- LB/RB for camera angle adjustment
- non-linear curves
- keyboard/mouse support

## Discord server to suggest features and share your clips

https://discord.gg/PyhmQ5scR
