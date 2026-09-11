// Client controller boundary; no optimistic authoritative mutation.
params ["_id", "_operation", ["_value", 0]];
if (!hasInterface || {isNull player}) exitWith {};
[_id, _operation, _value] remoteExecCall ["EDJ_fnc_serverRequest", 2];
