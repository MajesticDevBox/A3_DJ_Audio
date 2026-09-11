"""Inventory a local marketplace source file from Blender without modifying it.

Run with Blender in background mode, for example:
  blender --background --python tools/inventory_asset_source.py -- path/to/model.blend
"""

from __future__ import annotations

import hashlib
import json
import pathlib
import sys

import bpy
from mathutils import Vector


def source_argument() -> pathlib.Path:
    args = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    if len(args) != 1:
        raise SystemExit("expected exactly one source path after --")
    return pathlib.Path(args[0]).resolve()


def clear_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)


def load_source(source: pathlib.Path) -> None:
    suffix = source.suffix.lower()
    if suffix == ".blend":
        bpy.ops.wm.open_mainfile(filepath=str(source), load_ui=False)
    elif suffix == ".obj":
        clear_scene()
        bpy.ops.wm.obj_import(filepath=str(source))
    elif suffix == ".fbx":
        clear_scene()
        bpy.ops.import_scene.fbx(filepath=str(source))
    elif suffix in {".glb", ".gltf"}:
        clear_scene()
        bpy.ops.import_scene.gltf(filepath=str(source))
    elif suffix == ".dae":
        clear_scene()
        bpy.ops.wm.collada_import(filepath=str(source))
    else:
        raise SystemExit(f"unsupported source format: {suffix}")


def main() -> None:
    source = source_argument()
    load_source(source)
    rows = []
    for obj in sorted(bpy.data.objects, key=lambda item: item.name.casefold()):
        mesh = obj.data if obj.type == "MESH" else None
        mesh_hash = ""
        if mesh is not None:
            digest = hashlib.sha256()
            for vertex in mesh.vertices:
                digest.update(("%.6f,%.6f,%.6f;" % tuple(vertex.co)).encode("ascii"))
            for polygon in mesh.polygons:
                digest.update((",".join(str(index) for index in polygon.vertices) + ";").encode("ascii"))
            mesh_hash = digest.hexdigest()
        world_corners = [obj.matrix_world @ Vector(corner) for corner in obj.bound_box]
        world_bounds = {
            "min": [round(min(corner[index] for corner in world_corners), 4) for index in range(3)],
            "max": [round(max(corner[index] for corner in world_corners), 4) for index in range(3)],
        }
        rows.append(
            {
                "name": obj.name,
                "type": obj.type,
                "meshName": mesh.name if mesh else "",
                "meshHash": mesh_hash,
                "vertices": len(mesh.vertices) if mesh else 0,
                "polygons": len(mesh.polygons) if mesh else 0,
                "dimensions": [round(value, 4) for value in obj.dimensions],
                "location": [round(value, 4) for value in obj.location],
                "worldBounds": world_bounds,
                "rotation": [round(value, 6) for value in obj.rotation_euler],
                "scale": [round(value, 6) for value in obj.scale],
                "parent": obj.parent.name if obj.parent else "",
                "children": sorted(child.name for child in obj.children),
                "collections": sorted(collection.name for collection in obj.users_collection),
                "hiddenViewport": obj.hide_viewport,
                "hiddenRender": obj.hide_render,
                "materials": [slot.material.name if slot.material else "" for slot in obj.material_slots],
                "uvLayers": [layer.name for layer in mesh.uv_layers] if mesh else [],
                "modifiers": [modifier.type for modifier in obj.modifiers],
                "vertexGroups": [group.name for group in obj.vertex_groups],
                "animated": bool(obj.animation_data and obj.animation_data.action),
                "rigged": obj.type == "ARMATURE"
                or bool(obj.parent and obj.parent.type == "ARMATURE")
                or any(modifier.type == "ARMATURE" for modifier in obj.modifiers),
            }
        )
    images = [
        {"name": image.name, "width": image.size[0], "height": image.size[1], "source": image.filepath}
        for image in bpy.data.images
        if image.size[0] and image.size[1]
    ]
    print(
        "EDJ_ASSET_INVENTORY="
        + json.dumps(
            {
                "source": str(source),
                "scene": bpy.context.scene.name,
                "collections": sorted(collection.name for collection in bpy.data.collections),
                "objects": rows,
                "meshes": [row for row in rows if row["type"] == "MESH"],
                "images": images,
                "actions": [action.name for action in bpy.data.actions],
                "armatures": [armature.name for armature in bpy.data.armatures],
            }
        )
    )


if __name__ == "__main__":
    main()
