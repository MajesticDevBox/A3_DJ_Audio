params ["_module", "_units", "_activated"];

if (!isServer || {!_activated}) exitWith {true};

private _targets = (synchronizedObjects _module) select {
    !isNull _x && {!(_x isKindOf "Logic")}
};

if ((count _targets) isNotEqualTo 1) exitWith {
    ["WARN", "Invalid AE3 workstation target", ["expected_one", count _targets]] call EDJ_fnc_log;
    true
};

private _computer = _targets select 0;
if (!([_computer] call EDJ_fnc_isAE3Laptop)) exitWith {
    ["WARN", "Invalid AE3 workstation target", [typeOf _computer, netId _computer]] call EDJ_fnc_log;
    true
};

private _ready = if (isNil "AE3_armaos_fnc_device_ensureInit") then {false} else {
    [_computer] call AE3_armaos_fnc_device_ensureInit
};
if (!_ready) exitWith {
    ["WARN", "Invalid AE3 workstation target", [typeOf _computer, netId _computer, "AE3 initialization failed"]] call EDJ_fnc_log;
    true
};

_computer setVariable ["EDJ_isWorkstation", true, true];
["INFO", "Event DJ workstation configured", [typeOf _computer, netId _computer]] call EDJ_fnc_log;
true
