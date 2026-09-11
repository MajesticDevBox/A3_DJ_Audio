// Accept server snapshots only, including on hosted servers.
if (!hasInterface) exitWith {};
if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {};
if (!isRemoteExecuted && {!isServer}) exitWith {};
params ["_snapshot"];
private _stage = createHashMapFromArray _snapshot;
private _id = _stage get "stageId";
private _old = EDJ_clientStages getOrDefault [_id, createHashMap];
if (count _old > 0 && {(_old get "revision") >= (_stage get "revision")}) exitWith {};
EDJ_clientStages set [_id, _stage];
["DEBUG", "Snapshot applied", [_id, _stage get "revision", didJIP]] call EDJ_fnc_log;
if (EDJ_audioReady) then {[_stage] call EDJ_fnc_audioApply;};
