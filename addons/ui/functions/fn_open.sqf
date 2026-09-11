params ["_id"];
if (!hasInterface) exitWith {};
if (!isNull findDisplay 8700) exitWith {};
if (createDialog "EDJ_Dialog") then {
    [(findDisplay 8700) displayCtrl 8701, _id] call EDJ_fnc_mount;
};
