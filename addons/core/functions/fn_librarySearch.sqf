params [["_query", "", [""]], ["_sourceType", "all", [""]]];
private _needle = toLower _query;
private _result = [];
{
    private _entry = EDJ_libraryRegistry get _x;
    private _matchesType = _sourceType == "all" || {_entry get "sourceType" == _sourceType};
    private _haystack = toLower format ["%1 %2 %3 %4", _entry get "title", _entry get "artist", _entry get "album", _entry get "genre"];
    if (_matchesType && {_needle == "" || {_haystack find _needle >= 0}}) then {_result pushBack _entry;};
} forEach EDJ_libraryOrder;
_result
