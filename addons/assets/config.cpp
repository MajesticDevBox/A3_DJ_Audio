class CfgPatches {
    class EDJ_assets {
        name = "Event DJ assets";
        author = "Event DJ contributors";
        requiredVersion = 2.20;
        requiredAddons[] = {"A3_Data_F"};
        units[] = {
            "EDJ_Speaker_HornArray_Curved_03",
            "EDJ_Speaker_LineArray_Curved_04",
            "EDJ_Speaker_LineArray_Straight_04",
            "EDJ_Speaker_HornArray_Straight_03",
            "EDJ_Speaker_SubwooferArray_Straight_03",
            "EDJ_Speaker_LineArray_CurvedStack_08",
            "EDJ_DJ_MediaPlayer_01",
            "EDJ_DJ_Controller_01",
            "EDJ_Audio_MixingConsole_01",
            "EDJ_DJ_PerformanceKeyboard_01"
        };
        weapons[] = {};
    };
};
class CfgEditorCategories { class EDJ_Assets { displayName = "Event DJ"; }; };
class CfgEditorSubcategories {
    class EDJ_AudioLineArrays { displayName = "Audio - Line Arrays"; };
    class EDJ_AudioSpeakers { displayName = "Audio - Speakers"; };
    class EDJ_AudioSubwoofers { displayName = "Audio - Subwoofers"; };
    class EDJ_DJPlayers { displayName = "DJ Equipment - Players"; };
    class EDJ_DJMixers { displayName = "DJ Equipment - Mixers"; };
    class EDJ_DJControllers { displayName = "DJ Equipment - Controllers"; };
    class EDJ_AudioConsoles { displayName = "Audio - Mixing Consoles"; };
};
class CfgVehicles {
    class ThingX;
    class EDJ_Asset_Base: ThingX {
        scope = 0; scopeCurator = 0;
        author = "Event DJ contributors";
        editorCategory = "EDJ_Assets";
        simulation = "thingX";
        armor = 100;
        destrType = "DestructNo";
    };
    class EDJ_Speaker_HornArray_Curved_03: EDJ_Asset_Base {
        scope = 2;
        scopeCurator = 2;
        displayName = "Curved Horn Array 3 Cabinet 01";
        editorSubcategory = "EDJ_AudioSpeakers";
        model = "\z\edj\addons\assets\models\speaker_hornarray_curved_03.p3d";
        simpleObject = "\z\edj\addons\assets\models\speaker_hornarray_curved_03.p3d";
    };
    class EDJ_Speaker_LineArray_Curved_04: EDJ_Asset_Base {
        scope = 2;
        scopeCurator = 2;
        displayName = "Curved Line Array 4 Cabinet 01";
        editorSubcategory = "EDJ_AudioLineArrays";
        model = "\z\edj\addons\assets\models\speaker_linearray_curved_04.p3d";
        simpleObject = "\z\edj\addons\assets\models\speaker_linearray_curved_04.p3d";
    };
    class EDJ_Speaker_LineArray_Straight_04: EDJ_Asset_Base {
        scope = 2;
        scopeCurator = 2;
        displayName = "Straight Line Array 4 Cabinet 01";
        editorSubcategory = "EDJ_AudioLineArrays";
        model = "\z\edj\addons\assets\models\speaker_linearray_straight_04.p3d";
        simpleObject = "\z\edj\addons\assets\models\speaker_linearray_straight_04.p3d";
    };
    class EDJ_Speaker_HornArray_Straight_03: EDJ_Asset_Base {
        scope = 2;
        scopeCurator = 2;
        displayName = "Straight Horn Array 3 Cabinet 01";
        editorSubcategory = "EDJ_AudioSpeakers";
        model = "\z\edj\addons\assets\models\speaker_hornarray_straight_03.p3d";
        simpleObject = "\z\edj\addons\assets\models\speaker_hornarray_straight_03.p3d";
    };
    class EDJ_Speaker_SubwooferArray_Straight_03: EDJ_Asset_Base {
        scope = 2;
        scopeCurator = 2;
        displayName = "Straight Subwoofer Array 3 Cabinet 01";
        editorSubcategory = "EDJ_AudioSubwoofers";
        model = "\z\edj\addons\assets\models\speaker_subwooferarray_straight_03.p3d";
        simpleObject = "\z\edj\addons\assets\models\speaker_subwooferarray_straight_03.p3d";
    };
    class EDJ_Speaker_LineArray_CurvedStack_08: EDJ_Asset_Base {
        scope = 2;
        scopeCurator = 2;
        displayName = "Curved Line Array 8 Cabinet Stack 01";
        editorSubcategory = "EDJ_AudioLineArrays";
        model = "\z\edj\addons\assets\models\speaker_linearray_curvedstack_08.p3d";
        simpleObject = "\z\edj\addons\assets\models\speaker_linearray_curvedstack_08.p3d";
    };
    class EDJ_DJ_MediaPlayer_01: EDJ_Asset_Base {
        scope = 2;
        scopeCurator = 2;
        displayName = "DJ Media Player 01";
        editorSubcategory = "EDJ_DJPlayers";
        model = "\z\edj\addons\assets\models\dj_mediaplayer_01.p3d";
        simpleObject = "\z\edj\addons\assets\models\dj_mediaplayer_01.p3d";
    };
    class EDJ_DJ_Controller_01: EDJ_Asset_Base {
        scope = 2;
        scopeCurator = 2;
        displayName = "Dual-Deck DJ Controller 01";
        editorSubcategory = "EDJ_DJMixers";
        model = "\z\edj\addons\assets\models\dj_controller_01.p3d";
        simpleObject = "\z\edj\addons\assets\models\dj_controller_01.p3d";
    };
    class EDJ_Audio_MixingConsole_01: EDJ_Asset_Base {
        scope = 2;
        scopeCurator = 2;
        displayName = "Digital Audio Mixing Console 01";
        editorSubcategory = "EDJ_AudioConsoles";
        model = "\z\edj\addons\assets\models\audio_mixingconsole_01.p3d";
        simpleObject = "\z\edj\addons\assets\models\audio_mixingconsole_01.p3d";
    };
    class EDJ_DJ_PerformanceKeyboard_01: EDJ_Asset_Base {
        scope = 2;
        scopeCurator = 2;
        displayName = "DJ Performance Keyboard 01";
        editorSubcategory = "EDJ_DJControllers";
        model = "\z\edj\addons\assets\models\dj_performancekeyboard_01.p3d";
        simpleObject = "\z\edj\addons\assets\models\dj_performancekeyboard_01.p3d";
    };
};
