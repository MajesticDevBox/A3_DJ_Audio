"""Build all production MLOD models from the reviewed ingestion plan."""
from __future__ import annotations
import bmesh, importlib, json, os, pathlib, sys
import bpy
from mathutils import Matrix

REPO = pathlib.Path(__file__).resolve().parents[1]
WORK, OUTPUT = REPO / "asset_work", REPO / "addons" / "assets" / "models"
SOURCE, BLENDS = WORK / "source_copies", WORK / "blender"
ARMA_ROOT = "z\\edj\\addons\\assets"
sys.path.insert(0, str(REPO / "tools"))
from asset_ingestion_plan import ASSETS

def clear_scene():
    bpy.ops.object.select_all(action="SELECT"); bpy.ops.object.delete(use_global=False)
    for blocks in (bpy.data.meshes, bpy.data.materials, bpy.data.images):
        for block in list(blocks):
            if block.users == 0: blocks.remove(block)

def activate(obj):
    bpy.ops.object.select_all(action="DESELECT"); obj.select_set(True); bpy.context.view_layer.objects.active = obj

def load_objects(spec):
    path, names = SOURCE / spec["source"], list(spec["objects"])
    wildcard = names in (["*GAME_MESHES_EXCEPT_GROUND*"], ["*ALL_MESHES*"])
    if path.suffix == ".blend":
        with bpy.data.libraries.load(str(path), link=False) as (available, loaded):
            if names == ["*GAME_MESHES_EXCEPT_GROUND*"]:
                names = [name for name in available.objects if name != "Plane"]
            elif names == ["*ALL_MESHES*"]:
                names = list(available.objects)
            missing = [name for name in names if name not in available.objects]
            if missing: raise RuntimeError(f"missing from {path.name}: {missing}")
            loaded.objects = names
        selected = []
        for obj in loaded.objects:
            if obj is not None and obj.type == "MESH": bpy.context.collection.objects.link(obj); selected.append(obj)
    elif path.suffix == ".obj":
        bpy.ops.wm.obj_import(filepath=str(path), use_split_objects=True, use_split_groups=False)
        selected = [bpy.data.objects.get(name) for name in names]
    elif path.suffix == ".fbx":
        bpy.ops.import_scene.fbx(filepath=str(path), use_anim=False)
        selected = [bpy.data.objects.get(name) for name in names]
    else: raise RuntimeError(f"unsupported source: {path}")
    selected = [obj for obj in selected if obj is not None and obj.type == "MESH"]
    if not wildcard and len(selected) != len(names):
        raise RuntimeError(f"missing selected meshes in {path.name}: {sorted(set(names)-{o.name for o in selected})}")
    bpy.ops.object.select_all(action="DESELECT")
    depsgraph=bpy.context.evaluated_depsgraph_get()
    for index,obj in enumerate(selected):
        evaluated=obj.evaluated_get(depsgraph)
        mesh=bpy.data.meshes.new_from_object(evaluated, depsgraph=depsgraph)
        old=obj.data; obj.data=mesh; obj.modifiers.clear()
        if old.users==0: bpy.data.meshes.remove(old)
        if spec.get("recenter_parts") or spec.get("bake_world"):
            world=obj.matrix_world.copy()
            obj.parent=None
            obj.data.transform(world)
            obj.matrix_world=Matrix.Identity(4)
        if spec.get("recenter_parts"):
            xs=[v.co.x for v in obj.data.vertices]; ys=[v.co.y for v in obj.data.vertices]; zs=[v.co.z for v in obj.data.vertices]
            center=((min(xs)+max(xs))/2,(min(ys)+max(ys))/2,(min(zs)+max(zs))/2)
            for vertex in obj.data.vertices:
                vertex.co.x-=center[0]; vertex.co.y-=center[1]; vertex.co.z-=center[2]
        if index and spec.get("part_z_offset"):
            obj.data.transform(Matrix.Translation((0,0,spec["part_z_offset"])))
    for obj in selected: obj.hide_viewport=False; obj.hide_render=False; obj.hide_set(False); obj.select_set(True)
    bpy.context.view_layer.objects.active=selected[0]
    if len(selected)>1: bpy.ops.object.join()
    result=bpy.context.view_layer.objects.active
    for other in list(bpy.data.objects):
        if other != result: bpy.data.objects.remove(other, do_unlink=True)
    return result

def clean_and_orient(obj, spec):
    activate(obj); bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    obj.rotation_mode="XYZ"
    obj.rotation_euler[0]=spec.get("rotate_x",0); obj.rotation_euler[1]=spec.get("rotate_y",0); obj.rotation_euler[2]=spec.get("rotate_z",0)
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    if "target" in spec: obj.scale=tuple(spec["target"][i]/obj.dimensions[i] for i in range(3))
    else: obj.scale=(spec.get("scale",1.0),)*3
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    xs=[v.co.x for v in obj.data.vertices]; ys=[v.co.y for v in obj.data.vertices]; zs=[v.co.z for v in obj.data.vertices]
    offset=((min(xs)+max(xs))/2,(min(ys)+max(ys))/2,min(zs))
    for v in obj.data.vertices: v.co.x-=offset[0]; v.co.y-=offset[1]; v.co.z-=offset[2]
    bm=bmesh.new(); bm.from_mesh(obj.data)
    loose=[v for v in bm.verts if not v.link_faces]
    if loose: bmesh.ops.delete(bm,geom=loose,context="VERTS")
    bmesh.ops.remove_doubles(bm,verts=bm.verts,dist=.000001); bmesh.ops.recalc_face_normals(bm,faces=bm.faces)
    bm.to_mesh(obj.data); bm.free(); obj.data.update()
    return tuple(round(v,4) for v in obj.dimensions)

def material_for(kind):
    colors={"speaker_rave":(.025,.028,.032,1),"speaker":(.035,.038,.042,1),"metal":(.42,.45,.48,1),"deck":(.16,.16,.15,1),"light":(.025,.028,.032,1),"screen":(.008,.010,.012,1),"stage":(.08,.085,.09,1),"production":(.055,.06,.065,1),"equipment":(.045,.05,.06,1)}
    resource={"speaker_rave":"speaker","speaker":"speaker_generic","metal":"metal","deck":"deck","light":"light","screen":"light","stage":"metal","production":"light","equipment":"equipment"}[kind]
    mat=bpy.data.materials.new(f"EDJ_{kind}"); mat.use_nodes=False; mat.diffuse_color=colors[kind]
    mat.armaMatProps.texType="Texture"; mat.armaMatProps.texture=f"{ARMA_ROOT}\\data\\{resource}_co.paa"; mat.armaMatProps.rvMat=f"{ARMA_ROOT}\\data\\{resource}.rvmat"
    return mat

def palette_key(mat):
    """Reduce source materials to a small Arma-safe solid-color palette."""
    name=mat.name.lower()
    color=mat.diffuse_color
    if mat.use_nodes:
        # Marketplace sources frequently predate Principled BSDF and encode
        # their visible finish in Diffuse, Glossy, Glass, or Emission nodes.
        # Read the first explicit shader color so those models do not collapse
        # to Blender's pale material viewport fallback during Arma conversion.
        shader_types=("BSDF_PRINCIPLED","BSDF_DIFFUSE","BSDF_GLOSSY","BSDF_GLASS","EMISSION")
        shader=next((node for kind in shader_types for node in mat.node_tree.nodes if node.type==kind),None)
        if shader:
            color_input=shader.inputs.get("Base Color") or shader.inputs.get("Color")
            if color_input is not None: color=color_input.default_value
    r,g,b,_=color
    if any(token in name for token in ("glow","screen","emiss","blaster")): return "white"
    if r>g*1.5 and r>b*1.5: return "red"
    if g>r*1.35 and g>b*1.25: return "green"
    if b>r*1.35 and b>g*1.25: return "blue"
    if r>.45 and g>.25 and b<min(r,g)*.55: return "yellow"
    luma=.2126*r+.7152*g+.0722*b
    if luma<.025:return "black"
    if luma<.10:return "charcoal"
    if luma<.28:return "darkgray"
    if luma<.58:return "gray"
    if luma<.86:return "lightgray"
    return "white"

def palette_material(key,kind):
    name=f"EDJ_palette_{key}_{kind}"
    existing=bpy.data.materials.get(name)
    if existing:return existing
    colors={
        "black":(.035,.04,.048,1),"charcoal":(.09,.105,.125,1),
        "darkgray":(.18,.205,.235,1),"gray":(.38,.42,.47,1),
        "lightgray":(.68,.72,.76,1),"white":(.9,.92,.94,1),
        "red":(.48,.035,.045,1),"green":(.08,.48,.14,1),
        "blue":(.08,.20,.62,1),"yellow":(.72,.46,.035,1),
    }
    resource={"speaker":"speaker_generic","light":"light","production":"light","equipment":"equipment"}.get(kind,"equipment")
    mat=bpy.data.materials.new(name); mat.use_nodes=False; mat.diffuse_color=colors[key]
    mat.armaMatProps.texType="Texture"
    mat.armaMatProps.texture=f"{ARMA_ROOT}\\data\\palette_{key}_co.paa"
    mat.armaMatProps.rvMat=f"{ARMA_ROOT}\\data\\{resource}.rvmat"
    return mat

def preserve_source_palette(obj,kind,overrides=None):
    """Keep source face-color separation without shipping raw marketplace files."""
    old=list(obj.data.materials)
    if not old:return False
    overrides={name.lower():key for name,key in (overrides or {}).items()}
    keys=[overrides.get(mat.name.lower(),palette_key(mat)) if mat else "charcoal" for mat in old]
    unique=[]
    for key in keys:
        if key not in unique:unique.append(key)
    remap={index:unique.index(key) for index,key in enumerate(keys)}
    face_indices=[remap.get(face.material_index,0) for face in obj.data.polygons]
    obj.data.materials.clear()
    for key in unique:obj.data.materials.append(palette_material(key,kind))
    for face,index in zip(obj.data.polygons,face_indices):face.material_index=index
    return True

def preserve_dj_player_textures(obj):
    """Map the supplied media-player UV slots to namespaced Arma textures."""
    old=list(obj.data.materials)
    if not old:return False
    def resource(name):
        lowered=name.lower()
        if "__04" in lowered:return "dj_player_light"
        if "__02" in lowered or "__03" in lowered:return "dj_player_02"
        return "dj_player_01"
    resources=[resource(mat.name if mat else "") for mat in old]
    unique=[]
    for value in resources:
        if value not in unique:unique.append(value)
    remap={index:unique.index(value) for index,value in enumerate(resources)}
    face_indices=[remap.get(face.material_index,0) for face in obj.data.polygons]
    obj.data.materials.clear()
    colors={"dj_player_01":(.06,.065,.075,1),"dj_player_02":(.12,.13,.15,1),"dj_player_light":(.8,.55,.05,1)}
    for value in unique:
        mat=bpy.data.materials.new(f"EDJ_{value}"); mat.use_nodes=False; mat.diffuse_color=colors[value]
        mat.armaMatProps.texType="Texture"; mat.armaMatProps.texture=f"{ARMA_ROOT}\\data\\{value}_co.paa"; mat.armaMatProps.rvMat=f"{ARMA_ROOT}\\data\\{value}.rvmat"
        obj.data.materials.append(mat)
    for face,index in zip(obj.data.polygons,face_indices):face.material_index=index
    return True

def selections(obj,spec):
    obj.vertex_groups.clear()
    if spec.get("animated"):
        h=obj.dimensions.z
        obj.vertex_groups.new(name="light_pan").add([v.index for v in obj.data.vertices if v.co.z>=h*.2],1,"REPLACE")
        obj.vertex_groups.new(name="light_tilt").add([v.index for v in obj.data.vertices if v.co.z>=h*.55],1,"REPLACE")
    if spec.get("screen"): obj.vertex_groups.new(name="screen_surface").add(list(range(len(obj.data.vertices))),1,"REPLACE")

def visual(source,distance,ratio,material,dimensions,preserve_materials=False,force_smooth=True):
    obj=source.copy(); obj.data=source.data.copy(); bpy.context.collection.objects.link(obj); obj.name=f"Resolution_{distance:g}"
    if not preserve_materials:
        while obj.data.materials: obj.data.materials.pop(index=0)
        obj.data.materials.append(material)
        for face in obj.data.polygons: face.material_index=0
    if force_smooth is not None:
        for face in obj.data.polygons: face.use_smooth=force_smooth
    if ratio<.999:
        mod=obj.modifiers.new("EDJ_Decimate","DECIMATE"); mod.ratio=ratio; mod.use_collapse_triangulate=True
    obj.modifiers.new("EDJ_Triangulate","TRIANGULATE").quad_method="BEAUTY"
    obj.armaObjProps.isArmaObject=True; obj.armaObjProps.lod="-1.0"; obj.armaObjProps.lodDistance=distance
    prop=obj.armaObjProps.namedProps.add(); prop.name="autocenter"; prop.value="0"
    activate(obj)
    for modifier in list(obj.modifiers): bpy.ops.object.modifier_apply(modifier=modifier.name)
    # Aggressive decimation of imported marketplace topology can move boundary
    # vertices. Restore the audited physical envelope for every visual LOD.
    current=obj.dimensions
    obj.scale=tuple(dimensions[i]/current[i] if current[i] else 1 for i in range(3))
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    return obj

def reduced_proxy(source,distance,material,previous):
    obj=source.copy(); obj.data=source.data.copy(); bpy.context.collection.objects.link(obj); obj.name=f"Resolution_{distance:g}"
    while obj.data.materials: obj.data.materials.pop(index=0)
    obj.data.materials.append(material); activate(obj)
    bm=bmesh.new(); bm.from_mesh(obj.data)
    result=bmesh.ops.convex_hull(bm,input=list(bm.verts),use_existing_faces=False)
    discard=list(result.get("geom_unused",[]))+list(result.get("geom_interior",[]))
    if discard: bmesh.ops.delete(bm,geom=discard,context="VERTS")
    bm.to_mesh(obj.data); bm.free(); obj.data.update()
    if len(obj.data.polygons)>=previous:
        bpy.data.objects.remove(obj,do_unlink=True)
        d=source.dimensions
        if previous>6:
            bpy.ops.mesh.primitive_cube_add(location=(0,0,d.z/2)); obj=bpy.context.object; obj.scale=(d.x/2,d.y/2,d.z/2); bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
        elif previous>2:
            mesh=bpy.data.meshes.new("FarCross"); x,y,z=d.x/2,d.y/2,d.z
            mesh.from_pydata([(-x,0,0),(x,0,0),(x,0,z),(-x,0,z),(0,-y,0),(0,y,0),(0,y,z),(0,-y,z)],[],[(0,1,2,3),(4,5,6,7)])
            obj=bpy.data.objects.new(f"Resolution_{distance:g}",mesh); bpy.context.collection.objects.link(obj)
        else:
            mesh=bpy.data.meshes.new("FarPlane"); x,z=d.x/2,d.z
            mesh.from_pydata([(-x,0,0),(x,0,0),(x,0,z),(-x,0,z)],[],[(0,1,2,3)])
            obj=bpy.data.objects.new(f"Resolution_{distance:g}",mesh); bpy.context.collection.objects.link(obj)
        obj.data.materials.append(material)
    obj.name=f"Resolution_{distance:g}"; obj.armaObjProps.isArmaObject=True; obj.armaObjProps.lod="-1.0"; obj.armaObjProps.lodDistance=distance
    prop=obj.armaObjProps.namedProps.add(); prop.name="autocenter"; prop.value="0"
    return obj

def box(name,dimensions,lod,mass=0):
    bpy.ops.mesh.primitive_cube_add(location=(0,0,dimensions[2]/2)); obj=bpy.context.object; obj.name=name; obj.scale=tuple(v/2 for v in dimensions)
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True); obj.modifiers.new("EDJ_Triangulate","TRIANGULATE")
    obj.armaObjProps.isArmaObject=True; obj.armaObjProps.lod=lod; obj.armaObjProps.lodDistance=0
    if lod=="1.000e+13":
        obj.armaObjProps.mass=mass; obj.vertex_groups.new(name="component01").add(list(range(len(obj.data.vertices))),1,"REPLACE")
        bm=bmesh.new(); bm.from_mesh(obj.data); layer=bm.verts.layers.float.new("FHQWeights")
        for vertex in bm.verts: vertex[layer]=mass/len(bm.verts)
        bm.to_mesh(obj.data); bm.free()
    return obj

def component_boxes(name,components,lod,mass=0):
    """Create one closed convex box per cabinet while retaining one Arma LOD."""
    objects=[]
    for index,component in enumerate(components,1):
        dimensions=component["dimensions"]
        if "center" in component:
            location=component["center"]
        else:
            x,y,z=component.get("location",(0,0,0))
            location=(x,y,z+dimensions[2]/2)
        rotation=(component.get("rotate_x",0),component.get("rotate_y",0),component.get("rotate_z",0))
        bpy.ops.mesh.primitive_cube_add(location=location,rotation=rotation)
        obj=bpy.context.object; obj.name=f"{name}_{index:02d}"; obj.scale=tuple(value/2 for value in dimensions)
        bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
        if lod=="1.000e+13":
            obj.vertex_groups.new(name=f"component{index:02d}").add(list(range(len(obj.data.vertices))),1,"REPLACE")
        objects.append(obj)
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects: obj.select_set(True)
    bpy.context.view_layer.objects.active=objects[0]
    if len(objects)>1: bpy.ops.object.join()
    result=bpy.context.view_layer.objects.active; result.name=name
    result.modifiers.new("EDJ_Triangulate","TRIANGULATE")
    activate(result); bpy.ops.object.modifier_apply(modifier="EDJ_Triangulate")
    result.armaObjProps.isArmaObject=True; result.armaObjProps.lod=lod; result.armaObjProps.lodDistance=0
    if lod=="1.000e+13":
        result.armaObjProps.mass=mass
        bm=bmesh.new(); bm.from_mesh(result.data); layer=bm.verts.layers.float.new("FHQWeights")
        for vertex in bm.verts: vertex[layer]=mass/len(bm.verts)
        bm.to_mesh(result.data); bm.free()
    return result

def add_memory(spec,d):
    kind=spec.get("memory")
    if not kind:return
    h=d[2]
    if kind=="light": verts=[(0,0,h*.7),(0,max(d[1]*.45,.1),h*.7),(0,0,h*.2),(0,0,h*.5)]; groups={"light_pos":[0],"light_dir":[1],"axis_pan":[2,3],"axis_tilt":[0,1]}
    else: verts=[(0,0,h*.55)]; groups={kind:[0]}
    mesh=bpy.data.meshes.new("Memory"); mesh.from_pydata(verts,[],[]); obj=bpy.data.objects.new("Memory",mesh); bpy.context.collection.objects.link(obj)
    obj.armaObjProps.isArmaObject=True; obj.armaObjProps.lod="1.000e+15"
    for name,indices in groups.items(): obj.vertex_groups.new(name=name).add(indices,1,"REPLACE")

def add_roadway(d):
    x,y,z=d[0]/2,d[1]/2,d[2]; mesh=bpy.data.meshes.new("Roadway"); mesh.from_pydata([(-x,-y,z),(x,-y,z),(x,y,z),(-x,y,z)],[],[(0,1,2),(0,2,3)])
    obj=bpy.data.objects.new("Roadway",mesh); bpy.context.collection.objects.link(obj); obj.armaObjProps.isArmaObject=True; obj.armaObjProps.lod="3.000e+15"

def export_asset(spec,mdl):
    clear_scene(); source=load_objects(spec); d=clean_and_orient(source,spec); selections(source,spec); material=material_for(spec["material"]); count=len(source.data.polygons)
    mode=spec.get("material_mode")
    preserve_materials=(mode=="palette" and preserve_source_palette(source,spec["material"],spec.get("palette_overrides"))) or (mode=="dj_player_textures" and preserve_dj_player_textures(source))
    base=spec.get("base_ratio",1 if count<=6000 else .55 if count<=20000 else .18)
    # Marketplace stage meshes contain thousands of disconnected tubes, roof
    # panels, fixtures, and fabric pieces.  Large ratio jumps in the collapse
    # decimator turn those components into long stray triangles.  Build the
    # first optimized LOD once, then keep each later LOD close to that proven
    # silhouette.  This intentionally favors stable event scenery over a small
    # PBO or an aggressively reduced distant model.
    ratios=spec.get("lod_ratios",tuple(max(base*factor,.012) for factor in (1.0,.98,.96,.94)))
    lods=[]; previous=10**12
    for distance,ratio in zip((1,5,15,40),ratios):
        obj=visual(source,distance,ratio,material,d,preserve_materials,spec.get("force_smooth",True))
        if len(obj.data.polygons)>previous:
            bpy.data.objects.remove(obj,do_unlink=True); obj=reduced_proxy(source,distance,material,previous)
        lods.append(obj); previous=len(obj.data.polygons)
    bpy.data.objects.remove(source,do_unlink=True)
    components=spec.get("geometry_components")
    if not spec.get("decorative"):
        if components: component_boxes("Geometry",components,"1.000e+13",spec.get("mass",25))
        else: box("Geometry",spec.get("geometry_dims",d),"1.000e+13",spec.get("mass",25))
    if components: component_boxes("ShadowVolume",components,"1.100e+4")
    else: box("ShadowVolume",d,"1.100e+4")
    add_memory(spec,d)
    if spec.get("roadway"): add_roadway(spec.get("roadway_dims",d))
    output=OUTPUT/f"{spec['file']}.p3d"
    with output.open("wb") as handle: mdl.exportMDL(None,handle,False,True,True,True,True)
    if output.read_bytes()[:4]!=b"MLOD": raise RuntimeError(f"bad MLOD: {output}")
    bpy.ops.wm.save_as_mainfile(filepath=str(BLENDS/f"{spec['file']}.blend"))
    return {"class":spec["class"],"file":str(output.relative_to(REPO)),"bytes":output.stat().st_size,"dimensions":d,"sourcePolygons":count,"lodPolygons":[len(o.data.polygons) for o in lods]}

def main():
    OUTPUT.mkdir(parents=True,exist_ok=True); BLENDS.mkdir(parents=True,exist_ok=True)
    if not hasattr(bpy.types.Material,"armaMatProps"): bpy.ops.preferences.addon_enable(module="bl_ext.user_default.ArmaToolbox")
    mdl=importlib.import_module("bl_ext.user_default.ArmaToolbox.MDLExporter"); records=[]
    start=int(os.environ.get("EDJ_BUILD_START","1"))
    only={item.strip() for item in os.environ.get("EDJ_BUILD_ONLY","").split(",") if item.strip()}
    for index,spec in enumerate(ASSETS,1):
        if index<start: continue
        if only and spec["class"] not in only: continue
        print(f"EDJ_BUILDING={index}/{len(ASSETS)}:{spec['class']}"); records.append(export_asset(spec,mdl))
    (WORK/"asset-build-report.json").write_text(json.dumps({"assets":records},indent=2),encoding="utf-8"); print("EDJ_ASSET_BUILD="+json.dumps({"count":len(records)}))
if __name__=="__main__": main()
