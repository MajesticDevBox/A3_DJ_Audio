"""Create a standalone, horizontally curved horn row from the existing horn OBJ."""
from pathlib import Path
import math
import bpy
from mathutils import Vector

out = Path(__file__).resolve().parents[1] / 'asset_work' / 'legacy_ravespace_stacks'
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.wm.obj_import(filepath=str(out / 'horn_row_3.obj'))
objects = sorted(bpy.context.selected_objects, key=lambda o: o.name)
assert len(objects) == 3
for index, obj in enumerate(objects):
    obj.data.transform(obj.matrix_world)
    obj.matrix_world.identity()
    points = [v.co for v in obj.data.vertices]
    lo = Vector([min(v[k] for v in points) for k in range(3)])
    hi = Vector([max(v[k] for v in points) for k in range(3)])
    width, depth, height = hi - lo
    center = Vector(((lo.x + hi.x)/2, (lo.y + hi.y)/2, lo.z))
    for v in obj.data.vertices:
        v.co -= center
    side = index - 1
    angle = math.radians(12)
    obj.name = f'horn_row_curved_3_{index+1:02d}'
    obj.rotation_euler.z = side * angle
    if side:
        obj.location = (side * (width/2 + .008 + width/2*math.cos(angle) + depth/2*math.sin(angle)),
                        depth/2 + width/2*math.sin(angle) - depth/2*math.cos(angle), 0)
bpy.context.view_layer.update()
bpy.ops.wm.obj_export(filepath=str(out / 'horn_row_curved_3.obj'), export_selected_objects=True,
                      export_materials=True, path_mode='RELATIVE')
scene = bpy.context.scene
scene.unit_settings.system = 'METRIC'
scene.world = bpy.data.worlds.new('Studio')
scene.world.color = (.045, .045, .045)
bpy.ops.object.camera_add(location=(-2.5, -4, 2.6))
camera = bpy.context.object
camera.rotation_euler = (Vector((0, 0, .45))-camera.location).to_track_quat('-Z', 'Y').to_euler()
camera.data.type = 'ORTHO'
camera.data.ortho_scale = 2.7
scene.camera = camera
for location, energy in [((-3,-4,5),600),((3,-2,4),400),((0,3,4),600)]:
    bpy.ops.object.light_add(type='AREA', location=location)
    light = bpy.context.object
    light.data.energy = energy
    light.data.size = 4
    light.rotation_euler = (Vector((0,0,.45))-light.location).to_track_quat('-Z','Y').to_euler()
for img in bpy.data.images:
    if img.source == 'FILE' and Path(bpy.path.abspath(img.filepath)).is_file():
        img.pack()
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.render.resolution_x = 1400
scene.render.resolution_y = 1000
scene.render.resolution_percentage = 100
scene.render.filepath = str(out / 'horn_row_curved_3_preview.png')
bpy.ops.wm.save_as_mainfile(filepath=str(out / 'horn_row_curved_3.blend'))
bpy.ops.render.render(write_still=True)
assert all(o.data.uv_layers for o in objects)
assert all(i.packed_file for i in bpy.data.images if i.source == 'FILE')
print('VERIFIED: three editable cabinets, UVs and packed textures')
