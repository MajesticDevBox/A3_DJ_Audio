// DJ-local finite-track preview. It never enters authoritative stage state.
params ["_stageId", ["_deckId", "", [""]], ["_operation", "toggle", [""]]];
if (!hasInterface) exitWith {[false, "no_interface"]};
private _existing = EDJ_cueInstances getOrDefault [_stageId, []];
if (_operation == "stop" || {_existing isNotEqualTo []}) exitWith {
    if (_existing isNotEqualTo []) then {stopSound (_existing select 0);};
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
private _handle = playSoundUI [_file, 0.8, 1, false, _deck get "cuePoint"];
if (_handle < 0) exitWith {[false, "cue_start_failed"]};
EDJ_cueInstances set [_stageId, [_handle, _deckId, _deck get "loadedTrackId"]];
["DEBUG", "Local cue started", [_stageId, _deckId, _deck get "loadedTrackId"]] call EDJ_fnc_log;
[true, "playing"]
