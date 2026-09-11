params [["_deckId", "A", [""]], ["_entry", createHashMap, [createHashMap]]];
private _loaded = count _entry > 0;
[
    ["deckId", _deckId], ["loadedTrackId", [_entry getOrDefault ["id", ""], ""] select !_loaded],
    ["backend", [_entry getOrDefault ["backend", ""], ""] select !_loaded],
    ["source", [_entry getOrDefault ["source", ""], ""] select !_loaded],
    ["title", [_entry getOrDefault ["title", ""], ""] select !_loaded],
    ["artist", [_entry getOrDefault ["artist", ""], ""] select !_loaded],
    ["album", [_entry getOrDefault ["album", ""], ""] select !_loaded],
    ["duration", [_entry getOrDefault ["duration", -1], -1] select !_loaded],
    ["bpm", [_entry getOrDefault ["bpm", -1], -1] select !_loaded],
    ["genre", [_entry getOrDefault ["genre", ""], ""] select !_loaded],
    ["sourceType", [_entry getOrDefault ["sourceType", ""], ""] select !_loaded],
    ["playbackState", ["LOADED", "EMPTY"] select !_loaded],
    ["startServerTime", 0], ["startOffset", 0], ["volume", 1],
    ["cuePoint", 0], ["generation", 0], ["error", ""]
]
