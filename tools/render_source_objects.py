"""Render normalized thumbnails for each unique source mesh without editing the source."""

from __future__ import annotations

import hashlib
import json
import math
import pathlib
import re
import sys

import bpy
from mathutils import Vector


def args() -> tuple[pathlib.Path, pathlib.Path, str]:
    values = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    if len(values) != 3:
        raise SystemExit("expected source, output directory, and pack key")
    return pathlib.Path(values[0]).resolve(), pathlib.Path(values[1]).resolve(), values[2]


def load(path: pathlib.Path) -> None:
    if path.suffix.lower() == ".blend":
        bpy.ops.wm.open_mainfile(filepath=str(path), load_ui=False)
    else:
        bpy.ops.object.select_all(action="SELECT")
        bpy.ops.object.delete(use_global=False)
        if path.suffix.lower() == ".obj":
            bpy.ops.wm.obj_import(filepath=str(path), use_split_objects=True)
        elif path.suffix.lower() == ".fbx":
            bpy.ops.import_scene.fbx(filepath=str(path), use_anim=False)
        else:
            raise SystemExit(f"unsupported: {path.suffix}")


def mesh_hash(obj: bpy.types.Object) -> str:
    digest = hashlib.sha256()
    for vertex in obj.data.vertices:
        digest.update(("%.6f,%.6f,%.6f;" % tuple(vertex.co)).encode("ascii"))
    for polygon in obj.data.polygons:
        digest.update((",".join(str(i) for i in polygon.vertices) + ";").encode("ascii"))
    return digest.hexdigest()


def safe_name(value: str) -> str:
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", value)[:100]


def main() -> None:
    source, output, pack = args()
    output.mkdir(parents=True, exist_ok=True)
    load(source)
    scene = bpy.context.scene
    scene.render.engine = "BLENDER_WORKBENCH"
    scene.render.resolution_x = 256
    scene.render.resolution_y = 256
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.film_transparent = True
    scene.display.shading.light = "STUDIO"
    scene.display.shading.color_type = "MATERIAL"
    scene.display.shading.show_shadows = True
    scene.display.shading.show_cavity = True
    scene.display.shading.cavity_type = "WORLD"

    camera_data = bpy.data.cameras.new("EDJ_InventoryCamera")
    camera = bpy.data.objects.new("EDJ_InventoryCamera", camera_data)
    scene.collection.objects.link(camera)
    scene.camera = camera
    camera_data.type = "ORTHO"

    meshes = sorted((obj for obj in bpy.data.objects if obj.type == "MESH"), key=lambda item: item.name.casefold())
    hashes: dict[str, str] = {}
    records = []
    for index, obj in enumerate(meshes, start=1):
        digest = mesh_hash(obj)
        if digest in hashes:
            records.append({"name": obj.name, "duplicateOf": hashes[digest], "meshHash": digest})
            continue
        hashes[digest] = obj.name
        for candidate in meshes:
            candidate.hide_render = candidate != obj
        corners = [obj.matrix_world @ Vector(corner) for corner in obj.bound_box]
        center = sum(corners, Vector()) / 8
        extent = max((max(v[i] for v in corners) - min(v[i] for v in corners)) for i in range(3))
        extent = max(extent, 0.01)
        direction = Vector((1.35, -1.55, 1.10)).normalized()
        camera.location = center + direction * extent * 3.0
        camera.rotation_euler = (center - camera.location).to_track_quat("-Z", "Y").to_euler()
        camera_data.ortho_scale = extent * 1.35
        scene.render.filepath = str(output / f"{index:03d}_{safe_name(obj.name)}.png")
        bpy.ops.render.render(write_still=True)
        records.append(
            {
                "name": obj.name,
                "meshHash": digest,
                "thumbnail": pathlib.Path(scene.render.filepath).name,
                "dimensions": [round(value, 4) for value in obj.dimensions],
            }
        )
    (output / "index.json").write_text(json.dumps({"pack": pack, "records": records}, indent=2), encoding="utf-8")
    print(f"EDJ_SOURCE_PREVIEWS={pack}:{len(records)}:{len(hashes)}")


if __name__ == "__main__":
    main()
