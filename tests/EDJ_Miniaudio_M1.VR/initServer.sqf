if (!isServer) exitWith {};
EDJ_debug = true;
edjLaptop = createVehicle ["Land_Laptop_03_black_F_AE3", [4000,4002,0], [], 0, "CAN_COLLIDE"];
edjPA = createVehicle ["Land_Loudspeakers_F", [4000,4003,0], [], 0, "CAN_COLLIDE"];
[] spawn {
    // Let AE3's object event handlers initialize before ensuring the device.
    sleep 2;
    private _logicGroup = createGroup sideLogic;
    private _module = _logicGroup createUnit ["Logic", [4000,4002,0], [], 0, "NONE"];
    _module synchronizeObjectsAdd [edjLaptop];
    [_module, [], true] call EDJ_fnc_moduleWorkstation;
    private _ok = ["main", edjLaptop, edjPA, "edj_miniaudio_acceptance", "miniaudio", [], [1, 2, 100, 360]] call EDJ_fnc_registerStage;
    diag_log format ["[EDJ M1] registration=%1", _ok];
};
