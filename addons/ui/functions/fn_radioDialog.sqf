params ["_module"];
if (!hasInterface || {!isRemoteExecuted} || {remoteExecutedOwner != 2} || {isNull _module}) exitWith {};
private _parent = findDisplay 312;
if (isNull _parent) exitWith {};
private _display = _parent createDisplay "RscDisplayEmpty";
_display setVariable ["EDJ_module", _module];
private _make = {
    params ["_class", "_idc", "_pos", "_text"];
    private _ctrl = _display ctrlCreate [_class, _idc];
    _ctrl ctrlSetPosition _pos; _ctrl ctrlSetText _text; _ctrl ctrlCommit 0; _ctrl
};
private _bg = ["RscText", -1, [0.15,0.18,0.7,0.60], ""] call _make;
_bg ctrlSetBackgroundColor [0.025,0.035,0.05,1];
["RscText", -1, [0.17,0.20,0.66,0.05], "EVENT DJ RADIO - select prop and audio"] call _make;
private _targets = (nearestObjects [_module, ["All"], 20]) select {!(_x isKindOf "Logic") && {!(_x isKindOf "Man")} && {_x != _module}};
_display setVariable ["EDJ_targets", _targets];
private _target = ["RscCombo", 8801, [0.17,0.28,0.66,0.05], ""] call _make;
{_target lbAdd format ["%1 (%2 m)", getText (configOf _x >> "displayName"), round (_x distance _module)];} forEach _targets;
_target lbSetCurSel 0;
private _sources = ["RscCombo", 8802, [0.17,0.36,0.66,0.05], ""] call _make;
{
    private _index = _sources lbAdd format ["%1 [%2]", _x get "title", _x get "backend"];
    _sources lbSetData [_index, _x get "id"];
} forEach ([] call EDJ_fnc_libraryGetAll);
_sources lbSetCurSel 0;
["RscText", -1, [0.17,0.44,0.66,0.04], "Volume 0-1     |     Gain 0-10     |     Native range (m)"] call _make;
["RscEdit", 8803, [0.17,0.49,0.20,0.05], "1"] call _make;
["RscEdit", 8804, [0.40,0.49,0.20,0.05], "1"] call _make;
["RscEdit", 8805, [0.63,0.49,0.20,0.05], "50"] call _make;
["RscText", -1, [0.17,0.56,0.66,0.05], "Streams use Carpinchos range. Music tracks play once."] call _make;
private _play = ["RscButton", -1, [0.17,0.65,0.31,0.06], "START RADIO"] call _make;
_play ctrlEnable (_targets isNotEqualTo [] && {lbSize _sources > 0});
_play ctrlAddEventHandler ["ButtonClick", {
    private _display = ctrlParent (_this select 0);
    private _targets = _display getVariable "EDJ_targets";
    private _index = lbCurSel (_display displayCtrl 8801);
    private _source = _display displayCtrl 8802;
    if (_index < 0 || {lbCurSel _source < 0}) exitWith {};
    [_display getVariable "EDJ_module", _targets select _index, _source lbData lbCurSel _source,
        parseNumber ctrlText (_display displayCtrl 8803), parseNumber ctrlText (_display displayCtrl 8804),
        parseNumber ctrlText (_display displayCtrl 8805)] remoteExecCall ["EDJ_fnc_configureRadio", 2];
    _display closeDisplay 1;
}];
private _cancel = ["RscButton", -1, [0.52,0.65,0.31,0.06], "CANCEL"] call _make;
_cancel ctrlAddEventHandler ["ButtonClick", {(ctrlParent (_this select 0)) closeDisplay 2;}];
