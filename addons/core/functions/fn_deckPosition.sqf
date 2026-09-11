params ["_deck"];
private _map = if (_deck isEqualType createHashMap) then {_deck} else {createHashMapFromArray _deck};
private _position = _map getOrDefault ["startOffset", 0];
if (_map getOrDefault ["playbackState", "EMPTY"] == "PLAYING") then {
    _position = _position + (serverTime - (_map getOrDefault ["startServerTime", serverTime]));
};
private _duration = _map getOrDefault ["duration", -1];
if (_duration > 0) then {_position = (_position max 0) min _duration;};
_position max 0
