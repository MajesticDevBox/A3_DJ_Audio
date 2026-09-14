class CfgFactionClasses {
 class EDJ_Modules {displayName="Event DJ"; priority=2; side=7;};
};
class CfgVehicles {
 class Logic;
 class Module_F: Logic {class ArgumentsBaseUnits; class ModuleDescription;};
 class EDJ_Module_PA: Module_F {
  scope=2; scopeCurator=0; displayName="EDJ: Main PA"; category="EDJ_Modules";
  function="EDJ_fnc_moduleAudio"; functionPriority=10; isGlobal=0; isTriggerActivated=0; isDisposable=0;
  class Arguments: ArgumentsBaseUnits {
   class StageId {displayName="Stage ID"; description="Unique stage ID (letters, digits, underscore, hyphen)."; typeName="STRING"; defaultValue="main";};
   class Source {displayName="Audio source ID"; description="Registered stream or music-pack track ID. See CfgEventDJStreams / CfgEventDJTracks."; typeName="STRING"; defaultValue="groove";};
   class Volume {displayName="Volume (0-1)"; description="Initial master volume."; typeName="NUMBER"; defaultValue=1;};
   class Gain {displayName="PA gain (0-10)"; description="Output gain multiplier. Start at 2 and audition."; typeName="NUMBER"; defaultValue=2;};
   class Range {displayName="Native range (metres)"; description="Native tracks only. Stream range is limited by Carpinchos sound range setting."; typeName="NUMBER"; defaultValue=500;};
   class Cone {displayName="Stream front cone (degrees)"; description="360 is omnidirectional. Stream-only soft attenuation toward the rear, using the PA prop facing."; typeName="NUMBER"; defaultValue=360;};
  };
  class ModuleDescription: ModuleDescription {
   description="Sync one Event DJ Workstation module and up to eight Stage Speaker Arrays or one physical PA prop. Miniaudio uses one spatial emitter per nonempty array, sharing one track timeline. Arrays take priority over the prop; without arrays the prop emits. Native and Carpinchos retain their single-prop output.";
   sync[]={"Anything"};
  };
 };
 class EDJ_Module_SpeakerArray: Module_F {
  scope=2; scopeCurator=0; displayName="EDJ: Stage Speaker Array"; category="EDJ_Modules";
  class ModuleDescription: ModuleDescription {
   description="Sync speaker cabinets and one Main PA. Miniaudio creates one spatial emitter at the live cabinet centroid, facing this module's direction. Cabinets do not create individual sources. All arrays share a sample timeline and divide stage gain equally. Maximum eight arrays per PA.";
   sync[]={"Anything"};
  };
 };
 class EDJ_Module_Radio: EDJ_Module_PA {
  scopeCurator=2; displayName="EDJ: Radio / Music Player"; curatorCanAttach=1;
  class Arguments: ArgumentsBaseUnits {
   class Source {displayName="Audio source ID"; description="Registered stream or music-pack track ID."; typeName="STRING"; defaultValue="groove";};
   class Volume {displayName="Volume (0-1)"; description="Initial playback volume."; typeName="NUMBER"; defaultValue=1;};
   class Gain {displayName="Gain (0-10)"; description="Output gain multiplier."; typeName="NUMBER"; defaultValue=1;};
   class Range {displayName="Native range (metres)"; description="Native tracks only; streams use the Carpinchos sound range setting."; typeName="NUMBER"; defaultValue=50;};
  };
  class ModuleDescription: ModuleDescription {
   description="Eden: sync exactly one prop, set source ID and volume. Zeus: place on a prop and choose a nearby target, source and volume in the dialog. Starts playback automatically.";
   sync[]={"Anything"};
  };
 };
};
