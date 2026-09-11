# Changelog

## 0.2.6

- Add synchronized Main PA and Stage Speaker Array modules with one emitter per stage.
- Increase default PA gain and native range; add optional stream front/rear attenuation.
- Add Eden/Zeus Radio / Music Player module with source, volume, gain and native range settings.
- Open Event DJ at full safe-zone size, preserving AE3 titlebar controls.
- Add radio lifecycle and array synchronization engine smoke checks. Dedicated multiplayer, Zeus placement and audible range require event validation.

## 0.2.5

- Reset the production asset catalog to six reviewed RaveSpace speaker
  assemblies and removed the previous 76 non-retained asset classes and models.
- Added curved and straight four-cabinet line arrays, a straight three-cabinet
  horn array, a straight three-cabinet subwoofer array, and an eight-cabinet
  curved stack from the five supplied Blender files.
- Preserved `EDJ_Speaker_HornArray_Curved_03`; recovered its production source
  after the supplied same-name Blender file was found to contain a different array.
- Added substantial 1/5/15/40 LOD reduction, per-cabinet Geometry and
  ShadowVolume, ground alignment, source-scale checks, and `audio_origin` points
  to all six current assets.
- Added four user-selected DJ/audio props: a media player, dual-deck controller,
  digital mixing console, and performance keyboard. Each uses uniform audited
  scale correction, four visual LODs, simple Geometry/ShadowVolume, and an inert
  `control_origin` Memory point.
- Preserved the media player's supplied diffuse and normal maps in namespaced
  PAA/RVMAT resources; converted procedural materials on the other three props
  to a compact namespaced palette.
- Corrected the dual-deck controller's pale material conversion by reading the
  source's legacy Diffuse, Glossy, Glass, and Emission shader colors and mapping
  its chassis, screens, controls, and colored indicators explicitly.
- Corrected the media player's display crop by omitting its nonessential glass
  overlay, whose negative UV coordinates caused Arma to wrap unrelated regions
  of the device atlas over the correctly mapped screen underneath.

### Superseded initial catalog

- Expanded the isolated `EDJ_assets` PBO to 77 namespaced Eden/Zeus production
  props selected from every useful approved source family.
- Added `Curved Horn Array 3 Cabinet 01` from the supplied RaveSpace Blender
  assembly, preserving its three-cabinet curve, source UVs, optimized visual
  LODs, separate convex cabinet collision/shadow components, and audio origin.
- Added four silhouette-preserving Resolution LODs, convex Geometry, optimized
  ShadowVolume, a walkable stage Roadway, and future speaker/light memory points.
- Added RaveSpace PBR-to-PAA conversion, neutral materials for unrelated speaker
  packs, restrained specular response, and namespaced RVMAT material paths.
- Added read-only source staging, source hash/inventory tools, MLOD generation and
  re-import validation, local previews, provenance, credit, and pipeline records.
- Reconciled 611 canonical source records with zero unaccounted, retained Music
  Mixtable as LICENSE HOLD, and recorded the missing DJ player/source shortcuts.
- Corrected the reported cabinet, stage-deck, and moving-head scale/orientation
  defects plus complete-stage collision and Roadway bounds.
- Corrected destructive stage/truss LOD collapse, made inherited tower transforms
  explicit, and removed two invalid aggregate assemblies that combined source
  variants into overlapping piles.
- Corrected the lighting-pack speakers, blinders, consoles, keyboard, and moving
  head with per-device dimensions and source-derived PAA palette materials.
- Reclassified the Arena pack's 8 m and 10.5 m fabric objects as stage skirts and
  removed detached helper/text geometry from affected equipment assemblies.
- Expanded the `EDJ_Assets.VR` daylight validation mission across every converted
  source pack. Human pack-by-pack acceptance is pending and V0.3 has not started.

## 0.2.0

- Config-driven, cached library for third-party addon tracks and live streams.
- Server-authoritative Deck A/B, queue, active output, now-playing, and finite timing.
- Native play/stop/pause/resume/seek/progress and DJ-local cue architecture.
- Capability-aware AE3-sized library, deck, master, and queue interface.
- Deterministic CUT deck switching and registered-ID request validation.
- Separate example music-pack PBO with two original synthesized test signals.
- V0.2 diagnostics, acceptance tracking, music-pack contract, workflow docs, and ADRs.
- All 30 required interactive tests passed; final static, engine, dedicated, and
  packaging gates passed.

## 0.1.0-dev

- HEMTT project and six modular PBOs.
- Server stage registry, claim/release, validated play/stop/volume and JIP snapshots.
- Capability-based provider dispatch, Carpinchos local adapter and native tracks.
- Shared dashboard and AE3 native config app.
- One Blender speaker blockout, mission configuration examples, documentation and CI.
- Development milestone; runtime acceptance and game-model validation remain gates.
- Hardened provider discovery, single-path state commits, payload validation,
  generation-latched audio failures, source cleanup, UI teardown, and mission-owned
  remote execution policy after V0.1 validation.
- Fixed a runtime Carpinchos startup race, added metadata-backed online detection
  and bounded failure status, expanded lifecycle diagnostics, and added reproducible
  smoke/server/client launch tooling.
