class CfgPatches { class EDJ_ui { name = "Event DJ ui"; author = "Event DJ contributors"; units[] = {}; weapons[] = {}; requiredVersion = 2.20; requiredAddons[] = {"EDJ_audio"}; }; };
class CfgFunctions { class EDJ { tag = "EDJ"; class ui { file = "\z\edj\addons\ui\functions";
class open {};
class mount {};
class render {};
class control {};
class unmount {};
class radioDialog {};
}; }; };
class CfgRemoteExec {class Functions {class EDJ_fnc_radioDialog {allowedTargets=0;};};};
#include "dialog.hpp"
