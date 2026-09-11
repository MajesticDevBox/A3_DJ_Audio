params ["_id"];
if !(_id isEqualType "") exitWith {createHashMap};
EDJ_libraryRegistry getOrDefault [_id, createHashMap]
