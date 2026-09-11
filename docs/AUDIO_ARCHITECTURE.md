# Audio architecture

The accepted provider boundary remains `EDJ_fnc_audioCall`. `audioInit` discovers
handlers and capabilities from `CfgEDJAudioProviders`; compatibility PBOs contribute
providers without making the core depend on them.

| Provider | V0.2 capabilities |
| --- | --- |
| native | play, stop, pause, resume, seek, duration, position, spatial, cue, status |
| carpinchos | play, stop, volume, streaming, metadata, spatial, status |

The server owns logical deck states. Clients own local sound handles. A new deck
generation, source ID, or backend restarts the local active output; unrelated queue,
ownership, or UI revisions do not. Failed starts remain latched to that generation.

Native finite playback uses `playSound3D` with an absolute registered addon path and
an offset derived from `startOffset + (serverTime - startServerTime)`. Pause stores
the derived position and stops local output. Resume and a playing seek create a new
generation at the committed offset. Completion is clamped by the known duration and
the server maintenance pass stops the logical deck. Native cue uses `playSoundUI`
and a separate DJ-local handle; it never mutates or publishes stage state.

Carpinchos remains a local adapter over its installed CBA event/manager contract.
Each client attaches independently to the server-selected stream. The bounded
title-metadata online fallback remains: decoded metadata can establish online state
when this dependency build misses its earlier status callback, but playback success
does not require metadata. Stream controls do not advertise pause, seek, duration,
finite progress, or cue.

Stage master volume is the only V0.2 gain hierarchy. Carpinchos applies it live.
Native does not advertise live volume because Arma cannot safely adjust the existing
`playSound3D` handle without restarting. The UI reflects that difference.
