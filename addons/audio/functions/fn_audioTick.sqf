// 1Hz local status monitoring, independent of whether a dashboard is open.
if (!hasInterface) exitWith {};
private _listenerPushed = false;
{
    private _stage = EDJ_clientStages getOrDefault [_x, createHashMap];
    if (count _stage > 0 && {_y get "playing"}) then {
        private _status = ([_stage get "audioBackend", "status", _stage] call EDJ_fnc_audioCall) select 1;
        if (_status != _y get "status") then {
            _y set ["status", _status];
            private _phase = switch (_status) do {
                case "online"; case "playing": {"PLAYING"};
                case "connecting": {"STARTING"};
                default {"ERROR"};
            };
            _y set ["phase", _phase];
            ["INFO", "Audio status changed", [_x, _stage get "audioBackend", _status]] call EDJ_fnc_log;
        };
        // Both live backends (streams via Carpinchos, local tracks via the
        // miniaudio adapter) support a live volume change, so both get this
        // periodic cone-aware gain push. This is what gives local tracks the
        // same directional behavior streams already had; playSound3D-backed
        // "native" tracks still can't, since that backend sets volume once
        // at start and doesn't expose live per-source gain.
        if (_stage get "audioBackend" in ["carpinchos", "miniaudio"]) then {
            private _gain = [_stage] call EDJ_fnc_streamGain;
            if (abs (_gain - (_y getOrDefault ["spatialGain", -1])) > 0.001) then {
                [_stage get "audioBackend", "volume", _stage] call EDJ_fnc_audioCall;
                _y set ["spatialGain", _gain];
            };
        };
        if (_stage get "audioBackend" == "carpinchos") then {
            private _record = EDJ_carpinchosSources getOrDefault [_x, []];
            if (_record isNotEqualTo []) then {
                private _metadata = live_radio_manager_sourcesTitles getOrDefault [_record select 0, ""];
                _y set ["metadata", _metadata];
            };
        };
        // The miniaudio adapter mixes audio through its own device, entirely
        // outside Arma's own audio engine, so its distance-based attenuation
        // needs to know where the actual listener is in world space. Pushed
        // once per tick (not per stage) since it's engine-global, not
        // per-stage, state.
        if (_stage get "audioBackend" == "miniaudio" && {!_listenerPushed}) then {
            _listenerPushed = true;
            private _listener = if (isNull findDisplay 312) then {call CBA_fnc_currentUnit} else {curatorCamera};
            if !(isNull _listener) then {
                private _pos = getPosASL _listener;
                private _dir = eyeDirection _listener;
                "edj_miniaudio_x64" callExtension ["set_listener", [
                    str (_pos select 0), str (_pos select 1), str (_pos select 2),
                    str (_dir select 0), str (_dir select 1), str (_dir select 2)
                ]];
            };
        };
    };
} forEach EDJ_audioInstances;
{
    private _stage = EDJ_clientStages getOrDefault [_x, createHashMap];
    if (count _stage == 0 || {_stage get "operator" != player}) then {[_x, "", "stop"] call EDJ_fnc_audioCue;};
} forEach +keys EDJ_cueInstances;
