"""Render supplied source scenes for promotional catalog; never saves originals."""
import bpy, sys, json
from pathlib import Path
from mathutils import Vector
BASE=Path(r'G:\1 ARMA3_DEVELOPMENT\Blinder Assets')
OUT=Path(__file__).resolve().parents[1]/'assets'/'promo'
OUT.mkdir(exist_ok=True)
SOURCES={
 'arena':BASE/'Arena Stage Venue Props Pack -  Modular Event Stage'/'Blender_5.0.1.blend',
 'event':BASE/'Event Stage setup'/'Event+STAGE.blend',
 'mixer':BASE/'Music Mixtable'/'Mixtable.blend',
 'truss':BASE/'truss system line array'/'truss+square+line+array.blend',
 'devices':BASE/'Various projection sound and lighting devices'/'bar.lead+screen.blend1',
 'speakers':OUT.parents[1]/'asset_work'/'legacy_ravespace_stacks'/'ravespace_stacks.blend'}
key=sys.argv[sys.argv.index('--')+1]
bpy.ops.wm.open_mainfile(filepath=str(SOURCES[key]),use_scripts=False)
scene=bpy.context.scene
if key=='speakers':
 with bpy.data.libraries.load(str(OUT.parents[1]/'asset_work'/'legacy_ravespace_stacks'/'horn_row_curved_3.blend'),link=False) as (source,target):
  target.objects=[n for n in source.objects if n.startswith('horn_row_curved_3_')]
 for obj in target.objects:
  scene.collection.objects.link(obj)
  obj.location+=Vector((1.4,0,1.65))
for layer in scene.view_layers: layer.material_override=None
scene.use_nodes=False
missing=[]
for img in bpy.data.images:
 if img.source in {'FILE','MOVIE'} and not img.packed_file:
  if not Path(bpy.path.abspath(img.filepath)).is_file():
   matches=list(SOURCES[key].parent.rglob(Path(img.filepath.replace('\\','/')).name))
   if matches:
    img.filepath=str(matches[0]);img.reload()
   else: missing.append(img.name)
for o in list(scene.objects):
 if o.type in {'LIGHT','CAMERA'}:
  bpy.data.objects.remove(o,do_unlink=True)
  continue
 if o.type=='FONT' and not o.data.font.packed_file and not Path(bpy.path.abspath(o.data.font.filepath)).is_file():
  o.data.font=bpy.data.fonts.get('Bfont') or bpy.data.fonts.load('C:/Windows/Fonts/arial.ttf')
 if key=='event' and o.name=='Plane': o.hide_render=True
 if key=='devices' and o.name in {'Plane.004','Cube.044'}: o.hide_render=True
 if key=='mixer' and (o.name.startswith('Icosphere') or o.name in {'Knife_Party_Logo','Plane.012','Plane.020','Circle.004'}):o.hide_render=True
for mat in bpy.data.materials:
 if not mat.use_nodes:
  color=tuple(mat.diffuse_color)
  mat.use_nodes=True
  shader=mat.node_tree.nodes.get('Principled BSDF')
  if shader:
   shader.inputs['Base Color'].default_value=color
   shader.inputs['Roughness'].default_value=.48
 if mat.node_tree:
  for node in list(mat.node_tree.nodes):
   if node.type=='TEX_IMAGE' and node.image and node.image.name in missing:
    for output in node.outputs:
     for link in list(output.links):mat.node_tree.links.remove(link)
objects=[o for o in scene.objects if o.type in {'MESH','CURVE','FONT'} and not o.hide_render]
bpy.context.view_layer.update()
points=[o.matrix_world@Vector(v) for o in objects for v in o.bound_box]
lo=Vector([min(v[k] for v in points) for k in range(3)])
hi=Vector([max(v[k] for v in points) for k in range(3)])
center=(lo+hi)/2
extent=max(hi-lo)
direction=Vector((.4,-1,.65))
if key=='mixer':direction=Vector((.25,-.8,1.2))
bpy.ops.object.camera_add(location=center+direction.normalized()*extent*2)
camera=bpy.context.object
camera.rotation_euler=(center-camera.location).to_track_quat('-Z','Y').to_euler()
camera.data.type='ORTHO'; camera.data.clip_end=10000
scene.camera=camera
inv=camera.matrix_world.inverted()
bpy.context.view_layer.update();inv=camera.matrix_world.inverted()
view=[inv@p for p in points]
width=max(p.x for p in view)-min(p.x for p in view)
height=max(p.y for p in view)-min(p.y for p in view)
camera.data.ortho_scale=max(width,height*1.6)*1.12
for direction,power in [((-1,-2,3),90),((2,-1,2),60),((0,2,3),110)]:
 bpy.ops.object.light_add(type='AREA',location=center+Vector(direction)*extent*.6)
 light=bpy.context.object;light.data.energy=power*extent*extent;light.data.size=extent
 light.rotation_euler=(center-light.location).to_track_quat('-Z','Y').to_euler()
scene.world=bpy.data.worlds.new('Promo studio')
scene.world.use_nodes=True
scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.16,.19,.25,1)
scene.world.node_tree.nodes['Background'].inputs[1].default_value=.5
scene.render.engine='CYCLES';scene.cycles.samples=16;scene.cycles.use_denoising=True
scene.render.resolution_x=1600;scene.render.resolution_y=1000;scene.render.resolution_percentage=100
scene.render.film_transparent=True
scene.render.image_settings.file_format='PNG';scene.render.image_settings.color_mode='RGBA'
scene.render.filepath=str(OUT/(key+'.png'))
scene.render.use_border=False
scene.render.use_compositing=False
scene.view_settings.view_transform='AgX'
if key=='truss':scene.view_settings.exposure=1.3
(OUT/(key+'_report.json')).write_text(json.dumps({'source':str(SOURCES[key]),'objects':len(objects),'bounds':[list(lo),list(hi)],'missing_images':missing},indent=2))
bpy.ops.render.render(write_still=True)
print('RENDER_DONE',key)

