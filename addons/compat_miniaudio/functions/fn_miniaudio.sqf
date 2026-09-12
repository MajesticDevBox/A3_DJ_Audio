// Local-track adapter backed by extensions/miniaudio (edj_miniaudio_x64).
// Unlike fn_native.sqf's playSound3D, "volume" here changes a live sound's
// gain in place (no stop/restart), so this backend gets the same per-tick
// directional gain push carpinchos streams already get -- see the
// "miniaudio" branch added to addons/audio/functions/fn_audioTick.sqf.
//
// callExtension's array form returns [output, returnCode, errorCode]; a
// non-zero errorCode means Arma itself couldn't reach the extension (most
// commonly: edj_miniaudio_x64.dll isn't present in @edj's root yet).
params ["_operation", "_stage"];
private _extension = "edj_miniaudio_x64";
private _stageId = _stage get "stageId";
private _emitter = _stage get "emitter";

private _fnc_call = {
    params ["_function", ["_args", []]];
    (_extension callExtension [_function, _args]) params ["_output", "_returnCode", "_errorCode"];
    if (_errorCode != 0) exitWith {[false, "extension_missing"]};
    [true, _output]
};

switch (_operation) do {
    case "available": {
        (["status"] call _fnc_call) params ["_ok", "_status"];
        if (!_ok) exitWith {[false, _status]};
        if (_status == "running") exitWith {[true, "available"]};
        (["init"] call _fnc_call) params ["_ok2", "_initOutput"];
        if (_ok2 && {_initOutput == "1"}) exitWith {[true, "available"]};
        [false, "engine_init_failed"]
    };
    case "play": {
        if (isNull _emitter) exitWith {[false, "emitter_missing"]};
        private _entry = [_stage get "audioSource"] call EDJ_fnc_libraryGetTrack;
        private _file = _entry getOrDefault ["source", ""];
        if (_file == "" || {_file select [0, 1] != "\"}) exitWith {[false, "addon_track_missing"]};
        private _offset = (_stage get "startOffset") + (serverTime - (_stage get "startServerTime"));
        private _duration = _entry getOrDefault ["duration", -1];
        if (_duration > 0 && {_offset >= _duration}) exitWith {[false, "ended"]};
        private _gain = [_stage] call EDJ_fnc_streamGain;
        private _pos = getPosASL _emitter;
        private _range = _stage getOrDefault ["range", 50];
        private _args = [
            _stageId, _file, str _gain, str (_offset max 0),
            str (_pos select 0), str (_pos select 1), str (_pos select 2), str _range
        ];
        (["play", _args] call _fnc_call) params ["_ok", "_output"];
        if (!_ok) exitWith {[false, _output]};
        [_output == "1", ["error", "playing"] select (_output == "1")]
    };
    case "stop": {
        ["stop", [_stageId]] call _fnc_call;
        [true, "stopped"]
    };
    case "volume": {
        private _gain = [_stage] call EDJ_fnc_streamGain;
        (["volume", [_stageId, str _gain]] call _fnc_call) params ["_ok", "_output"];
        if (!_ok) exitWith {[false, _output]};
        [_output == "1", ["volume_failed", "volume_applied"] select (_output == "1")]
    };
    case "status": {
        (["playback_status", [_stageId]] call _fnc_call) params ["_ok", "_output"];
        if (!_ok) exitWith {[false, _output]};
        [true, ["stopped", "playing"] select (_output == "playing")]
    };
    default {[false, "unsupported"]};
}
