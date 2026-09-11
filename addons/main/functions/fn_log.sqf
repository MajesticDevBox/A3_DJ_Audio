// Local diagnostics: callers supply identifiers, never URLs or credentials.
params ["_level", "_message", ["_context", []]];
if (_level in ["TRACE", "DEBUG"] && {!(missionNamespace getVariable ["EDJ_debug", false])}) exitWith {};
diag_log format ["[EDJ][%1] %2 %3", _level, _message, _context];
