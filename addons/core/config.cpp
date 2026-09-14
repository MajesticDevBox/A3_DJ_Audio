class CfgPatches { class EDJ_core { name = "Event DJ core"; author = "Event DJ contributors"; units[] = {"EDJ_Module_PA", "EDJ_Module_SpeakerArray", "EDJ_Module_Radio"}; weapons[] = {}; requiredVersion = 2.20; requiredAddons[] = {"EDJ_main", "A3_Modules_F"}; }; };
class CfgFunctions { class EDJ { tag = "EDJ"; class core { file = "\z\edj\addons\core\functions";
class libraryInit {preInit = 1;};
class libraryGetAll {};
class libraryGetTrack {};
class librarySearch {};
class libraryFilter {};
class deckCreate {};
class deckPosition {};
class deckClampPosition {};
class registerStage {};
class request {};
class serverRequest {};
class publish {};
class receive {};
class sync {};
class maintain {};
class hasEmitter {};
class commitStage {};
class deny {};
class debugStage {};
class moduleAudio {};
class configureRadio {};
}; }; };
class CfgRemoteExec {
 class Functions {
  class EDJ_fnc_serverRequest { allowedTargets = 2; };
  class EDJ_fnc_sync { allowedTargets = 2; };
  class EDJ_fnc_receive { allowedTargets = 0; };
  class EDJ_fnc_configureRadio { allowedTargets = 2; };
 };
};
#include "modules.hpp"
