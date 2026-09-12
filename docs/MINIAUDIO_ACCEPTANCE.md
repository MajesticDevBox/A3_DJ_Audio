# Miniaudio acceptance status — 2026-09-12

**M1 HUMAN ACCEPTANCE: PASS (2026-09-12).** The user confirmed all three
interactive cycles were audible, live volume changed without restarting, and
STOP worked correctly. M1 is accepted; M2–M4 are authorized and in progress.
The provider as a whole is not yet accepted.

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
