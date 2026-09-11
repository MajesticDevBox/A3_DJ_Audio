class CfgPatches {
    class EDJ_compat_ae3 {
        name = "Event DJ compat_ae3";
        author = "Event DJ contributors";
        units[] = {"EDJ_Module_AddEventDJWorkstation"};
        weapons[] = {};
        requiredVersion = 2.20;
        requiredAddons[] = {"EDJ_ui", "ae3_armaos", "ae3_desktop"};
    };
};

class CfgFunctions {
    class EDJ {
        tag = "EDJ";
        class compat_ae3 {
            file = "\z\edj\addons\compat_ae3\functions";
            class ae3Init {postInit = 1;};
            class ae3App {};
            class ae3OpenWebApp {};
            class isAE3Laptop {};
            class moduleWorkstation {};
        };
    };
};

class CfgFactionClasses {
    class EDJ_Modules {
        displayName = "Event DJ";
        priority = 2;
        side = 7;
    };
};

class CfgVehicles {
    class Logic;
    class Module_F: Logic {
        class ModuleDescription;
    };

    class EDJ_Module_AddEventDJWorkstation: Module_F {
        scope = 2;
        scopeCurator = 0;
        displayName = "EDJ: Add Event DJ Workstation";
        category = "EDJ_Modules";
        function = "EDJ_fnc_moduleWorkstation";
        functionPriority = 1;
        isGlobal = 1;
        isTriggerActivated = 0;
        isDisposable = 0;
        is3DEN = 0;

        class ModuleDescription: ModuleDescription {
            description = "Synchronize to exactly one AE3 laptop to install the Event DJ armaOS application.";
            sync[] = {"Anything"};
            class Anything {
                description = "One compatible AE3 computer or laptop";
                displayName = "AE3 laptop";
                icon = "iconObject_1x1";
                position = 1;
                direction = 1;
                optional = 0;
                duplicate = 0;
                synced[] = {"Anything"};
            };
        };
    };
};
