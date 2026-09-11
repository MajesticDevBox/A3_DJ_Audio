// One-time config registry. Optional compat PBOs contribute their own providers.
if (!hasInterface) exitWith {};
EDJ_providers = createHashMap;
{
    private _handler = missionNamespace getVariable [getText (_x >> "handler"), 0];
    if (_handler isEqualType {}) then {
        EDJ_providers set [configName _x, [_handler, getArray (_x >> "capabilities")]];
    };
} forEach ("true" configClasses (configFile >> "CfgEDJAudioProviders"));
EDJ_audioReady = true;
{[_y] call EDJ_fnc_audioApply;} forEach EDJ_clientStages;
EDJ_audioPFH = [{call EDJ_fnc_audioTick}, 1] call CBA_fnc_addPerFrameHandler;
["INFO", "Audio providers initialized", keys EDJ_providers] call EDJ_fnc_log;
