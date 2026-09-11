params ["_computer", "_user", "_data", "_rid", ["_command", "edj_open_event_dj"]];

private _available =
    [_computer] call EDJ_fnc_isAE3Laptop &&
    {_computer getVariable ["EDJ_isWorkstation", false]} &&
    {!isNil "AE3_desktop_fnc_desktop_open"} &&
    {!isNil "AE3_desktop_fnc_wm_createWindow"};

["DEBUG", "AE3 application availability", [
    _available,
    if (isNull _computer) then {""} else {netId _computer},
    if (isNull _computer) then {false} else {_computer getVariable ["EDJ_isWorkstation", false]}
]] call EDJ_fnc_log;

if (!_available) exitWith {
    [_command, _rid, createHashMapFromArray [["ok", false]]]
        call AE3_desktop_fnc_jsReply;
};

[_command, _rid, createHashMapFromArray [["ok", true]]]
    call AE3_desktop_fnc_jsReply;

private _webDisplay = findDisplay 17010;
if (isNull _webDisplay) exitWith {
    ["WARN", "Invalid AE3 workstation target", [typeOf _computer, netId _computer, "web desktop session missing"]] call EDJ_fnc_log;
};

_webDisplay closeDisplay 0;
[{
    params ["_computer"];
    if (!([_computer] call EDJ_fnc_isAE3Laptop) || {!(_computer getVariable ["EDJ_isWorkstation", false])}) exitWith {};

    _computer setVariable ["AE3_computer_mutex", player, true];
    [_computer] spawn {
        params ["_computer"];
        [_computer] call AE3_desktop_fnc_desktop_open;
        private _window = ["EDJ_EventDJ", [], [safeZoneX, safeZoneY]] call AE3_desktop_fnc_wm_createWindow;
        ["DEBUG", "AE3 application availability", ["native_window", _window, netId _computer]] call EDJ_fnc_log;
    };
}, [_computer]] call CBA_fnc_execNextFrame;
