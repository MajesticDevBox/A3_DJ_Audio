private _ctrl = _this;
private _group = _ctrl getVariable ["EDJ_group", controlNull];
if (isNull _group) exitWith {};
private _stageId = _group getVariable ["EDJ_stageId", ""];
private _action = _ctrl getVariable ["EDJ_action", []];
if (count _action != 2) exitWith {};
_action params ["_operation", "_payload"];
switch (_operation) do {
    case "loadSelected": {private _track = _group getVariable ["EDJ_selectedTrack", ""]; if (_track != "") then {[_stageId, "deckLoad", [_payload, _track]] call EDJ_fnc_request;};};
    case "queueAdd": {private _track = _group getVariable ["EDJ_selectedTrack", ""]; if (_track != "") then {[_stageId, "queueAdd", _track] call EDJ_fnc_request;};};
    case "queueRemove": {private _queue = (_group getVariable "EDJ_namedControls") get "queue"; private _index = _queue getVariable ["EDJ_selectedIndex", -1]; if (_index >= 0) then {[_stageId, "queueRemove", _index] call EDJ_fnc_request;};};
    case "queueMove": {private _queue = (_group getVariable "EDJ_namedControls") get "queue"; private _index = _queue getVariable ["EDJ_selectedIndex", -1]; if (_index >= 0) then {[_stageId, "queueMove", [_index, _payload]] call EDJ_fnc_request;};};
    case "queueClear": {
        private _armed = _group getVariable ["EDJ_clearArmed", -10];
        if (diag_tickTime - _armed <= 3) then {[_stageId, "queueClear", 0] call EDJ_fnc_request; _group setVariable ["EDJ_clearArmed", -10];} else {_group setVariable ["EDJ_clearArmed", diag_tickTime]; _ctrl ctrlSetText "OK?";};
    };
    case "cue": {[_stageId, _payload, "toggle"] call EDJ_fnc_audioCue;};
    default {[_stageId, _operation, _payload] call EDJ_fnc_request;};
};
