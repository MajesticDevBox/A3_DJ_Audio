params ["_stage"];
if (!hasInterface || {!EDJ_audioReady}) exitWith {};
private _backend = _stage get "audioBackend";
private _id = _stage get "stageId";
private _instance = EDJ_audioInstances getOrDefault [_id, createHashMapFromArray [["generation", -1], ["backend", ""], ["source", ""], ["playing", false], ["status", "stopped"], ["phase", "IDLE"], ["volume", -1], ["metadata", ""]]];
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
