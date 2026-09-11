params ["_stage"];
if (!isServer) exitWith {};
// Send explicit serializable pairs; keep allowlists and rate state on server.
private _snapshot = [];
{if (_x != "allowedUIDs") then {_snapshot pushBack [_x, _y];};} forEach _stage;
[_snapshot] remoteExecCall ["EDJ_fnc_receive", 0];
["DEBUG", "Published stage", [_stage get "stageId", _stage get "revision", _stage get "playback"]] call EDJ_fnc_log;
