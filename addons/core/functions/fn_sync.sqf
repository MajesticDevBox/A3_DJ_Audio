if (!isServer || {!isRemoteExecuted}) exitWith {};
private _sender = remoteExecutedOwner;
if (_sender < 2) exitWith {};
if ((allPlayers findIf {owner _x == _sender && {isPlayer _x}}) < 0) exitWith {};
private _key = "sync_" + str _sender;
if (diag_tickTime - (EDJ_rate getOrDefault [_key, -10]) < 2) exitWith {};
EDJ_rate set [_key, diag_tickTime];
{
    private _snapshot = [];
    {if (_x != "allowedUIDs") then {_snapshot pushBack [_x, _y];};} forEach _y;
    [_snapshot] remoteExecCall ["EDJ_fnc_receive", _sender];
} forEach EDJ_stages;
