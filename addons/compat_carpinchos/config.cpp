class CfgPatches { class EDJ_compat_carpinchos { name = "Event DJ compat_carpinchos"; author = "Event DJ contributors"; units[] = {}; weapons[] = {}; requiredVersion = 2.20; requiredAddons[] = {"EDJ_audio", "live_radio_manager"}; }; };
class CfgFunctions { class EDJ { tag = "EDJ"; class compat_carpinchos { file = "\z\edj\addons\compat_carpinchos\functions";
class carpinchos {};
}; }; };
class CfgEDJAudioProviders {
 class carpinchos { handler = "EDJ_fnc_carpinchos"; capabilities[] = {"play", "stop", "volume", "streaming", "metadata", "spatial", "status"}; };
};
