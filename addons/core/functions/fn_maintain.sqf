if (!isServer) exitWith {};
private _removed = [];
{
    private _stage = _y;
    private _operator = _stage get "operator";
    private _changes = [];
    if ("radioModule" in _stage && {isNull (_stage get "radioModule")} && {_stage get "playback" == "playing"}) then {_changes pushBack ["playback", "stopped"];};
    if (_stage get "audioBackend" == "native" && {_stage get "playback" == "playing"}) then {
        private _decks = +(_stage get "decks");
        private _index = ["A", "B"] find (_stage get "activeDeck");
        private _deck = createHashMapFromArray (_decks select _index);
        private _duration = _deck get "duration";
        if (_duration > 0 && {[_deck] call EDJ_fnc_deckPosition >= _duration}) then {
            _deck set ["playbackState", "STOPPED"]; _deck set ["startOffset", 0];
            private _pairs = []; {_pairs pushBack [_x, _y];} forEach _deck; _decks set [_index, _pairs];
            _changes append [["decks", _decks], ["playback", "stopped"], ["startOffset", 0]];
            private _now = createHashMapFromArray (_stage getOrDefault ["nowPlaying", []]);
            if (count _now > 0) then {
                _now set ["playbackState", "STOPPED"];
                private _nowPairs = []; {_nowPairs pushBack [_x, _y];} forEach _now;
                _changes pushBack ["nowPlaying", _nowPairs];
            };
        };
    };
    if (_stage get "operatorUID" != "" && {isNull _operator || {!alive _operator} || {!isPlayer _operator} || {_operator distance (_stage get "workstation") > 5}}) then {
        _changes append [["operator", objNull], ["operatorUID", ""]];
    };
    if ((isNull (_stage get "emitter") || {!alive (_stage get "emitter")} || {isNull (_stage get "workstation")} || {!alive (_stage get "workstation")}) && {_stage get "playback" == "playing"}) then {
        _changes pushBack ["playback", "stopped"];
    };
    if (_changes isNotEqualTo []) then {[_stage get "stageId", _changes, "maintenance"] call EDJ_fnc_commitStage;};
    if ("radioModule" in _stage && {isNull (_stage get "radioModule")}) then {
        (_stage get "workstation") setVariable ["EDJ_stageId", nil, true];
        _removed pushBack (_stage get "stageId");
    };
} forEach EDJ_stages;
{EDJ_stages deleteAt _x;} forEach _removed;
