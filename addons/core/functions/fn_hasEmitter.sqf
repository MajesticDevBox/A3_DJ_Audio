params ["_stage"];
if ("paModule" in _stage && {isNull (_stage get "paModule")}) exitWith {false};
if (_stage get "audioBackend" == "miniaudio" && {((_stage getOrDefault ["speakerArrays", []]) findIf {
    !isNull (_x select 0) && {((_x select 1) findIf {!isNull _x && {alive _x}}) >= 0}
}) >= 0}) exitWith {true};
!isNull (_stage get "emitter") && {alive (_stage get "emitter")}
