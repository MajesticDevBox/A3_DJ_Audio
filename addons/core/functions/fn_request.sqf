// Client controller boundary; no optimistic authoritative mutation.
params ["_id", "_operation", ["_value", 0]];
if (!hasInterface || {isNull player}) exitWith {};
// Singleplayer has no remote transport context. Use the same validation path
// locally; multiplayer always obtains identity from remoteExecutedOwner.
if (!isMultiplayer && {isServer}) exitWith {[_id, _operation, _value] call EDJ_fnc_serverRequest;};
[_id, _operation, _value] remoteExecCall ["EDJ_fnc_serverRequest", 2];
