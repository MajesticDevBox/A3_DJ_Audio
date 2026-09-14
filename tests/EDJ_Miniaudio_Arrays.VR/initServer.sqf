if (!isServer) exitWith {};
EDJ_debug = true;
edjLaptop = createVehicle ["Land_Laptop_03_black_F_AE3", [4000,4002,0], [], 0, "CAN_COLLIDE"];
edjPA = createVehicle ["Land_Loudspeakers_F", [4500,4500,0], [], 0, "CAN_COLLIDE"];
[] spawn {
    sleep 2;
    private _g = createGroup sideLogic;
    private _workstation = _g createUnit ["EDJ_Module_AddEventDJWorkstation", [4000,4002,0], [], 0, "NONE"];
    _workstation synchronizeObjectsAdd [edjLaptop];
    [_workstation, [], true] call EDJ_fnc_moduleWorkstation;
    edjArray = _g createUnit ["EDJ_Module_SpeakerArray", [4000,4010,0], [], 0, "NONE"];
    edjArray setDir 180;
    edjCabinets = [];
    {
        edjCabinets pushBack createVehicle ["Land_Loudspeakers_F", [4000 + _x,4010,0], [], 0, "CAN_COLLIDE"];
    } forEach [-3,-1,1,3];
    edjArray synchronizeObjectsAdd edjCabinets;
    edjMainPA = _g createUnit ["EDJ_Module_PA", [4000,4005,0], [], 0, "NONE"];
    edjMainPA setVariable ["Source", "edj_miniaudio_acceptance"];
    edjMainPA setVariable ["Range", 100]; edjMainPA setVariable ["Cone", 90];
    edjMainPA synchronizeObjectsAdd [_workstation, edjArray, edjPA];
    [edjMainPA, [], true] call EDJ_fnc_moduleAudio;
};
