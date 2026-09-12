class CfgPatches {
    class EDJ_compat_miniaudio {
        name = "Event DJ compat_miniaudio";
        author = "Event DJ contributors";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.20;
        requiredAddons[] = {"EDJ_audio"};
    };
};
class CfgFunctions {
    class EDJ {
        tag = "EDJ";
        class compat_miniaudio {
            file = "\z\edj\addons\compat_miniaudio\functions";
            class miniaudio {};
        };
    };
};
class CfgEDJAudioProviders {
    class miniaudio { handler = "EDJ_fnc_miniaudio"; capabilities[] = {"play", "stop", "pause", "resume", "seek", "duration", "position", "cue", "volume", "spatial", "status"}; };
};
