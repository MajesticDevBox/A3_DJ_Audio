class CfgPatches {
    class EDJ_example_music_pack {
        name = "Event DJ example music pack";
        author = "Event DJ contributors";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.20;
        requiredAddons[] = {"EDJ_audio"};
    };
};
class CfgEventDJTracks {
    class EDJ_ExampleTone_A {
        id = "edj_example_tone_a";
        title = "Deck Test Tone A";
        artist = "Event DJ";
        album = "V0.2 Development Signals";
        genre = "Test Signal";
        duration = 12;
        bpm = 120;
        sourceType = "addon";
        backend = "native";
        file = "\z\edj\addons\example_music_pack\audio\edj_test_tone_a.ogg";
        originatingAddon = "EDJ_example_music_pack";
        compatibilityVersion = 2;
    };
    class EDJ_ExampleTone_B {
        id = "edj_example_tone_b";
        title = "Deck Test Tone B";
        artist = "Event DJ";
        album = "V0.2 Development Signals";
        genre = "Test Signal";
        duration = 16;
        bpm = 128;
        sourceType = "addon";
        backend = "native";
        file = "\z\edj\addons\example_music_pack\audio\edj_test_tone_b.ogg";
        originatingAddon = "EDJ_example_music_pack";
        compatibilityVersion = 2;
    };
};
