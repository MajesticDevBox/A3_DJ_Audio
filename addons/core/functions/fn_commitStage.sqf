// Internal server mutation boundary. Not remotely executable.
// All runtime mutations and revisions pass here; registerStage only creates state.
params ["_id", "_changes", "_reason"];
if (!isServer) exitWith {false};
private _stage = EDJ_stages getOrDefault [_id, createHashMap];
if (count _stage == 0) exitWith {false};
private _changed = _reason == "registered";
{
    _x params ["_field", "_value"];
    if ((_stage getOrDefault [_field, ""]) isNotEqualTo _value) then {
        _stage set [_field, _value]; _changed = true;
    };
} forEach _changes;
if (!_changed) exitWith {false};
_stage set ["revision", (_stage get "revision") + 1];
_stage set ["lastStateChange", serverTime];
[_stage] call EDJ_fnc_publish;
["INFO", "Stage transition", [
    _id,
    _reason,
    _stage get "operatorUID",
    _stage get "audioBackend",
    _stage get "audioSource",
    _stage get "playback",
    _stage get "masterVolume",
    _stage get "revision",
    _stage get "playGeneration",
    netId (_stage get "emitter")
]] call EDJ_fnc_log;
true
