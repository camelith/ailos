#define VAR_LASTSEEN_POS    "AILOS_LastSeenPos"
#define VAR_LASTSEEN_TIME   "AILOS_LastSeenTime"
#define VAR_PREV_KA         "AILOS_PrevKnowsAbout"
#define VAR_FORGET_COOLDOWN "AILOS_ForgetCooldown"
#define VAR_FORGET_ROLL     "AILOS_ForgetRoll"
#define VAR_ENEMY_DIR       "AILOS_EnemyDir"
#define VAR_REGISTERED      "AILOS_Registered"

params ["_group"];

if !(local (leader _group)) exitWith {};

private _affectPlayer = missionNamespace getVariable ["AILOS_Setting_AffectPlayerGroups", false];
if (!_affectPlayer && {isPlayer (leader _group)}) exitWith {};

private _aliveUnits = (units _group) select { alive _x };
if (_aliveUnits isEqualTo []) exitWith {};
if (side _group in [civilian, sideLogic, sideEmpty]) exitWith {};

private _startDisabled = missionNamespace getVariable ["AILOS_Setting_StartDisabled", true];
if (_startDisabled) then {
    {
        if !(_x getVariable [VAR_REGISTERED, false]) then {
            _x disableAI "AUTOTARGET";
            _x setVariable [VAR_REGISTERED, true];
        };
    } forEach _aliveUnits;
};

private _enemy = [_group] call AILOS_fnc_pickPrimaryEnemy;
if (isNull _enemy) exitWith {
    _group setVariable [VAR_PREV_KA, 0];
    _group setVariable [VAR_FORGET_ROLL, nil];
};

// check suppressor and smoke
private _suppressed = false;
if (missionNamespace getVariable ["AILOS_Setting_SuppressorEnabled", true]) then {
    private _weapon = currentWeapon _enemy;
    if (_weapon != "") then {
        private _acc = _enemy weaponAccessories _weapon;
        if (count _acc > 0 && {(_acc select 0) != ""}) then { _suppressed = true };
    };
};

private _smoked = false;
if (missionNamespace getVariable ["AILOS_Setting_SmokeEnabled", true]) then {
    private _smokeRadius = missionNamespace getVariable ["AILOS_Setting_SmokeRadius", 15];
    private _nearSmoke = nearestObjects [_enemy, ["SmokeShell", "SmokeLauncherAmmo"], _smokeRadius];
    if (count _nearSmoke > 0) then { _smoked = true };
};

// check LOS
private _canSee = [_group, _enemy] call AILOS_fnc_canSeeEnemy;

// night/weather modifiers
private _leader = leader _group;
if (_canSee && {missionNamespace getVariable ["AILOS_Setting_NightWeatherEnabled", true]}) then {
    private _maxRange = missionNamespace getVariable ["AILOS_Setting_MaxDetectRange", 1500];
    private _nightMult = missionNamespace getVariable ["AILOS_Setting_NightMultiplier", 0.3];

    private _sun = sunOrMoon;
    private _fog = fog;
    private _cap = _maxRange * (_nightMult + (1 - _nightMult) * _sun);
    _cap = _cap * (1 - 0.7 * _fog);

    if ((_leader distance _enemy) > _cap) then { _canSee = false };
};

// under fire
private _ka     = _group knowsAbout vehicle _enemy;
private _prevKa = _group getVariable [VAR_PREV_KA, 0];
_group setVariable [VAR_PREV_KA, _ka];

private _underFire = false;

if (!_canSee && {missionNamespace getVariable ["AILOS_Setting_UnderFireOverride", true]}) then {
    private _kaRising = (_ka > _prevKa + 0.1);
    private _kaThreshold = if (_suppressed) then { 3.5 } else { 2.0 };

    private _lastKnownPos = _group getVariable [VAR_LASTSEEN_POS, []];
    private _nearLastPos = false;
    if !(_lastKnownPos isEqualTo []) then {
        private _alertZone = missionNamespace getVariable ["AILOS_Setting_AlertZoneRadius", 300];
        if ((_enemy distance _lastKnownPos) < _alertZone) then {
            _kaThreshold = if (_suppressed) then { 1.5 } else { 0.5 };
            _nearLastPos = true;
        };
    };
    _kaThreshold = _kaThreshold * (0.7 + random 0.6);

    if (_kaRising && {_ka >= _kaThreshold}) then {
        _underFire = true;

        { _x enableAI "AUTOTARGET"; _x enableAI "AUTOCOMBAT" } forEach _aliveUnits;
        _group setVariable [VAR_FORGET_COOLDOWN, 0];
        _group setVariable [VAR_FORGET_ROLL, nil];

        private _baseInaccuracy = missionNamespace getVariable ["AILOS_Setting_UnderFireInaccuracy", 0.1];
        if (_suppressed)  then { _baseInaccuracy = _baseInaccuracy max 0.2 };
        if (_smoked)      then { _baseInaccuracy = _baseInaccuracy max 0.3 };
        if (_nearLastPos) then { _baseInaccuracy = _baseInaccuracy * 0.5 };

        private _dist = _leader distance _enemy;
        private _dir  = _leader getDir _enemy;
        private _inaccuracy = _dist * _baseInaccuracy;

        private _approxPos = _leader getPos [_dist, _dir];
        _approxPos set [0, (_approxPos select 0) + (random _inaccuracy) - (random _inaccuracy)];
        _approxPos set [1, (_approxPos select 1) + (random _inaccuracy) - (random _inaccuracy)];

        _group setVariable [VAR_LASTSEEN_POS, _approxPos];
        _group setVariable [VAR_LASTSEEN_TIME, time];
    };
};

// behavior once LOS confirmed
if (_canSee) exitWith {
    { _x enableAI "AUTOTARGET"; _x enableAI "AUTOCOMBAT" } forEach _aliveUnits;

    private _curPos  = getPos _enemy;
    private _prevPos = _group getVariable [VAR_LASTSEEN_POS, _curPos];
    private _moveDir = if ((_prevPos distance2D _curPos) > 1) then {
        _prevPos getDir _curPos
    } else {
        getDir _enemy
    };

    _group setVariable [VAR_LASTSEEN_POS,    _curPos];
    _group setVariable [VAR_LASTSEEN_TIME,   time];
    _group setVariable [VAR_PREV_KA,         0];
    _group setVariable [VAR_FORGET_COOLDOWN, 0];
    _group setVariable [VAR_FORGET_ROLL,     nil];
    _group setVariable [VAR_ENEMY_DIR,       _moveDir];

    [_group, _enemy, _suppressed] call AILOS_fnc_soundAlert;
};

if (_underFire) exitWith {
    [_group, _enemy, _suppressed] call AILOS_fnc_soundAlert;
};

// forget timer

private _lastSeenTime = _group getVariable VAR_LASTSEEN_TIME;
if (isNil "_lastSeenTime") then {
    _lastSeenTime = time;
    _group setVariable [VAR_LASTSEEN_TIME, time];
};

private _forgetRoll = _group getVariable VAR_FORGET_ROLL;
if (isNil "_forgetRoll") then {
    private _forgetRandom = missionNamespace getVariable ["AILOS_Setting_ForgetRandom", 10];
    _forgetRoll = random _forgetRandom;
    _group setVariable [VAR_FORGET_ROLL, _forgetRoll];
};

private _forgetBase = missionNamespace getVariable ["AILOS_Setting_ForgetBase", 15];
private _skill = [_group] call AILOS_fnc_skill;
private _forgetTime = (_forgetBase + _forgetRoll) * _skill;

private _distance = _leader distance _enemy;
private _distMult = linearConversion [200, 1000, _distance, 1.0, 0.4, true];
_forgetTime = _forgetTime * _distMult;

private _elapsed = time - _lastSeenTime;

//forget
if (_elapsed > _forgetTime) then {
    { _x forgetTarget _enemy; _x disableAI "AUTOTARGET" } forEach _aliveUnits;

    private _cooldown = missionNamespace getVariable ["AILOS_Setting_ForgetCooldown", 15];
    _group setVariable [VAR_FORGET_COOLDOWN, time + _cooldown];
    _group setVariable [VAR_FORGET_ROLL, nil];
};

private _cooldownEnd = _group getVariable [VAR_FORGET_COOLDOWN, 0];
if (time < _cooldownEnd) then {
    { _x forgetTarget _enemy } forEach _aliveUnits;
};
