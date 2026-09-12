// Automated SINGLEPLAYER engine checks. These do not replace dedicated multi-client tests.
if (!hasInterface) exitWith {};
[] spawn {
    waitUntil {sleep 0.1; !isNull player && {!isNil "edjOrdinaryLaptop"} && {missionNamespace getVariable ["EDJ_audioReady", false]} && {"main" in EDJ_clientStages}};
    EDJ_debug = true;
    private _check = {
        params ["_name", "_ok"];
        diag_log format ["[EDJ VALIDATION] %1=%2", _name, ["FAIL", "PASS"] select _ok];
    };
    ["client_init", true] call _check;
    call compile preprocessFileLineNumbers "audioModules.sqf";
    ["library_registry_count", count EDJ_libraryOrder == 6] call _check;
    ["library_tracks_discovered", "edj_example_tone_a" in EDJ_libraryRegistry && {"edj_example_tone_b" in EDJ_libraryRegistry}] call _check;
    ["library_stream_discovered", "groove" in EDJ_libraryRegistry && {(EDJ_libraryRegistry get "groove") get "sourceType" == "stream"}] call _check;
    ["library_malformed_rejected", !("edj_malformed" in EDJ_libraryRegistry)] call _check;
    ["library_duplicate_override", (EDJ_libraryRegistry get "groove") get "configClass" == "edj_smoke_override"] call _check;
    ["library_search", count (["deck test", "addon"] call EDJ_fnc_librarySearch) == 2] call _check;
    private _testDeck = ["A", EDJ_libraryRegistry get "edj_example_tone_a"] call EDJ_fnc_deckCreate;
    private _testDeckMap = createHashMapFromArray _testDeck;
    ["deck_load_model", _testDeckMap get "loadedTrackId" == "edj_example_tone_a" && {_testDeckMap get "playbackState" == "LOADED"}] call _check;
    _testDeckMap set ["playbackState", "PLAYING"]; _testDeckMap set ["startOffset", 2]; _testDeckMap set ["startServerTime", serverTime - 3];
    private _derivedPosition = [_testDeckMap] call EDJ_fnc_deckPosition;
    ["native_position_calculation", _derivedPosition >= 4.5 && {_derivedPosition <= 5.5}] call _check;
    ["native_capabilities", {["native", _x] call EDJ_fnc_audioSupportsFeature} count ["play", "stop", "pause", "resume", "seek", "duration", "position", "cue"] == 8] call _check;
    ["stream_capabilities", ["carpinchos", "streaming"] call EDJ_fnc_audioSupportsFeature && {!(["carpinchos", "seek"] call EDJ_fnc_audioSupportsFeature)}] call _check;
    ["workstation_state", edjLaptop getVariable ["EDJ_isWorkstation", false]] call _check;
    ["ordinary_laptop_excluded", !(edjOrdinaryLaptop getVariable ["EDJ_isWorkstation", false])] call _check;
    ["base_patch_present", isClass (configFile >> "CfgPatches" >> "A3_Characters_F")] call _check;
    ["AE3_app_list_function", !isNil "AE3_desktop_fnc_app_list"] call _check;
    ["Carpinchos_function", !isNil "live_radio_manager_fnc_play"] call _check;
    private _stage = EDJ_clientStages get "main";
    ["jip_deck_snapshot", count (_stage get "decks") == 2 && {(_stage get "activeDeck") == "A"} && {(_stage get "queue") isEqualTo []}] call _check;
    private _originalDecks = +(_stage get "decks");
    private _diagDeckA = ["A", EDJ_libraryRegistry get "edj_example_tone_a"] call EDJ_fnc_deckCreate;
    private _diagDeckB = ["B", EDJ_libraryRegistry get "edj_example_tone_b"] call EDJ_fnc_deckCreate;
    ["main", [["decks", [_diagDeckA, _diagDeckB]], ["queue", ["edj_example_tone_a", "edj_example_tone_b"]]], "v02_load_queue"] call EDJ_fnc_commitStage;
    sleep 0.3;
    private _diagStage = EDJ_clientStages get "main";
    ["deck_a_load_transition", (createHashMapFromArray ((_diagStage get "decks") select 0)) get "loadedTrackId" == "edj_example_tone_a"] call _check;
    ["deck_b_load_transition", (createHashMapFromArray ((_diagStage get "decks") select 1)) get "loadedTrackId" == "edj_example_tone_b"] call _check;
    ["queue_add_mutation", (_diagStage get "queue") isEqualTo ["edj_example_tone_a", "edj_example_tone_b"]] call _check;
    ["main", [["queue", ["edj_example_tone_b", "edj_example_tone_a"]]], "v02_queue_reorder"] call EDJ_fnc_commitStage;
    sleep 0.3;
    ["queue_reorder_mutation", ((EDJ_clientStages get "main") get "queue") isEqualTo ["edj_example_tone_b", "edj_example_tone_a"]] call _check;
    ["main", [["queue", ["edj_example_tone_b"]]], "v02_queue_remove"] call EDJ_fnc_commitStage;
    sleep 0.3;
    ["queue_remove_mutation", ((EDJ_clientStages get "main") get "queue") isEqualTo ["edj_example_tone_b"]] call _check;
    private _diagMap = createHashMapFromArray _diagDeckA;
    _diagMap set ["playbackState", "PLAYING"]; _diagMap set ["startServerTime", serverTime]; _diagMap set ["generation", 1];
    private _diagPairs = []; {_diagPairs pushBack [_x, _y];} forEach _diagMap;
    ["main", [["decks", [_diagPairs, _diagDeckB]]], "v02_deck_play"] call EDJ_fnc_commitStage;
    sleep 0.3;
    ["deck_play_transition", (createHashMapFromArray (((EDJ_clientStages get "main") get "decks") select 0)) get "playbackState" == "PLAYING"] call _check;
    _diagMap set ["playbackState", "PAUSED"]; _diagMap set ["startOffset", 4]; _diagPairs = []; {_diagPairs pushBack [_x, _y];} forEach _diagMap;
    ["main", [["decks", [_diagPairs, _diagDeckB]]], "v02_deck_pause"] call EDJ_fnc_commitStage;
    sleep 0.3;
    ["deck_pause_transition", (createHashMapFromArray (((EDJ_clientStages get "main") get "decks") select 0)) get "playbackState" == "PAUSED"] call _check;
    ["seek_clamping", ([-5, 12] call EDJ_fnc_deckClampPosition) == 0 && {([50, 12] call EDJ_fnc_deckClampPosition) == 12}] call _check;
    ["unknown_track_graceful", count (["not.registered"] call EDJ_fnc_libraryGetTrack) == 0] call _check;
    ["main", [["decks", _originalDecks], ["queue", []]], "v02_diagnostic_restore"] call EDJ_fnc_commitStage;
    sleep 0.3;
    ["queue_clear_mutation", ((EDJ_clientStages get "main") get "queue") isEqualTo []] call _check;
    // Singleplayer has no remoteExecutedOwner transport context. Preserve the
    // production guard and drive state through the internal server boundary.
    ["main", "play", 0] call EDJ_fnc_request;
    sleep 0.5;
    ["singleplayer_transport_guard", (EDJ_stages get "main") get "playback" == "stopped"] call _check;
    ["main", [["operator", player], ["operatorUID", "SP_TEST"]], "smoke_claim"] call EDJ_fnc_commitStage;
    sleep 0.5;
    ["direct_claim_setup", (EDJ_stages get "main") get "operator" == player] call _check;
    private _before = (EDJ_stages get "main") get "masterVolume";
    ["main", "volume", "invalid"] remoteExecCall ["EDJ_fnc_serverRequest", 2];
    sleep 0.5;
    ["singleplayer_malformed_transport_guard", (EDJ_stages get "main") get "masterVolume" == _before] call _check;
    ["main", [["masterVolume", 0.25]], "smoke_volume"] call EDJ_fnc_commitStage;
    sleep 0.5;
    ["direct_volume_setup", (EDJ_stages get "main") get "masterVolume" == 0.25] call _check;
    ["main", [["playback", "playing"], ["startServerTime", serverTime], ["lastPlay", serverTime], ["playGeneration", 1]], "smoke_play"] call EDJ_fnc_commitStage;
    sleep 3;
    _stage = EDJ_clientStages get "main";
    ["direct_play_setup", _stage get "playback" == "playing"] call _check;
    ["main", [["masterVolume", 0.75]], "smoke_live_volume"] call EDJ_fnc_commitStage;
    sleep 0.5;
    ["live_volume_update", (EDJ_stages get "main") get "masterVolume" == 0.75] call _check;
    ["main"] call EDJ_fnc_debugStage;
    private _generation = _stage get "playGeneration";
    for "_i" from 1 to 5 do {["main", [["playback", "playing"], ["playGeneration", _generation]], "smoke_duplicate_play"] call EDJ_fnc_commitStage; sleep 0.3;};
    ["duplicate_play_generation", (EDJ_stages get "main") get "playGeneration" == _generation] call _check;
    // Verify actual local source status, not just server intent.
    sleep 12;
    private _status = ["carpinchos", "status", _stage] call EDJ_fnc_audioCall;
    private _sourceId = format ["EDJ_%1_%2", _stage get "stageId", _stage get "playGeneration"];
    private _delayedProbe = "live_radio" callExtension ["source:exists", [_sourceId]];
    diag_log format ["[EDJ VALIDATION] carpinchos_maps=%1", [
        _sourceId in live_radio_manager_sources,
        live_radio_manager_sourcesStatus getOrDefault [_sourceId, "missing"],
        live_radio_manager_sourcesTitles getOrDefault [_sourceId, "missing"],
        _delayedProbe
    ]];
    diag_log format ["[EDJ VALIDATION] stream_observation=%1 (not an audibility assertion)", _status];
    ["main", [["playback", "stopped"]], "smoke_stop"] call EDJ_fnc_commitStage;
    sleep 1;
    ["stop_request", (EDJ_stages get "main") get "playback" == "stopped"] call _check;
    ["source_destroyed", (["carpinchos", "status", _stage] call EDJ_fnc_audioCall) select 1 == "stopped"] call _check;
    // Controlled failure and recovery use the internal boundary only in this
    // diagnostic mission; production V0.2 source changes resolve registered IDs.
    ["main", [["audioSource", "edj_unreachable"], ["playback", "playing"], ["startServerTime", serverTime], ["playGeneration", 2]], "smoke_failure"] call EDJ_fnc_commitStage;
    sleep 18;
    private _failedStage = EDJ_clientStages get "main";
    private _failedStatus = ["carpinchos", "status", _failedStage] call EDJ_fnc_audioCall;
    diag_log format ["[EDJ VALIDATION] failure_observation=%1", _failedStatus];
    ["failure_error_state", (_failedStatus select 1) == "offline" && {(EDJ_audioInstances get "main") get "phase" == "ERROR"}] call _check;
    ["failure_generation_latched", (EDJ_stages get "main") get "playGeneration" == 2] call _check;
    ["main", [["playback", "stopped"]], "smoke_failure_stop"] call EDJ_fnc_commitStage;
    sleep 1;
    ["main", [["audioSource", "groove"], ["playback", "playing"], ["startServerTime", serverTime], ["playGeneration", 3]], "smoke_recovery"] call EDJ_fnc_commitStage;
    sleep 8;
    private _recoveredStage = EDJ_clientStages get "main";
    private _recoveredStatus = ["carpinchos", "status", _recoveredStage] call EDJ_fnc_audioCall;
    diag_log format ["[EDJ VALIDATION] recovery_observation=%1", _recoveredStatus];
    ["failure_recovery", (_recoveredStatus select 1) == "online"] call _check;
    ["main", [["playback", "stopped"]], "smoke_recovery_stop"] call EDJ_fnc_commitStage;
    sleep 1;
    for "_i" from 1 to 3 do {
        ["main"] call EDJ_fnc_open;
        sleep 0.4;
        private _group = (findDisplay 8700) displayCtrl 8701;
        [format ["UI_open_%1", _i], !isNull _group] call _check;
        [_group, "main"] call EDJ_fnc_mount;
        [format ["UI_remount_controls_%1", _i], count (_group getVariable ["EDJ_controls", []]) >= 30 && {count (_group getVariable ["EDJ_namedControls", createHashMap]) >= 25}] call _check;
        closeDialog 0;
        sleep 0.4;
        [format ["UI_closed_%1", _i], isNull findDisplay 8700] call _check;
        [format ["cue_cleanup_%1", _i], !("main" in EDJ_cueInstances)] call _check;
    };
    if (!isNil "AE3_desktop_fnc_app_list") then {
        private _apps = [] call AE3_desktop_fnc_app_list;
        private _matches = _apps select {(_x param [0, ""]) isEqualTo "EDJ_EventDJ"};
        ["AE3_registry_singleton", (count _matches) isEqualTo 1] call _check;
        private _registryFieldsValid = false;
        if ((count _matches) isEqualTo 1) then {
            private _app = _matches select 0;
            _registryFieldsValid =
                ((_app param [1, ""]) isEqualTo "Event DJ") &&
                {(_app param [2, ""]) isEqualTo "EDJ_fnc_ae3App"} &&
                {abs ((_app param [3, 0]) - 1) < 0.001} &&
                {abs ((_app param [4, 0]) - 1) < 0.001} &&
                {!(_app param [5, true])} &&
                {_app param [6, false]};
        };
        ["AE3_registry_fields", _registryFieldsValid] call _check;
        private _extApps = missionNamespace getVariable ["AE3_desktop_extApps", []];
        private _extMatches = _extApps select {(_x getOrDefault ["id", ""]) isEqualTo "edj_event_dj"};
        private _extValid = false;
        if ((count _extMatches) isEqualTo 1) then {
            private _extra = (_extMatches select 0) getOrDefault ["extra", createHashMap];
            _extValid =
                ((_extra getOrDefault ["requiresVar", []]) isEqualTo ["EDJ_isWorkstation", true]) &&
                {_extra getOrDefault ["showOnDesktop", false]} &&
                {(_extra getOrDefault ["openCommand", ""]) isEqualTo "edj_open_event_dj"};
        };
        ["AE3_web_launcher", _extValid] call _check;
        // Exercise the installed web-desktop extension command that transitions
        // into the preserved native Event DJ window.
        [edjLaptop] call AE3_desktop_fnc_desktop_openWeb;
        sleep 0.5;
        [edjLaptop, "", createHashMap, "", "edj_open_event_dj"] call EDJ_fnc_ae3OpenWebApp;
        sleep 1.5;
        private _desktop = findDisplay 17000;
        ["AE3_web_bridge_desktop", !isNull _desktop] call _check;
        private _session = uiNamespace getVariable ["AE3_desktop_session", createHashMap];
        private _windows = _session getOrDefault ["windows", createHashMap];
        private _bridgeWindows = [];
        {
            if (((_windows get _x) getOrDefault ["app", ""]) isEqualTo "EDJ_EventDJ") then {
                _bridgeWindows pushBack _x;
            };
        } forEach keys _windows;
        ["AE3_web_bridge_window", (count _bridgeWindows) isEqualTo 1] call _check;
        if (_bridgeWindows isNotEqualTo []) then {
            private _win = _windows get (_bridgeWindows select 0);
            private _pos = ctrlPosition (_win get "group");
            ["AE3_fullscreen_bounds", abs ((_pos select 0) - safeZoneX) < 0.001 && {abs ((_pos select 1) - safeZoneY) < 0.001} && {abs ((_pos select 2) - safeZoneW) < 0.001} && {abs ((_pos select 3) - safeZoneH) < 0.001}] call _check;
            private _body = uiNamespace getVariable ["EDJ_ae3_" + str (_bridgeWindows select 0), controlNull];
            ["AE3_content_below_titlebar", !isNull _body && {((ctrlPosition _body) select 1) >= 0.04}] call _check;
            [_bridgeWindows select 0] call AE3_desktop_fnc_wm_closeWindow;
        };

        // The native helper is deliberately hidden from every native desktop.
        private _icons = if (isNull _desktop) then {[]} else {
            (allControls _desktop) select {(ctrlText _x) isEqualTo "Event DJ"}
        };
        ["AE3_native_helper_hidden", (count _icons) isEqualTo 0] call _check;
        for "_i" from 1 to 3 do {
            private _window = ["EDJ_EventDJ"] call AE3_desktop_fnc_wm_createWindow;
            [format ["AE3_window_%1", _i], _window >= 0] call _check;
            sleep 0.4;
            [_window] call AE3_desktop_fnc_wm_closeWindow;
        };
        closeDialog 0;
    };
    ["main", [["operator", objNull], ["operatorUID", ""]], "smoke_release"] call EDJ_fnc_commitStage;
    sleep 0.5;
    ["release_request", isNull ((EDJ_stages get "main") get "operator")] call _check;
    diag_log "[EDJ VALIDATION] COMPLETE (inspect individual results and RPT errors)";
    endMission "END1";
};
