class RscText;
class RscControlsGroupNoScrollbars;
class EDJ_Dialog {
 idd = 8700; movingEnable = 0; enableSimulation = 1;
 onUnload = "[(_this select 0) displayCtrl 8701] call EDJ_fnc_unmount";
 class controlsBackground {
  class Background: RscText {idc=-1; x="safeZoneX"; y="safeZoneY"; w="safeZoneW"; h="safeZoneH"; colorBackground[]={0.025,0.035,0.05,0.98};};
 };
 class controls {
  class Body: RscControlsGroupNoScrollbars {idc=8701; x="safeZoneX + 0.02"; y="safeZoneY + 0.02"; w="safeZoneW - 0.04"; h="safeZoneH - 0.04";};
 };
};
