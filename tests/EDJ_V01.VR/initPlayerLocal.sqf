EDJ_debug = true;
// Test convenience: opens the standalone view; use AE3 desktop separately.
[{!isNil "EDJ_clientStages" && {"main" in EDJ_clientStages}}, {
    ["main"] call EDJ_fnc_open;
    diag_log format ["[EDJ TEST] received stage revision=%1 JIP=%2", (EDJ_clientStages get "main") get "revision", didJIP];
}, [], 30, {diag_log "[EDJ TEST] FAIL: no stage snapshot within 30s";}] call CBA_fnc_waitUntilAndExecute;
