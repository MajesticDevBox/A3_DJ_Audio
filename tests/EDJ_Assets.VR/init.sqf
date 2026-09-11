private _classes = [
    "EDJ_Speaker_LineArray_01",
    "EDJ_Speaker_Sub_01",
    "EDJ_Truss_Straight_2m_01",
    "EDJ_StageDeck_2x2_01",
    "EDJ_Light_MovingHead_01",
    "EDJ_Stage_Complete_01"
];

{
    private _config = configFile >> "CfgVehicles" >> _x;
    private _model = getText (_config >> "model");
    diag_log format [
        "[EDJ ASSET VALIDATION] class=%1 exists=%2 scope=%3 scopeCurator=%4 model=%5",
        _x,
        isClass _config,
        getNumber (_config >> "scope"),
        getNumber (_config >> "scopeCurator"),
        _model
    ];
} forEach _classes;

private _allEDJAssets = ("getNumber (_x >> 'scope') == 2 && {getText (_x >> 'editorCategory') == 'EDJ_Assets'}" configClasses (configFile >> "CfgVehicles"));
diag_log format ["[EDJ ASSET VALIDATION] representative packs loaded; public EDJ asset count=%1; human visual and collision checks remain required", count _allEDJAssets];
