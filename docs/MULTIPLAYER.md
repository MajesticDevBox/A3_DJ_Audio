# Multiplayer and security

The server owns stage, Deck A/B, queue, active deck, master volume, now-playing,
timing, generation, and revision. `commitStage` remains the only runtime mutation
and publication path. Snapshots omit the private UID allowlist and include serialized
deck records and queue IDs for JIP.

Clients send stage ID, operation, and a bounded payload. The server derives the
sender from `remoteExecutedOwner`, resolves the live player, checks five-metre range,
UID allowlist, and current operator, then resolves registered track/stream IDs from
its own config cache. It never accepts a file path, URL, config expression, player
object, or claimed UID from the client.

Protected operations are claim/release, master volume, deck load/play/pause/resume/
stop/seek, queue add/remove/reorder/clear/load-next, and active-deck CUT. Unknown,
malformed, unsupported, out-of-range, and non-operator requests are denied without
changing revision, generation, or queue. Existing denial rate limiting remains.

Finite tracks publish transitions and timing anchors only. Each client derives
position locally, including JIP, and starts its local sound at that offset. Streams
attach the joining client without restarting existing clients. Missing local packs
produce a client-local error while authoritative state remains intact.

Cue is intentionally outside the network mutation surface. The UI allows it only
for the current operator and a native finite track. Operator loss or UI teardown
stops the local cue handle.

| Function | Direction | Purpose |
| --- | --- | --- |
| `EDJ_fnc_serverRequest` | client to server | Validate and apply one registered-ID intent |
| `EDJ_fnc_sync` | client to server | Request current revisioned snapshots after player initialization |
| `EDJ_fnc_receive` | server to clients | Apply newer snapshots and local provider state |

The addon retains restrictive per-function `CfgRemoteExec` targets without setting
the mission's global mode. Mission/server administrators own the final merged remote
policy and must retain the AE3 functions needed by the installed desktop.
