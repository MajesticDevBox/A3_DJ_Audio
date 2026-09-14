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
if (!hasInterface) exitWith {[false, "no_interface"]};
private _extension = "edj_miniaudio";
private _stageId = _stage get "stageId";
private _emitter = _stage get "emitter";

private _fnc_call = {
    params ["_function", ["_args", []]];
    (_extension callExtension [_function, _args]) params ["_output", "_returnCode", "_errorCode"];
    if (_errorCode != 0 || {_output == ""}) exitWith {[false, "extension_missing_or_blocked"]};
    if (_returnCode != 0) exitWith {[false, "extension_call_failed"]};
    if (_output select [0, 2] == "0:") exitWith {[false, _output select [2]]};
    [true, _output]
};

switch (_operation) do {
    case "pause"; case "resume"; case "duration"; case "position": {
        [_operation, [_stageId]] call _fnc_call
    };
    case "seek": {
        private _offset = _stage get "startOffset";
        if (_stage get "playback" == "playing") then {_offset = _offset + (serverTime - (_stage get "startServerTime"));};
        ["seek", [_stageId, str (_offset max 0)]] call _fnc_call
    };
    case "available": {
        private _discovery = [true, "available"];
        if (!(missionNamespace getVariable ["EDJ_miniaudioDiscovered", false])) then {
            _discovery = ["discover"] call _fnc_call;
            if (_discovery select 0) then {missionNamespace setVariable ["EDJ_miniaudioDiscovered", true];};
        };
        if !(_discovery select 0) exitWith {_discovery};
        (["status"] call _fnc_call) params ["_ok", "_status"];
        if (!_ok) exitWith {[false, _status]};
        if (_status == "running") exitWith {[true, "available"]};
        (["init"] call _fnc_call) params ["_ok2", "_initOutput"];
        if (_ok2 && {_initOutput == "1"}) exitWith {[true, "available"]};
        [false, _initOutput]
    };
    case "play": {
        private _ready = ["available", _stage] call EDJ_fnc_miniaudio;
        if !(_ready select 0) exitWith {_ready};
        if !([_stage] call EDJ_fnc_hasEmitter) exitWith {[false, "emitter_missing"]};
        private _entry = [_stage get "audioSource"] call EDJ_fnc_libraryGetTrack;
        private _file = _entry getOrDefault ["source", ""];
        if (_file == "" || {_file select [0, 1] != "\"}) exitWith {[false, "addon_track_missing"]};
        private _offset = (_stage get "startOffset") + (serverTime - (_stage get "startServerTime"));
        private _duration = _entry getOrDefault ["duration", -1];
        if (_duration > 0 && {_offset >= _duration}) exitWith {[false, "ended"]};
        private _gain = (_stage get "masterVolume") * (_stage getOrDefault ["outputGain", 1]);
        private _pos = getPosASL _emitter;
        private _range = _stage getOrDefault ["range", 50];
        // Set the listener before the first sample, not one status tick later.
        private _listener = if (isNull findDisplay 312) then {call CBA_fnc_currentUnit} else {curatorCamera};
        private _lp = if (isNull findDisplay 312) then {eyePos _listener} else {getPosASL _listener};
        private _ld = if (isNull findDisplay 312) then {eyeDirection _listener} else {vectorDir _listener};
        ["set_listener", (_lp + _ld) apply {str _x}] call _fnc_call;
        private _args = [
            _stageId, _file, str _gain, str (_offset max 0),
            str (_pos select 0), str (_pos select 1), str (_pos select 2), str _range
        ];
        (["play", _args] call _fnc_call) params ["_ok", "_output"];
        if (!_ok) exitWith {[false, _output]};
        [_output == "1", ["error", "playing"] select (_output == "1")]
    };
    case "stop": {
        private _result = ["stop", [_stageId]] call _fnc_call;
        if !(_result select 0) exitWith {_result};
        [true, "stopped"]
    };
    case "volume": {
        private _gain = (_stage get "masterVolume") * (_stage getOrDefault ["outputGain", 1]);
        (["volume", [_stageId, str _gain]] call _fnc_call) params ["_ok", "_output"];
        if (!_ok) exitWith {[false, _output]};
        [_output == "1", ["volume_failed", "volume_applied"] select (_output == "1")]
    };
    case "status": {
        (["playback_status", [_stageId]] call _fnc_call) params ["_ok", "_output"];
        if (!_ok) exitWith {[false, _output]};
        [true, _output]
    };
    default {[false, "unsupported"]};
}
