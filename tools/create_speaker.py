"""Blender --background --python tools/create_speaker.py: original metric blockout."""
import bpy
from pathlib import Path

out = Path(__file__).resolve().parents[1] / 'assets' / 'speaker'
out.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.context.scene.unit_settings.system = 'METRIC'

def box(name, location, size, color):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1)
    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)

box('speaker_cabinet', (0, 0, 0.45), (0.48, 0.38, 0.9), (0.025, 0.03, 0.04))
box('speaker_grille', (0, -0.196, 0.47), (0.42, 0.012, 0.76), (0.08, 0.095, 0.11))
box('speaker_badge', (0, -0.205, 0.13), (0.12, 0.008, 0.035), (0.02, 0.65, 0.7))
bpy.ops.object.empty_add(type='PLAIN_AXES', location=(0, -0.21, 0.5))
bpy.context.object.name = 'audio_pos_reference'
bpy.ops.wm.save_as_mainfile(filepath=str(out / 'edj_speaker.blend'))
bpy.ops.wm.obj_export(filepath=str(out / 'edj_speaker.obj'), export_materials=True)
