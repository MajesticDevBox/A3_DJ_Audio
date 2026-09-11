// Idempotent, client-local cleanup for remount and both window hosts.
params ["_group"];
if (isNull _group) exitWith {};
private _stageId = _group getVariable ["EDJ_stageId", ""];
if (_stageId != "" && {!isNil "EDJ_fnc_audioCue"}) then {[_stageId, "", "stop"] call EDJ_fnc_audioCue;};
private _pfh = _group getVariable ["EDJ_pfh", -1];
private _controls = _group getVariable ["EDJ_controls", []];
if (_pfh >= 0 || {_controls isNotEqualTo []}) then {
    ["DEBUG", "UI teardown", [ctrlIDC _group, _pfh, count _controls]] call EDJ_fnc_log;
};
if (_pfh >= 0) then {[_pfh] call CBA_fnc_removePerFrameHandler;};
_group setVariable ["EDJ_pfh", -1];
{if (!isNull _x) then {ctrlDelete _x;};} forEach _controls;
_group setVariable ["EDJ_controls", []];
