"""Render the generated media player with its staged Arma diffuse sources."""
from __future__ import annotations

import pathlib

import bpy
from mathutils import Vector


REPO = pathlib.Path(__file__).resolve().parents[1]
BLEND = REPO / "asset_work" / "blender" / "dj_mediaplayer_01.blend"
TEXTURES = REPO / "asset_work" / "source_copies"
OUTPUT = REPO / "asset_work" / "validation" / "previews" / "dj_mediaplayer_01_textured.png"


def point_camera(camera: bpy.types.Object, target: Vector) -> None:
    camera.rotation_euler = (target - camera.location).to_track_quat("-Z", "Y").to_euler()


def main() -> None:
    bpy.ops.wm.open_mainfile(filepath=str(BLEND), load_ui=False)
    visual = bpy.data.objects["Resolution_1"]
    for obj in bpy.context.scene.objects:
        obj.hide_render = obj != visual

    texture_names = {
        "EDJ_dj_player_01": "dj_player_01_co.png",
        "EDJ_dj_player_02": "dj_player_02_co.png",
        "EDJ_dj_player_light": "dj_player_light_co.png",
    }
    for material in visual.data.materials:
        source = texture_names.get(material.name)
        if source is None:
            continue
        material.use_nodes = True
        nodes = material.node_tree.nodes
        nodes.clear()
        output = nodes.new("ShaderNodeOutputMaterial")
        shader = nodes.new("ShaderNodeBsdfPrincipled")
        image = nodes.new("ShaderNodeTexImage")
        image.image = bpy.data.images.load(str(TEXTURES / source), check_existing=True)
        shader.inputs["Roughness"].default_value = 0.68
        if "IOR Level" in shader.inputs:
            shader.inputs["IOR Level"].default_value = 0.22
        material.node_tree.links.new(image.outputs["Color"], shader.inputs["Base Color"])
        material.node_tree.links.new(shader.outputs["BSDF"], output.inputs["Surface"])

    scene = bpy.context.scene
    scene.render.engine = "BLENDER_EEVEE"
    scene.render.resolution_x = 1000
    scene.render.resolution_y = 1000
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.film_transparent = False
    scene.world.color = (0.008, 0.01, 0.014)
    scene.view_settings.exposure = -1.0

    span = max(visual.dimensions.x, visual.dimensions.y)
    camera_data = bpy.data.cameras.new("PreviewCamera")
    camera = bpy.data.objects.new("PreviewCamera", camera_data)
    scene.collection.objects.link(camera)
    camera.location = (span * 0.72, -span * 1.2, span * 1.55)
    camera.data.lens = 62
    point_camera(camera, Vector((0, 0, visual.dimensions.z * 0.32)))
    scene.camera = camera

    for location, energy, size in (((-.6, -.8, 1.4), 135, 1.6), ((.8, .3, .9), 65, 1.2)):
        data = bpy.data.lights.new("PreviewLight", "AREA")
        data.energy = energy
        data.shape = "DISK"
        data.size = size
        light = bpy.data.objects.new("PreviewLight", data)
        scene.collection.objects.link(light)
        light.location = location
        point_camera(light, Vector((0, 0, 0)))

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    scene.render.filepath = str(OUTPUT)
    bpy.ops.render.render(write_still=True)
    print(f"EDJ_MEDIA_PLAYER_PREVIEW={OUTPUT}")


if __name__ == "__main__":
    main()
