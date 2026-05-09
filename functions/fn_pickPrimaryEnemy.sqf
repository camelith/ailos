params ["_group"];

private _bestEnemy = objNull;
private _bestKa = 0;

// simple target picker to replace TCL's weighted threat assessment
private _contacts = (leader _group) nearTargets 2000;

{
    _x params ["", "", "_targetSide", "_ka", "_target"];

    if (
        !isNull _target &&
        {alive _target} &&
        {_targetSide getFriend (side _group) < 0.6} &&
        {_ka > _bestKa}
    ) then {
        _bestKa = _ka;
        _bestEnemy = _target;
    };
} forEach _contacts;

_bestEnemy
