// Eden calls locally; Zeus requests are accepted only from the module's curator owner.
if (!isServer) exitWith {};
if !(_this isEqualType [] && {count _this == 6}) exitWith {};
params ["_module", "_target", "_source", "_volume", "_gain", "_range"];
if !(_module isEqualType objNull && {_target isEqualType objNull} && {_source isEqualType ""}) exitWith {};
if (isNull _module || {isNull _target} || {!(_module isKindOf "EDJ_Module_Radio")} || {_target isKindOf "Logic"}) exitWith {};
if (([_volume, _gain, _range] findIf {!(_x isEqualType 0) || {!finite _x}}) >= 0) exitWith {};
if (isRemoteExecuted && {remoteExecutedOwner != owner _module || {(allCurators findIf {owner (getAssignedCuratorUnit _x) == remoteExecutedOwner}) < 0} || {_target distance _module > 20}}) exitWith {};
if (_module getVariable ["EDJ_configured", false]) exitWith {};
private _entry = [_source] call EDJ_fnc_libraryGetTrack;
if (count _entry == 0) exitWith {};
_module setVariable ["EDJ_configured", true, true];
// Leave remote execution context before invoking the local-only registration API.
[{
    params ["_module", "_target", "_source", "_volume", "_gain", "_range"];
    if (isNull _module || {isNull _target}) exitWith {};
    private _serial = missionNamespace getVariable ["EDJ_radioSerial", 0];
    private _id = "radio_" + str _serial;
    while {_id in EDJ_stages} do {_serial = _serial + 1; _id = "radio_" + str _serial;};
    missionNamespace setVariable ["EDJ_radioSerial", _serial + 1];
    private _entry = [_source] call EDJ_fnc_libraryGetTrack;
    if !([_id, _target, _target, _source, _entry get "backend", [], [_volume, _gain, _range, 360]] call EDJ_fnc_registerStage) exitWith {
        _module setVariable ["EDJ_configured", false, true];
        ["WARN", "Radio registration rejected; target already in use", [_id]] call EDJ_fnc_log;
    };
    private _stage = EDJ_stages get _id;
    private _decks = +(_stage get "decks");
    private _deck = createHashMapFromArray (_decks select 0);
    _deck set ["playbackState", "PLAYING"]; _deck set ["startServerTime", serverTime]; _deck set ["generation", 1];
    private _pairs = []; {_pairs pushBack [_x, _y];} forEach _deck; _decks set [0, _pairs];
    [_id, [["radioModule", _module], ["decks", _decks], ["playback", "playing"], ["startServerTime", serverTime], ["playGeneration", 1]], "radio_started"] call EDJ_fnc_commitStage;
}, _this] call CBA_fnc_execNextFrame;
