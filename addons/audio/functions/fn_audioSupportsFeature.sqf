params ["_backend", "_feature"];
private _provider = EDJ_providers getOrDefault [_backend, [{}, []]];
_feature in (_provider select 1)
