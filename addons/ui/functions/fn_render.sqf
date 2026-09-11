params ["_group", "_id"];
private _named = _group getVariable ["EDJ_namedControls", createHashMap];
private _stage = EDJ_clientStages getOrDefault [_id, createHashMap];
if (count _stage == 0) exitWith {
    (_named get "message") ctrlSetStructuredText parseText "No linked stage.";
    {(_named get _x) ctrlEnable false;} forEach keys _named;
};
private _operator = _stage get "operator"; private _mine = _operator == player;
private _decks = _stage get "decks"; private _active = _stage get "activeDeck";
private _instance = EDJ_audioInstances getOrDefault [_id, createHashMap];
private _localStatus = _instance getOrDefault ["status", "stopped"];
private _metadata = _instance getOrDefault ["metadata", ""];
private _formatTime = {params ["_seconds"]; if (_seconds < 0) exitWith {"--:--"}; format ["%1:%2", floor (_seconds / 60), [str (floor _seconds mod 60), "0" + str (floor _seconds mod 60)] select (floor _seconds mod 60 < 10)]};
{
    private _deckId = _x; private _index = ["A", "B"] find _deckId; private _deck = createHashMapFromArray (_decks select _index);
    private _loaded = _deck get "loadedTrackId" != ""; private _backend = _deck get "backend"; private _caps = if (_loaded) then {(EDJ_providers getOrDefault [_backend, [{}, []]]) select 1} else {[]};
    private _position = [_deck] call EDJ_fnc_deckPosition; private _duration = _deck get "duration";
    (_named get ("deck" + _deckId + "Info")) ctrlSetStructuredText composeText [
        format ["DECK %1%2", _deckId, ["", "  [OUTPUT]"] select (_active == _deckId)], lineBreak,
        [_deck get "title", "Empty"] select !_loaded, lineBreak,
        [_deck get "artist", "—"] select (!_loaded || {_deck get "artist" == ""}), lineBreak,
        format ["%1 / %2 / %3", [_deck get "sourceType", "—"] select !_loaded, [_backend, "—"] select !_loaded, _deck get "playbackState"], lineBreak,
        format ["%1 / %2", [_position] call _formatTime, [_duration] call _formatTime]
    ];
    private _state = _deck get "playbackState";
    (_named get ("play" + _deckId)) ctrlEnable (_mine && {_loaded} && {"play" in _caps} && {!(_state in ["PLAYING", "STARTING"])});
    private _pause = _named get ("pause" + _deckId);
    if (_state == "PAUSED") then {_pause ctrlSetText "RESUME"; _pause setVariable ["EDJ_action", ["deckResume", _deckId]]; _pause ctrlEnable (_mine && {"resume" in _caps});} else {_pause ctrlSetText "PAUSE"; _pause setVariable ["EDJ_action", ["deckPause", _deckId]]; _pause ctrlEnable (_mine && {_state == "PLAYING"} && {"pause" in _caps});};
    (_named get ("stop" + _deckId)) ctrlEnable (_mine && {_loaded} && {"stop" in _caps} && {_state != "STOPPED"});
    (_named get ("cue" + _deckId)) ctrlEnable (_mine && {_loaded} && {"cue" in _caps});
    private _seek = _named get ("seek" + _deckId); _seek ctrlEnable (_mine && {_duration > 0} && {"seek" in _caps});
    if (_duration > 0) then {_seek sliderSetRange [0, _duration]; if ((_group getVariable ["EDJ_pendingSeek", []]) isEqualTo []) then {_seek sliderSetPosition _position;};};
} forEach ["A", "B"];
(_named get "masterInfo") ctrlSetStructuredText composeText [
    "MASTER", lineBreak, format ["Operator: %1", if (isNull _operator) then {"Unclaimed"} else {name _operator}], lineBreak,
    format ["Output: Deck %1 / CUT", _active], lineBreak, format ["PA: %1 / %2", _stage get "playback", _localStatus], lineBreak,
    format ["Gain: %1%%", round ((_stage get "masterVolume") * 100)], if (_metadata == "") then {""} else {lineBreak}, _metadata
];
(_named get "claim") ctrlEnable (isNull _operator); (_named get "release") ctrlEnable _mine;
(_named get "activateA") ctrlEnable (_mine && {_active != "A"}); (_named get "activateB") ctrlEnable (_mine && {_active != "B"});
private _volume = _named get "volume"; _volume ctrlEnable (_mine && {[_stage get "audioBackend", "volume"] call EDJ_fnc_audioSupportsFeature});
private _pendingVolume = _group getVariable ["EDJ_pendingVolume", []];
if (_pendingVolume isNotEqualTo []) then {if (!_mine) then {_group setVariable ["EDJ_pendingVolume", []];} else {if (diag_tickTime - (_pendingVolume select 1) >= 0.3) then {[_id, "volume", _pendingVolume select 0] call EDJ_fnc_request; _group setVariable ["EDJ_pendingVolume", []];};};} else {_volume sliderSetPosition (_stage get "masterVolume");};
private _pendingSeek = _group getVariable ["EDJ_pendingSeek", []];
if (_pendingSeek isNotEqualTo [] && {diag_tickTime - (_pendingSeek select 2) >= 0.3}) then {if (_mine) then {[_id, "deckSeek", [_pendingSeek select 0, _pendingSeek select 1]] call EDJ_fnc_request;}; _group setVariable ["EDJ_pendingSeek", []];};

private _query = _group getVariable ["EDJ_libraryQuery", ""]; private _filter = _group getVariable ["EDJ_libraryFilter", "all"]; private _signature = _query + "|" + _filter;
if (_signature != _group getVariable ["EDJ_librarySignature", ""]) then {
    private _libraryCtrl = _named get "library"; lbClear _libraryCtrl;
    {private _durationText = [_x get "duration"] call _formatTime; private _bpm = _x get "bpm"; private _row = _libraryCtrl lbAdd format ["%1  |  %2  |  %3  |  %4  |  %5", _x get "title", [_x get "artist", "—"] select (_x get "artist" == ""), toUpper (_x get "sourceType"), [_bpm, "—"] select (_bpm < 0), _durationText]; _libraryCtrl lbSetData [_row, _x get "id"];} forEach ([_query, _filter] call EDJ_fnc_librarySearch);
    _group setVariable ["EDJ_librarySignature", _signature];
};
{(_named get _x) ctrlEnable _mine;} forEach ["loadA", "loadB", "addQueue", "queueRemove", "queueUp", "queueDown", "queueClear", "nextA", "nextB"];
private _queueCtrl = _named get "queue"; private _queueSignature = str [_stage get "revision", _stage get "queue"];
if (_queueSignature != _group getVariable ["EDJ_queueSignature", ""]) then {lbClear _queueCtrl; {private _entry = [_x] call EDJ_fnc_libraryGetTrack; private _row = _queueCtrl lbAdd format ["%1. %2 — %3", _forEachIndex + 1, _entry getOrDefault ["title", _x], _entry getOrDefault ["artist", ""]]; _queueCtrl lbSetData [_row, _x];} forEach (_stage get "queue"); _group setVariable ["EDJ_queueSignature", _queueSignature];};
if (diag_tickTime - (_group getVariable ["EDJ_clearArmed", -10]) > 3) then {(_named get "queueClear") ctrlSetText "X";};
private _warning = ["Registered library IDs only / server authoritative", "Required music pack is missing on this client."] select (_stage get "audioSource" != "" && {count ([_stage get "audioSource"] call EDJ_fnc_libraryGetTrack) == 0});
(_named get "message") ctrlSetStructuredText parseText _warning;
