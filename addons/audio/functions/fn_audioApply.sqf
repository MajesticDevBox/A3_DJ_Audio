params ["_stage"];
if (!hasInterface || {!EDJ_audioReady}) exitWith {};
private _backend = _stage get "audioBackend";
private _id = _stage get "stageId";
private _instance = EDJ_audioInstances getOrDefault [_id, createHashMapFromArray [["generation", -1], ["backend", ""], ["source", ""], ["playing", false], ["status", "stopped"], ["phase", "IDLE"], ["volume", -1], ["metadata", ""]]];
if (_backend == "miniaudio") exitWith {
    private _state = _stage get "playback";
    private _same = _instance get "backend" == _backend && {_instance get "source" == _stage get "audioSource"};
    private _held = _instance getOrDefault ["held", false];
    if (!_same && {_instance get "playing" || {_held}}) then {
        [_instance get "backend", "stop", _stage] call EDJ_fnc_audioCall;
        _held = false;
    };
    private _result = [true, "stopped"];
    if (_state == "stopped") then {
        [_backend, "stop", _stage] call EDJ_fnc_audioCall;
        _held = false;
    } else {
        if (!_held && {_state == "playing"} && {(!_same) || {_instance get "generation" != _stage get "playGeneration"}}) then {
            _result = [_backend, "play", _stage] call EDJ_fnc_audioCall;
            _held = _result select 0;
        } else {
            if (_held) then {
                private _timing = [_stage get "playGeneration", _stage get "startOffset", _stage get "startServerTime", _state];
                if (_timing isNotEqualTo (_instance getOrDefault ["timing", []])) then {
                    if (_state == "paused") then {[_backend, "pause", _stage] call EDJ_fnc_audioCall;};
                    _result = [_backend, "seek", _stage] call EDJ_fnc_audioCall;
                    if (_state == "playing" && {_result select 0}) then {_result = [_backend, "resume", _stage] call EDJ_fnc_audioCall;};
                };
            };
        };
    };
    if (_held) then {[_backend, "volume", _stage] call EDJ_fnc_audioCall;};
    _instance set ["held", _held];
    _instance set ["playing", _held && {_state == "playing"}];
    _instance set ["backend", _backend]; _instance set ["source", _stage get "audioSource"];
    _instance set ["generation", _stage get "playGeneration"];
    _instance set ["timing", [_stage get "playGeneration", _stage get "startOffset", _stage get "startServerTime", _state]];
    _instance set ["status", if (_result select 0) then {_state} else {_result select 1}];
    _instance set ["phase", if !(_result select 0) then {"ERROR"} else {["IDLE", "PLAYING"] select (_state == "playing")}];
    EDJ_audioInstances set [_id, _instance];
};
if (_instance getOrDefault ["held", false]) then {[_instance get "backend", "stop", _stage] call EDJ_fnc_audioCall; _instance set ["held", false]; _instance set ["playing", false];};
if (_stage get "playback" == "playing") then {
    // Failed starts are latched to this generation, not retried by volume/claim changes.
    if (_instance get "generation" != _stage get "playGeneration" || {_instance get "backend" != _backend} || {_instance get "source" != _stage get "audioSource"}) then {
        if (_instance get "playing") then {[_instance get "backend", "stop", _stage] call EDJ_fnc_audioCall;};
        _instance set ["phase", "STARTING"];
        private _result = [_backend, "play", _stage] call EDJ_fnc_audioCall;
        _instance set ["playing", _result select 0];
        _instance set ["status", _result select 1];
        _instance set ["generation", _stage get "playGeneration"];
        _instance set ["backend", _backend];
        _instance set ["source", _stage get "audioSource"];
        _instance set ["phase", ["ERROR", "STARTING"] select (_result select 0)];
        _instance set ["volume", _stage get "masterVolume"];
        ["INFO", "Audio generation applied", [_id, _backend, _stage get "playGeneration", _result select 1]] call EDJ_fnc_log;
        if !(_result select 0) then {["WARN", "Audio start failed", [_id, _backend, _result select 1]] call EDJ_fnc_log;};
    };
    if (_instance get "playing" && {_instance get "volume" != _stage get "masterVolume"} && {[_backend, "volume"] call EDJ_fnc_audioSupportsFeature}) then {
        [_backend, "volume", _stage] call EDJ_fnc_audioCall;
        _instance set ["volume", _stage get "masterVolume"];
    };
} else {
    if (_instance get "playing") then {
        _instance set ["phase", "STOPPING"];
        [_backend, "stop", _stage] call EDJ_fnc_audioCall;
        ["INFO", "Audio stopped", [_id, _backend]] call EDJ_fnc_log;
    };
    _instance set ["playing", false]; _instance set ["status", "stopped"]; _instance set ["phase", "IDLE"];
};
EDJ_audioInstances set [_id, _instance];
