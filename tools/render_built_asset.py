"""Render a normalized workbench preview of a generated production asset."""
from __future__ import annotations

import math
import pathlib
import sys

import bpy
from mathutils import Vector


def main() -> None:
    values = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    if len(values) not in (2, 3):
        raise SystemExit("expected generated .blend, output .png, and optional LOD distance")
    source, output = map(lambda value: pathlib.Path(value).resolve(), values[:2])
    distance = float(values[2]) if len(values) == 3 else 1.0
    bpy.ops.wm.open_mainfile(filepath=str(source), load_ui=False)
    scene = bpy.context.scene
    target = next(
        obj for obj in scene.objects
        if obj.type == "MESH"
        and obj.armaObjProps.isArmaObject
        and obj.armaObjProps.lod == "-1.0"
        and float(obj.armaObjProps.lodDistance) == distance
    )
    for obj in scene.objects:
        obj.hide_render = obj != target
    corners = [target.matrix_world @ Vector(corner) for corner in target.bound_box]
    center = sum(corners, Vector()) / 8
    extent = max(max(v[i] for v in corners) - min(v[i] for v in corners) for i in range(3))
    camera_data = bpy.data.cameras.new("EDJ_PreviewCamera")
    camera = bpy.data.objects.new("EDJ_PreviewCamera", camera_data)
    scene.collection.objects.link(camera)
    scene.camera = camera
    camera_data.type = "ORTHO"
    camera_data.ortho_scale = max(extent * 1.35, .1)
    camera.location = center + Vector((1.35, -1.55, 1.10)).normalized() * max(extent, .1) * 3
    camera.rotation_euler = (center - camera.location).to_track_quat("-Z", "Y").to_euler()
    scene.render.engine = "BLENDER_WORKBENCH"
    scene.display.shading.light = "STUDIO"
    scene.display.shading.color_type = "MATERIAL"
    scene.display.shading.show_shadows = True
    scene.display.shading.show_cavity = True
    scene.render.resolution_x = 768
    scene.render.resolution_y = 768
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.film_transparent = False
    scene.world.color = (.08, .08, .08)
    output.parent.mkdir(parents=True, exist_ok=True)
    scene.render.filepath = str(output)
    bpy.ops.render.render(write_still=True)
    print(f"EDJ_BUILT_PREVIEW={output}")


if __name__ == "__main__":
    main()
