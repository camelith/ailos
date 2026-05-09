#define CATEGORY_FORGET ["AILOS", "Forget Target"]
#define CATEGORY_VIS    ["AILOS", "Visibility"]
#define CATEGORY_SOUND  ["AILOS", "Sound & Awareness"]
#define CATEGORY_PERF   ["AILOS", "Performance"]

[
    "AILOS_Setting_Enabled", "CHECKBOX",
    ["Enable AILOS", "Turning this off disables the mod."],
    CATEGORY_FORGET,
    true,
    1, {}, true
] call CBA_fnc_addSetting;

// ============================================================================
// FORGET / LOSE TARGET SETTINGS
// ============================================================================
[
    "AILOS_Setting_ForgetBase", "SLIDER",
    ["Forget Base Time", "Base seconds before AI forgets enemy after losing line of sight. Multiplied by skill."],
    CATEGORY_FORGET,
    [5, 120, 15, 0],
    1, {}, true
] call CBA_fnc_addSetting;

[
    "AILOS_Setting_ForgetRandom", "SLIDER",
    ["Forget Random Time", "Random seconds added to base forget time for variation between groups."],
    CATEGORY_FORGET,
    [0, 120, 10, 0],
    1, {}, true
] call CBA_fnc_addSetting;

[
    "AILOS_Setting_ForgetCooldown", "SLIDER",
    ["Forget Cooldown", "Time before a group can be re-targeted after being forgotten."],
    CATEGORY_FORGET,
    [0, 60, 15, 0],
    1, {}, true
] call CBA_fnc_addSetting;

[
    "AILOS_Setting_StartDisabled", "CHECKBOX",
    ["Start AI With AUTOTARGET Off", "This mimics normal TCL behavior. Turning it on or off shouldn't make much difference but leaving it on is probably for the best."],
    CATEGORY_FORGET,
    true,
    1, {}, true
] call CBA_fnc_addSetting;

// ============================================================================
// UNDER FIRE SETTINGS
// ============================================================================
[
    "AILOS_Setting_UnderFireOverride", "CHECKBOX",
    ["Under-Fire Override", "TCL's check to keep a group from forgetting a target if they're actively under fire from it. Probably always leave this on."],
    CATEGORY_FORGET,
    true,
    1, {}, true
] call CBA_fnc_addSetting;

[
    "AILOS_Setting_UnderFireInaccuracy", "SLIDER",
    ["Under-Fire Position Inaccuracy", "Base inaccuracy when targeting a concealed group. Higher is more inaccurate. Smoke and suppressors double this value."],
    CATEGORY_FORGET,
    [0, 0.5, 0.1, 2],
    1, {}, true
] call CBA_fnc_addSetting;

// ============================================================================
// VISIBILITY SETTINGS
// ============================================================================
[
    "AILOS_Setting_NightWeatherEnabled", "CHECKBOX",
    ["Apply Night & Weather Range Cap", "AI detection range is reduced by darkness and fog. Disable to use full detection range at all times."],
    CATEGORY_VIS,
    true,
    1, {}, true
] call CBA_fnc_addSetting;

[
    "AILOS_Setting_MaxDetectRange", "SLIDER",
    ["Max Detection Range", "Maximum distance (m) AI can visually detect enemies in daylight, clear weather. Reduced by night and fog."],
    CATEGORY_VIS,
    [300, 3000, 1500, 0],
    1, {}, true
] call CBA_fnc_addSetting;

[
    "AILOS_Setting_NightMultiplier", "SLIDER",
    ["Night Vision Factor", "Detection range multiplier at night. 0.3 = 30% of day range (450m at default). 1.0 = no night penalty."],
    CATEGORY_VIS,
    [0.1, 1.0, 0.3, 2],
    1, {}, true
] call CBA_fnc_addSetting;

// ============================================================================
// SOUND & AWARENESS SETTINGS
// ============================================================================
[
    "AILOS_Setting_SuppressorEnabled", "CHECKBOX",
    ["Suppressor Detection Penalty", "AI detects suppressors and adjusts detection accordingly. Disable to ignore suppressor effects entirely."],
    CATEGORY_SOUND,
    true,
    1, {}, true
] call CBA_fnc_addSetting;

[
    "AILOS_Setting_SmokeEnabled", "CHECKBOX",
    ["Smoke Obscurement", "When enabled, enemies shooting from within a smoke cloud (thrown grenades or vehicle smoke) are harder to locate precisely. AI still hears the gunshot but cannot pinpoint the exact position. Disable to let AI ignore smoke for position estimation."],
    CATEGORY_SOUND,
    true,
    1, {}, true
] call CBA_fnc_addSetting;

[
    "AILOS_Setting_SmokeRadius", "SLIDER",
    ["Smoke Detection Radius (m)", "Radius around a smoke grenade/canister within which a shooter is considered obscured. Typical smoke clouds cover 10-15m."],
    CATEGORY_SOUND,
    [5, 30, 15, 0],
    1, {}, true
] call CBA_fnc_addSetting;

[
    "AILOS_Setting_AlertZoneRadius", "SLIDER",
    ["Alert Zone Radius (m)", "Distance (m) from last known enemy position where AI reacts faster to new gunfire. AI is already alert in this zone."],
    CATEGORY_SOUND,
    [50, 800, 300, 0],
    1, {}, true
] call CBA_fnc_addSetting;

[
    "AILOS_Setting_SoundEnabled", "CHECKBOX",
    ["Enable Sound Propagation", "Nearby allied AI groups react to gunfire and investigate. Disable to prevent AI from alerting each other through sound."],
    CATEGORY_SOUND,
    true,
    1, {}, true
] call CBA_fnc_addSetting;

[
    "AILOS_Setting_SoundRadius", "SLIDER",
    ["Sound Radius (Unsuppressed)", "Distance (m) at which nearby allied groups hear gunfire and react. Applies to unsuppressed weapons."],
    CATEGORY_SOUND,
    [100, 2000, 800, 0],
    1, {}, true
] call CBA_fnc_addSetting;

[
    "AILOS_Setting_SoundRadiusSuppressed", "SLIDER",
    ["Sound Radius (Suppressed)", "Distance (m) at which nearby allied groups hear suppressed gunfire. Reduced but not silent."],
    CATEGORY_SOUND,
    [25, 500, 150, 0],
    1, {}, true
] call CBA_fnc_addSetting;

// ============================================================================
// PERFORMANCE
// ============================================================================
[
    "AILOS_Setting_TickInterval", "SLIDER",
    ["Tick Interval", "Frequency of group LOS checks. Lower is faster and more expensive."],
    CATEGORY_PERF,
    [0.25, 5.0, 1.0, 2],
    1, {}, true
] call CBA_fnc_addSetting;

[
    "AILOS_Setting_BatchSize", "SLIDER",
    ["Groups Per Tick", "Number of groups processed per tick."],
    CATEGORY_PERF,
    [0, 100, 25, 0],
    1, {}, true
] call CBA_fnc_addSetting;

[
    "AILOS_Setting_AffectPlayerGroups", "CHECKBOX",
    ["Affect Player-Led Groups", "Turn this on if you want player group AI to use AILOS behavior. You probably don't want that though."],
    CATEGORY_PERF,
    false,
    1, {}, true
] call CBA_fnc_addSetting;

diag_log "AILOS: CBA settings defined";
