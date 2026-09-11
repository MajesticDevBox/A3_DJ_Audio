// Local development inspection only. No remote whitelist entry, no state mutation.
params [["_id", "main", [""]]];
if (!(missionNamespace getVariable ["EDJ_debug", false])) exitWith {[]};
private _registry = missionNamespace getVariable [["EDJ_clientStages", "EDJ_stages"] select isServer, createHashMap];
private _stage = _registry getOrDefault [_id, createHashMap];
private _result = [];
{
    _result pushBack [_x, _stage getOrDefault [_x, "unavailable"]];
} forEach ["stageId", "operatorUID", "audioBackend", "audioSource", "playback", "emitter", "masterVolume", "activeDeck", "decks", "queue", "nowPlaying", "revision", "playGeneration"];
if (hasInterface && {!isNil "EDJ_providers"}) then {
    private _provider = EDJ_providers getOrDefault [_stage getOrDefault ["audioBackend", ""], [{}, []]];
    _result pushBack ["capabilities", _provider select 1];
    private _instance = EDJ_audioInstances getOrDefault [_id, createHashMap];
    _result pushBack ["localStatus", _instance getOrDefault ["status", "unavailable"]];
    _result pushBack ["localPhase", _instance getOrDefault ["phase", "unavailable"]];
};
["DEBUG", "Stage inspection", _result] call EDJ_fnc_log;
_result
