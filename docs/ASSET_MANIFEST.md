# Event DJ asset manifest

This manifest records the V0.2.5 intake decision for every known marketplace pack. The original library at `G:\1 ARMA3_DEVELOPMENT\Blinder Assets` is read-only. Conversion scripts copy only selected inputs into ignored `asset_work/`; no marketplace source format is part of the addon or release.

CGTrader describes the listed license as permitting use inside a game when the model is incorporated in a proprietary format and cannot be retrieved as a standalone asset. It prohibits redistribution in the downloaded form and requires reasonable safeguards. Event DJ therefore distributes only binarized P3D/PAA/RVMAT content inside PBOs. See the [CGTrader Royalty Free License](https://help.cgtrader.com/hc/en-us/articles/360015124437-Royalty-Free-License).

The full machine-readable inventory is generated locally at `asset_work/validation/source-inventory.json` by `tools/inventory_asset_library.ps1`. Counts below describe the inspected source scenes and are not release contents.

## RaveSpace PA Free Audio Systems Speaker Set

- **Asset Pack:** RaveSpace Audio Systems
- **Original Creator:** konstantin-andoerfer
- **Marketplace:** CGTrader
- **Source URL:** https://www.cgtrader.com/free-3d-models/electronics/audio/ravespace-audio-systems
- **Local Source Path:** `G:\1 ARMA3_DEVELOPMENT\Blinder Assets\RAVESpace - Speakers`
- **License Name:** Royalty Free License (no AI), confirmed on the source listing
- **License/Credit File:** No local credit or license text was present
- **Required Credit:** None stated locally; attribution is retained in Event DJ documentation
- **Modification Permission:** Allowed for an incorporated product under the marketplace license
- **Redistribution Permission:** Incorporated, safeguarded game asset only
- **Raw Source Redistribution Permission:** No
- **Workshop Status:** APPROVED
- **Notes:** Three separate UV-mapped meshes were inventoried: `RA-LT01` (592 vertices, 534 source polygons, 0.500 x 0.249 x 0.800 m), `RA_MT01`, and `RA_SUB01` (888 vertices, 707 source polygons, 0.800 x 1.000 x 0.600 m). All three are converted at their corrected native proportions. The 4K base-color and normal maps were reviewed and converted to 2048 PAA. A prior raw working assembly was moved from `assets/ravespace_stacks` into ignored `asset_work/legacy_ravespace_stacks`.

## Truss system line array

- **Asset Pack:** Truss system line array
- **Original Creator:** sibawalkece
- **Marketplace:** CGTrader
- **Source URL:** https://www.cgtrader.com/free-3d-models/industrial/other/truss-system-line-array
- **Local Source Path:** `G:\1 ARMA3_DEVELOPMENT\Blinder Assets\truss system line array`
- **License Name:** Royalty Free License (no AI), confirmed on the source listing
- **License/Credit File:** `New Text Document.txt`
- **Required Credit:** “Give credit to sibawalkece”
- **Modification Permission:** Allowed for an incorporated product under the marketplace license
- **Redistribution Permission:** Incorporated, safeguarded game asset only
- **Raw Source Redistribution Permission:** No
- **Workshop Status:** APPROVED
- **Notes:** 72 meshes, 67,995 vertices, and 57,670 polygons were inventoried. The native 2 m object `200` is a separate 0.4 x 0.4 x 2.0 m mesh with one UV map and a Solidify modifier. It was rotated into a horizontal modular section without changing its 2.0 x 0.4 x 0.4 m scale.

## Arena Stage Venue Props Pack — Modular Event Stage

- **Asset Pack:** Arena Stage Venue Props Pack — Modular Event Stage
- **Original Creator:** ogilko
- **Marketplace:** CGTrader
- **Source URL:** https://www.cgtrader.com/free-3d-models/exterior/exterior-public/arena-stage-venue-props-pack-modular-event-stage
- **Local Source Path:** `G:\1 ARMA3_DEVELOPMENT\Blinder Assets\Arena Stage Venue Props Pack -  Modular Event Stage`
- **License Name:** Royalty Free License (no AI), confirmed on the source listing
- **License/Credit File:** `New Text Document.txt`
- **Required Credit:** “Give credit to ogilko”
- **Modification Permission:** Allowed for an incorporated product under the marketplace license
- **Redistribution Permission:** Incorporated, safeguarded game asset only
- **Raw Source Redistribution Permission:** No
- **Workshop Status:** APPROVED
- **Notes:** 95 meshes, 1,185,529 vertices, 1,275,663 polygons, 31 loaded images, and no animation actions were inventoried. Reusable platforms, barriers, fixtures, speakers, screens, roof/wall structures, truss families, and assembled rigs were selected. `SM_04` is the modular square platform: 5,422 vertices, 3,618 source polygons, three materials, two UV sets, and source dimensions 3.925 x 4.210 x 1.013 m. It uses a uniform 0.5 conversion scale, producing an approximately 1.963 x 2.105 x 0.507 m walk-on deck without distorting its proportions.

## Various projection, sound and lighting devices

- **Asset Pack:** Various projection, sound and lighting devices for parties
- **Original Creator:** Yousef696
- **Marketplace:** CGTrader
- **Source URL:** https://www.cgtrader.com/free-3d-models/electronics/other/various-projection-sound-and-lighting-devices-for-parti
- **Local Source Path:** `G:\1 ARMA3_DEVELOPMENT\Blinder Assets\Various projection sound and lighting devices`
- **License Name:** Royalty Free License (no AI), confirmed on the source listing
- **License/Credit File:** No local credit or license text was present
- **Required Credit:** None stated locally; attribution is retained in Event DJ documentation
- **Modification Permission:** Allowed for an incorporated product under the marketplace license
- **Redistribution Permission:** Incorporated, safeguarded game asset only
- **Raw Source Redistribution Permission:** No
- **Workshop Status:** APPROVED
- **Notes:** 133 meshes, 379,516 vertices, 366,833 polygons, one loaded image, and two source animation actions were inventoried. The useful catalog includes speakers, truss, PAR and wash fixtures, stands, a stage deck, consoles, a portable projection screen, and a power distribution unit. The moving head combines its actual parented head and yoke, removes the source scene's remote transform, and retains `light_pos`, `light_dir`, pan/tilt axes, and future pan/tilt selections. No active lamp or controller behavior is included.

## Event Stage setup

- **Asset Pack:** Event Stage setup
- **Original Creator:** designerkrishnan
- **Marketplace:** CGTrader
- **Source URL:** https://www.cgtrader.com/free-3d-models/exterior/stadium/event-stage-setup
- **Local Source Path:** `G:\1 ARMA3_DEVELOPMENT\Blinder Assets\Event Stage setup`
- **License Name:** Royalty Free License (no AI), confirmed on the source listing
- **License/Credit File:** `New Text Document.txt`
- **Required Credit:** “Give credit to designerkrishnan”
- **Modification Permission:** Allowed for an incorporated product under the marketplace license
- **Redistribution Permission:** Incorporated, safeguarded game asset only
- **Raw Source Redistribution Permission:** No
- **Workshop Status:** APPROVED
- **Notes:** 94 meshes, 307,835 vertices, 288,949 polygons, and no animation actions were inventoried. The platform, stairs, screen families, side wing, truss towers, PAR fixture, and optimized complete stage are converted. The complete asset uses only the 12.192 x 6.096 x 0.762 m platform for Geometry and Roadway so the surrounding truss and screen envelope does not create invisible collision.

## DJ Player

- **Asset Pack:** DJ player Free 3D model
- **Original Creator:** kuriko1984
- **Marketplace:** CGTrader
- **Source URL:** https://www.cgtrader.com/free-3d-models/electronics/audio/dj-player-c0b8baf1-6288-408d-bfa6-c7201ac259bb
- **Local Source Path:** `G:\1 ARMA3_DEVELOPMENT\Blinder Assets\DJ player Free 3D model`
- **License Name:** Royalty Free License (no AI), confirmed on the listing
- **License/Credit File:** `New Text Document.txt`
- **Required Credit:** “Give credit to kuriko1984”
- **Modification Permission:** Allowed for an incorporated product under the marketplace license, once the model is locally available
- **Redistribution Permission:** Incorporated, safeguarded game asset only
- **Raw Source Redistribution Permission:** No
- **Workshop Status:** REVIEW REQUIRED
- **Notes:** **DEFERRED — SOURCE NOT PRESENT.** The local directory contains only the credit text. No `EDJ_DJ_Player_01` class or model was created.

## Music Mixtable

- **Asset Pack:** Music Mixtable
- **Original Creator:** basicsdone
- **Marketplace:** CGTrader
- **Source URL:** https://www.cgtrader.com/free-3d-models/electronics/audio/music-mixtable
- **Local Source Path:** `G:\1 ARMA3_DEVELOPMENT\Blinder Assets\Music Mixtable`
- **License Name:** Not relied upon; explicit creator permission remains pending
- **License/Credit File:** `New Text Document.txt`
- **Required Credit:** “Give credit to basicsdone”
- **Modification Permission:** Pending explicit permission
- **Redistribution Permission:** Pending explicit permission
- **Raw Source Redistribution Permission:** No
- **Workshop Status:** HOLD
- **Notes:** **LICENSE HOLD.** Inventory-only access is allowed. No source file was staged, converted, configured, packed, or published.
## Production conversion manifest


The fresh production plan contains **10 placeable production assets**. Each item below is generated from `tools/asset_ingestion_plan.py`; the preserved source library is recorded in `ASSET_SOURCE_INVENTORY.md`.

### EDJ_Speaker_HornArray_Curved_03 — Curved Horn Array 3 Cabinet 01

- **Source pack/file/object(s):** RaveSpace PA Free Audio Systems Speaker Set / `horn_row_curved_3_retained.blend` / `Resolution_1`
- **Creator/license/source:** konstantin-andoerfer; CGTrader Royalty Free License (no AI); https://www.cgtrader.com/free-3d-models/electronics/audio/ravespace-audio-systems
- **Conversion status:** CONVERTED_PLACEABLE
- **Category/config/P3D:** EDJ_AudioSpeakers; `EDJ_Speaker_HornArray_Curved_03`; `\z\edj\addons\assets\models\speaker_hornarray_curved_03.p3d`
- **Texture/RVMAT:** `data\speaker_co.paa`; matching namespaced RVMAT
- **Built dimensions:** 1.6474 x 0.6606 x 0.9 m
- **Visual LODs:** 1 / 5 / 15 / 40; conservative silhouette-preserving reduction and P3D re-import validation.
- **Geometry/View/Fire/Shadow:** simplified convex Geometry; Omitted; coarse Geometry provides physical collision and separate view blocking is not required. Omitted; event props are not intended as ballistic cover. optimized ShadowVolume proxy.
- **Memory/animation:** audio_origin; no active animation.
- **Screen support:** Not applicable
- **Simple object/Eden/Zeus:** Yes / Yes / Yes.
- **Known issues:** User confirmed correct scale and runtime behavior on 2026-09-11.
- **Optimization:** source modifiers baked; loose geometry removed; base LOD ratio `automatic`; repeated visual prop does not create audio or controller state.

### EDJ_Speaker_LineArray_Curved_04 — Curved Line Array 4 Cabinet 01

- **Source pack/file/object(s):** RaveSpace PA Free Audio Systems Speaker Set / `array_row_curved_4.blend` / `array_curved_4_01, array_curved_4_02, array_curved_4_03, array_curved_4_04`
- **Creator/license/source:** konstantin-andoerfer; CGTrader Royalty Free License (no AI); https://www.cgtrader.com/free-3d-models/electronics/audio/ravespace-audio-systems
- **Conversion status:** CONVERTED_PLACEABLE
- **Category/config/P3D:** EDJ_AudioLineArrays; `EDJ_Speaker_LineArray_Curved_04`; `\z\edj\addons\assets\models\speaker_linearray_curved_04.p3d`
- **Texture/RVMAT:** `data\speaker_co.paa`; matching namespaced RVMAT
- **Built dimensions:** 0.8 x 0.6448 x 0.9631 m
- **Visual LODs:** 1 / 5 / 15 / 40; conservative silhouette-preserving reduction and P3D re-import validation.
- **Geometry/View/Fire/Shadow:** simplified convex Geometry; Omitted; coarse Geometry provides physical collision and separate view blocking is not required. Omitted; event props are not intended as ballistic cover. optimized ShadowVolume proxy.
- **Memory/animation:** audio_origin; no active animation.
- **Screen support:** Not applicable
- **Simple object/Eden/Zeus:** Yes / Yes / Yes.
- **Known issues:** User confirmed correct scale and runtime behavior on 2026-09-11.
- **Optimization:** source modifiers baked; loose geometry removed; base LOD ratio `automatic`; repeated visual prop does not create audio or controller state.

### EDJ_Speaker_LineArray_Straight_04 — Straight Line Array 4 Cabinet 01

- **Source pack/file/object(s):** RaveSpace PA Free Audio Systems Speaker Set / `array_row_straight_4.blend` / `array_straight_4_01, array_straight_4_02, array_straight_4_03, array_straight_4_04`
- **Creator/license/source:** konstantin-andoerfer; CGTrader Royalty Free License (no AI); https://www.cgtrader.com/free-3d-models/electronics/audio/ravespace-audio-systems
- **Conversion status:** CONVERTED_PLACEABLE
- **Category/config/P3D:** EDJ_AudioLineArrays; `EDJ_Speaker_LineArray_Straight_04`; `\z\edj\addons\assets\models\speaker_linearray_straight_04.p3d`
- **Texture/RVMAT:** `data\speaker_co.paa`; matching namespaced RVMAT
- **Built dimensions:** 0.8 x 0.5 x 1.0145 m
- **Visual LODs:** 1 / 5 / 15 / 40; conservative silhouette-preserving reduction and P3D re-import validation.
- **Geometry/View/Fire/Shadow:** simplified convex Geometry; Omitted; coarse Geometry provides physical collision and separate view blocking is not required. Omitted; event props are not intended as ballistic cover. optimized ShadowVolume proxy.
- **Memory/animation:** audio_origin; no active animation.
- **Screen support:** Not applicable
- **Simple object/Eden/Zeus:** Yes / Yes / Yes.
- **Known issues:** User confirmed correct scale and runtime behavior on 2026-09-11.
- **Optimization:** source modifiers baked; loose geometry removed; base LOD ratio `automatic`; repeated visual prop does not create audio or controller state.

### EDJ_Speaker_HornArray_Straight_03 — Straight Horn Array 3 Cabinet 01

- **Source pack/file/object(s):** RaveSpace PA Free Audio Systems Speaker Set / `horn_row_straight_3.blend` / `horn_row_3_01, horn_row_3_02, horn_row_3_03`
- **Creator/license/source:** konstantin-andoerfer; CGTrader Royalty Free License (no AI); https://www.cgtrader.com/free-3d-models/electronics/audio/ravespace-audio-systems
- **Conversion status:** CONVERTED_PLACEABLE
- **Category/config/P3D:** EDJ_AudioSpeakers; `EDJ_Speaker_HornArray_Straight_03`; `\z\edj\addons\assets\models\speaker_hornarray_straight_03.p3d`
- **Texture/RVMAT:** `data\speaker_co.paa`; matching namespaced RVMAT
- **Built dimensions:** 1.6537 x 0.5653 x 0.9 m
- **Visual LODs:** 1 / 5 / 15 / 40; conservative silhouette-preserving reduction and P3D re-import validation.
- **Geometry/View/Fire/Shadow:** simplified convex Geometry; Omitted; coarse Geometry provides physical collision and separate view blocking is not required. Omitted; event props are not intended as ballistic cover. optimized ShadowVolume proxy.
- **Memory/animation:** audio_origin; no active animation.
- **Screen support:** Not applicable
- **Simple object/Eden/Zeus:** Yes / Yes / Yes.
- **Known issues:** User confirmed correct scale and runtime behavior on 2026-09-11.
- **Optimization:** source modifiers baked; loose geometry removed; base LOD ratio `automatic`; repeated visual prop does not create audio or controller state.

### EDJ_Speaker_SubwooferArray_Straight_03 — Straight Subwoofer Array 3 Cabinet 01

- **Source pack/file/object(s):** RaveSpace PA Free Audio Systems Speaker Set / `sub_row_3.blend` / `sub_row_3_01, sub_row_3_02, sub_row_3_03`
- **Creator/license/source:** konstantin-andoerfer; CGTrader Royalty Free License (no AI); https://www.cgtrader.com/free-3d-models/electronics/audio/ravespace-audio-systems
- **Conversion status:** CONVERTED_PLACEABLE
- **Category/config/P3D:** EDJ_AudioSubwoofers; `EDJ_Speaker_SubwooferArray_Straight_03`; `\z\edj\addons\assets\models\speaker_subwooferarray_straight_03.p3d`
- **Texture/RVMAT:** `data\speaker_co.paa`; matching namespaced RVMAT
- **Built dimensions:** 1.8155 x 0.8 x 1.0 m
- **Visual LODs:** 1 / 5 / 15 / 40; conservative silhouette-preserving reduction and P3D re-import validation.
- **Geometry/View/Fire/Shadow:** simplified convex Geometry; Omitted; coarse Geometry provides physical collision and separate view blocking is not required. Omitted; event props are not intended as ballistic cover. optimized ShadowVolume proxy.
- **Memory/animation:** audio_origin; no active animation.
- **Screen support:** Not applicable
- **Simple object/Eden/Zeus:** Yes / Yes / Yes.
- **Known issues:** User confirmed correct scale and runtime behavior on 2026-09-11.
- **Optimization:** source modifiers baked; loose geometry removed; base LOD ratio `automatic`; repeated visual prop does not create audio or controller state.

### EDJ_Speaker_LineArray_CurvedStack_08 — Curved Line Array 8 Cabinet Stack 01

- **Source pack/file/object(s):** RaveSpace PA Free Audio Systems Speaker Set / `array_curved_stack.blend` / `array_curved_4_01, array_curved_4_02, array_curved_4_03, array_curved_4_04, array_straight_4_01, array_straight_4_02, array_straight_4_03, array_straight_4_04`
- **Creator/license/source:** konstantin-andoerfer; CGTrader Royalty Free License (no AI); https://www.cgtrader.com/free-3d-models/electronics/audio/ravespace-audio-systems
- **Conversion status:** CONVERTED_PLACEABLE
- **Category/config/P3D:** EDJ_AudioLineArrays; `EDJ_Speaker_LineArray_CurvedStack_08`; `\z\edj\addons\assets\models\speaker_linearray_curvedstack_08.p3d`
- **Texture/RVMAT:** `data\speaker_co.paa`; matching namespaced RVMAT
- **Built dimensions:** 0.8 x 0.6532 x 1.9946 m
- **Visual LODs:** 1 / 5 / 15 / 40; conservative silhouette-preserving reduction and P3D re-import validation.
- **Geometry/View/Fire/Shadow:** simplified convex Geometry; Omitted; coarse Geometry provides physical collision and separate view blocking is not required. Omitted; event props are not intended as ballistic cover. optimized ShadowVolume proxy.
- **Memory/animation:** audio_origin; no active animation.
- **Screen support:** Not applicable
- **Simple object/Eden/Zeus:** Yes / Yes / Yes.
- **Known issues:** User confirmed correct scale and runtime behavior on 2026-09-11.
- **Optimization:** source modifiers baked; loose geometry removed; base LOD ratio `automatic`; repeated visual prop does not create audio or controller state.

### EDJ_DJ_MediaPlayer_01 — DJ Media Player 01

- **Source pack/file/object(s):** DJ Mixer 1 source / `dj_mixer_1.blend` / `Disc_01, Disc_02, Light_01, Light_02, Light_03, Light_04, Light_05, pane_A_01, pane_A_02, pane_A_03, pane_B_01, pane_B_01_vector, pane_B_02, pane_B_03`
- **Creator/license/source:** User-supplied local source; Redistribution provenance pending documentation; Local source file
- **Conversion status:** CONVERTED_PLACEABLE
- **Category/config/P3D:** EDJ_DJPlayers; `EDJ_DJ_MediaPlayer_01`; `\z\edj\addons\assets\models\dj_mediaplayer_01.p3d`
- **Texture/RVMAT:** `data\dj_player_01_co.paa`, `data\dj_player_02_co.paa`, and `data\dj_player_light_co.paa`; matching namespaced RVMATs
- **Built dimensions:** 0.3251 x 0.3878 x 0.1364 m
- **Visual LODs:** 1 / 5 / 15 / 40; conservative silhouette-preserving reduction and P3D re-import validation.
- **Geometry/View/Fire/Shadow:** simplified convex Geometry; Omitted; coarse Geometry provides physical collision and separate view blocking is not required. Omitted; event props are not intended as ballistic cover. optimized ShadowVolume proxy.
- **Memory/animation:** control_origin; no active animation.
- **Screen support:** Correctly UV-mapped source display retained; invalid atlas-mapped glass overlay omitted.
- **Simple object/Eden/Zeus:** Yes / Yes / Yes.
- **Known issues:** Scale and runtime behavior confirmed on 2026-09-11; corrected display-screen crop requires in-game reconfirmation.
- **Optimization:** source modifiers baked; loose geometry removed; base LOD ratio `automatic`; repeated visual prop does not create audio or controller state.

### EDJ_DJ_Controller_01 — Dual-Deck DJ Controller 01

- **Source pack/file/object(s):** DJ Mixer 2 source / `dj_mixer_2.blend` / `*ALL_MESHES*`
- **Creator/license/source:** User-supplied local source; Redistribution provenance pending documentation; Local source file
- **Conversion status:** CONVERTED_PLACEABLE
- **Category/config/P3D:** EDJ_DJMixers; `EDJ_DJ_Controller_01`; `\z\edj\addons\assets\models\dj_controller_01.p3d`
- **Texture/RVMAT:** `data\equipment_co.paa`; matching namespaced RVMAT
- **Built dimensions:** 0.7501 x 0.4013 x 0.1213 m
- **Visual LODs:** 1 / 5 / 15 / 40; conservative silhouette-preserving reduction and P3D re-import validation.
- **Geometry/View/Fire/Shadow:** simplified convex Geometry; Omitted; coarse Geometry provides physical collision and separate view blocking is not required. Omitted; event props are not intended as ballistic cover. optimized ShadowVolume proxy.
- **Memory/animation:** control_origin; no active animation.
- **Screen support:** Not applicable
- **Simple object/Eden/Zeus:** Yes / Yes / Yes.
- **Known issues:** User confirmed correct scale and runtime behavior on 2026-09-11.
- **Optimization:** source modifiers baked; loose geometry removed; base LOD ratio `automatic`; repeated visual prop does not create audio or controller state.

### EDJ_Audio_MixingConsole_01 — Digital Audio Mixing Console 01

- **Source pack/file/object(s):** Audio Equipment source / `audio_soundboard.blend` / `meter_base.002`
- **Creator/license/source:** User-supplied local source; Redistribution provenance pending documentation; Local source file
- **Conversion status:** CONVERTED_PLACEABLE
- **Category/config/P3D:** EDJ_AudioConsoles; `EDJ_Audio_MixingConsole_01`; `\z\edj\addons\assets\models\audio_mixingconsole_01.p3d`
- **Texture/RVMAT:** `data\equipment_co.paa`; matching namespaced RVMAT
- **Built dimensions:** 1.1 x 0.9019 x 0.235 m
- **Visual LODs:** 1 / 5 / 15 / 40; conservative silhouette-preserving reduction and P3D re-import validation.
- **Geometry/View/Fire/Shadow:** simplified convex Geometry; Omitted; coarse Geometry provides physical collision and separate view blocking is not required. Omitted; event props are not intended as ballistic cover. optimized ShadowVolume proxy.
- **Memory/animation:** control_origin; no active animation.
- **Screen support:** Not applicable
- **Simple object/Eden/Zeus:** Yes / Yes / Yes.
- **Known issues:** User confirmed correct scale and runtime behavior on 2026-09-11.
- **Optimization:** source modifiers baked; loose geometry removed; base LOD ratio `automatic`; repeated visual prop does not create audio or controller state.

### EDJ_DJ_PerformanceKeyboard_01 — DJ Performance Keyboard 01

- **Source pack/file/object(s):** Audio Equipment source / `dj_keyboard.blend` / `Text.003, Text.001, Plane.115`
- **Creator/license/source:** User-supplied local source; Redistribution provenance pending documentation; Local source file
- **Conversion status:** CONVERTED_PLACEABLE
- **Category/config/P3D:** EDJ_DJControllers; `EDJ_DJ_PerformanceKeyboard_01`; `\z\edj\addons\assets\models\dj_performancekeyboard_01.p3d`
- **Texture/RVMAT:** `data\equipment_co.paa`; matching namespaced RVMAT
- **Built dimensions:** 1.3778 x 0.5293 x 0.1555 m
- **Visual LODs:** 1 / 5 / 15 / 40; conservative silhouette-preserving reduction and P3D re-import validation.
- **Geometry/View/Fire/Shadow:** simplified convex Geometry; Omitted; coarse Geometry provides physical collision and separate view blocking is not required. Omitted; event props are not intended as ballistic cover. optimized ShadowVolume proxy.
- **Memory/animation:** control_origin; no active animation.
- **Screen support:** Not applicable
- **Simple object/Eden/Zeus:** Yes / Yes / Yes.
- **Known issues:** User confirmed correct scale and runtime behavior on 2026-09-11.
- **Optimization:** source modifiers baked; loose geometry removed; base LOD ratio `automatic`; repeated visual prop does not create audio or controller state.
