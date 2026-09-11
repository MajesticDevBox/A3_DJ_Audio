// Shared V0.2 layout for standalone and AE3 native-window hosts.
params ["_group", "_id"];
if (isNull _group || {!hasInterface}) exitWith {};
[_group] call EDJ_fnc_unmount;
_group setVariable ["EDJ_stageId", _id];
private _display = ctrlParent _group;
private _controls = [];
private _named = createHashMap;
private _make = {
    params ["_type", "_name", "_position", ["_text", ""]];
    private _ctrl = _display ctrlCreate [_type, -1, _group];
    _ctrl ctrlSetPosition _position; _ctrl ctrlSetText _text; _ctrl ctrlCommit 0;
    _controls pushBack _ctrl; if (_name != "") then {_named set [_name, _ctrl];};
    _ctrl
};
private _button = {
    params ["_name", "_position", "_text", "_action", ["_payload", ""]];
    private _ctrl = ["RscButton", _name, _position, _text] call _make;
    _ctrl setVariable ["EDJ_group", _group]; _ctrl setVariable ["EDJ_action", [_action, _payload]];
    _ctrl ctrlAddEventHandler ["ButtonClick", {(_this select 0) call EDJ_fnc_control;}];
    _ctrl
};

private _header = ["RscText", "header", [0.01, 0.005, 0.46, 0.035], "EVENT DJ  /  MAIN STAGE"] call _make;
_header ctrlSetTextColor [0.2, 0.85, 0.85, 1];
["claim", [0.48, 0.005, 0.105, 0.035], "CLAIM", "claim"] call _button;
["release", [0.59, 0.005, 0.105, 0.035], "RELEASE", "release"] call _button;

["RscStructuredText", "deckAInfo", [0.01, 0.05, 0.215, 0.115], ""] call _make;
["RscStructuredText", "masterInfo", [0.245, 0.05, 0.21, 0.115], ""] call _make;
["RscStructuredText", "deckBInfo", [0.475, 0.05, 0.215, 0.115], ""] call _make;
{
    _x params ["_deck", "_xPos"];
    ["play" + _deck, [_xPos, 0.17, 0.048, 0.032], "PLAY", "deckPlay", _deck] call _button;
    ["pause" + _deck, [_xPos + 0.052, 0.17, 0.052, 0.032], "PAUSE", "deckPause", _deck] call _button;
    ["stop" + _deck, [_xPos + 0.108, 0.17, 0.048, 0.032], "STOP", "deckStop", _deck] call _button;
    ["cue" + _deck, [_xPos + 0.16, 0.17, 0.048, 0.032], "CUE", "cue", _deck] call _button;
    private _seek = ["RscXSliderH", "seek" + _deck, [_xPos, 0.205, 0.208, 0.026], ""] call _make;
    _seek sliderSetRange [0, 1]; _seek setVariable ["EDJ_group", _group]; _seek setVariable ["EDJ_deck", _deck];
    _seek ctrlAddEventHandler ["SliderPosChanged", {params ["_ctrl", "_value"]; (_ctrl getVariable "EDJ_group") setVariable ["EDJ_pendingSeek", [_ctrl getVariable "EDJ_deck", _value, diag_tickTime]];}];
} forEach [["A", 0.01], ["B", 0.475]];
["activateA", [0.255, 0.17, 0.09, 0.032], "OUTPUT A", "activeDeck", "A"] call _button;
["activateB", [0.355, 0.17, 0.09, 0.032], "OUTPUT B", "activeDeck", "B"] call _button;
private _volume = ["RscXSliderH", "volume", [0.255, 0.205, 0.19, 0.026], ""] call _make;
_volume sliderSetRange [0, 1]; _volume sliderSetSpeed [0.05, 0.1]; _volume setVariable ["EDJ_group", _group];
_volume ctrlAddEventHandler ["SliderPosChanged", {params ["_ctrl", "_value"]; (_ctrl getVariable "EDJ_group") setVariable ["EDJ_pendingVolume", [_value, diag_tickTime]];}];

["RscText", "", [0.01, 0.238, 0.16, 0.03], "LIBRARY"] call _make;
private _search = ["RscEdit", "search", [0.15, 0.238, 0.30, 0.03], ""] call _make;
_search setVariable ["EDJ_group", _group];
_search ctrlAddEventHandler ["KeyUp", {private _group = (_this select 0) getVariable "EDJ_group"; _group setVariable ["EDJ_libraryQuery", ctrlText (_this select 0)]; _group setVariable ["EDJ_librarySignature", ""];}];
private _filter = ["RscCombo", "filter", [0.46, 0.238, 0.15, 0.03], ""] call _make;
{_filter lbAdd _x;} forEach ["ALL SOURCES", "LOCAL", "STREAMS"]; _filter lbSetCurSel 0; _filter setVariable ["EDJ_group", _group];
_filter ctrlAddEventHandler ["LBSelChanged", {private _group = (_this select 0) getVariable "EDJ_group"; _group setVariable ["EDJ_libraryFilter", ["all", "addon", "stream"] select (_this select 1)]; _group setVariable ["EDJ_librarySignature", ""];}];
private _library = ["RscListbox", "library", [0.01, 0.273, 0.52, 0.14], ""] call _make;
_library setVariable ["EDJ_group", _group]; _library ctrlAddEventHandler ["LBSelChanged", {private _group = (_this select 0) getVariable "EDJ_group"; _group setVariable ["EDJ_selectedTrack", (_this select 0) lbData (_this select 1)];}];
["loadA", [0.54, 0.273, 0.075, 0.04], "LOAD A", "loadSelected", "A"] call _button;
["loadB", [0.62, 0.273, 0.075, 0.04], "LOAD B", "loadSelected", "B"] call _button;
["addQueue", [0.54, 0.318, 0.155, 0.04], "ADD TO QUEUE", "queueAdd"] call _button;

["RscText", "", [0.01, 0.42, 0.16, 0.03], "QUEUE"] call _make;
private _queue = ["RscListbox", "queue", [0.01, 0.452, 0.46, 0.125], ""] call _make;
_queue setVariable ["EDJ_group", _group]; _queue ctrlAddEventHandler ["LBSelChanged", {(_this select 0) setVariable ["EDJ_selectedIndex", _this select 1];}];
["queueRemove", [0.48, 0.452, 0.065, 0.035], "REMOVE", "queueRemove"] call _button;
["queueUp", [0.55, 0.452, 0.045, 0.035], "UP", "queueMove", -1] call _button;
["queueDown", [0.60, 0.452, 0.055, 0.035], "DOWN", "queueMove", 1] call _button;
["queueClear", [0.66, 0.452, 0.035, 0.035], "X", "queueClear"] call _button;
["nextA", [0.48, 0.495, 0.10, 0.035], "NEXT -> A", "queueLoadNext", "A"] call _button;
["nextB", [0.59, 0.495, 0.105, 0.035], "NEXT -> B", "queueLoadNext", "B"] call _button;
["RscStructuredText", "message", [0.48, 0.535, 0.215, 0.042], ""] call _make;

_group setVariable ["EDJ_namedControls", _named]; _group setVariable ["EDJ_controls", _controls];
_group setVariable ["EDJ_libraryQuery", ""]; _group setVariable ["EDJ_libraryFilter", "all"]; _group setVariable ["EDJ_librarySignature", ""];
private _pfh = [{
    params ["_args", "_handle"]; _args params ["_group", "_id"];
    if (isNull _group) exitWith {[_handle] call CBA_fnc_removePerFrameHandler;};
    [_group, _id] call EDJ_fnc_render;
}, 0.25, [_group, _id]] call CBA_fnc_addPerFrameHandler;
_group setVariable ["EDJ_pfh", _pfh];
["DEBUG", "UI mounted", [_id, ctrlIDC _group, _pfh, count _controls]] call EDJ_fnc_log;
private _scaleX = ((ctrlPosition _group) select 2) / 0.72; private _scaleY = ((ctrlPosition _group) select 3) / 0.60;
{(ctrlPosition _x) params ["_left", "_top", "_width", "_height"]; _x ctrlSetPosition [_left * _scaleX, _top * _scaleY, _width * _scaleX, _height * _scaleY]; _x ctrlCommit 0;} forEach _controls;
