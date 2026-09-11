"""Generate CfgVehicles and CfgModels from the reviewed ingestion plan."""
from __future__ import annotations
import pathlib, sys
ROOT=pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from asset_ingestion_plan import ASSETS

CATEGORIES={
"EDJ_AudioLineArrays":"Audio - Line Arrays","EDJ_AudioSpeakers":"Audio - Speakers","EDJ_AudioSubwoofers":"Audio - Subwoofers","EDJ_AudioMonitors":"Audio - Monitors","EDJ_AudioPA":"Audio - PA Equipment",
"EDJ_DJPlayers":"DJ Equipment - Players","EDJ_DJMixers":"DJ Equipment - Mixers",
"EDJ_DJControllers":"DJ Equipment - Controllers","EDJ_AudioConsoles":"Audio - Mixing Consoles",
"EDJ_StageComplete":"Stages - Complete Stages","EDJ_StageDecks":"Stages - Decks","EDJ_StageRisers":"Stages - Risers","EDJ_StageStairs":"Stages - Stairs","EDJ_StageStructures":"Stages - Structures",
"EDJ_TrussStraight":"Truss & Rigging - Straight","EDJ_TrussCorners":"Truss & Rigging - Corners","EDJ_TrussJunctions":"Truss & Rigging - Junctions","EDJ_TrussTowers":"Truss & Rigging - Towers","EDJ_TrussRigging":"Truss & Rigging - Rigging",
"EDJ_LightingMoving":"Lighting - Moving Heads","EDJ_LightingPAR":"Lighting - PAR","EDJ_LightingWash":"Lighting - Wash & Blinders","EDJ_LightingSpot":"Lighting - Spotlights","EDJ_LightingProjectors":"Lighting - Projectors & Lasers",
"EDJ_ScreensLED":"Screens & Video - LED Panels","EDJ_ScreensMain":"Screens & Video - Main Screens","EDJ_ScreensSide":"Screens & Video - Side Screens","EDJ_ScreensProjection":"Screens & Video - Projection Screens",
"EDJ_ProductionRacks":"Production - Racks & Consoles","EDJ_ProductionBarriers":"Production - Barriers","EDJ_ProductionStands":"Production - Stands",
}

units=',\n            '.join(f'"{a["class"]}"' for a in ASSETS)
subcats='\n'.join(f'    class {key} {{ displayName = "{value}"; }};' for key,value in CATEGORIES.items() if any(a['category']==key for a in ASSETS))
classes=[]
for a in ASSETS:
    path=f"\\z\\edj\\addons\\assets\\models\\{a['file']}.p3d"
    simple='' if a.get('animated') else f'\n        simpleObject = "{path}";'
    classes.append(f'''    class {a['class']}: EDJ_Asset_Base {{
        scope = 2;
        scopeCurator = 2;
        displayName = "{a['display']}";
        editorSubcategory = "{a['category']}";
        model = "{path}";{simple}
    }};''')
config=f'''class CfgPatches {{
    class EDJ_assets {{
        name = "Event DJ assets";
        author = "Event DJ contributors";
        requiredVersion = 2.20;
        requiredAddons[] = {{"A3_Data_F"}};
        units[] = {{
            {units}
        }};
        weapons[] = {{}};
    }};
}};
class CfgEditorCategories {{ class EDJ_Assets {{ displayName = "Event DJ"; }}; }};
class CfgEditorSubcategories {{
{subcats}
}};
class CfgVehicles {{
    class ThingX;
    class EDJ_Asset_Base: ThingX {{
        scope = 0; scopeCurator = 0;
        author = "Event DJ contributors";
        editorCategory = "EDJ_Assets";
        simulation = "thingX";
        armor = 100;
        destrType = "DestructNo";
    }};
{chr(10).join(classes)}
}};
'''
(ROOT/'addons/assets/config.cpp').write_text(config,encoding='utf-8')

models=[]
for a in ASSETS:
    skeleton='EDJ_MovingHeadSkeleton' if a.get('animated') else ''
    sections=[]
    if a.get('animated'): sections += ['light_pan','light_tilt']
    if a.get('screen'): sections += ['screen_surface']
    section_text='{' + ', '.join(f'"{s}"' for s in sections) + '}'
    models.append(f'''    class {a['file']}: Default {{
        skeletonName = "{skeleton}";
        sections[] = {section_text};
        class Animations {{}};
    }};''')
model_cfg=f'''class CfgSkeletons {{
    class EDJ_MovingHeadSkeleton {{
        isDiscrete = 0; skeletonInherit = "";
        skeletonBones[] = {{"light_pan", "", "light_tilt", "light_pan"}};
    }};
}};
class CfgModels {{
    class Default {{ sectionsInherit = ""; sections[] = {{}}; skeletonName = ""; }};
{chr(10).join(models)}
}};
'''
(ROOT/'addons/assets/model.cfg').write_text(model_cfg,encoding='utf-8')
print(f"Generated config for {len(ASSETS)} production assets and {len(set(a['category'] for a in ASSETS))} populated subcategories")
