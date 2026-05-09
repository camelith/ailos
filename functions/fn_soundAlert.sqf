params ["_group", "_enemy", "_suppressed"];

if !(missionNamespace getVariable ["AILOS_Setting_SoundEnabled", true]) exitWith {};

private _lastAlert = _group getVariable ["AILOS_LastSoundAlert", 0];
if (time - _lastAlert < 10) exitWith {};

_group setVariable ["AILOS_LastSoundAlert", time];

private _normal = missionNamespace getVariable ["AILOS_Setting_SoundRadius", 800];
private _suppressedR = missionNamespace getVariable ["AILOS_Setting_SoundRadiusSuppressed", 150];
private _radius = if (_suppressed) then { _suppressedR } else { _normal };

private _leader = leader _group;

//forget cooldown and filter out empty groups and civilians
{
    if (
        side _x getFriend side _group >= 0.6 &&
        {_x != _group} &&
        {alive leader _x} &&
        {(_x knowsAbout _enemy) < 1} &&
        {(_x getVariable ["AILOS_ForgetCooldown", 0]) < time} &&
        {(leader _x distance _leader) < _radius}
    ) then {
        _x reveal [_enemy, 1.5];
    };
} forEach (allGroups select { count units _x > 0 && {side _x != civilian} });
