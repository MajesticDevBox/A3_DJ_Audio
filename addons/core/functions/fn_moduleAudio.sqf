params ["_module", "_units", "_activated"];
if (!isServer || {!_activated} || {isNull _module}) exitWith {};
if (_module getVariable ["EDJ_configured", false]) exitWith {};
if (_module isKindOf "EDJ_Module_Radio" && {owner _module > 2 || {hasInterface && {!isNull findDisplay 312}}}) exitWith {
    [_module] remoteExecCall ["EDJ_fnc_radioDialog", owner _module];
};
// Defer until all Eden objects and synchronization links exist.
[{
    params ["_module"];
    if (isNull _module) exitWith {};
    private _links = synchronizedObjects _module;
    private _props = _links select {!(_x isKindOf "Logic")};
    private _arrays = [];
    {
        private _speakers = synchronizedObjects _x select {!(_x isKindOf "Logic")};
        if (_speakers isNotEqualTo []) then {_arrays pushBack [_x, _speakers];};
    } forEach (_links select {_x isKindOf "EDJ_Module_SpeakerArray"});
    if (count _props > 1 || {count _arrays > 8} || {_props isEqualTo [] && {_arrays isEqualTo []}}) exitWith {["WARN", "PA requires up to one fallback prop and up to eight nonempty arrays", []] call EDJ_fnc_log;};
    private _source = _module getVariable ["Source", "groove"];
    private _volume = _module getVariable ["Volume", 1];
    private _gain = _module getVariable ["Gain", 2];
    private _range = _module getVariable ["Range", 500];
    private _cone = _module getVariable ["Cone", 360];
    if (_module isKindOf "EDJ_Module_Radio") exitWith {
        if (count _props != 1) exitWith {};
        [_module, _props select 0, _source, _volume, _gain, _range] call EDJ_fnc_configureRadio;
    };
    private _workstations = _links select {_x isKindOf "EDJ_Module_AddEventDJWorkstation"};
    if (count _workstations != 1) exitWith {["WARN", "PA needs one workstation module", []] call EDJ_fnc_log;};
    private _computers = synchronizedObjects (_workstations select 0) select {!(_x isKindOf "Logic")};
    if (count _computers != 1) exitWith {["WARN", "Workstation needs one laptop", []] call EDJ_fnc_log;};
    if (!((_computers select 0) getVariable ["EDJ_isWorkstation", false])) exitWith {["WARN", "PA target is not a configured Event DJ workstation", []] call EDJ_fnc_log;};
    private _members = +_props;
    {
        {if (!(_x isKindOf "Logic")) then {_members pushBackUnique _x;};} forEach synchronizedObjects _x;
    } forEach (_links select {_x isKindOf "EDJ_Module_SpeakerArray"});
    private _entry = [_source] call EDJ_fnc_libraryGetTrack;
    private _id = _module getVariable ["StageId", "main"];
    private _fallback = if (_props isNotEqualTo []) then {_props select 0} else {((_arrays select 0) select 1) select 0};
    if ([_id, _computers select 0, _fallback, _source, _entry getOrDefault ["backend", ""], [], [_volume, _gain, _range, _cone]] call EDJ_fnc_registerStage) then {
        _module setVariable ["EDJ_configured", true, true];
        [_id, [["arrayMembers", _members], ["speakerArrays", _arrays], ["paModule", _module]], "array_configured"] call EDJ_fnc_commitStage;
    } else {["WARN", "PA registration rejected; check ID, source and duplicate objects", [_id]] call EDJ_fnc_log;};
}, [_module]] call CBA_fnc_execNextFrame;
