params ["_group", "_enemy"];

if !(alive _enemy) exitWith { false };

private _leader = leader _group;
if !(alive _leader) exitWith { false };

private _posEnemy = getPos _enemy;
_posEnemy set [2, (_posEnemy select 2) + 1.5];
private _posLeader = getPos _leader;
_posLeader set [2, (_posLeader select 2) + 1.5];

private _canSee = false;

// Terrain and object LOS check
if !(terrainIntersectASL [AGLToASL _posLeader, AGLToASL _posEnemy]) then {
    private _intersects = lineIntersectsSurfaces [AGLToASL _posLeader, AGLToASL _posEnemy, _leader, _enemy, true, 1];
    if (_intersects isEqualTo []) then { _canSee = true };
};

// If leader can't see, check one random alive unit
if (!_canSee) then {
    private _others = (units _group) select { alive _x && {_x != _leader} };
    if (count _others > 0) then {
        private _unit = selectRandom _others;
        private _posUnit = getPos _unit;
        _posUnit set [2, (_posUnit select 2) + 1.5];

        if !(terrainIntersectASL [AGLToASL _posUnit, AGLToASL _posEnemy]) then {
            private _intersects = lineIntersectsSurfaces [AGLToASL _posUnit, AGLToASL _posEnemy, _unit, _enemy, true, 1];
            if (_intersects isEqualTo []) then { _canSee = true };
        };
    };
};

//smoke check for AI pos and intervals to target
if (_canSee && {missionNamespace getVariable ["AILOS_Setting_SmokeEnabled", true]}) then {
    private _smokeRadius = missionNamespace getVariable ["AILOS_Setting_SmokeRadius", 15];
    private _smokeTypes = ["SmokeShell", "SmokeLauncherAmmo"];

    private _smokeAtAI = nearestObjects [_posLeader, _smokeTypes, _smokeRadius];
    if (count _smokeAtAI > 0) exitWith { _canSee = false };

    private _midpoint = [
        ((_posLeader select 0) + (_posEnemy select 0)) / 2,
        ((_posLeader select 1) + (_posEnemy select 1)) / 2,
        ((_posLeader select 2) + (_posEnemy select 2)) / 2
    ];
    private _smokeOnLine = nearestObjects [_midpoint, _smokeTypes, _smokeRadius];
    if (count _smokeOnLine > 0) then { _canSee = false };
};

_canSee
