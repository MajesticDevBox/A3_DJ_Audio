class CfgPatches { class EDJ_audio { name = "Event DJ audio"; author = "Event DJ contributors"; units[] = {}; weapons[] = {}; requiredVersion = 2.20; requiredAddons[] = {"EDJ_core"}; }; };
class CfgFunctions { class EDJ { tag = "EDJ"; class audio { file = "\z\edj\addons\audio\functions";
class audioInit {};
class audioCall {};
class audioSupportsFeature {};
class audioApply {};
class audioTick {};
class audioSpatial {};
class audioCue {};
class native {};
class streamGain {};
}; }; };
class CfgEventDJStreams {
 class groove {
  id = "groove";
  displayName = "SomaFM Groove Salad";
  description = "External test stream";
  backend = "carpinchos";
  url = "https://ice2.somafm.com/groovesalad-128-mp3";
  compatibilityVersion = 2;
 };
 class rock {
  id = "rock";
  displayName = "83.1 Misfit FM";
  description = "External test stream";
  backend = "carpinchos";
  url = "https://radio.shgmilsim.com/listen/83.1_misfit_fm/radio.mp3";
  compatibilityVersion = 2;
 };
};
class CfgEventDJTracks {};
class CfgEDJAudioProviders {
 class native { handler = "EDJ_fnc_native"; capabilities[] = {"play", "stop", "pause", "resume", "seek", "duration", "position", "spatial", "cue", "status"}; };
};
