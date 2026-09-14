// Identity comes from transport ownership. Client payloads carry registered IDs only.
if (!isServer || {!isRemoteExecuted && {isMultiplayer || {!hasInterface}}}) exitWith {};
private _sender = if (isRemoteExecuted) then {remoteExecutedOwner} else {clientOwner};
if !(_this isEqualType [] && {count _this == 3} && {(_this select 0) isEqualType ""} && {(_this select 1) isEqualType ""}) exitWith {
    [_sender, "", "malformed_payload"] call EDJ_fnc_deny;
};
params ["_id", "_operation", "_value"];
private _operations = ["claim", "release", "play", "stop", "volume", "deckLoad", "deckPlay", "deckPause", "deckResume", "deckStop", "deckSeek", "queueAdd", "queueRemove", "queueMove", "queueClear", "queueLoadNext", "activeDeck"];
if (count _id > 48 || {!(_operation in _operations)}) exitWith {[_sender, _id, "invalid_operation"] call EDJ_fnc_deny;};
private _unit = objNull;
if (!isMultiplayer) then {_unit = player;} else {
    {if (owner _x == _sender && {isPlayer _x}) exitWith {_unit = _x};} forEach allPlayers;
};
if (isNull _unit || {!alive _unit}) exitWith {[_sender, _id, "no_live_player"] call EDJ_fnc_deny;};
private _key = str _sender;
if (diag_tickTime - (EDJ_rate getOrDefault [_key, -10]) < 0.2) exitWith {};
EDJ_rate set [_key, diag_tickTime];
["DEBUG", "Request received", [_sender, _id, _operation]] call EDJ_fnc_log;
private _stage = EDJ_stages getOrDefault [_id, createHashMap];
if (count _stage == 0) exitWith {};
private _uid = getPlayerUID _unit;
private _allowed = _stage get "allowedUIDs";
private _workstation = _stage get "workstation";
private _authorized = !isNull _workstation && {alive _workstation} && {_unit distance _workstation <= 5} && {count _allowed == 0 || {_uid in _allowed}};
if (!_authorized) exitWith {[_sender, _id, "range_uid_or_workstation"] call EDJ_fnc_deny;};
private _operator = _stage get "operator";
if (_operation == "claim") exitWith {
    if (isNull _operator || {!alive _operator} || {!isPlayer _operator} || {_operator == _unit}) then {
        [_id, [["operator", _unit], ["operatorUID", _uid]], "claimed"] call EDJ_fnc_commitStage;
    } else {[_sender, _id, "station_busy"] call EDJ_fnc_deny;};
};
if (_operator != _unit || {_stage get "operatorUID" != _uid}) exitWith {[_sender, _id, "not_operator"] call EDJ_fnc_deny;};
if (_operation == "release") exitWith {[_id, [["operator", objNull], ["operatorUID", ""]], "release"] call EDJ_fnc_commitStage;};

private _decks = +(_stage get "decks");
private _active = _stage get "activeDeck";
private _queue = +(_stage get "queue");
private _changes = [];
private _serialize = {params ["_map"]; private _pairs = []; {_pairs pushBack [_x, _y];} forEach _map; _pairs};
private _deckIndex = {params ["_deckId"]; ["A", "B"] find _deckId};
private _providerCapabilities = {params ["_backend"]; getArray (configFile >> "CfgEDJAudioProviders" >> _backend >> "capabilities")};
private _mirrorOutput = {
    params ["_deckRecords", "_activeId"];
    private _deck = createHashMapFromArray (_deckRecords select (["A", "B"] find _activeId));
    private _state = _deck get "playbackState";
    private _playback = switch (_state) do {case "PLAYING"; case "STARTING": {"playing"}; case "PAUSED": {"paused"}; default {"stopped"};};
    private _now = if (_deck get "loadedTrackId" == "") then {[]} else {[
        ["title", _deck get "title"], ["artist", _deck get "artist"], ["deck", _activeId],
        ["sourceType", _deck get "sourceType"], ["backend", _deck get "backend"],
        ["playbackState", _state], ["duration", _deck get "duration"]
    ]};
    [["audioBackend", _deck get "backend"], ["audioSource", _deck get "loadedTrackId"], ["playback", _playback], ["startServerTime", _deck get "startServerTime"], ["startOffset", _deck get "startOffset"], ["playGeneration", _deck get "generation"], ["nowPlaying", _now]]
};
private _deny = {params ["_reason"]; [_sender, _id, _reason] call EDJ_fnc_deny;};

if (_operation == "volume") exitWith {
    if !(_value isEqualType 0 && {finite _value}) exitWith {["invalid_volume"] call _deny;};
    if !("volume" in ([_stage get "audioBackend"] call _providerCapabilities)) exitWith {["unsupported_volume"] call _deny;};
    [_id, [["masterVolume", (_value max 0) min 1]], "volume"] call EDJ_fnc_commitStage;
};
if (_operation == "play") then {_operation = "deckPlay"; _value = _active;};
if (_operation == "stop") then {_operation = "deckStop"; _value = _active;};

switch (_operation) do {
    case "deckLoad": {
        if !(_value isEqualType [] && {count _value == 2} && {(_value select 0) isEqualType ""} && {(_value select 1) isEqualType ""}) exitWith {["malformed_deck_load"] call _deny;};
        _value params ["_deckId", "_trackId"];
        private _index = [_deckId] call _deckIndex;
        private _entry = [_trackId] call EDJ_fnc_libraryGetTrack;
        if (_index < 0 || {count _entry == 0}) exitWith {["unknown_deck_or_track"] call _deny;};
        if !(isClass (configFile >> "CfgEDJAudioProviders" >> (_entry get "backend"))) exitWith {["unsupported_backend"] call _deny;};
        _decks set [_index, [_deckId, _entry] call EDJ_fnc_deckCreate];
        _changes = [["decks", _decks]];
        if (_active == _deckId) then {_changes append ([_decks, _active] call _mirrorOutput);};
    };
    case "deckPlay": {
        if !(_value isEqualType "") exitWith {["malformed_deck"] call _deny;};
        private _index = [_value] call _deckIndex;
        if (_index < 0) exitWith {["unknown_deck"] call _deny;};
        private _deck = createHashMapFromArray (_decks select _index);
        if (_deck get "loadedTrackId" == "") exitWith {["empty_deck"] call _deny;};
        if !("play" in ([_deck get "backend"] call _providerCapabilities)) exitWith {["unsupported_play"] call _deny;};
        if !(_stage get "powerState" && {[_stage] call EDJ_fnc_hasEmitter} && {serverTime - (_stage get "lastPlay") >= 2}) exitWith {["play_state_or_cooldown"] call _deny;};
        private _otherIndex = 1 - _index;
        private _other = createHashMapFromArray (_decks select _otherIndex);
        if (_other get "playbackState" in ["PLAYING", "STARTING", "PAUSED"]) then {_other set ["playbackState", "STOPPED"]; _other set ["startOffset", 0]; _decks set [_otherIndex, [_other] call _serialize];};
        _deck set ["playbackState", "PLAYING"]; _deck set ["startOffset", 0]; _deck set ["startServerTime", serverTime]; _deck set ["error", ""]; _deck set ["generation", (_deck get "generation") + 1];
        _decks set [_index, [_deck] call _serialize]; _active = _value;
        _changes = [["decks", _decks], ["activeDeck", _active], ["lastPlay", serverTime]]; _changes append ([_decks, _active] call _mirrorOutput);
    };
    case "deckPause": {
        if !(_value isEqualType "") exitWith {["malformed_deck"] call _deny;};
        private _index = [_value] call _deckIndex;
        if (_index < 0 || {_active != _value}) exitWith {["inactive_or_unknown_deck"] call _deny;};
        private _deck = createHashMapFromArray (_decks select _index);
        if (_deck get "playbackState" != "PLAYING" || {!("pause" in ([_deck get "backend"] call _providerCapabilities))}) exitWith {["unsupported_pause_state"] call _deny;};
        _deck set ["startOffset", [_deck] call EDJ_fnc_deckPosition]; _deck set ["playbackState", "PAUSED"];
        _decks set [_index, [_deck] call _serialize]; _changes = [["decks", _decks]]; _changes append ([_decks, _active] call _mirrorOutput);
    };
    case "deckResume": {
        if !(_value isEqualType "") exitWith {["malformed_deck"] call _deny;};
        private _index = [_value] call _deckIndex;
        if (_index < 0 || {_active != _value}) exitWith {["inactive_or_unknown_deck"] call _deny;};
        private _deck = createHashMapFromArray (_decks select _index);
        if (_deck get "playbackState" != "PAUSED" || {!("resume" in ([_deck get "backend"] call _providerCapabilities))}) exitWith {["unsupported_resume_state"] call _deny;};
        _deck set ["playbackState", "PLAYING"]; _deck set ["startServerTime", serverTime]; _deck set ["generation", (_deck get "generation") + 1];
        _decks set [_index, [_deck] call _serialize]; _changes = [["decks", _decks]]; _changes append ([_decks, _active] call _mirrorOutput);
    };
    case "deckStop": {
        if !(_value isEqualType "") exitWith {["malformed_deck"] call _deny;};
        private _index = [_value] call _deckIndex;
        if (_index < 0) exitWith {["unknown_deck"] call _deny;};
        private _deck = createHashMapFromArray (_decks select _index);
        _deck set ["playbackState", "STOPPED"]; _deck set ["startOffset", 0]; _decks set [_index, [_deck] call _serialize]; _changes = [["decks", _decks]];
        if (_active == _value) then {_changes append ([_decks, _active] call _mirrorOutput);};
    };
    case "deckSeek": {
        if !(_value isEqualType [] && {count _value == 2} && {(_value select 0) isEqualType ""} && {(_value select 1) isEqualType 0} && {finite (_value select 1)}) exitWith {["malformed_seek"] call _deny;};
        _value params ["_deckId", "_position"];
        private _index = [_deckId] call _deckIndex;
        if (_index < 0) exitWith {["unknown_deck"] call _deny;};
        private _deck = createHashMapFromArray (_decks select _index);
        private _duration = _deck get "duration";
        if (_duration <= 0 || {!("seek" in ([_deck get "backend"] call _providerCapabilities))}) exitWith {["seek_unavailable"] call _deny;};
        _deck set ["startOffset", [_position, _duration] call EDJ_fnc_deckClampPosition];
        if (_deck get "playbackState" == "PLAYING") then {_deck set ["startServerTime", serverTime]; _deck set ["generation", (_deck get "generation") + 1];};
        _decks set [_index, [_deck] call _serialize]; _changes = [["decks", _decks]];
        if (_active == _deckId) then {_changes append ([_decks, _active] call _mirrorOutput);};
    };
    case "queueAdd": {
        if !(_value isEqualType "" && {_value in EDJ_libraryRegistry} && {count _queue < 100}) exitWith {["unknown_track_or_queue_full"] call _deny;};
        _queue pushBack _value; _changes = [["queue", _queue]];
    };
    case "queueRemove": {
        if !(_value isEqualType 0 && {finite _value} && {_value == floor _value} && {_value >= 0} && {_value < count _queue}) exitWith {["invalid_queue_index"] call _deny;};
        _queue deleteAt _value; _changes = [["queue", _queue]];
    };
    case "queueMove": {
        if !(_value isEqualType [] && {count _value == 2} && {(_value select 0) isEqualType 0} && {(_value select 1) in [-1, 1]}) exitWith {["invalid_queue_move"] call _deny;};
        _value params ["_from", "_delta"]; private _to = _from + _delta;
        if (_from < 0 || {_from >= count _queue} || {_to < 0} || {_to >= count _queue}) exitWith {["invalid_queue_move"] call _deny;};
        private _item = _queue deleteAt _from; _queue insert [_to, [_item]]; _changes = [["queue", _queue]];
    };
    case "queueClear": {_changes = [["queue", []]];};
    case "queueLoadNext": {
        if !(_value isEqualType "") exitWith {["malformed_deck"] call _deny;};
        private _index = [_value] call _deckIndex;
        if (_index < 0 || {_queue isEqualTo []}) exitWith {["empty_queue_or_unknown_deck"] call _deny;};
        private _trackId = _queue deleteAt 0; private _entry = [_trackId] call EDJ_fnc_libraryGetTrack;
        if (count _entry == 0) exitWith {["queued_track_missing"] call _deny;};
        _decks set [_index, [_value, _entry] call EDJ_fnc_deckCreate]; _changes = [["queue", _queue], ["decks", _decks]];
        if (_active == _value) then {_changes append ([_decks, _active] call _mirrorOutput);};
    };
    case "activeDeck": {
        if !(_value isEqualType "") exitWith {["malformed_deck"] call _deny;};
        private _index = [_value] call _deckIndex;
        if (_index < 0 || {_value == _active}) exitWith {["unknown_or_active_deck"] call _deny;};
        private _deck = createHashMapFromArray (_decks select _index);
        if (_deck get "loadedTrackId" == "") exitWith {["empty_deck"] call _deny;};
        if !(_stage get "powerState" && {[_stage] call EDJ_fnc_hasEmitter} && {serverTime - (_stage get "lastPlay") >= 2}) exitWith {["play_state_or_cooldown"] call _deny;};
        private _oldIndex = [_active] call _deckIndex; private _old = createHashMapFromArray (_decks select _oldIndex);
        _old set ["playbackState", "STOPPED"]; _old set ["startOffset", 0]; _decks set [_oldIndex, [_old] call _serialize];
        _deck set ["playbackState", "PLAYING"];
        if (_deck get "duration" > 0 && {_deck get "startOffset" >= _deck get "duration"}) then {_deck set ["startOffset", 0];};
        _deck set ["startServerTime", serverTime]; _deck set ["generation", (_deck get "generation") + 1]; _decks set [_index, [_deck] call _serialize]; _active = _value;
        _changes = [["decks", _decks], ["activeDeck", _active], ["lastPlay", serverTime]]; _changes append ([_decks, _active] call _mirrorOutput);
    };
};
if (_changes isNotEqualTo []) then {[_id, _changes, _operation] call EDJ_fnc_commitStage;};
