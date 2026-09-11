params [["_position", 0, [0]], ["_duration", -1, [0]]];
if (!finite _position || {_duration <= 0}) exitWith {0};
(_position max 0) min _duration
