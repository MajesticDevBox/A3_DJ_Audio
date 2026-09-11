// Build one normalized config registry per machine. UI queries this cache only.
EDJ_libraryRegistry = createHashMap;
EDJ_libraryOrder = [];

private _registerRoot = {
    params ["_root", "_sourceType", ["_replace", false]];
    {
        private _cfg = _x;
        private _class = configName _cfg;
        private _id = getText (_cfg >> "id");
        if (_id == "") then {_id = _class;};
        private _title = if (_sourceType == "stream") then {getText (_cfg >> "displayName")} else {getText (_cfg >> "title")};
        private _artist = getText (_cfg >> "artist");
        private _backend = getText (_cfg >> "backend");
        if (_backend == "") then {_backend = ["native", "carpinchos"] select (_sourceType == "stream");};
        private _path = getText (_cfg >> (["file", "url"] select (_sourceType == "stream")));
        private _duration = getNumber (_cfg >> "duration");
        private _bpm = getNumber (_cfg >> "bpm");
        private _validId = _id != "" && {count _id <= 96} && {(toArray _id findIf {!(_x in toArray "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.-")}) < 0};
        private _validPath = if (_sourceType == "stream") then {
            _path select [0, 8] == "https://" || {_path select [0, 7] == "http://"}
        } else {
            _path != "" && {_path select [0, 1] == "\"} && {_duration > 0}
        };
        private _valid = _validId && {_title != ""} && {_validPath} && {_backend != ""};
        if (!_valid) then {
            ["WARN", "Library record skipped", [_sourceType, _class, _id, "malformed"]] call EDJ_fnc_log;
        } else {
            if (_id in EDJ_libraryRegistry && {!_replace}) then {
                ["WARN", "Library record skipped", [_sourceType, _class, _id, "duplicate_id"]] call EDJ_fnc_log;
            } else {
                if !(_id in EDJ_libraryRegistry) then {EDJ_libraryOrder pushBack _id;};
                private _addons = configSourceAddonList _cfg;
                private _pack = getText (_cfg >> "originatingAddon");
                if (_pack == "" && {_addons isNotEqualTo []}) then {_pack = _addons select 0;};
                EDJ_libraryRegistry set [_id, createHashMapFromArray [
                    ["id", _id], ["configClass", _class], ["title", _title],
                    ["artist", _artist], ["album", getText (_cfg >> "album")],
                    ["genre", getText (_cfg >> "genre")], ["description", getText (_cfg >> "description")],
                    ["duration", [_duration, -1] select (_sourceType == "stream")],
                    ["bpm", [_bpm, -1] select (_sourceType == "stream")],
                    ["sourceType", _sourceType], ["backend", _backend], ["source", _path],
                    ["originatingAddon", _pack], ["artwork", getText (_cfg >> "artwork")],
                    ["compatibilityVersion", getNumber (_cfg >> "compatibilityVersion")]
                ]];
            };
        };
    } forEach ("true" configClasses _root);
};

[configFile >> "CfgEventDJTracks", "addon", false] call _registerRoot;
[configFile >> "CfgEventDJStreams", "stream", false] call _registerRoot;
if (isClass (missionConfigFile >> "CfgEventDJStreams")) then {
    [missionConfigFile >> "CfgEventDJStreams", "stream", true] call _registerRoot;
};
EDJ_libraryOrder sort true;
["INFO", "DJ library initialized", [count EDJ_libraryOrder, +EDJ_libraryOrder]] call EDJ_fnc_log;
