# V0.1 validation

The milestone is not production-ready until the runtime acceptance below passes.
Do not equate building PBOs with audible or synchronized multiplayer playback.

## Automated and launch evidence

- HEMTT 1.21.0 `check`: passed, six configs rapified and 30 SQF files compiled.
- `build`: passed, six PBOs; no model binarization was needed.
- `launch`: succeeded with CBA, ACE, AE3 and Carpinchos installed. Arma RPT listed
  all six EDJ PBOs and loaded `live_radio_x64.dll`. This first launch reached the
  game startup, not a multiplayer mission.
- Blender 5.2.1 generated the original speaker .blend and OBJ successfully.
- `release`: passed; local development ZIPs produced without publishing.
- Dedicated Arma server 64-bit, loopback port 2392: executed the supplied mission.
  After fixing preInit/postInit ordering, RPT reported all three server tests true,
  with no script-expression errors in the rerun. No player clients joined this test.
- Interactive multiplayer acceptance passed. Blender-to-P3D validation remains
  optional outside the accepted V0.1 Carpinchos/existing-PA path.

Dedicated rerun evidence (2026-09-07):

```text
07:52:09 [EDJ TEST] stage registration=true dedicated=true
07:52:09 [EDJ TEST] duplicate rejected=true
07:52:09 [EDJ TEST] null workstation rejected=true
07:52:09 [EDJ][INFO] Initialized V0.1 [true,false]
```

Full local log: `.hemttout/runtime-server/arma3server_x64_2026-09-07_07-51-55.rpt`.
The AE3 workstation bridge was rerun at 19:13:18. Server-side workstation
configuration, ordinary-laptop exclusion, stage registration, duplicate rejection,
null-object rejection, dependency presence, and no-op revision stability all passed
in `arma3server_x64_2026-09-07_19-13-04.rpt`.
The initial failed log is retained beside it. The test server was stopped after
verification. The test mission copy remains in the local Arma mpmissions folder.

Environment note: both successful server runs also report
`You cannot play/edit this mission ... a3_characters_f`. Server initialization
continues, and the later interactive multi-client acceptance passed. Adding the
base patch to the mission dependency list did not clear this contradictory warning;
the loaded configuration confirms that patch is present. The warning is retained as
environment evidence and does not override the completed client acceptance.

## Dedicated mission

Copy `tests/EDJ_V01.VR` into the server's `mpmissions` directory. Use the included
server.cfg only for a private loopback test (signatures/BattlEye disabled for dev).
Load the same build/dependencies on server and clients. Bind the server to loopback
for testing. Never use this test config as a public production server policy.

`tools/start_test_server.ps1` resolves the installed Workshop paths, synchronizes
the current test mission, starts a hidden loopback server, and returns its PID. It
accepts ArmaPath and WorkshopPath parameters.

```powershell
# Run from the repository root.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\start_test_server.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\start_runtime_client.ps1 -Role A
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\start_runtime_client.ps1 -Role B
# Launch C only after A has started playback.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\start_runtime_client.ps1 -Role C
```

Run Client A/B/C on independent Arma-capable sessions or machines for final
acceptance. Each role uses a separate profile/RPT directory. For the automated
single-client engine diagnostic, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\start_smoke_test.ps1
```

The automated mission creates two AE3 laptops when available, marks one through
the workstation-module function, leaves the other ordinary, and creates a stock PA
prop. Server RPT reports workstation inclusion/exclusion, stage registration,
duplicate rejection, and null-object rejection. Client RPT reports snapshot
reception/revision/JIP and opens the standalone dashboard. The smoke path exercises
the installed AE3 web-extension command, its transition to the native window, and
three close/reopen cycles. It does not replace clicking the real CEF icon through
a powered laptop.

For physical acceptance in Eden:

1. Place an AE3 Rugged Laptop and configure its normal user, power, and GUI/Both interface.
2. Place `EDJ: Add Event DJ Workstation` from the `Event DJ` module category.
3. Synchronize the module to exactly that laptop.
4. Place a second compatible AE3 laptop without synchronizing it to the EDJ module.
5. Start the mission and confirm the server RPT contains `[EDJ][INFO] Event DJ workstation configured` once.

Also test the validation cases separately: no synchronized object must warn; a
non-AE3 object must warn; and more than one synchronized object must be rejected
with `[EDJ][WARN] Invalid AE3 workstation target`.

## Acceptance sequence (record each client/server RPT)

1. Start the dedicated server. **Expected:** VR loads, all `[EDJ TEST]` checks are true, and no EDJ script error appears.
2. Join as Client A (DJ). **Expected:** the dashboard shows stage `main`, stopped, unclaimed, backend `carpinchos`.
3. Join as Client B (listener). **Expected:** A and B show the same stage source, state, and revision.
4. Claim the workstation from A while within 5 m. **Expected:** A becomes operator on both clients.
5. Power and boot the synchronized AE3 laptop, open armaOS, and confirm Event DJ is visible in its dock and Applications menu. Click it. **Expected:** AE3 transitions to one native Event DJ window with one set of controls.
6. Power and boot the ordinary unsynchronized AE3 laptop. **Expected:** Event DJ is absent from its dock and Applications menu.
7. Confirm the configured test stream. **Expected:** source `groove` is displayed; V0.1 has no source-switch control.
8. Press PLAY on A once, then repeatedly. **Expected:** state becomes playing and only one source generation is created.
9. Listen on A near the PA. **Expected:** A hears the stream from the PA emitter and status reaches online/live if upstream is available.
10. Listen on B near the PA. **Expected:** B hears the same live stream from the same emitter.
11. Walk B away from and around the PA. **Expected:** spatial attenuation/direction follows the PA, with no decorative-speaker duplicates.
12. Change master volume on A. **Expected:** the server value remains within 0..1 and playback does not restart.
13. Listen on B after the change. **Expected:** B receives the revision and hears the corresponding source-gain change.
14. Try PLAY, STOP, RELEASE, and volume from B, including a direct `EDJ_fnc_request` call. **Expected:** all are denied and RPT denial logging is rate-limited.
15. Compare state after B's attempts. **Expected:** operator, playback, volume, and revision are unchanged.
16. Join Client C while playback is active. **Expected:** C receives the current stage and the synchronized laptop's `EDJ_isWorkstation=true` state without a persistent remote-exec queue.
17. Inspect C's dashboard. **Expected:** operator, backend, source, playing state, volume, emitter, and revision match A/B.
18. Listen on C near the PA. **Expected:** C creates one local connection to the active live stream; buffer alignment may differ.
19. Press STOP on A. **Expected:** A, B, and C destroy their local sources and show stopped.
20. Reconnect C while stopped. **Expected:** C receives stopped state and creates no stale source.
21. RELEASE from A, then test A disconnect/death/>5 m in separate runs. **Expected:** the lock clears while playback policy remains unchanged.
22. Claim from B. **Expected:** B becomes the sole operator and can issue valid controls.

Additional failure checks: use an unreachable URL, omit the client extension, and
enable streamer mode. **Expected:** the dashboard remains responsive, reports a
meaningful non-live state, does not flood retries, and recovers after STOP/PLAY.
Open Event DJ from armaOS, close it, and repeat three times. **Expected:** no
duplicate launcher, controls, windows, render PFHs, handlers, or app registrations
remain, and no SQF errors appear.

All 17 release-blocking V0.1 interactive tests passed. Native addon-track playback
and a custom speaker P3D remain optional future validation outside the accepted
Carpinchos/existing-PA V0.1 path. No V0.2 implementation was started in this task.

## Interactive acceptance record

| Test | Result | Evidence |
| --- | --- | --- |
| 01 Audible Stream Playback | PASS | Human operator confirmed audible, singular playback with active Event DJ state and no rapid restart or overlap |
| 02 Audible STOP | PASS | Human operator confirmed playback stopped audibly with no residual source and Event DJ returned to stopped state |
| 03 Audible Volume Control | PASS | Human operator confirmed a clear audible increase from 25% to 75% with uninterrupted singular playback and coherent UI volume |
| 04 PA Spatial Position | PASS | Human operator confirmed PA-localized sound, appropriate spatial change while moving around it, and noticeable attenuation |
| 05 PA Distance Attenuation | PASS | Human operator confirmed the expected close, audience, far, and outside-range attenuation behavior |
| 06 Client B Receives Audio | PASS | Human multiplayer test confirmed Client B received the active state and stream without advancing the play generation |
| 07 Client B Unauthorized Normal Control | PASS | Human multiplayer test confirmed normal Client B controls could not alter ownership, playback, or revision while Client A remained operator |
| 08 Client B Forged/Direct Request Rejection | PASS | Bounded `EDJ_fnc_request` diagnostic and server RPT confirmed non-operator rejection with authoritative state unchanged |
| 09 Client C Join-In-Progress State | PASS | Human multiplayer test confirmed Client C received the complete active authoritative state without resetting operator, playback, backend, or revision |
| 10 Client C Live Stream Attachment | PASS | Human multiplayer test confirmed Client C attached audibly while existing clients continued uninterrupted and the global play generation remained unchanged |
| 11 JIP Volume State | PASS | Human multiplayer test confirmed Client C received the established non-default authoritative volume and matching UI value |
| 12 DJ Disconnect While Playing | PASS | Human multiplayer test confirmed playback persisted, stage state survived, and stale Client A ownership cleared after disconnect |
| 13 DJ Reclaim After Disconnect | PASS | Human multiplayer test confirmed Client B could claim after cleanup and continue using the preserved event stream |
| 14 Control After Reclaim | PASS | Human multiplayer test confirmed the new operator could change volume, stop, and restart with coherent authoritative revisions and generations |
| 15 Multiplayer Invalid Stream Failure | PASS | Human multiplayer test confirmed ERROR latching, responsive UI, and no retry churn or competing sources for the unreachable stream |
| 16 Multiplayer Stream Recovery | PASS | Human multiplayer test confirmed a new valid generation cleared ERROR, reached online, restored audible playback, and did not revive the failed source |
| 17 Final AE3/UI Regression Check | PASS | Human regression test confirmed one launcher/window per open, clean repeated teardown, no SQF errors, and continued exclusion from the unsynchronized laptop |

Final static checks: `hemtt check`, `hemtt build`, and `hemtt release` passed;
retained final RPTs contain zero SQF runtime errors and zero validation failures;
source and release contain zero `.ogg`, `.mp3`, `.wav`, or `.wss` music files.

**V0.1 RUNTIME ACCEPTED — READY FOR V0.2.**

## V0.2 release-candidate gates

Run `hemtt check` and `hemtt build`, then use `tools/start_smoke_test.ps1` for
library normalization, malformed-record rejection, mission ID replacement, search,
deck serialization, derived position, capability, JIP snapshot, provider lifecycle,
AE3 bridge, and repeated UI teardown diagnostics. A release candidate also requires
`hemtt release` and an audit confirming that music exists only in the separate
example pack PBO, never in a mission PBO.

Interactive behavior follows the 30-item table in `V0.2_VALIDATION.md`. Present one
test at a time and record only the operator's `PASS`, `FAIL`, `BLOCKED`, or `SKIP`.
Logs can support a result but cannot assert human audibility, spatial behavior,
visual layout, cue isolation, or multiplayer observation.

Use both generated entries from `edj_example_music_pack.pbo` for local Deck A/B
tests. Remove that PBO only after native tests are complete. Every client must load
it for local-track and finite-track JIP acceptance. Streaming regression tests use
the registered `groove` entry and do not depend on the example pack.

The current V0.2 automated pass produced 61/61 PASS markers with no validation
failure or SQF expression error in
`C:\Users\jaret\AppData\Local\Temp\edj-runtime-smoke\profiles\arma3_x64_2026-09-08_00-01-14.rpt`.
The dedicated rerun initialized V0.2 and passed workstation, registration,
duplicate, null-target, dependency, and revision checks in
`.hemttout/runtime-server/arma3server_x64_2026-09-07_23-57-20.rpt`.

All 30 required V0.2 interactive tests were marked PASS by the operator on
2026-09-08. The complete result table is in `V0.2_VALIDATION.md`.

**V0.2 RUNTIME ACCEPTED — READY FOR V0.3.**

## V0.2.5 fresh asset acceptance

Build the assets with `tools/build_assets.ps1`, run
`tools/validate_asset_ingestion.py`, then run `hemtt check`, `hemtt build`, and
`hemtt release`. Copy `tests/EDJ_Assets.VR` into the appropriate user/server
mission folder and load the current `@edj` build. The mission contains one player
and representative objects from every converted source pack; it embeds no music.

Human-observed checks are recorded in `V0.2.5_VALIDATION.md`. Inspect the six
current RaveSpace assemblies and four DJ/audio props together, then record
PASS/FAIL/BLOCKED/SKIP. Do not
infer visual, collision, LOD, shadow, or performance PASS from MLOD re-import or
HEMTT output. Previous stage, truss, lighting, screen, production, and individual
speaker classes must be absent from Eden and Zeus. Music Mixtable remains
`LICENSE_HOLD`; other source packs remain deferred until stage candidates are
deliberately selected.
