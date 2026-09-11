params ["_operation", "_stage"];
private _key = "EDJ_native_" + (_stage get "stageId");
switch (_operation) do {
    case "available": {[true, "available"]};
    case "stop": {
        private _handle = missionNamespace getVariable [_key, -1];
        if (_handle >= 0) then {stopSound _handle;};
        missionNamespace setVariable [_key, -1]; [true, "stopped"]
    };
    case "play": {
        private _entry = [_stage get "audioSource"] call EDJ_fnc_libraryGetTrack;
        private _file = _entry getOrDefault ["source", ""];
        if (_file == "" || {_file select [0,1] != "\"}) exitWith {[false, "addon_track_missing"]};
        private _offset = (_stage get "startOffset") + (serverTime - (_stage get "startServerTime"));
        private _duration = _entry getOrDefault ["duration", -1];
        if (_duration > 0 && {_offset >= _duration}) exitWith {[false, "ended"]};
        private _gain = ((_stage get "masterVolume") * (_stage getOrDefault ["outputGain", 1])) min 5;
        private _handle = playSound3D [_file, _stage get "emitter", false, getPosASL (_stage get "emitter"), _gain, 1, _stage get "range", _offset max 0, true];
        missionNamespace setVariable [_key, _handle];
        [_handle >= 0, ["error", "playing"] select (_handle >= 0)]
    };
    case "status": {
        private _handle = missionNamespace getVariable [_key, -1];
        [true, ["stopped", "playing"] select (_handle >= 0 && {count (soundParams _handle) > 0})]
    };
    default {[false, "unsupported"]};
}
