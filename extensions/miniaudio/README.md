# Event DJ miniaudio adapter (extension scaffold)

Native Windows extension intended to give **local (native) track playback**
the same live per-source volume/directional control that the Carpinchos
stream provider already has, instead of the fire-and-forget `playSound3D`
call used today (`addons/audio/functions/fn_native.sqf`). Background and the
two options considered are in the project chat history; miniaudio (over
extending Carpinchos itself) was chosen so streams keep using Carpinchos
unmodified and this stays a separate, optional provider.

## Status

**2026-09-12: M1 human acceptance PASS.** Array playback and in-place controls
now pass native and Arma engine tests. See
[`docs/MINIAUDIO_ACCEPTANCE.md`](../../docs/MINIAUDIO_ACCEPTANCE.md) and
[`docs/STAGE_ARRAY_AUDIO.md`](../../docs/STAGE_ARRAY_AUDIO.md) for current evidence,
spatial behavior, packaging and the sequential human listening tests. HEMTT now
packages the bundled Windows DLL automatically. Dedicated multiplayer and the
remaining M4 integrations are not yet accepted. Older sections below describe
the original implementation; the linked acceptance audit is authoritative.

Three slices in:

1. **Extension scaffold** -- CMake build producing `edj_miniaudio_x64.dll` on
   Windows (and a `.so` on Linux/macOS for local sanity builds only -- **not**
   a shippable artifact; Arma clients are Windows-only per
   `docs/DEVELOPMENT.md`), the four standard `RVExtension` entry points, and
   a `ma_engine` lifecycle wrapper (`init` / `shutdown` / `status`).
2. **PBO audio reader** -- reads music-pack audio directly out of a `.pbo`
   file on disk (no loose-file copies needed), and validates each extracted
   track by decoding its header through miniaudio.
3. **Path resolution + live playback + SQF provider** -- resolves a track's
   virtual addon path (e.g. `\z\edj\addons\example_music_pack\audio\
   groove.ogg`) to either a loose file (HEMTT dev builds) or a PBO entry
   (deployed builds); plays it as a positioned `ma_sound`; and, critically,
   supports **live volume changes on an already-playing sound** via
   `ma_sound_set_volume` -- no stop/restart. `addons/compat_miniaudio` wires
   this up as a real `CfgEDJAudioProviders` entry (`native`/`carpinchos`/
   `miniaudio`), and `addons/audio/functions/fn_audioTick.sqf` now pushes the
   same cone-aware gain (`fn_streamGain.sqf`) to `miniaudio` on every tick
   that it already pushed to `carpinchos` -- which is the actual fix for the
   original question that started this thread ("why can streams have
   directional audio but not local tracks"). `native`/`playSound3D` is
   unchanged and still can't do this; `miniaudio` is a new, separate backend
   option, not a replacement.

**Not implemented yet, on purpose:**

- **This has not been built or tested on Windows/Arma at all.** Everything
  above has only been exercised on Linux: compiled, loaded via `dlopen`,
  and driven through synthetic fixtures (hand-built PBOs, a loose-file tree,
  a null/dummy audio device) that reproduce the real PBO binary format and
  the real `callExtension`/`RVExtensionArgs` calling convention as precisely
  as this environment allows -- see "Testing" below for exactly what that
  does and doesn't prove. The SQF files were only checked for balanced
  brackets/strings, not run through HEMTT or a real Arma instance.
- **Decompressing PBO entries packed with the "Cprs" LZSS scheme** -- same
  gap as before. Run `list_entries` against a real HEMTT-built PBO once you
  can, and check nothing reports as compressed.
- **Registering a search root is entirely manual right now.** Something
  (mission init, a CBA setting, a userconfig file -- not decided) needs to
  call `register_search_root` with a real disk path once per music pack.
  There is no general way for the extension or SQF to discover a mod's
  install directory automatically -- confirmed by checking `getLoadedModsInfo`,
  which reports a mod's relative folder name and Steam Workshop ID but not
  an absolute path. `addons/compat_miniaudio` does not yet do this
  registration step itself.
- **Synchronous decode.** `play` fully decodes on the calling thread via
  `MA_SOUND_FLAG_DECODE`. Fine for short tracks, a real hitch risk for long
  ones. `RVExtensionRegisterCallback` is still wired up and unused --
  moving decode to a worker thread and reporting back through it is the
  natural next step.
- **Engine-side directional cones.** Directionality is still the same
  scalar-gain-over-time trick the project already used for streams
  (`fn_streamGain.sqf`), not a true spatial cone on the `ma_sound` itself
  (`ma_sound_set_cone` is available in miniaudio and unused). Distance-based
  falloff *is* real (`ma_sound_set_max_distance`/`ma_attenuation_model_inverse`),
  which is why the listener position has to be kept in sync (see below).
- **Listener updates are 1 Hz**, piggybacking on `fn_audioTick.sqf`'s
  existing per-second loop. Fine for background ambience, coarse for a
  fast-moving listener. Also note stereo panning (not just volume) will
  shift with listener orientation as a side effect of `ma_engine`'s built-in
  spatializer, which streams don't currently get -- worth listening for
  during Windows testing, since it wasn't a design goal.
- Multiplayer/JIP timing, ACE hearing/volume integration.
- Deploying the actual `edj_miniaudio_x64.dll` -- nothing places it in
  `@edj`'s root yet; someone has to do that manually until this is built into
  the HEMTT/release process.

Each of those is worth its own follow-up.

## Layout

```
extensions/miniaudio/
  CMakeLists.txt           Build script (see below)
  vendor/                  miniaudio.h, stb_vorbis.c, LICENSE (already present)
  src/
    ma_impl.cpp            The one TU that compiles miniaudio + stb_vorbis
    engine.h / engine.cpp  Process-wide ma_engine init/shutdown wrapper
    pbo_reader.h / .cpp    Parses a PBO's header table; extracts uncompressed entries
    pbo_cache.h / .cpp     Keeps parsed PboArchive headers around by path
    track_cache.h / .cpp   Process-wide cache of extracted+validated track bytes, by key
    path_resolver.h / .cpp Virtual addon path -> loose file or PBO entry
    playback_manager.h / .cpp  One ma_sound per stage; live volume/position
    extension_api.cpp      RVExtension entry points; dispatches to the above

addons/compat_miniaudio/   SQF provider: CfgEDJAudioProviders "miniaudio" entry
```

Only `ma_impl.cpp` may define `MINIAUDIO_IMPLEMENTATION`; every other file
just `#include "miniaudio.h"` for declarations and links against it.

## Building

### Windows (the actual target)

Requires CMake 3.15+ and MSVC (Visual Studio 2019+ Build Tools, or full VS).
From this directory:

```powershell
cmake -B build -A x64
cmake --build build --config Release
```

Output: `build/Release/edj_miniaudio_x64.dll`. Drop it into the mission's
`@edj` folder root (next to `mod.cpp`) once there's something for it to do --
there's no reason to install it yet since it has no SQF-facing operations.

### Linux/macOS (dev-time sanity build only)

```bash
cmake -B build
cmake --build build
```

This exists so the C++ compiles and both the engine lifecycle and the PBO
reader can be smoke-tested without a Windows box. It has been:

- Loaded like Arma loads the DLL (`dlopen` + calling `RVExtension`/
  `RVExtensionArgs` directly) and exercised through `init`, `status`,
  `shutdown`, and an idempotent double-`init`.
- Tested against two hand-built synthetic PBOs (correct binary header/entry
  table/data-block layout per the BI PBO format, generated with a small
  Python script, not copied from any existing tool): one with a real WAV
  track plus a text file plus a `Vers` properties block, one with a single
  entry declared as `Cprs`-compressed. 12/12 checks passed, including an
  exact round-trip of the WAV's duration (1.5s), sample rate (8000), and
  channel count (1) after extraction + miniaudio decode, correct entry
  listing (including the properties block not being mistaken for a file
  entry), and clean, non-crashing rejection of the compressed entry, a
  missing PBO file, a missing internal entry, and missing arguments.
- Not yet tested against a real HEMTT-built PBO -- that needs the Windows
  toolchain. See the compressed-entries note above for the one thing to
  check first once that's possible.

## RVExtensionArgs functions available right now

| function              | args                                              | returns                                                          |
| --------------------- | -------------------------------------------------- | ----------------------------------------------------------------- |
| `version`             | --                                                 | extension version string (`0.1.0-dev`, tracks the extension ABI, not the mod version) |
| `init`                | --                                                 | `"1"` on success, `"0:<reason>"` on failure                       |
| `shutdown`            | --                                                 | `"1"` (idempotent)                                                 |
| `status`              | --                                                 | `"running"` or `"stopped"`                                         |
| `list_entries`        | `[pboPath]`                                       | `"1:<count>:<name1>|<name2>|..."` (capped at 20 names) or `"0:<error>"` |
| `read_track`          | `[trackId, pboPath, entryName]`                   | `"1:<durationSeconds>:<sampleRate>:<channels>"` or `"0:<error>"`   |
| `track_status`        | `[trackId]`                                       | `"loaded"` or `"missing"`                                          |
| `release_track`       | `[trackId]`                                       | `"1"`                                                              |
| `register_search_root`| `[rootPath]`                                      | `"1:<pboCount>"` or `"0:<error>"`                                  |
| `resolve_track`       | `[virtualPath]`                                   | `"1:loose:<path>"` / `"1:pbo:<pboPath>:<entryName>"` / `"0:not_found"` |
| `play`                | `[stageId, virtualPath, gain, offsetSeconds, x, y, z, range]` | `"1"` or `"0:<error>"`                          |
| `stop`                | `[stageId]`                                       | `"1"`                                                              |
| `volume`              | `[stageId, gain]`                                 | `"1"` or `"0:<error>"` -- **changes gain on the running sound in place** |
| `set_position`        | `[stageId, x, y, z]`                              | `"1"` or `"0:<error>"`                                             |
| `set_listener`        | `[x, y, z, dirX, dirY, dirZ]`                     | `"1"` or `"0:<error>"`                                             |
| `playback_status`     | `[stageId]`                                       | `"playing"` / `"stopped"` / `"missing"`                            |
| anything else / missing required args | --                                | `"unsupported"` / `"0:missing_args"`                               |

Possible `<error>` values: `cannot_open_file`, `truncated_entry_name`,
`truncated_entry_header`, `truncated_properties`, `unknown_packing_method:
<name>`, `entry_not_found`, `compressed_entry_unsupported`, `seek_failed`,
`short_read`, `decode_failed:<reason>`, `duration_query_failed`,
`search_root_not_a_directory`, `not_found`, `track_not_found`,
`engine_not_initialized`, `sound_init_failed:<reason>`, `start_failed:<reason>`,
`stage_not_playing`.

Example from the in-game console once the DLL is present:

```sqf
"edj_miniaudio_x64" callExtension "init";
"edj_miniaudio_x64" callExtension ["register_search_root", ["G:\path\to\@MyEventMusicPack\addons"]];
"edj_miniaudio_x64" callExtension ["play", ["debug_stage", "\mypack\audio\song01.ogg", "1.0", "0", "0", "0", "0", "50"]];
"edj_miniaudio_x64" callExtension ["volume", ["debug_stage", "0.3"]];
"edj_miniaudio_x64" callExtension ["playback_status", ["debug_stage"]];
"edj_miniaudio_x64" callExtension ["stop", ["debug_stage"]];
```

## Testing

Everything above has been exercised on Linux only (no Windows/Arma
available in the environment this was built in), via `dlopen` + calling the
`RVExtension`/`RVExtensionArgs` entry points directly, exactly as Arma's
`callExtension` would. This proves the C++ logic and the binary/wire formats
are correct; it does **not** prove anything about the actual Arma
integration (SQF syntax was only checked for balanced brackets, not run
through HEMTT or a real client).

What was actually tested, end to end:

- Engine lifecycle: `init`/`status`/`shutdown`, idempotent double-`init`.
- Two hand-built synthetic PBOs (correct binary header/entry table/data-block
  layout per the BI PBO format, generated with a small Python script, not
  copied from any existing tool): a real WAV track plus a text file plus a
  `Vers` properties block; and a single entry declared `Cprs`-compressed.
  `list_entries`, `read_track` (exact round-trip of duration/sample
  rate/channel count after PBO extraction + miniaudio decode), and clean
  rejection of the compressed entry, a missing PBO, a missing entry, and
  missing arguments.
- Path resolution against both a loose-file fixture tree (mimicking a HEMTT
  dev build) and a PBO with a real `prefix` property (mimicking a deployed
  build), including a not-found case.
- Full playback lifecycle: `play` from both a loose-resolved and a
  PBO-resolved virtual path (the latter with a mid-track offset/seek),
  `playback_status` transitions, **`volume` changing gain on an already-
  playing sound without restarting it** (the core ask that started this
  whole thread), `set_position`, `set_listener`, `stop` removing exactly the
  targeted stage and leaving others untouched, and error paths (`volume` on
  a stage that isn't playing, `play` on an unresolvable path).
- 44 checks total across both test runs, all passing. `ma_engine_init`
  succeeds even with no real audio device present (this environment has
  none), which is expected -- it doesn't prove audio is actually audible on
  a real machine, only that the lifecycle and API calls behave correctly.

## Suggested next step

Get this in front of an actual Windows Arma client: build the DLL via the
CMake project (or the CI workflow), drop it in `@edj`'s root, register a
search root pointing at a real (dev-linked or packed) music pack, and load a
mission with a stage set to `backend = "miniaudio"`. Listen for whether the
volume changes and stereo panning described above actually sound right, and
check `list_entries` against the real pack for any `Cprs`-compressed
entries before relying on it.
