//batch initialization system adapted from TCL_KnowsAbout.sqf
if !(missionNamespace getVariable ["AILOS_Setting_Enabled", true]) exitWith {};

if (isNil "AILOS_BatchIndex") then { AILOS_BatchIndex = 0 };

private _groups = allGroups select {
    count units _x > 0 &&
    {alive leader _x} &&
    {local leader _x} &&
    {!(side _x in [civilian, sideLogic, sideEmpty])}
};

private _total = count _groups;
if (_total == 0) exitWith {};

private _batchSize = missionNamespace getVariable ["AILOS_Setting_BatchSize", 25];

if (_batchSize <= 0 || _batchSize >= _total) then {
    { [_x] call AILOS_fnc_processGroup } forEach _groups;
} else {
    if (AILOS_BatchIndex >= _total) then { AILOS_BatchIndex = 0 };
    private _end = (AILOS_BatchIndex + _batchSize) min _total;
    for "_i" from AILOS_BatchIndex to (_end - 1) do {
        [_groups select _i] call AILOS_fnc_processGroup;
    };
    AILOS_BatchIndex = _end;
    if (AILOS_BatchIndex >= _total) then { AILOS_BatchIndex = 0 };
};
