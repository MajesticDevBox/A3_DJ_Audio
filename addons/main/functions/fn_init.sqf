if (isServer && {!isNil "EDJ_fnc_maintain"}) then {
    [{call EDJ_fnc_maintain}, 2] call CBA_fnc_addPerFrameHandler;
};
if (hasInterface) then {
    // Sync after all dependency postInit handlers and player creation.
    [{!isNull player && {time > 0}}, {
        if (!isNil "EDJ_fnc_audioInit") then {call EDJ_fnc_audioInit;};
        if (!isNil "EDJ_fnc_sync") then {[] remoteExecCall ["EDJ_fnc_sync", 2];};
    }] call CBA_fnc_waitUntilAndExecute;
};
["INFO", "Initialized V0.2", [isServer, hasInterface, count EDJ_libraryRegistry]] call EDJ_fnc_log;
