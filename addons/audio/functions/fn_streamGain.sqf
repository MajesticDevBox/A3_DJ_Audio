params ["_stage"];
private _gain = (_stage get "masterVolume") * (_stage getOrDefault ["outputGain", 1]);
private _cone = _stage getOrDefault ["cone", 360];
private _emitter = _stage get "emitter";
if (_cone < 360 && {!isNull _emitter}) then {
    private _listener = if (isNull findDisplay 312) then {call CBA_fnc_currentUnit} else {curatorCamera};
    private _angle = abs ((((_emitter getDir _listener) - getDir _emitter + 540) % 360) - 180);
    _gain = _gain * linearConversion [_cone / 2, 180, _angle, 1, 0.15, true];
};
_gain
