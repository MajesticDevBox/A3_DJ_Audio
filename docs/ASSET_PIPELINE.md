# Event DJ asset pipeline

## Installed environment

The V0.2.5 pipeline was validated on Windows with:

- Blender **5.2.1 LTS** at `C:\Program Files\Blender Foundation\Blender 5.2\blender.exe`.
- [Arma Toolbox for Blender **4.2.3**](https://github.com/AlwarrenSidh/ArmAToolbox/releases/tag/v4.2.3), SHA-256 `D8BC24FAB55F40E170410821CED5D100F01998168297A7C16E752FADAF13AF56`. It was installed from the official project release because Blender had no P3D exporter. The extension successfully exports and re-imports unbinarized MLOD P3Ds under Blender 5.2.1.
- Arma 3 Tools with Object Builder, O2Script, Binarize, ImageToPAA/Pal2PacE, Buldozer, and Buldozer Configurator present under `C:\Program Files (x86)\Steam\steamapps\common\Arma 3 Tools`.
- HEMTT **1.21.0**. The release gate validates and binarizes all ten P3Ds in the reviewed production catalog and builds the existing addon set plus the isolated asset PBO.

## Directory policy

`G:\1 ARMA3_DEVELOPMENT\Blinder Assets` is read-only. `tools/stage_asset_sources.ps1` records SHA-256 hashes, copies the selected inputs, and verifies that every original hash is unchanged. Work takes place under:

```text
asset_work/
├── source_copies/  # marketplace working copies and source hash manifest
├── blender/        # editable conversion scenes
├── exports/        # reserved intermediate exchange files
├── textures/       # generated intermediate textures
├── validation/     # inventory, P3D re-import reports, previews
└── notes/          # local build logs
```

The entire directory is ignored by Git. Production files are limited to `addons/assets/`: P3D, PAA, RVMAT, `config.cpp`, `model.cfg`, and `$PBOPREFIX$`. Marketplace `.blend`, `.fbx`, `.obj`, `.max`, `.gltf`, archives, and development-drive paths must fail the release audit.

## Repeatable build

From the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\inventory_asset_library.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_assets.ps1
hemtt check
hemtt build
```

`build_assets.ps1` stages working copies, generates controlled surface textures, converts the RaveSpace base-color and normal maps, creates every MLOD in the current ingestion plan, and re-imports every P3D. `validate_asset_models.py` requires four non-increasing visual LODs, ShadowVolume, Geometry except for explicitly documented decorative shells, and no printable development path inside a model.

`inventory_asset_library.ps1` reads one canonical richest scene from each pack. `generate_asset_coverage.py` assigns exactly one terminal status to every object, writes the source inventory, and reconciles totals in `ASSET_COVERAGE.md`. Alternate exports of the same scene are audited as source files without multiplying the object count.

## Model conversion

All selected meshes have evaluated source modifiers baked, are centered in X/Y with their origin on the ground plane, have loose vertices removed, duplicate vertices merged at a one-micrometer tolerance, and face normals recalculated. The conversion uses uniform scale unless a source-specific dimensional target has been justified.

The current catalog contains the retained curved three-cabinet horn array, five assemblies built from the user-selected RaveSpace source files, and four user-selected DJ/audio props. Each source was normalized with uniform scale, corrected to stand upright on Z=0, and kept at an equipment-scale envelope. Every speaker cabinet receives its own coarse convex Geometry and ShadowVolume box. Each console/controller uses one coarse closed proxy rather than detailed controls for collision.

| Class | Final size | Visual LOD polygons at 1 / 5 / 15 / 40 | Geometry | Extra LOD/data |
| --- | --- | --- | --- | --- |
| `EDJ_Speaker_HornArray_Curved_03` | 1.647 x 0.661 x 0.900 m | 5436 / 3912 / 2064 / 868 | Three cabinet boxes, 102 kg | `audio_origin` Memory point |
| `EDJ_Speaker_LineArray_Curved_04` | 0.800 x 0.645 x 0.963 m | 4224 / 3040 / 1604 / 674 | Four cabinet boxes, 136 kg | `audio_origin` Memory point |
| `EDJ_Speaker_LineArray_Straight_04` | 0.800 x 0.500 x 1.015 m | 4224 / 3040 / 1604 / 674 | Four cabinet boxes, 136 kg | `audio_origin` Memory point |
| `EDJ_Speaker_HornArray_Straight_03` | 1.654 x 0.565 x 0.900 m | 5436 / 3912 / 2064 / 868 | Three cabinet boxes, 102 kg | `audio_origin` Memory point |
| `EDJ_Speaker_SubwooferArray_Straight_03` | 1.816 x 0.800 x 1.000 m | 5316 / 3826 / 2020 / 850 | Three cabinet boxes, 186 kg | `audio_origin` Memory point |
| `EDJ_Speaker_LineArray_CurvedStack_08` | 0.800 x 0.653 x 1.995 m | 8448 / 6082 / 3209 / 1350 | Eight cabinet boxes, 272 kg | `audio_origin` Memory point |
| `EDJ_DJ_MediaPlayer_01` | 0.325 x 0.388 x 0.136 m | 49700 / 27335 / 12425 / 4969 | One equipment box, 6 kg | `control_origin` Memory point |
| `EDJ_DJ_Controller_01` | 0.750 x 0.401 x 0.121 m | 79170 / 43542 / 19792 / 7916 | One equipment box, 9 kg | `control_origin` Memory point |
| `EDJ_Audio_MixingConsole_01` | 1.100 x 0.902 x 0.235 m | 66993 / 33496 / 14738 / 5358 | One equipment box, 22 kg | `control_origin` Memory point |
| `EDJ_DJ_PerformanceKeyboard_01` | 1.378 x 0.529 x 0.156 m | 19407 / 12031 / 5433 / 1939 | One equipment box, 17 kg | `control_origin` Memory point |

Geometry remains coarse and convex so grille, horn, and cabinet hardware do not become collision surfaces. No View Geometry, Fire Geometry, or Roadway LOD is added to these speaker props.

## Materials and textures

RaveSpace supplies Base Color, Normal, and Roughness at 4K. Base Color and Normal are downsampled to 2048 and converted to `speaker_co.paa` and `speaker_nohq.paa`. The grayscale roughness map was reviewed but is not copied directly: Arma expects channel-packed specular/gloss information rather than a standalone PBR roughness map, so `speaker.rvmat` uses a conservative fabric/cabinet specular response.

The six speaker assemblies use the supplied RaveSpace texture set. The media
player preserves three supplied 2K diffuse/normal material groups through
namespaced PAA/RVMAT resources. The controller, mixing console, and keyboard use
a compact EDJ material palette derived from their procedural node base colors.
All P3D face paths are `z\edj\addons\assets\...`; no source-drive texture
reference survives export.

## Architecture and future work

The models are visual/physical props only. Ten placed speaker cabinets do not create ten music streams and do not register as Event DJ emitters. `audio_origin` is a future logical linking point for V0.3; it is inert in V0.2.5.

`simpleObject` is enabled for all ten static props because they have no scripted state. The DJ/audio `control_origin` points are inert preparation for later integration.

Use Object Builder and Buldozer for an optional manual technical inspection of selections, mass, convexity, and shadow volume. Blender re-import and HEMTT binarization are automated gates; they do not replace the Eden/Zeus, visual, collision, shadow, performance, or dedicated-server tests in `V0.2.5_VALIDATION.md`.
