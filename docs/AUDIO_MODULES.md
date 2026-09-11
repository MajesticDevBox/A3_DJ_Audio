# PA, speaker arrays, and radios

## Eden stage without variable names or initServer code

1. Sync **EDJ: Add Event DJ Workstation** to one compatible AE3 laptop. Configure its AE3 user and power as before.
2. Sync **EDJ: Main PA** to that workstation module and exactly one prop that will emit audio.
3. Set the PA module's unique stage ID, registered audio source ID, volume, gain, native range, and optional stream cone.
4. Optionally place **EDJ: Stage Speaker Array**, sync it to the Main PA module, and sync any number of speaker props to the array module. Multiple array modules may connect to one PA.

Do not also call registerStage for this stage. Each PA must have its own laptop and emitter. The stage ID defaults to `main`; change it for additional stages.

The main PA is the only playback origin. Array members are a logical group recorded in the stage snapshot, not a physically merged model, distributed emitter, or acoustic simulation. Moving or rotating a secondary speaker does not change playback. Place and face the main PA where the combined array should sound from. This avoids overlapping streams, echoes, and duplicate sources. Rewire Eden links before mission start; runtime graph changes are not applied.

## Volume and direction

New stage defaults are master volume 1, output gain 2, native range 500 m (previously 0.5 and 200 m). The existing six-argument registration call remains supported. An optional seventh argument is `[volume, gain, nativeRange, streamConeDegrees]`.

Gain accepts 0-10. Native playback caps the final gain at 5. Range is clamped to 1-5000 m. These values are settings to audition, not a guaranteed audible radius.

Carpinchos still controls stream distance attenuation and its global sound-range cutoff. Increase that CBA setting for a larger event; an EDJ native-range value cannot override it. EDJ does not change the listener's global volume, streamer mode, or ACE hearing settings.

A stream cone of 360 is omnidirectional. Smaller cones preserve full gain inside the front cone and gradually reduce it to 15% at the rear, following the main prop's heading. Listener movement is evaluated once per second. This is gain-based directionality, not obstruction or beamforming. Native tracks remain omnidirectional: playSound3D does not expose a live cone control. Native volume/gain is applied at playback start; existing provider limitations on live volume remain.

## Radio / Music Player

Eden: synchronize **EDJ: Radio / Music Player** to one prop. Enter a registered stream or music-pack track ID and set volume, gain, and native range. No laptop or variable name is needed. Playback starts when the mission initializes.

Zeus: drop the module on/near a prop. The picker lists props within 20 m and the installed audio library, with volume, gain, and native-range inputs. Select the intended prop and click START RADIO. Streams require Carpinchos on listeners; addon tracks require the music pack. A finite track plays once. This module selects individual music-pack tracks, not an entire playlist.

One target may belong to only one stage/radio. Delete the radio module to stop playback; after the server maintenance interval (up to two seconds), another module may reuse the prop. To change the source/settings, delete and replace the module. Cancelling the picker leaves an inactive module that can be deleted. An invalid source or occupied target is rejected; inspect the server RPT for registration failures.

Missions with an explicit remote-execution whitelist must also allow `EDJ_fnc_radioDialog` (targets 0, server-sender checked) and `EDJ_fnc_configureRadio` (targets 2, curator-owner checked). No remote command permissions are needed.

## Workstation display

The AE3 app now uses the full safe-zone dimensions, with content below its titlebar so Close remains reachable. The standalone dashboard also fills the safe zone (Escape closes it). The existing layout scales to the available area.

## Verification

HEMTT compilation/build checks cover SQF and module configs. `tests/EDJ_Smoke.VR/audioModules.sqf` exercises radio creation, duplicate rejection, module deletion, gain defaults, and front/rear stream gain. The existing smoke suite checks AE3 registration and open/close cycles.

Before event use, verify Eden synchronization, Zeus placement/picker, close/reopen and screen edges at your aspect ratio, radio replacement, native tracks and streams at several distances, front/rear stream levels, and dedicated-server two-client/JIP playback. Confirm there is exactly one active provider source per stage with several array props connected. Compilation alone does not establish these outcomes.
