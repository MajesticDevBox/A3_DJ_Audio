"""Cross-check source coverage against configs and release-safe outputs."""
from __future__ import annotations

import collections
import json
import pathlib
import re
import sys
import zipfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from asset_ingestion_plan import ASSETS

ALLOWED = {
    "CONVERTED_PLACEABLE", "CONVERTED_COMPONENT", "MERGED_INTO_OTHER_ASSET",
    "DUPLICATE", "HELPER_OR_NON_GAME_ASSET", "DEFERRED_TECHNICAL",
    "LICENSE_HOLD", "UNUSABLE", "SOURCE_NOT_PRESENT",
}
RAW_EXTENSIONS = {".blend", ".fbx", ".obj", ".max", ".gltf", ".glb", ".3ds", ".dae", ".stl", ".zip", ".rar", ".7z"}
MATERIAL_RESOURCE = {
    "speaker_rave": ("speaker_co.paa", "speaker.rvmat"),
    "speaker": ("speaker_generic_co.paa", "speaker_generic.rvmat"),
    "metal": ("metal_co.paa", "metal.rvmat"),
    "deck": ("deck_co.paa", "deck.rvmat"),
    "light": ("light_co.paa", "light.rvmat"),
    "screen": ("light_co.paa", "light.rvmat"),
    "stage": ("metal_co.paa", "metal.rvmat"),
    "production": ("light_co.paa", "light.rvmat"),
    "equipment": ("equipment_co.paa", "equipment.rvmat"),
}


def fail(message: str, failures: list[str]) -> None:
    failures.append(message)


def main() -> None:
    failures: list[str] = []
    coverage_path = ROOT / "asset_work" / "validation" / "asset-coverage.json"
    if not coverage_path.exists():
        raise RuntimeError("run generate_asset_coverage.py first")
    coverage = json.loads(coverage_path.read_text(encoding="utf-8-sig"))
    rows = coverage["objects"]
    counts = collections.Counter(row.get("status") for row in rows)
    for index, row in enumerate(rows, 1):
        status = row.get("status")
        if status not in ALLOWED:
            fail(f"inventory row {index} has invalid status {status!r}", failures)
        if status != "CONVERTED_PLACEABLE" and not str(row.get("reason", "")).strip():
            fail(f"inventory row {index} has no non-conversion reason", failures)
    if sum(counts.values()) != len(rows):
        fail("status totals do not reconcile to discovered rows", failures)
    if coverage.get("totals", {}).get("unaccounted") != 0:
        fail("unaccounted source objects are nonzero", failures)

    classes = [spec["class"] for spec in ASSETS]
    files = [spec["file"] for spec in ASSETS]
    for value, count in collections.Counter(classes).items():
        if count != 1:
            fail(f"duplicate EDJ class: {value}", failures)
    for value, count in collections.Counter(files).items():
        if count != 1:
            fail(f"duplicate production filename: {value}", failures)

    config = (ROOT / "addons" / "assets" / "config.cpp").read_text(encoding="utf-8-sig")
    model_config = (ROOT / "addons" / "assets" / "model.cfg").read_text(encoding="utf-8-sig")
    data = ROOT / "addons" / "assets" / "data"
    models = ROOT / "addons" / "assets" / "models"
    expected_models = set()
    for spec in ASSETS:
        expected_models.add(f"{spec['file']}.p3d")
        if not re.search(rf"\bclass\s+{re.escape(spec['class'])}\b", config):
            fail(f"missing CfgVehicles class: {spec['class']}", failures)
        if not re.search(rf"\bclass\s+{re.escape(spec['file'])}\b", model_config):
            fail(f"missing CfgModels class: {spec['file']}", failures)
        model = models / f"{spec['file']}.p3d"
        if not model.exists():
            fail(f"missing P3D: {model.name}", failures)
        texture, rvmat = MATERIAL_RESOURCE[spec["material"]]
        if not (data / texture).exists():
            fail(f"missing texture: {texture}", failures)
        if not (data / rvmat).exists():
            fail(f"missing RVMAT: {rvmat}", failures)
    actual_models = {path.name for path in models.glob("*.p3d")}
    for stale in sorted(actual_models - expected_models):
        fail(f"unmanifested P3D: {stale}", failures)

    audit_roots = [ROOT / "addons"]
    for candidate in (ROOT / ".hemttout" / "release", ROOT / "releases"):
        if candidate.exists():
            audit_roots.append(candidate)
    for audit_root in audit_roots:
        for path in audit_root.rglob("*"):
            is_distribution = path.suffix.casefold() == ".zip" and path.name.casefold().startswith("edj-")
            if path.is_file() and path.suffix.casefold() in RAW_EXTENSIONS and not is_distribution:
                fail(f"raw marketplace/source file in output: {path.relative_to(ROOT)}", failures)
            lowered = str(path).casefold()
            if "music mixtable" in lowered or "basicsdone" in lowered:
                fail(f"license-hold content in output: {path.relative_to(ROOT)}", failures)
            if path.is_file() and is_distribution:
                with zipfile.ZipFile(path) as archive:
                    for name in archive.namelist():
                        suffix = pathlib.PurePosixPath(name).suffix.casefold()
                        if suffix in RAW_EXTENSIONS:
                            fail(f"raw marketplace/source file in distribution: {name}", failures)
                        lowered_name = name.casefold()
                        if "music mixtable" in lowered_name or "basicsdone" in lowered_name:
                            fail(f"license-hold content in distribution: {name}", failures)

    result = {
        "sourceObjects": len(rows),
        "productionAssets": len(ASSETS),
        "statusCounts": dict(sorted(counts.items())),
        "unaccounted": coverage.get("totals", {}).get("unaccounted"),
        "failures": failures,
    }
    output = ROOT / "asset_work" / "validation" / "ingestion-validation.json"
    output.write_text(json.dumps(result, indent=2), encoding="utf-8")
    print("EDJ_INGESTION_VALIDATION=" + json.dumps(result))
    if failures:
        raise RuntimeError("; ".join(failures))


if __name__ == "__main__":
    main()
