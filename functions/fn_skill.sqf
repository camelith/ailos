params ["_group"];

private _leader = leader _group;
if !(alive _leader) exitWith { 1 };

private _skill = 1
    + (_leader skill "general")
    + (_leader skill "commanding")
    - (_leader skill "courage");

_skill max 1
