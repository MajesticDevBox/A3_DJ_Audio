# Carpinchos integration

Inspected upstream HEAD `0345887571038b5414c4ecc4d22e849fea4eb445` on 2026-09-07.
Source: https://github.com/Doble-K/ArmaRadio/tree/0345887571038b5414c4ecc4d22e849fea4eb445
Read manager/functions/fnc_play.sqf, fnc_tick.sqf, fnc_applyGain.sqf,
manager/XEH_preInit.sqf, XEH_postInit.sqf and src/source.rs.

There is no stable documented public server-authoritative DJ API. This adapter
depends on the inspected implementation's **local** CBA event contracts:

| Surface | Actual arguments / behavior |
| --- | --- |
| live_radio_manager_start | [id, url, emitter]; creates extension source and adds it to sources map |
| live_radio_manager_stop | [id]; destroys source and removes title/status/source entries |
| live_radio_manager_volume | [id, gain]; applies gain, respecting out-of-range state |
| live_radio_manager_sourcesStatus | id -> online/offline from ExtensionCallback |
| live_radio_manager_volume object variable | local per-emitter gain |

The upstream play function uses global events and public active variables; EDJ
intentionally does not invoke it. EDJ snapshots and JIP are the only EDJ network
state. IDs are namespaced by stage and play generation. The adapter keeps one local
source record per stage and refuses to start a competing source before the prior
generation is destroyed. EDJ does not set the upstream `active` variable,
avoiding the upstream JIP scan and auto-off logic creating duplicate streams.
The manager tick updates source positions relative to player/curator and the
listener orientation. Range comes from Carpinchos settings, not EDJ's native range.

The manager's local source map confirms event handling. Event DJ does not issue an
immediate `source:exists` probe because source creation and extension registration
are asynchronous; doing so raced and destroyed valid starts during runtime testing.
Carpinchos owns its own `source:exists` watchdog and source recreation. Delayed
callbacks report online/offline. The tested extension produced title metadata but
dropped its earlier online callback; because title metadata is emitted only after
decoded stream data arrives, Event DJ also treats a title for the active source as
online. Without either signal the state remains connecting for 15 seconds and then
becomes offline, preventing a permanent STARTING state after DNS/HTTP failure.
Start still never proves audible output. The upstream decoder
handles stream retries. EDJ itself adds no retry loop and
does not rapidly recreate failed streams. STOP/PLAY offers deliberate recovery.
An extension load failure returns an error without blocking the UI.

The compatibility PBO requires `live_radio_manager` and publishes its provider
through `CfgEDJAudioProviders`. Dependencies are detected on interactive clients;
dedicated servers never create
an EDJ extension audio source. Missing manager functions/maps returns unavailable.
Personal gain, streamer mode, ACE hearing and upstream interference remain active.
This is a version-bound implementation dependency, not a claim of upstream API
stability. Repeat runtime tests on dependency upgrades. No dependency code is bundled.
