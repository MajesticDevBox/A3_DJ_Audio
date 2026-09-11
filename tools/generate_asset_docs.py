"""Generate production manifest and attribution rows for every production asset."""
from __future__ import annotations
import json,pathlib,sys
ROOT=pathlib.Path(__file__).resolve().parents[1]; sys.path.insert(0,str(ROOT/'tools'))
from asset_ingestion_plan import ASSETS,SOURCE_FILE_TO_PACK,SOURCE_PACKS
META={
'raveSpace':('konstantin-andoerfer','https://www.cgtrader.com/free-3d-models/electronics/audio/ravespace-audio-systems','CGTrader Royalty Free License (no AI)'),
'truss':('sibawalkece','https://www.cgtrader.com/free-3d-models/industrial/other/truss-system-line-array','CGTrader Royalty Free License (no AI); creator credit required'),
'eventStage':('designerkrishnan','https://www.cgtrader.com/free-3d-models/exterior/stadium/event-stage-setup','CGTrader Royalty Free License (no AI); creator credit required'),
'arenaStage':('ogilko','https://www.cgtrader.com/free-3d-models/exterior/exterior-public/arena-stage-venue-props-pack-modular-event-stage','CGTrader Royalty Free License (no AI); creator credit required'),
'lighting':('Yousef696','https://www.cgtrader.com/free-3d-models/electronics/other/various-projection-sound-and-lighting-devices-for-parti','CGTrader Royalty Free License (no AI)'),
'djMixer1':('User-supplied local source','Local source file','Redistribution provenance pending documentation'),
'djMixer2':('User-supplied local source','Local source file','Redistribution provenance pending documentation'),
'audioEquipment':('User-supplied local source','Local source file','Redistribution provenance pending documentation'),
}
report_path=ROOT/'asset_work/asset-build-report.json'; report={}
if report_path.exists(): report={r['class']:r for r in json.loads(report_path.read_text())['assets']}
validation_path=ROOT/'asset_work/validation/p3d-validation.json'
if validation_path.exists():
    by_model={row['model']:row for row in json.loads(validation_path.read_text())['models']}
    for asset_spec in ASSETS:
        row=by_model.get(f"{asset_spec['file']}.p3d")
        if row:
            report[asset_spec['class']]={'class':asset_spec['class'],'dimensions':row['dimensions']}

base=(ROOT/'docs/ASSET_MANIFEST.md').read_text(encoding='utf-8')
marker='\n## Production conversion manifest\n'
base=base.split(marker)[0].rstrip()+marker
lines=[base,'',f'The fresh production plan contains **{len(ASSETS)} placeable production assets**. Each item below is generated from `tools/asset_ingestion_plan.py`; the preserved source library is recorded in `ASSET_SOURCE_INVENTORY.md`.','']
for a in ASSETS:
 p=SOURCE_FILE_TO_PACK[a['source']]; creator,url,license_name=META[p]; built=report.get(a['class'],{}); dims=' x '.join(map(str,built.get('dimensions',a.get('target',['pending']))))
 memory='light_pos, light_dir, axis_pan, axis_tilt' if a.get('memory')=='light' else a.get('memory','Omitted; no justified integration point.')
 view='Omitted; coarse Geometry provides physical collision and separate view blocking is not required.' if not a.get('decorative') else 'Omitted with Geometry because this assembled structure is a decorative shell; use modular decks for walkable surfaces.'
 fire='Omitted; event props are not intended as ballistic cover.'
 resource={'speaker_rave':'speaker','speaker':'speaker_generic','metal':'metal','deck':'deck','light':'light','screen':'light','stage':'metal','production':'light','equipment':'equipment'}[a['material']]
 geometry='omitted for the decorative assembled shell' if a.get('decorative') else 'simplified convex Geometry'
 texture_desc = ('`data\\dj_player_01_co.paa`, `data\\dj_player_02_co.paa`, and `data\\dj_player_light_co.paa`; matching namespaced RVMATs' if a.get('material_mode') == 'dj_player_textures' else f'`data\\{resource}_co.paa`; matching namespaced RVMAT')
 screen_support = 'Correctly UV-mapped source display retained; invalid atlas-mapped glass overlay omitted.' if a['class'] == 'EDJ_DJ_MediaPlayer_01' else ('`screen_surface` named selection for future texture/video assignment' if a.get('screen') else 'Not applicable')
 known_issues = a.get('manual_acceptance','Human in-game scale, orientation, material, collision, shadow, and LOD acceptance remains pending.')
 lines += [f"### {a['class']} — {a['display']}",'',f"- **Source pack/file/object(s):** {SOURCE_PACKS[p]} / `{a['source']}` / `{', '.join(a['objects'])}`",f"- **Creator/license/source:** {creator}; {license_name}; {url}",'- **Conversion status:** CONVERTED_PLACEABLE',f"- **Category/config/P3D:** {a['category']}; `{a['class']}`; `\\z\\edj\\addons\\assets\\models\\{a['file']}.p3d`",f"- **Texture/RVMAT:** {texture_desc}",f"- **Built dimensions:** {dims} m",'- **Visual LODs:** 1 / 5 / 15 / 40; conservative silhouette-preserving reduction and P3D re-import validation.',f"- **Geometry/View/Fire/Shadow:** {geometry}; {view} {fire} optimized ShadowVolume proxy.",f"- **Memory/animation:** {memory}; {'pan/tilt selections preserved for later animation' if a.get('animated') else 'no active animation'}.",f"- **Screen support:** {screen_support}",f"- **Simple object/Eden/Zeus:** {'No, animated structure retained' if a.get('animated') else 'Yes'} / Yes / Yes.",f'- **Known issues:** {known_issues}',f"- **Optimization:** source modifiers baked; loose geometry removed; base LOD ratio `{a.get('base_ratio','automatic')}`; repeated visual prop does not create audio or controller state.",'']
(ROOT/'docs/ASSET_MANIFEST.md').write_text('\n'.join(lines),encoding='utf-8')

credits=['# Event DJ asset credits','','This is the Steam Workshop attribution basis. Every production asset remains incorporated in binarized Arma formats; raw marketplace files are excluded.','', '| Event DJ asset | Display name | Source pack | Original creator | Source | License |','|---|---|---|---|---|---|']
for a in ASSETS:
 p=SOURCE_FILE_TO_PACK[a['source']]; creator,url,license_name=META[p]
 source_link=f"[CGTrader]({url})" if url.startswith('http') else url
 credits.append(f"| `{a['class']}` | {a['display']} | {SOURCE_PACKS[p]} | {creator} | {source_link} | {license_name} |")
credits += ['','## Accounted but not released','','| Source | Creator | Status |','|---|---|---|','| DJ Player | kuriko1984 | SOURCE_NOT_PRESENT; local folder contains credit text only |','| Music Mixtable | basicsdone | LICENSE_HOLD; all 179 canonical source objects excluded |','','Tooling credit: [Arma Toolbox for Blender 4.2.3](https://github.com/AlwarrenSidh/ArmAToolbox/releases/tag/v4.2.3), GPL-3.0 with its stated output-file exception.']
(ROOT/'docs/ASSET_CREDITS.md').write_text('\n'.join(credits)+'\n',encoding='utf-8')
print(f'Generated production manifest and credits for {len(ASSETS)} assets')
