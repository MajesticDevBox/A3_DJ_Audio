// initServer.sqf may execute before CfgFunctions postInit. Never reset in postInit.
if (isServer) then {
    EDJ_stages = createHashMap;
    EDJ_rate = createHashMap;
    EDJ_denials = createHashMap;
};
if (hasInterface) then {
    EDJ_clientStages = createHashMap;
    EDJ_audioInstances = createHashMap;
    EDJ_audioReady = false;
    EDJ_providers = createHashMap;
    EDJ_carpinchosSources = createHashMap;
    EDJ_cueInstances = createHashMap;
};
