"""Re-import production MLODs and assert the required LOD and path structure."""

from __future__ import annotations

import importlib
import json
import os
import pathlib
import re
import sys

import bpy


REPO = pathlib.Path(__file__).resolve().parents[1]
MODELS = REPO / "addons" / "assets" / "models"
REQUIRED_VISUAL = {1.0, 5.0, 15.0, 40.0}
sys.path.insert(0, str(REPO / "tools"))
from asset_ingestion_plan import ASSETS


def clear_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)


def main() -> None:
    if not hasattr(bpy.types.Material, "armaMatProps"):
        bpy.ops.preferences.addon_enable(module="bl_ext.user_default.ArmaToolbox")
    importer = importlib.import_module("bl_ext.user_default.ArmaToolbox.MDLImporter")
    records = []
    specs = {f"{spec['file']}.p3d": spec for spec in ASSETS}
    only = os.environ.get("EDJ_VALIDATE_ONLY", "")
    paths = [path for path in sorted(MODELS.glob("*.p3d")) if not only or path.name == only]
    for path in paths:
        clear_scene()
        try:
            result = importer.importMDL(bpy.context, str(path), 0)
        except IndexError:
            # Arma Toolbox's final UI collection selection has no background-mode
            # collection to select. All LODs are already parsed at this point.
            if not any(obj.type == "MESH" for obj in bpy.context.scene.objects):
                raise
            result = 0
        if result != 0:
            raise RuntimeError(f"P3D import failed ({result}): {path}")
        lods = []
        for obj in bpy.context.scene.objects:
            if obj.type != "MESH" or not obj.armaObjProps.isArmaObject:
                continue
            lod = float(obj.armaObjProps.lodDistance) if obj.armaObjProps.lod == "-1.0" else float(obj.armaObjProps.lod)
            lods.append({"name": obj.name, "lod": lod, "vertices": len(obj.data.vertices), "polygons": len(obj.data.polygons)})
        visual = {row["lod"] for row in lods if row["lod"] < 1000}
        if not REQUIRED_VISUAL.issubset(visual):
            raise RuntimeError(f"missing visual LODs in {path.name}: {visual}")
        if not specs[path.name].get("decorative") and not any(row["lod"] == 1.0e13 for row in lods):
            raise RuntimeError(f"missing Geometry LOD: {path.name}")
        if not any(11000 <= row["lod"] < 12000 for row in lods):
            raise RuntimeError(f"missing ShadowVolume LOD: {path.name}")
        visual_rows = sorted((row for row in lods if row["lod"] in REQUIRED_VISUAL), key=lambda row: row["lod"])
        polygon_counts = [row["polygons"] for row in visual_rows]
        if any(later > earlier for earlier, later in zip(polygon_counts, polygon_counts[1:])):
            raise RuntimeError(f"visual LODs increase in complexity in {path.name}: {polygon_counts}")
        raw = path.read_bytes().lower()
        strings = b"\n".join(re.findall(rb"[\x20-\x7e]{5,}", raw))
        for forbidden in (b"g:\\", b"c:\\users\\", b"downloads", b"desktop"):
            if forbidden in strings:
                raise RuntimeError(f"development path leaked into {path.name}: {forbidden!r}")
        primary = next(obj for obj in bpy.context.scene.objects if obj.type == "MESH" and obj.armaObjProps.isArmaObject and obj.armaObjProps.lod == "-1.0" and float(obj.armaObjProps.lodDistance) == 1.0)
        dimensions = [round(value, 4) for value in primary.dimensions]
        expected = specs[path.name].get("expected", specs[path.name].get("target"))
        if expected and any(abs(actual-wanted) > max(.01, wanted*.015) for actual,wanted in zip(dimensions,expected)):
            raise RuntimeError(f"dimension mismatch in {path.name}: actual={dimensions}, expected={expected}")
        records.append({"model": path.name, "bytes": path.stat().st_size, "dimensions": dimensions, "lods": lods})
    if not only and len(records) != len(ASSETS):
        raise RuntimeError(f"expected {len(ASSETS)} P3Ds, found {len(records)}")
    output = REPO / "asset_work" / "validation" / "p3d-validation.json"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps({"models": records}, indent=2), encoding="utf-8")
    print("EDJ_P3D_VALIDATION=" + json.dumps(records))


if __name__ == "__main__":
    main()
