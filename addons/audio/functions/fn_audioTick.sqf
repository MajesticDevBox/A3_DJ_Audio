// 1Hz local status monitoring, independent of whether a dashboard is open.
if (!hasInterface) exitWith {};
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
        // Carpinchos retains its existing scalar cone gain. Miniaudio spatial
        // state is pushed separately at 20Hz by audioSpatial.
        if (_stage get "audioBackend" == "carpinchos") then {
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

    };
} forEach EDJ_audioInstances;
{
    private _stage = EDJ_clientStages getOrDefault [_x, createHashMap];
    if (count _stage == 0 || {_stage get "operator" != player}) then {[_x, "", "stop"] call EDJ_fnc_audioCue;};
} forEach +keys EDJ_cueInstances;
