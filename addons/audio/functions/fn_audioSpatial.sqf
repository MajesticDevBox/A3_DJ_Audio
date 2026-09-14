// 20Hz local spatial updates. No stage commits, remoteExec or replicated transforms.
if (!hasInterface) exitWith {};
private _listener = if (isNull findDisplay 312) then {call CBA_fnc_currentUnit} else {curatorCamera};
if (isNull _listener) exitWith {};
private _convert = {params ["_v"]; [_v select 0, _v select 2, -(_v select 1)]};
private _pos = if (isNull findDisplay 312) then {eyePos _listener} else {getPosASL _listener};
private _dir = if (isNull findDisplay 312) then {eyeDirection _listener} else {vectorDir _listener};
private _listenerArgs = (([_pos] call _convert) + ([_dir] call _convert)) apply {str _x};
private _pushed = false;
{
    if (_y get "backend" == "miniaudio" && {_y getOrDefault ["held", false]}) then {
        private _stage = EDJ_clientStages getOrDefault [_x, createHashMap];
        if (count _stage == 0) then {
            "edj_miniaudio" callExtension ["stop", [_x]];
            _y set ["held", false]; _y set ["playing", false];
        } else {
            if (!_pushed) then {"edj_miniaudio" callExtension ["set_listener", _listenerArgs]; _pushed = true;};
            private _values = [];
            {
                _x params ["_module", "_members"];
                private _live = _members select {!isNull _x && {alive _x}};
                if (!isNull _module && {_live isNotEqualTo []}) then {
                    private _center = [0,0,0];
                    {_center = _center vectorAdd getPosASL _x;} forEach _live;
                    _center = _center vectorMultiply (1 / count _live);
                    _values append (([_center] call _convert) + ([vectorDir _module] call _convert) + [(_stage get "range") max 2, _stage get "cone"]);
                };
            } forEach (_stage getOrDefault ["speakerArrays", []]);
            if (_values isEqualTo [] && {!isNull (_stage get "emitter")} && {alive (_stage get "emitter")}) then {
                private _emitter = _stage get "emitter";
                _values = ([getPosASL _emitter] call _convert) + ([vectorDir _emitter] call _convert) + [(_stage get "range") max 2, _stage get "cone"];
            };
            if (_values isEqualTo []) then {
                "edj_miniaudio" callExtension ["stop", [_stage get "stageId"]];
                _y set ["held", false]; _y set ["playing", false];
            } else {
                "edj_miniaudio" callExtension ["set_arrays", [_stage get "stageId", (_values apply {str _x}) joinString ","]];
                ["miniaudio", "volume", _stage] call EDJ_fnc_audioCall;
            };
        };
    };
} forEach EDJ_audioInstances;
