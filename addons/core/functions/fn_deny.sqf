// Rate-limited denial logging: one message per network owner per five seconds.
params ["_sender", "_id", "_reason"];
private _key = str _sender;
if (diag_tickTime - (EDJ_denials getOrDefault [_key, -10]) >= 5) then {
    EDJ_denials set [_key, diag_tickTime];
    ["WARN", "Command denied", [_sender, _id select [0, 48], _reason]] call EDJ_fnc_log;
};
