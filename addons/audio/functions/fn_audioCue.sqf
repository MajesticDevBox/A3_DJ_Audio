// DJ-local finite-track preview. It never enters authoritative stage state.
params ["_stageId", ["_deckId", "", [""]], ["_operation", "toggle", [""]]];
if (!hasInterface) exitWith {[false, "no_interface"]};
private _existing = EDJ_cueInstances getOrDefault [_stageId, []];
if (_operation == "stop" || {_existing isNotEqualTo []}) exitWith {
    if (_existing isNotEqualTo []) then {
        if ((_existing select 0) isEqualType "") then {"edj_miniaudio" callExtension ["stop", [_existing select 0]];} else {stopSound (_existing select 0);};
    };
    EDJ_cueInstances deleteAt _stageId;
    [true, "stopped"]
};
private _stage = EDJ_clientStages getOrDefault [_stageId, createHashMap];
if (count _stage == 0 || {_stage get "operator" != player}) exitWith {[false, "not_operator"]};
private _index = ["A", "B"] find _deckId;
if (_index < 0) exitWith {[false, "unknown_deck"]};
private _deck = createHashMapFromArray ((_stage get "decks") select _index);
if (_deck get "sourceType" != "addon" || {!([_deck get "backend", "cue"] call EDJ_fnc_audioSupportsFeature)}) exitWith {[false, "cue_unavailable"]};
private _entry = [_deck get "loadedTrackId"] call EDJ_fnc_libraryGetTrack;
private _file = _entry getOrDefault ["source", ""];
if (_file == "") exitWith {[false, "track_missing"]};
if (_deck get "backend" == "miniaudio") exitWith {
    private _ready = ["miniaudio", "available", _stage] call EDJ_fnc_audioCall;
    if !(_ready select 0) exitWith {_ready};
    private _id = "cue:" + _stageId;
    private _result = "edj_miniaudio" callExtension ["play", [_id, _file, "0", str (_deck get "cuePoint"), "0", "0", "0", "1"]];
    if ((_result select 0) != "1") exitWith {[false, _result select 0]};
    "edj_miniaudio" callExtension ["cue_mode", [_id]];
    "edj_miniaudio" callExtension ["volume", [_id, "0.8"]];
    EDJ_cueInstances set [_stageId, [_id, _deckId, _deck get "loadedTrackId"]];
    [true, "playing"]
};
private _handle = playSoundUI [_file, 0.8, 1, false, _deck get "cuePoint"];
if (_handle < 0) exitWith {[false, "cue_start_failed"]};
EDJ_cueInstances set [_stageId, [_handle, _deckId, _deck get "loadedTrackId"]];
["DEBUG", "Local cue started", [_stageId, _deckId, _deck get "loadedTrackId"]] call EDJ_fnc_log;
[true, "playing"]
