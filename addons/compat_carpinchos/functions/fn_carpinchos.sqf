// Version-bound adapter: inspected ArmaRadio 0345887571038b5414c4ecc4d22e849fea4eb445.
// Only LOCAL CBA events: never call upstream global play or publish its active variable.
params ["_operation", "_stage"];
if (!hasInterface || {isNil "live_radio_manager_sources"} || {isNil "live_radio_manager_sourcesStatus"} || {isNil "live_radio_manager_fnc_play"}) exitWith {[false, "backend_unavailable"]};
private _stageId = _stage get "stageId";
private _record = EDJ_carpinchosSources getOrDefault [_stageId, []];
private _id = _record param [0, ""];
private _emitter = _stage get "emitter";
private _gain = [_stage] call EDJ_fnc_streamGain;
switch (_operation) do {
    case "available": {
        // The manager owns extension liveness and source recreation. Its map/event
        // surface is the adapter contract; stream health arrives asynchronously.
        [true, "available"]
    };
    case "play": {
        if (isNull _emitter) exitWith {[false, "emitter_missing"]};
        if (_record isNotEqualTo []) exitWith {[false, "source_busy"]};
        // New generation => new ID. Late old callbacks cannot mark a new stream LIVE.
        _id = format ["EDJ_%1_%2", _stageId, _stage get "playGeneration"];
        private _entry = [_stage get "audioSource"] call EDJ_fnc_libraryGetTrack;
        private _url = _entry getOrDefault ["source", ""];
        if (_url select [0,8] != "https://" && {_url select [0,7] != "http://"}) exitWith {[false, "invalid_source"]};
        _emitter setVariable ["live_radio_manager_volume", _gain];
        ["live_radio_manager_start", [_id, _url, _emitter]] call CBA_fnc_localEvent;
        if !(_id in live_radio_manager_sources) exitWith {[false, "manager_start_failed"]};
        EDJ_carpinchosSources set [_stageId, [_id, diag_tickTime]];
        ["INFO", "Carpinchos source created", [_stageId, _id, _stage get "playGeneration"]] call EDJ_fnc_log;
        [true, "connecting"]
    };
    case "stop": {
        if (_id != "") then {["live_radio_manager_stop", [_id]] call CBA_fnc_localEvent;};
        EDJ_carpinchosSources deleteAt _stageId;
        ["INFO", "Carpinchos source destroyed", [_stageId, _id]] call EDJ_fnc_log;
        [true, "stopped"]
    };
    case "volume": {
        if (_id == "") exitWith {[false, "source_missing"]};
        _emitter setVariable ["live_radio_manager_volume", _gain];
        ["live_radio_manager_volume", [_id, _gain]] call CBA_fnc_localEvent;
        ["DEBUG", "Carpinchos volume applied", [_stageId, _id, _stage get "masterVolume"]] call EDJ_fnc_log;
        [true, "volume_applied"]
    };
    case "status": {
        if (_record isEqualTo []) exitWith {[true, "stopped"]};
        private _started = _record select 1;
        // Carpinchos performs its own source:exists watchdog and recreates dead
        // extension sources. Do not race that asynchronous lifecycle here.
        if !(_id in live_radio_manager_sources) exitWith {[false, "source_missing"]};
        private _status = live_radio_manager_sourcesStatus getOrDefault [_id, "connecting"];
        // A title callback can arrive even when this dependency version drops the
        // earlier online callback. Title metadata is emitted only from live data.
        if (_status == "connecting" && {_id in live_radio_manager_sourcesTitles}) then {_status = "online";};
        if (_status == "connecting" && {diag_tickTime - _started > 15}) then {_status = "offline";};
        [true, _status]
    };
    default {[false, "unsupported"]};
}
