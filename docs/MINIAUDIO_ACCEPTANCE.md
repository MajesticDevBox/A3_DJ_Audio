# Miniaudio acceptance status — 2026-09-12

**M1 HUMAN ACCEPTANCE: PASS (2026-09-12).** The user confirmed all three
interactive cycles were audible, live volume changed without restarting, and
STOP worked correctly. M1 is accepted; M2–M4 are authorized and in progress.
The provider as a whole is not yet accepted.

**Human test 3: PASS (2026-09-13).** The user confirmed the explicit DualVolume
scenario: both miniaudio arrays followed 100% / 25% / 100% / 0% without restart.
**Human test 4: PASS**, confirmed by the user (DualPause: pause/resume together).
**Human test 5: PASS (2026-09-14)**, confirmed by the user: playing and paused
seek with both arrays (DualSeek). **Human test 6: PASS**, confirmed by the user:
natural track completion without pressing STOP (DualCompletion).
**Human test 7: PASS**, confirmed by the user: source-facing cones (DualDirection).
**Human test 8: PASS**, confirmed by the user: moving arrays and distance
attenuation (DualRange). **Human test 9: PASS**, confirmed by the user: listener
orientation and stereo positioning (DualListener). **Human test 10: PASS**,
confirmed by the user: continuous listener movement (DualMoveListener).
**Human test 11: PASS**, confirmed by the user: continuous array movement
(DualMoveArrays). **Human test 12: PASS**, confirmed by the user: independent
local cue (DualCue). Human test 13 (DualDelete: deleted-array cleanup) is pending;
cue isolation from other clients still requires dedicated multiplayer testing.
DualCue engine preflight passed main-output silence, independent cue PCM and
cleanup, continued primary progress, unchanged primary instance and final cleanup
(`arma3_x64_2026-09-14_00-36-29.rpt`). No SQF expression errors found.
DualMoveArrays engine preflight kept two emitters and the same playing source,
produced no geometry-related stage revisions, and cleaned up on STOP
(`arma3_x64_2026-09-14_00-34-16.rpt`). No SQF expression errors found. Human
confirmation of audible smoothness remains pending.
DualMoveListener engine preflight retained the same playing source and both
arrays throughout motion, then reclaimed the workstation and stopped cleanly
(`arma3_x64_2026-09-14_00-28-48.rpt`). No SQF expression errors found. Human
observation is needed to verify perceptual smoothness and spatial movement.
DualListener engine preflight verified east/west eye-direction changes, an
unchanged source, nonzero PCM and STOP cleanup
(`arma3_x64_2026-09-14_00-20-37.rpt`). No SQF expression errors found. These
checks do not measure channel balance; human stereo confirmation remains required.
DualRange engine preflight passed: quieter at approximately 70 metres, silent
beyond 100 metres, audible after return, unchanged source/revision and STOP
cleanup (`arma3_x64_2026-09-14_00-17-56.rpt`). No SQF expression errors found.
The fixture moves cabinets in discrete steps; continuous-motion smoothness
and moving-listener behavior remain separate checks.
DualDirection engine preflight passed rear attenuation, restored front output,
unchanged source instance, unchanged stage revision during rotation and STOP
cleanup (`arma3_x64_2026-09-14_00-15-46.rpt`). No SQF expression errors found.
DualCompletion engine preflight passed: stage/deck stopped naturally, the primary
source was destroyed, output became silent and did not restart. Evidence:
`arma3_x64_2026-09-14_00-13-07.rpt`; no SQF expression errors found.
DualSeek engine preflight passed: playing seek reached approximately 6.5 seconds,
paused seek held at 2 seconds silently, resume advanced from the new position,
the source instance stayed unchanged and STOP cleaned up. Evidence:
`arma3_x64_2026-09-13_17-53-23.rpt`; no SQF expression errors found.
Its Arma preflight passed eight checks, including frozen cursor/silent output
during pause, correct resumed position, nonzero resumed PCM, unchanged source
and STOP cleanup (`arma3_x64_2026-09-13_13-09-43.rpt`). No SQF expression errors
were found. The user subsequently confirmed the pause/resume listening test.

Human test 2 harness preflight: `arma3_x64_2026-09-12_23-00-34.rpt`
confirmed two emitters, nonzero PCM, an unchanged source instance throughout
eight seconds, and STOP cleanup. **Human test 2: PASS**, confirmed by the user. Run
the array mission with `-ListeningTest DualArray -Interactive` for this test.

## Current array integration evidence (supersedes older limitations below)

- Stage Speaker Arrays now emit through one shared decoder/cursor per stage,
  with one spatializer per array and no cabinet-level sounds. Main PA retains
  the authoritative state. See [array behavior and test guide](STAGE_ARRAY_AUDIO.md).
- Real Arma run `arma3_x64_2026-09-12_22-50-38.rpt` in
  `%LOCALAPPDATA%\Temp\edj_miniaudio_arrays\profiles` passed 27 assertions, zero failures:
  one array/four cabinets, real PCM, duration, paused cursor, paused/playing seek,
  resume, stable source instance, moving centroid/facing, no spatial revisions,
  live gain, independent cue, completion, repeated play/stop, left/right arrays,
  recreation from server time, array deletion, physical fallback and last-source
  cleanup. No SQF expression or AE3 duplicate-link errors were found.
- Windows native array tests passed, including coincident-array gain distribution,
  front/rear cone, near/far/out-of-range attenuation and unchanged playback cursor
  ownership. The original 19 PBO/decoder checks still pass.
- The existing native/Carpinchos regression harness passed 72 assertions, zero
  failures (`arma3_x64_2026-09-12_22-52-46.rpt` in the runtime-smoke profile;
  COMPLETE at 22:54:09). Audible regressions remain separate human tests.
- HEMTT check/build/release passed. Both `edj-latest.zip` and `edj-0.2.6.0.zip`
  contain `@edj/edj_miniaudio_x64.dll` (998400 bytes), SHA-256 matching the bundled
  Windows runtime. The post-build hook packages the DLL without manual copying.
- Human M1 remains accepted. **Human array test 1: PASS**, confirmed by the user:
  one four-cabinet array was audible and STOP silenced it. **Test 2: PASS** for
  left/right arrays together. Dedicated A/B/C JIP,
  reconnect, cue isolation and audible regression acceptance remain outstanding.
  Local recreation from a server snapshot is not a dedicated multiplayer test.
- Broader M4 work remains: asynchronous loading, full mission/disconnect/device
  recovery, player volume/mute and supported ACE integration. The current array
  implementation must not be described as full provider acceptance.

The sections below retain the earlier M1 audit history; packaging and controls
have advanced as recorded above.

## Mission discrepancy investigated 2026-09-13

The user's report of audio only at the rightmost physical prop was traced to
`Arma3_x64_2026-09-12_23-03-22.rpt`: at 23:09:34 Main PA plays `rock` using
`carpinchos`, which creates the single source `EDJ_main_1`. It is not running
miniaudio. The loaded mod path is the updated `releases/@edj`. Carpinchos streams
still use one physical emitter; miniaudio arrays currently support packed local
tracks. This is a provider limitation, not evidence that miniaudio arrays passed
with the stream. The earlier manual volume-test instructions omitted this
distinction. Test 3 is pending and now has an explicit `DualVolume` scenario using
the registered Miniaudio Acceptance Tone, eliminating source-selection ambiguity.

## Changes and evidence

- Fixed PBO Vers/Cprs byte order, archive bounds and entry/property limits;
  unsupported compression is rejected. Extraction is limited to 64 MiB per track.
- Enabled miniaudio stage registration, initialized the extension before play,
  corrected the Arma extension name and serialized-string handling, and added
  discovery through the extension's addons directory and command-line -mod roots.
- Registered an acceptance track referencing the existing packed OGG; no music
  files are put in the mission. Native and Carpinchos providers remain present.
- Hardened numeric/path inputs and ABI exception handling; STOP destroys the
  sound, replacement destroys its predecessor, and explicit shutdown drains sounds.
- Added audio-device PCM and source-instance diagnostics to verify gain changes.
- Corrected single-player workstation request routing while retaining server
  authorization checks and the multiplayer transport-owner path.

Windows DLL build passed. `tools/test_miniaudio_m1.py` passed all 19 checks,
including the actual HEMTT example pack, 12-second 48 kHz stereo OGG decoding,
virtual-path resolution, malformed archives, unsupported compression, missing
files/tracks, invalid inputs and decoder failure.

Arma RPT `C:\Users\jaret\AppData\Local\Temp\edj-miniaudio-m1\profiles\arma3_x64_2026-09-12_16-18-22.rpt`
records AE3 workstation creation, claim/load via the normal controller, and three
successful play/live-volume/stop cycles. WASAPI produced nonzero PCM each cycle.
Gain changed from 2 to 0.5 while the cursor advanced and source serial stayed
unchanged. No SQF expression errors or Event DJ ERROR entries were found in this
run. Controls were invoked programmatically through their normal handler; this
does not establish physical mouse interaction or human-audible output.

`hemtt check`, `hemtt build` and `hemtt release` passed. One premature release
attempt encountered HEMTT's temporary-directory lock while build was still
running; the sequential retry passed. Release ZIP inspection confirms the
compatibility and music-pack PBOs, but **no extension DLL**. This release is not
ready to distribute as a working miniaudio installation. The M1 runner stages
the compiled DLL into the development build only; automatic packaging is M4.

## Immediate human M1 check

From PowerShell run:

```powershell
powershell -ExecutionPolicy Bypass -File "G:\Github Repos\A3_DJ_Audio\tools\start_miniaudio_m1.ps1" -Interactive
```

The scenario automatically opens the workstation and runs three short cycles.
Confirm that the tone is audible, becomes quieter without restarting, and stops
each time. Report missing sound, wrong device, interruptions or failure to stop.
The scenario exits after the cycles. The runner requires the built extension
and HEMTT build plus the locally installed test dependencies.

## Remaining acceptance work after M1

- M2: pause/resume/seek, duration/position, local independent cue and completion.
- M3: coordinate conversion, listener orientation, source-facing cones, moving
  emitters and predictable attenuation; current spatial implementation is incomplete.
- M4: asynchronous loading, aggregate resource limits, mission/disconnect/reset
  cleanup, device recovery, player volume/mute and supported ACE behavior,
  portable automatic DLL packaging and release verification.
- Human runtime checks: all M2 controls; cue inaudible to other players; moving
  PA direction/range; multiple stages; repeated missions; missing DLL/PBO/track,
  corrupt data and recovery; native/radio/Carpinchos audible regressions.
- Dedicated server plus DJ A/listener B/JIP C: authoritative position, reconnect,
  authorization, no duplicates and no interruption to existing listeners.

PCM diagnostics do not establish audibility, multiplayer behavior, spatial
correctness or the complete acceptance criteria. Discovery currently covers
direct -mod arguments and the extension's own addons folder, not -par files.

## Existing regression harness

The final EDJ_Smoke run passed 72 assertions with zero failures and reached
COMPLETE (`arma3_x64_2026-09-12_16-23-59.rpt` in the temporary
`edj-runtime-smoke/profiles` directory). No SQF expression errors, Event DJ ERROR
entries or AE3 duplicate-link initialization errors were found. The fixture now
waits for AE3 initialization before registering its workstation. The intentional
unreachable-stream case emits a Carpinchos transport error and passes its
failure/recovery assertions. These checks do not replace audible native/radio/
Carpinchos or dedicated multiplayer regression acceptance.
