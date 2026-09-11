# Architecture

Seven PBO boundaries are implemented:

| Addon | Responsibility |
| --- | --- |
| main | Initialization and TRACE/DEBUG/INFO/WARN/ERROR diagnostics |
| core | Stage registration, transport identity, authority, snapshots, JIP |
| audio | Provider dispatch, capability checks, native addon-track playback |
| ui | Shared dashboard controls and request controller |
| compat_ae3 | Config app registration and documented native entry callback |
| compat_carpinchos | Version-bound local stream events and extension probe |
| example_music_pack | Removable source-pack example with two original development signals |

The core does not call dependency-specific APIs. UI calls `request`, which sends
only stage ID, command and a bounded registered-ID/index value. `serverRequest` resolves the
actual network sender and validates the request. `commitStage` is the only runtime
mutation path: it applies changed keys, increments the revision once and invokes
`publish`. `receive` rejects non-server origins and applies the audio snapshot locally.

`EDJ_stages` is a server HashMap keyed by stage ID. Entries include workstation,
emitter, private allowedUIDs, operator object/UID, serialized Deck A/B records,
queue IDs, active deck, normalized now-playing data, the V0.1-compatible active
output projection, master volume, revision, powerState, zoneId, and range. Snapshots
omit allowedUIDs. One emitter and one active playback timeline exist per stage;
decorative props never automatically become audio sources.

Public mission configuration entry: `EDJ_fnc_registerStage` is server-local only.
It rejects duplicate IDs, missing objects and unregistered sources. Register in
`initServer.sqf`; registries initialize in preInit because mission initServer can
precede addon postInit. Runtime stage removal/reconfiguration is not
part of V0.1; use a new mission session to change the registry.

Extension paths: introduce zone arrays in V0.3, then
lighting/LED preset IDs and server epoch times. Preserve monotonic revisions and
the command boundary. The `powerState` field currently defaults true and does not
implement generator consumption; AE3 itself owns laptop power and access.
