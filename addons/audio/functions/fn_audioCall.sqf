// Uniform result: [success, status]. Adapters are strictly client-local.
params ["_backend", "_operation", "_stage"];
if (!hasInterface) exitWith {[false, "no_interface"]};
private _provider = EDJ_providers getOrDefault [_backend, []];
if (count _provider == 0) exitWith {[false, "backend_unavailable"]};
if (!(_operation in ["available", "status"]) && {!([_backend, _operation] call EDJ_fnc_audioSupportsFeature)}) exitWith {[false, "unsupported"]};
[_operation, _stage] call (_provider select 0)
