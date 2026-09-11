"""Render developer-local workbench previews of the generated visual LODs."""

from __future__ import annotations

import math
import os
import pathlib

import bpy
from mathutils import Vector


REPO = pathlib.Path(__file__).resolve().parents[1]
BLENDS = REPO / "asset_work" / "blender"
OUTPUT = REPO / "asset_work" / "validation" / "previews"


def point_camera(camera: bpy.types.Object, target: Vector) -> None:
    camera.rotation_euler = (target - camera.location).to_track_quat("-Z", "Y").to_euler()


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    only = {name.strip() for name in os.environ.get("EDJ_PREVIEW_ONLY", "").split(",") if name.strip()}
    for blend in sorted(BLENDS.glob("*.blend")):
        if only and blend.stem not in only:
            continue
        bpy.ops.wm.open_mainfile(filepath=str(blend), load_ui=False)
        visual = bpy.data.objects.get("Resolution_1")
        if visual is None:
            raise RuntimeError(f"Resolution_1 missing from {blend}")
        for obj in bpy.context.scene.objects:
            obj.hide_render = obj != visual
        dimensions = visual.dimensions
        span = max(dimensions)
        target = Vector((0, 0, dimensions.z * 0.45))
        camera_data = bpy.data.cameras.new("PreviewCamera")
        camera = bpy.data.objects.new("PreviewCamera", camera_data)
        bpy.context.scene.collection.objects.link(camera)
        camera.location = (span * 1.8, -span * 2.2, max(span * 1.35, dimensions.z * 1.5))
        camera.data.lens = 58
        point_camera(camera, target)
        bpy.context.scene.camera = camera
        scene = bpy.context.scene
        scene.render.engine = "BLENDER_WORKBENCH"
        scene.display.shading.light = "STUDIO"
        scene.display.shading.studio_light = "paint.sl"
        scene.display.shading.color_type = "MATERIAL"
        scene.display.shading.show_shadows = True
        scene.display.shading.show_cavity = True
        scene.display.shading.cavity_type = "WORLD"
        scene.render.resolution_x = 640
        scene.render.resolution_y = 640
        scene.render.resolution_percentage = 100
        scene.render.image_settings.file_format = "PNG"
        scene.render.film_transparent = False
        scene.world.color = (0.055, 0.06, 0.07)
        scene.render.filepath = str(OUTPUT / f"{blend.stem}.png")
        bpy.ops.render.render(write_still=True)
        print(scene.render.filepath)


if __name__ == "__main__":
    main()
