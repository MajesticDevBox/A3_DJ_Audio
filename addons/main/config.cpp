class CfgPatches { class EDJ_main { name = "Event DJ main"; author = "Event DJ contributors"; units[] = {}; weapons[] = {}; requiredVersion = 2.20; requiredAddons[] = {"cba_main", "cba_common", "cba_events"}; }; };
class CfgFunctions { class EDJ { tag = "EDJ"; class main { file = "\z\edj\addons\main\functions";
class log {};
class initState {preInit = 1;};
class init {postInit = 1;};
}; }; };
