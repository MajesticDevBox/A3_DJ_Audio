# Blender to Arma 3 Export Guide

This guide uses `asset_work/legacy_ravespace_stacks/horn_row_curved_3.blend` as a concrete example. The original `.blend` is source art and should remain unchanged. Perform the Arma preparation in a working copy.

## Audited source

The file was inspected in Blender 5.2.1 LTS.

| Property | Measured value |
|---|---:|
| Unit system | Metric, 1 Blender unit = 1 metre |
| Cabinets | 3 independent mesh objects |
| Combined mesh bounds | approximately 1.647 x 0.661 x 0.900 m |
| Resolution 0 triangles | 5,436 total |
| UV maps | one `UVMap` per cabinet |
| Source material | one Blender material, `RAS` |
| Source textures | packed 4096 x 4096 base colour, normal, and roughness images |
| Loose vertices/edges | none |
| Open boundary edges | 258 per cabinet |
| Arma LOD metadata | not assigned |

The dimensions are plausible for a row of three compact horn cabinets. The centre cabinet has zero rotation. The left and right cabinets use intentional Z rotations of -12 and +12 degrees to form the curve. Their scales are already 1,1,1.

The high-detail geometry is suitable as the starting point for Resolution LOD 0. It is not suitable for Geometry or ShadowVolume because it contains open boundaries and detailed horn surfaces.

## 1. Make an Arma working copy

Open the source file and immediately use **File > Save As**:

```text
horn_row_curved_3_arma.blend
```

Keep these source objects untouched in a disabled collection:

```text
SOURCE_ARCHIVE
  horn_row_curved_3_01
  horn_row_curved_3_02
  horn_row_curved_3_03
```

Move the camera and three area lights to a separate `PREVIEW_ONLY` collection. They must never be selected for FBX or P3D export.

## 2. Create Resolution LOD 0

Duplicate the three cabinet meshes into a collection named `LOD_0`.

On the duplicates:

1. Select all three cabinets.
2. Use **Object > Apply > Rotation & Scale**.
3. Verify that all three objects now show rotation 0,0,0 and scale 1,1,1.
4. Confirm that the curved arrangement did not change.
5. Join the duplicates into one object if the array will always be placed as one prop.
6. Name the joined object `horn_row_curved_3_LOD0`.
7. Put its origin at the bottom centre of the complete array.
8. Place the bottom contact plane at Z = 0.

Applying the side rotations bakes the intentional curve into the vertices. It prevents an exporter from dropping or interpreting the two object-level rotations differently.

The resulting object should remain approximately:

```text
Width:  1.647 m
Depth:  0.661 m
Height: 0.900 m
```

Do not scale this assembly to a guessed target size during export. Correct the Blender source dimensions and keep export scale at 1.0.

## 3. Prepare Arma materials

The source has one Blender material using packed base-colour, normal, and roughness images. That material is useful for authoring but does not directly become an Arma RVMAT.

Unpack or save copies of the images into the addon data directory. Use Arma-style names:

```text
horn_row_curved_3_co.png
horn_row_curved_3_nohq.png
horn_row_curved_3_roughness_source.png
```

Convert the final engine textures to PAA with ImageToPAA or through the HEMTT/Binarize pipeline.

Do not rename the roughness image to `_smdi`. An Arma SMDI texture encodes specular data and must be authored from the source roughness/specular information with the correct channel layout.

Create an RVMAT that references the final `_nohq`, `_smdi`, and optional `_as` maps. Assign the RVMAT and `_co.paa` texture to the Resolution LOD faces through Arma Toolbox or Object Builder.

Inspect the normal map in Buldozer. If dents appear raised or highlights respond backward, correct the normal-map channel orientation at the texture-authoring stage.

## 4. Create visual LODs

Duplicate the completed LOD 0 object for each lower-detail version. Simplify each copy deliberately.

| Blender/FBX name | Starting target | Preserve |
|---|---:|---|
| `horn_row_curved_3_LOD0` | 5,436 triangles | Full cabinet, grille, labels and horn openings |
| `horn_row_curved_3_LOD1` | 2,500-3,500 triangles | Curved silhouette and major horn shapes |
| `horn_row_curved_3_LOD2` | 900-1,800 triangles | Three-cabinet silhouette and large openings |
| `horn_row_curved_3_LOD5` | 250-600 triangles | Cabinet arrangement and front/back distinction |
| `horn_row_curved_3_LOD10` | 60-200 triangles | Coarse curved row silhouette |

Use these as initial budgets, then judge transitions in Eden. Do not produce lower LODs by copying the same mesh unchanged.

For LOD 1, remove small branding geometry, tiny fasteners, grille depth, and unseen interior details. For LOD 2, replace detailed horn interiors with shallow shapes or textured faces. For LOD 5 and LOD 10, retain the three-box curved outline so the asset does not visibly collapse into an unrelated rectangle.

After decimation or manual retopology:

1. Apply modifiers.
2. Merge accidental duplicate vertices.
3. Recalculate normals outside.
4. Triangulate.
5. Check the model from the front, rear, both sides and above.
6. Verify that no isolated triangles moved away from the cabinets.

## 5. Build Geometry LOD

Do not copy the horn meshes into Geometry. Build three new closed convex cabinet hulls instead.

Use one simple box or convex hull for each cabinet and match its 12-degree placement. Leave out the horn cavities, grille depth, side handles and labels.

Name the components:

```text
component01
component02
component03
```

Assign mass in Object Builder or Arma Toolbox. A starting total mass around 75-150 kg is reasonable for a movable three-cabinet audio assembly, but the final value should follow the intended equipment specification and simulation class.

The Geometry LOD must be:

- closed;
- convex per component;
- much simpler than the visible model;
- validated in Object Builder;
- free of distant vertices and oversized empty bounds.

## 6. Build other functional LODs

### View Geometry

Duplicate the three simple cabinet hulls. Use them to block player and AI visibility through the assembly.

### Fire Geometry

Use the same basic three-cabinet arrangement or a slightly closer convex representation. Apply an appropriate penetration material if the prop is expected to respond to weapon hits.

### ShadowVolume

Create three closed, triangulated, sharp-edged cabinet shapes. They may include the major front recess, but should omit grille holes, branding, screws and internal horn vanes. Keep the shadow volume slightly inside the visible surface to reduce self-shadow artifacts.

### LandContact

Add contact vertices at the lowest support corners. Because all three cabinets currently reach Z = 0, use enough points to support the left, centre and right sections without producing an unintended tilt.

### Memory

Add a named memory point:

```text
audio_origin
```

Place it near the acoustic centre of the row, approximately centred in X, near the front of the cabinets, and around mid-height. Use the exact selection name expected by Event DJ's audio code.

## 7. Mark the objects for Arma Toolbox

For direct MLOD P3D export, mark each prepared mesh as an Arma object and assign its LOD type/distance in Arma Toolbox:

```text
Resolution 0
Resolution 1
Resolution 2
Resolution 5
Resolution 10
Geometry
View Geometry
Fire Geometry
ShadowVolume
LandContact
Memory
```

Set the resolution objects' named property:

```text
autocenter = 0
```

This preserves the deliberately authored origin instead of allowing the model to be recentered during processing.

If using FBX through Object Builder, keep the documented `NAME_LOD###` object naming and verify every imported LOD before saving the MLOD P3D.

## 8. Export and validate

Export only the prepared Arma LOD objects. Do not export:

- the `SOURCE_ARCHIVE` collection;
- Camera;
- Area, Area.001 or Area.002;
- preview backgrounds;
- duplicate hidden source meshes.

Open the MLOD P3D in Object Builder and verify:

1. Overall dimensions remain approximately 1.647 x 0.661 x 0.900 m.
2. All three cabinets face the intended direction.
3. The curved arrangement is preserved.
4. The bottom is at Z = 0.
5. Texture and RVMAT paths use the addon prefix.
6. Resolution LODs switch without isolated or stretched triangles.
7. Geometry components are closed, convex and named consecutively.
8. Mass is assigned.
9. ShadowVolume is closed and triangulated.
10. `audio_origin` exists in Memory LOD.

Preview it in Buldozer before binarization.

## 9. Add model configuration

For a static non-animated horn row, the model definition can remain small:

```cpp
class CfgSkeletons
{
};

class CfgModels
{
    class Default
    {
        sectionsInherit = "";
        sections[] = {};
        skeletonName = "";
    };

    class horn_row_curved_3: Default
    {
        sections[] =
        {
            "camo"
        };
    };
};
```

The `CfgModels` class name must match the final P3D filename without `.p3d`. Add only selections that actually exist and are used by hidden textures, materials, damage behavior, or animations.

## 10. Build and perform the real acceptance test

Run:

```powershell
hemtt check
hemtt build
```

Then place the horn row in Eden next to a standing soldier and existing speakers. Confirm:

- realistic scale;
- upright orientation;
- correct front direction;
- no floating pieces;
- readable material separation;
- correct ground placement;
- usable collision around all three cabinets;
- weapon collision where intended;
- plausible shadow;
- clean LOD transitions;
- audible origin in the expected position;
- no P3D, material, texture or config errors in the RPT.

The build result is an automated packaging check. It does not replace the Eden visual, collision, or audio acceptance test.
