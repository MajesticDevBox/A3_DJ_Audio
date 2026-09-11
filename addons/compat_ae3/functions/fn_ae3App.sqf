// Documented native desktop entry contract.
params ["_winId", "_ctrlGroup", "_computer", "_args"];
if (hasInterface && {!isNull _computer}) then {
    _ctrlGroup ctrlSetPosition [safeZoneX, safeZoneY, safeZoneW, safeZoneH];
    _ctrlGroup ctrlCommit 0;
    // Keep AE3's titlebar and close button outside the application content.
    private _body = (ctrlParent _ctrlGroup) ctrlCreate ["RscControlsGroupNoScrollbars", -1, _ctrlGroup];
    _body ctrlSetPosition [0.02, 0.05, safeZoneW - 0.04, safeZoneH - 0.07];
    _body ctrlCommit 0;
    [_body, _computer getVariable ["EDJ_stageId", ""]] call EDJ_fnc_mount;
    uiNamespace setVariable ["EDJ_ae3_" + str _winId, _body];
};
createHashMapFromArray [["onClose", {
    params ["_winId"];
    private _key = "EDJ_ae3_" + str _winId;
    [uiNamespace getVariable [_key, controlNull]] call EDJ_fnc_unmount;
    uiNamespace setVariable [_key, nil];
}]]
