# V0.2 dashboard

The same mount/render/controller functions serve the standalone dialog and AE3's
native window bridge at approximately `0.72 x 0.60`.

The upper row presents Deck A, master/output status, and Deck B. Each deck shows
track, artist, source/backend, state, and finite position/duration. Play, pause or
resume, stop, cue, and seek derive their enabled state from the loaded provider's
capabilities. Output A/B performs the documented CUT transition.

The library reads the normalized preInit cache. Its edit field searches title,
artist, album, and genre case-insensitively; the combo filters all/local/stream
entries. Rows display human metadata and load into either deck. No config traversal
runs during render or keypress handling.

The queue lists normalized track names and provides add, remove, up, down, load-next,
and confirmed clear. Controls submit intent through `EDJ_fnc_request`; they never
mutate snapshots optimistically. Master volume and seek requests debounce for 300 ms.

The 4 Hz render PFH is presentation-only and is removed with all dynamic controls on
remount or close. Teardown also stops local cue. Audio output otherwise continues
when the dashboard closes. Missing local music packs produce a visible warning.
