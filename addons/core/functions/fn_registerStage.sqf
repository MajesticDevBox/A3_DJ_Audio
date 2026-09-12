// Server-only mission API. Call from initServer.sqf, not remoteExec.
params [["_id", "", [""]], ["_workstation", objNull, [objNull]], ["_emitter", objNull, [objNull]], ["_source", "groove", [""]], ["_backend", "carpinchos", [""]], ["_allowedUIDs", [], [[]]], ["_audio", [1, 2, 500, 360], [[]]]];
if (!isServer || {isRemoteExecuted} || {_id == ""} || {isNull _workstation} || {isNull _emitter}) exitWith {false};
if (count _id > 48 || {(toArray _id findIf {!(_x in toArray "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-")}) >= 0}) exitWith {false};
if ((_allowedUIDs findIf {!(_x isEqualType "")}) >= 0) exitWith {false};
if (count _audio != 4 || {(_audio findIf {!(_x isEqualType 0) || {!finite _x}}) >= 0}) exitWith {false};
_audio params ["_volume", "_gain", "_range", "_cone"];
if ((values EDJ_stages findIf {(_x get "emitter") == _emitter || {(_x get "workstation") == _workstation}}) >= 0) exitWith {false};
if (_id in EDJ_stages || {!(_backend in ["carpinchos", "native", "miniaudio"])}) exitWith {false};
private _entry = [_source] call EDJ_fnc_libraryGetTrack;
if (count _entry == 0 || {_entry get "backend" != _backend}) exitWith {false};
private _deckA = ["A", _entry] call EDJ_fnc_deckCreate;
private _deckB = ["B"] call EDJ_fnc_deckCreate;
private _stage = createHashMapFromArray [
    ["stageId", _id], ["workstation", _workstation], ["emitter", _emitter],
    ["allowedUIDs", +_allowedUIDs], ["operator", objNull], ["operatorUID", ""],
    ["decks", [_deckA, _deckB]], ["queue", []], ["activeDeck", "A"], ["transitionMode", "CUT"],
    ["nowPlaying", []],
    ["audioBackend", _backend], ["audioSource", _source], ["playback", "stopped"],
    ["masterVolume", (_volume max 0) min 1], ["outputGain", (_gain max 0) min 10], ["cone", (_cone max 1) min 360], ["startServerTime", 0], ["startOffset", 0],
    ["revision", 0], ["playGeneration", 0], ["lastPlay", -10], ["lastStateChange", serverTime],
    ["powerState", true], ["zoneId", "main"], ["range", (_range max 1) min 5000]
];
EDJ_stages set [_id, _stage];
_workstation setVariable ["EDJ_stageId", _id, true];
[_id, [], "registered"] call EDJ_fnc_commitStage;
true
