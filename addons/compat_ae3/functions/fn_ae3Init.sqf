if (!hasInterface) exitWith {};

private _nativeReady = !isNil "AE3_desktop_fnc_registerApp";
private _webReady =
    !isNil "AE3_desktop_fnc_registerExtApp" &&
    {!isNil "AE3_desktop_fnc_registerCmd"} &&
    {!isNil "AE3_desktop_fnc_jsReply"};

if (_nativeReady) then {
    // The installed armaOS web renderer has a separate application registry.
    // Keep this native entry hidden; it exists only so the supported web bridge
    // can open the preserved EDJ native window through wm_createWindow.
    ["EDJ_EventDJ", "Event DJ", "EDJ_fnc_ae3App", [1, 1], false, true]
        call AE3_desktop_fnc_registerApp;
};

if (_webReady) then {
    private _extra = createHashMapFromArray [
        ["requiresVar", ["EDJ_isWorkstation", true]],
        ["showOnDesktop", true],
        ["showInDock", true],
        ["showInMenu", true],
        ["menu", "Event DJ"],
        ["subtitle", "Opening the Event DJ workstation"],
        ["openCommand", "edj_open_event_dj"],
        ["launchApps", []],
        ["width", 430],
        ["height", 220]
    ];
    ["edj_event_dj", "Event DJ", "EDJ", "launcher", _extra]
        call AE3_desktop_fnc_registerExtApp;
    ["edj_open_event_dj", EDJ_fnc_ae3OpenWebApp]
        call AE3_desktop_fnc_registerCmd;
};

private _apps = if (isNil "AE3_desktop_fnc_app_list") then {[]} else {
    [] call AE3_desktop_fnc_app_list
};
private _matches = _apps select {(_x param [0, ""]) isEqualTo "EDJ_EventDJ"};
private _nativeValid = false;
if ((count _matches) isEqualTo 1) then {
    private _app = _matches select 0;
    _nativeValid =
        ((_app param [1, ""]) isEqualTo "Event DJ") &&
        {(_app param [2, ""]) isEqualTo "EDJ_fnc_ae3App"} &&
        {abs ((_app param [3, 0]) - 1) < 0.001} &&
        {abs ((_app param [4, 0]) - 1) < 0.001} &&
        {!(_app param [5, true])} &&
        {_app param [6, false]} &&
        {!isNil "EDJ_fnc_ae3App"};
};

private _level = ["ERROR", "INFO"] select (_nativeValid && _webReady);
[_level, "AE3 application availability", [_nativeValid, _webReady, _matches]] call EDJ_fnc_log;
