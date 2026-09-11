"""Run with Blender --background --python tools/create_ravespace_stacks.py.

Uses supplied meshes/UVs unchanged; transforms and duplicates cabinets only.
"""
from pathlib import Path
import hashlib
import json
import math
import shutil
import bpy
from mathutils import Matrix, Vector

SOURCE = Path(r'G:\1 ARMA3_DEVELOPMENT\Blinder Assets\RAVESpace - Speakers')
OUT = Path(__file__).resolve().parents[1] / 'asset_work' / 'legacy_ravespace_stacks'
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'textures').mkdir(exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.ops.wm.obj_import(filepath=str(SOURCE / 'RaveSpace_Audio_Systems.obj'))
originals = {o.name: o for o in bpy.context.selected_objects}

# Repair stale source MTL paths using the supplied, unmodified texture files.
mat = bpy.data.materials['RAS']
mat.use_nodes = True
nodes = mat.node_tree.nodes
nodes.clear()
shader = nodes.new('ShaderNodeBsdfPrincipled')
output = nodes.new('ShaderNodeOutputMaterial')
mat.node_tree.links.new(shader.outputs['BSDF'], output.inputs['Surface'])
for kind, socket in [('BaseColor', 'Base Color'), ('Roughness', 'Roughness'), ('Normal', None)]:
    name = f'RaveSpace_Audio_Systems_DefaultMaterial_{kind}_4K.jpg'
    shutil.copy2(SOURCE / 'Textures' / name, OUT / 'textures' / name)
    node = nodes.new('ShaderNodeTexImage')
    node.image = bpy.data.images.load(str(OUT / 'textures' / name))
    if kind != 'BaseColor':
        node.image.colorspace_settings.name = 'Non-Color'
    if socket:
        mat.node_tree.links.new(node.outputs['Color'], shader.inputs[socket])
    else:
        normal = nodes.new('ShaderNodeNormalMap')
        mat.node_tree.links.new(node.outputs['Color'], normal.inputs['Color'])
        mat.node_tree.links.new(normal.outputs['Normal'], shader.inputs['Normal'])

def bounds(obj):
    points = [obj.matrix_world @ v.co for v in obj.data.vertices]
    return [Vector([fn(v[k] for v in points) for k in range(3)]) for fn in (min, max)]

for name, obj in originals.items():
    transform = Matrix.Rotation(math.pi / 2, 4, 'Z') @ obj.matrix_world
    if name == 'RA-LT01':
        transform = Matrix.Rotation(math.pi, 4, 'Y') @ transform
    obj.data.transform(transform)
    obj.matrix_world.identity()
    lo, hi = bounds(obj)
    center = Vector(((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, lo.z))
    for vertex in obj.data.vertices:
        vertex.co -= center
    obj.data.materials.clear()
    obj.data.materials.append(mat)

specs = [('array_straight_4', 'RA-LT01', 4, 'straight'),
         ('array_curved_4', 'RA-LT01', 4, 'curved'),
         ('horn_row_3', 'RA_MT01', 3, 'row'),
         ('sub_row_3', 'RA_SUB01', 3, 'row')]
groups = {}
for label, source_name, count, layout in specs:
    collection = bpy.data.collections.new(label)
    bpy.context.scene.collection.children.link(collection)
    source = originals[source_name]
    lo, hi = bounds(source)
    width, depth, height = hi - lo
    items = []
    previous = None
    for index in range(count):
        obj = source.copy()
        obj.name = f'{label}_{index + 1:02d}'
        collection.objects.link(obj)
        if layout == 'row':
            obj.location.x = (index - (count - 1) / 2) * (width + .008)
        elif layout == 'straight':
            obj.location.z = (count - 1 - index) * (height + .006)
        else:
            # Successive downward splay, joined along the cabinet rear edges.
            obj.rotation_euler.x = math.radians(index * 8)
            rotation = obj.rotation_euler.to_matrix()
            if previous is not None:
                anchor = previous.location + previous.rotation_euler.to_matrix() @ Vector((0, depth / 2, 0))
                obj.location = anchor - rotation @ Vector((0, depth / 2, height)) - Vector((0, 0, .006))
            previous = obj
        items.append(obj)
    bpy.context.view_layer.update()
    floor = min(bounds(o)[0].z for o in items)
    for obj in items:
        obj.location.z -= floor
    groups[label] = items

for obj in originals.values():
    bpy.data.objects.remove(obj, do_unlink=True)
bpy.context.view_layer.update()
report = {'source': str(SOURCE / 'RaveSpace_Audio_Systems.obj'),
          'source_sha256': hashlib.sha256((SOURCE / 'RaveSpace_Audio_Systems.obj').read_bytes()).hexdigest(),
          'front': '-Y', 'up': '+Z', 'scale': 'source scale retained', 'assemblies': {}}
for label, items in groups.items():
    bpy.ops.object.select_all(action='DESELECT')
    for obj in items:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = items[0]
    bpy.ops.wm.obj_export(filepath=str(OUT / f'{label}.obj'), export_selected_objects=True,
                          export_materials=True, path_mode='RELATIVE')
    report['assemblies'][label] = {'cabinets': len(items), 'vertices': sum(len(o.data.vertices) for o in items)}

# Display layout; exported individual assemblies above each have a ground origin.
for label, items in groups.items():
    offset = {'array_straight_4': (-1.65, 0, 1.55), 'array_curved_4': (-.55, 0, 1.55),
              'horn_row_3': (1.35, 0, 0), 'sub_row_3': (-1.15, 0, 0)}[label]
    for obj in items:
        obj.location += Vector(offset)
scene = bpy.context.scene
scene.unit_settings.system = 'METRIC'
scene.world.color = (.055, .055, .055)
bpy.ops.object.camera_add(location=(4, -8, 4.2))
camera = bpy.context.object
camera.rotation_euler = (Vector((0, 0, 1.35)) - camera.location).to_track_quat('-Z', 'Y').to_euler()
camera.data.type = 'ORTHO'
camera.data.ortho_scale = 5.7
scene.camera = camera
for location, energy, size in [((1, -4, 6), 700, 5), ((-4, -2, 3), 450, 4), ((2, 3, 5), 850, 3)]:
    bpy.ops.object.light_add(type='AREA', location=location)
    light = bpy.context.object
    light.data.energy = energy
    light.data.shape = 'DISK'
    light.data.size = size
    light.rotation_euler = (Vector((0, 0, 1)) - light.location).to_track_quat('-Z', 'Y').to_euler()
scene.render.engine = 'CYCLES'
scene.cycles.samples = 48
scene.render.resolution_x = 1600
scene.render.resolution_y = 1100
scene.render.resolution_percentage = 100
scene.render.filepath = str(OUT / 'ravespace_stacks_preview.png')
for img in bpy.data.images:
    if img.source == 'FILE' and Path(bpy.path.abspath(img.filepath)).is_file():
        img.pack()
bpy.ops.wm.save_as_mainfile(filepath=str(OUT / 'ravespace_stacks.blend'))
bpy.ops.render.render(write_still=True)
(OUT / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
print('STACKS_COMPLETE', json.dumps(report))
