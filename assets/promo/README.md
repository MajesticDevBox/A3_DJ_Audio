# Event DJ promotional previews

Six supplied asset packs are shown in the combined showcase. The DJ player is
listed as Coming Soon because no model was supplied. Images are Blender source
renders, not screenshots of working Arma 3 assets.

- `event_dj_asset_showcase_3840.png`: full-resolution master (3840 x 2240).
- `event_dj_asset_showcase_3840.jpg`: full-resolution JPEG.
- `event_dj_asset_showcase_1920.jpg`: smaller sharing copy (1920 x 1120).
- `*_preview_card.png`: six individually labeled pack previews (1920 x 1280).
- `arena.png`, `event.png`, `speakers.png`, `truss.png`, `devices.png`, `mixer.png`:
  transparent renders for future layouts.

Rendering preserves source geometry. Studio lighting and framing were added.
The equipment room enclosure and scene ground were hidden to expose the assets.
The mixer's unrelated logo/decorative objects were hidden, its missing font was
substituted, and its clay material override was disabled to show source materials.
Missing image nodes were disconnected for neutral material fallbacks in preview
copies only. Source files were not saved or modified. Event stage surface textures
and some equipment media are missing; these renders do not establish final finish.
The RaveSpace view includes all five previously created assemblies.

`render_manifest.json` records source paths, visible object counts, and unavailable
image references. Counts include component objects, not unique product counts.

Rebuild a render with Blender:

```powershell
& 'C:\Program Files\Blender Foundation\Blender 5.2\blender.exe' --background --factory-startup --disable-autoexec --python tools\render_asset_promo.py -- arena
```

Replace `arena` with `event`, `speakers`, `truss`, `devices`, or `mixer`.
Run `python tools\layout_asset_promo.py` to rebuild the layouts after rendering.
