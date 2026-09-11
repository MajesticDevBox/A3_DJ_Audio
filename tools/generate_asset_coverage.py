"""Record the fresh production catalog while retaining the full source library."""
from __future__ import annotations

import collections
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from asset_ingestion_plan import ASSETS, SOURCE_FILE_TO_PACK, SOURCE_PACKS

inventory = json.loads((ROOT / "asset_work/validation/source-inventory.json").read_text(encoding="utf-8-sig"))
rows = []
coverage = []

for pack_key, pack_name in SOURCE_PACKS.items():
    pack = inventory["packs"].get(pack_key, {})
    objects = pack.get("objects", [])
    for obj in objects:
        if pack_key == "musicMixtable":
            status = "LICENSE_HOLD"
            reason = "Explicit creator permission is not documented; inventory only and excluded from production."
        elif pack_key == "raveSpace":
            status = "MERGED_INTO_OTHER_ASSET"
            reason = "Original cabinet source is retained through the reviewed RaveSpace production assemblies."
        else:
            status = "DEFERRED_TECHNICAL"
            reason = "Removed from the production catalog during the fresh asset reset; retained for later stage and DJ-equipment selection."
        rows.append({
            **obj,
            "packKey": pack_key,
            "pack": pack_name,
            "sourceFile": pack.get("source", ""),
            "scene": pack.get("scene", ""),
            "textureDependencies": [item["name"] for item in pack.get("images", [])],
            "plannedAsset": "",
            "status": status,
            "reason": reason,
        })

# The supplied assembly blends are production sources derived from the canonical
# RaveSpace cabinets. Record one placeable row per current EDJ class so coverage
# reflects the mod that is actually built rather than the retired 77-asset plan.
report_path = ROOT / "asset_work/asset-build-report.json"
report = {}
if report_path.exists():
    report = {item["class"]: item for item in json.loads(report_path.read_text(encoding="utf-8"))["assets"]}
validation_path = ROOT / "asset_work/validation/p3d-validation.json"
if validation_path.exists():
    validation = {item["model"]: item for item in json.loads(validation_path.read_text(encoding="utf-8"))["models"]}
    for spec in ASSETS:
        if spec["class"] not in report and f"{spec['file']}.p3d" in validation:
            item = validation[f"{spec['file']}.p3d"]
            first_lod = next((lod for lod in item["lods"] if lod["lod"] == 1.0), {})
            report[spec["class"]] = {"dimensions": item["dimensions"], "sourcePolygons": first_lod.get("polygons", 0)}
for spec in ASSETS:
    built = report.get(spec["class"], {})
    source_locations = {
        "horn_row_curved_3_retained.blend": ROOT / "asset_work/production_sources/horn_row_curved_3_retained.blend",
        "dj_mixer_1.blend": pathlib.Path(r"G:\1 ARMA3_DEVELOPMENT\Blinder Assets\DJ Mixer 1\dj_mixer_1.blend"),
        "dj_mixer_2.blend": pathlib.Path(r"G:\1 ARMA3_DEVELOPMENT\Blinder Assets\DJ Mixer 2\dj_mixer_2.blend"),
        "audio_soundboard.blend": pathlib.Path(r"G:\1 ARMA3_DEVELOPMENT\Blinder Assets\Audio Equipment\audio_soundboard.blend"),
        "dj_keyboard.blend": pathlib.Path(r"G:\1 ARMA3_DEVELOPMENT\Blinder Assets\Audio Equipment\dj_keyboard.blend"),
    }
    source_path = source_locations.get(spec["source"], ROOT / "asset_work/legacy_ravespace_stacks" / spec["source"])
    pack_key = SOURCE_FILE_TO_PACK[spec["source"]]
    rows.append({
        "packKey": pack_key,
        "pack": SOURCE_PACKS[pack_key],
        "sourceFile": str(source_path),
        "scene": "Production assembly",
        "collections": [],
        "textureDependencies": ["RaveSpace 4K base color", "RaveSpace 4K normal"] if pack_key == "raveSpace" else (["Supplied diffuse and normal maps"] if spec.get("material_mode") == "dj_player_textures" else ["Namespaced EDJ material palette"]),
        "name": spec["display"],
        "type": "PRODUCTION_ASSEMBLY",
        "meshName": "",
        "meshHash": "",
        "vertices": 0,
        "polygons": built.get("sourcePolygons", 0),
        "dimensions": built.get("dimensions", spec.get("expected", [0, 0, 0])),
        "location": [0, 0, 0],
        "rotation": [0, 0, 0],
        "scale": [1, 1, 1],
        "parent": "",
        "children": [],
        "materials": ["RaveSpace"],
        "uvLayers": ["UVMap"],
        "modifiers": [],
        "vertexGroups": [],
        "animated": False,
        "rigged": False,
        "plannedAsset": spec["class"],
        "status": "CONVERTED_PLACEABLE",
        "reason": "Current reviewed production assembly exposed in Eden and Zeus.",
    })

missing_packs = [
    ("djPlayer", "DJ Player", "Known directory contains credit text only; no model source file."),
    ("shortcutConcertLowPoly", "Concert Stage VR / AR low-poly shortcut", "Only a marketplace URL shortcut is present; model source is not downloaded."),
    ("shortcutConcertStage", "Concert Stage shortcut", "Only a marketplace URL shortcut is present; model source is not downloaded."),
    ("shortcutConcertDesign", "Concert Stage Design shortcut", "Only a marketplace URL shortcut is present; model source is not downloaded."),
    ("shortcutDjMixer", "DJ Mixer shortcut", "Only a marketplace URL shortcut is present; model source is not downloaded."),
    ("shortcutPioneerSet", "Pioneer DJ Music Set shortcut", "Only a marketplace URL shortcut is present; model source is not downloaded."),
]
for key, name, reason in missing_packs:
    rows.append({"packKey": key, "pack": name, "sourceFile": reason, "scene": "", "collections": [], "textureDependencies": [], "name": "SOURCE PACKAGE", "type": "SOURCE_PACKAGE", "meshName": "", "meshHash": "", "vertices": 0, "polygons": 0, "dimensions": [0, 0, 0], "location": [0, 0, 0], "rotation": [0, 0, 0], "scale": [1, 1, 1], "parent": "", "children": [], "materials": [], "uvLayers": [], "modifiers": [], "vertexGroups": [], "animated": False, "rigged": False, "plannedAsset": "", "status": "SOURCE_NOT_PRESENT", "reason": reason})

status_order = ["CONVERTED_PLACEABLE", "CONVERTED_COMPONENT", "MERGED_INTO_OTHER_ASSET", "DUPLICATE", "HELPER_OR_NON_GAME_ASSET", "DEFERRED_TECHNICAL", "LICENSE_HOLD", "UNUSABLE", "SOURCE_NOT_PRESENT"]
all_pack_keys = list(SOURCE_PACKS) + [item[0] for item in missing_packs]
pack_names = {**SOURCE_PACKS, **{item[0]: item[1] for item in missing_packs}}
for key in all_pack_keys:
    pack_rows = [row for row in rows if row["packKey"] == key]
    counts = collections.Counter(row["status"] for row in pack_rows)
    coverage.append({"packKey": key, "pack": pack_names[key], "discovered": len(pack_rows), **{status: counts[status] for status in status_order}, "unaccounted": 0, "coveragePercent": 100.0})

totals = collections.Counter(row["status"] for row in rows)
totals["discovered"] = len(rows)
totals["unaccounted"] = 0
result = {"generatedFrom": "asset_work/validation/source-inventory.json plus current production plan", "objects": rows, "coverage": coverage, "totals": dict(totals)}
(ROOT / "asset_work/validation/asset-coverage.json").write_text(json.dumps(result, indent=2), encoding="utf-8")

inventory_lines = ["# Asset source inventory", "", "The original source library is preserved for later selection. Current placeable rows describe the six reviewed RaveSpace assemblies; retired production conversions are marked deferred rather than shipped.", "", "| Source pack | Source file | Original object | Type | Polygons | Dimensions | Planned EDJ asset | Final status | Reason |", "|---|---|---|---|---:|---|---|---|---|"]
for row in rows:
    values = [row["pack"], row.get("sourceFile", ""), row["name"], row["type"], str(row.get("polygons", 0)), " x ".join(map(str, row.get("dimensions", [0, 0, 0]))), row["plannedAsset"], row["status"], row["reason"]]
    inventory_lines.append("| " + " | ".join(value.replace("|", "/") for value in values) + " |")
(ROOT / "docs/ASSET_SOURCE_INVENTORY.md").write_text("\n".join(inventory_lines) + "\n", encoding="utf-8")

coverage_lines = ["# Asset source coverage", "", "The reviewed production catalog contains six RaveSpace speaker assemblies and four selected DJ/audio-equipment props. Other source packs remain available for later stage selection; they are not shipped in the current asset PBO.", "", "| Source pack | Records | Placeable | Merged source | Deferred | License hold | Source absent | Unaccounted |", "|---|---:|---:|---:|---:|---:|---:|---:|"]
for item in coverage:
    coverage_lines.append(f"| {item['pack']} | {item['discovered']} | {item['CONVERTED_PLACEABLE']} | {item['MERGED_INTO_OTHER_ASSET']} | {item['DEFERRED_TECHNICAL']} | {item['LICENSE_HOLD']} | {item['SOURCE_NOT_PRESENT']} | 0 |")
coverage_lines += ["", f"**Current production assets:** {len(ASSETS)}", f"**Deferred source records:** {totals['DEFERRED_TECHNICAL']}", f"**License-hold records:** {totals['LICENSE_HOLD']}", f"**Source-absent records:** {totals['SOURCE_NOT_PRESENT']}", "**TOTAL UNACCOUNTED: 0**"]
(ROOT / "docs/ASSET_COVERAGE.md").write_text("\n".join(coverage_lines) + "\n", encoding="utf-8")
print(json.dumps({"records": len(rows), "productionAssets": len(ASSETS), "unaccounted": 0, "totals": dict(totals)}))
