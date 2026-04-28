[Setting category="Physics" name="Enabled"]
bool cfgEnabled = true;

[Setting category="Physics" name="Motor thrust (m/s²)" min=10.0 max=1000.0]
float cfgThrust = 150.0f;

[Setting category="Physics" name="Pitch/Roll tilt rate (rad/s)" min=0.2 max=20.0]
float cfgTiltRate = 5.0f;

[Setting category="Physics" name="Yaw rotation rate (rad/s)" min=0.1 max=20.0]
float cfgYawRate = 5.0f;

[Setting category="Physics" name="Angular inertia (0=instant)" min=0.0 max=0.9]
float cfgAngInertia = 0.0f;

[Setting category="Physics" name="Camera tilt angle (deg)" min=-100.0 max=100.0]
float cfgCameraTilt = -63.0f;

[Setting category="Physics" name="Visual camera roll"]
bool cfgVisualRoll = true;

[Setting category="Physics" name="Horizontal linear drag" min=0.0 max=0.5]
float cfgDrag = 0.016f;

[Setting category="Physics" name="Vertical linear drag" min=0.0 max=0.3]
float cfgDragY = 0.023f;

[Setting category="Physics" name="Gravity enabled"]
bool cfgGravityEnabled = true;

[Setting category="Physics" name="Gravity force (m/s²)" min=0.0 max=200.0]
float cfgGravity = 50.0f;

[Setting category="Physics" name="Minimum height (anti-ground)"]
bool cfgUseMinHeight = true;

[Setting category="Physics" name="Minimum height value" min=-50.0 max=500.0]
float cfgMinHeight = 2.0f;

[Setting category="Physics" name="Keyframe frequency (Hz)" min=1 max=60]
int cfgKfFreq = 30;

[Setting category="Physics" name="Max throttle" min=1.0 max=2.0]
float cfgThrottleMax = 1.0f;

[Setting category="Physics" name="Throttle curve" min=0.5 max=3.0]
float cfgThrottleCurve = 2.0f;

[Setting category="Physics" name="Minimum throttle (%)" min=0.0 max=30.0]
float cfgMinThrottlePct = 0.0f;

[Setting category="Controller" name="Pad index (0 = first gamepad found)" min=0 max=7]
int cfgPadIndex = 0;

[Setting category="Axes" name="Throttle axis source" description="Which stick axis to use for throttle"]
AxisSource cfgThrottleAxis = AxisSource::LeftY;

[Setting category="Axes" name="Yaw axis source" description="Which stick axis to use for yaw"]
AxisSource cfgYawAxis = AxisSource::LeftX;

[Setting category="Axes" name="Pitch axis source" description="Which stick axis to use for pitch"]
AxisSource cfgPitchAxis = AxisSource::RightY;

[Setting category="Axes" name="Roll axis source" description="Which stick axis to use for roll"]
AxisSource cfgRollAxis = AxisSource::RightX;

[Setting category="Axes" name="Stick deadzone" min=0.0 max=0.4]
float cfgDeadzone = 0.0f;

[Setting category="Axes" name="Stick expo (yaw/pitch/roll)" description="Exponential curve for yaw, pitch and roll axes. Higher values give finer control near center and faster response at edges. 1 = linear, 2-3 = typical FPV feel. Throttle uses its own curve in Physics settings." min=1.0 max=5.0]
float cfgStickExpo = 1.0f;

[Setting category="Axes" name="Invert Throttle"]
bool cfgInvThrottle = false;

[Setting category="Axes" name="Invert Yaw"]
bool cfgInvYaw = false;

[Setting category="Axes" name="Invert Pitch"]
bool cfgInvPitch = false;

[Setting category="Axes" name="Invert Roll"]
bool cfgInvRoll = true;

[Setting category="Axes" name="Invert visual roll"]
bool cfgInvVisualRoll = false;

[Setting category="Overlay" name="Show stick overlay"]
bool cfgShowInputOverlay = true;

[Setting category="Overlay" name="Position X" min=0 max=3840]
int cfgOverlayX = 21;

[Setting category="Overlay" name="Position Y" min=0 max=2160]
int cfgOverlayY = 751;

[Setting category="Overlay" name="Box size" min=40.0 max=150.0]
float cfgOverlaySize = 150.0f;

[Setting category="Overlay" name="Spacing" min=0.0 max=60.0]
float cfgOverlayGap = 13.0f;

[Setting category="Overlay" name="Background alpha" min=0.0 max=1.0]
float cfgOverlayBgAlpha = 0.71f;

[Setting category="Overlay" name="Border alpha" min=0.0 max=1.0]
float cfgOverlayBorderAlpha = 0.36f;

[Setting category="Overlay" name="Cross alpha" min=0.0 max=1.0]
float cfgOverlayCrossAlpha = 0.22f;

[Setting category="Overlay" name="Dot size" min=1.5 max=14.0]
float cfgOverlayDotSize = 4.0f;

[Setting category="Overlay" name="Dot color R" min=0.0 max=1.0]
float cfgOverlayDotR = 0.61f;

[Setting category="Overlay" name="Dot color G" min=0.0 max=1.0]
float cfgOverlayDotG = 1.0f;

[Setting category="Overlay" name="Dot color B" min=0.0 max=1.0]
float cfgOverlayDotB = 0.21f;
