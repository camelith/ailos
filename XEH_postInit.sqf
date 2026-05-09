diag_log "AILOS: XEH_postInit loaded";

if (is3DEN) exitWith {};

[{
    if (!isNil "AILOS_LoopHandle") exitWith {
        diag_log "AILOS: Loop already running";
    };

    private _interval = missionNamespace getVariable ["AILOS_Setting_TickInterval", 1.0];

    AILOS_LoopHandle = [_interval] spawn {
        params ["_interval"];
        scriptName "AILOS_mainLoop";

        AILOS_LoopRunning = true;
		
        while { AILOS_LoopRunning } do {
            try {
                call AILOS_fnc_mainLoop;
            } catch {
                diag_log format ["AILOS: Main loop error: %1", _exception];
            };

            sleep _interval;
        };

        diag_log "AILOS: Main loop exited";
    };

    diag_log format ["AILOS: Main loop started (interval=%1s, handle=%2)", _interval, AILOS_LoopHandle];
}, [], 3] call CBA_fnc_waitAndExecute;
