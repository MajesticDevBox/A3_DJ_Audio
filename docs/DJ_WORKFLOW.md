# DJ workflow

Open Event DJ from the synchronized AE3 workstation and claim it within five
metres. The library combines finite addon tracks and live streams. Search matches
title, artist, album, and genre; the source filter limits results to local entries
or streams.

Select an entry and choose **LOAD A** or **LOAD B**. Loading resolves the registered
ID on the server. It never accepts a client-provided file path or URL. Each deck
shows title, artist, source type, backend, state, and finite progress when known.

**PLAY** selects that deck as output and starts it from the beginning. **PAUSE**,
**RESUME**, and seek are enabled for the native finite-track backend. They remain
disabled for live streams. **CUE** previews a native finite track locally for the
current DJ and never changes stage state. Closing the dashboard or losing operator
ownership stops cue.

The queue stores registered IDs. **ADD TO QUEUE**, **REMOVE**, **UP**, **DOWN**,
and **NEXT -> A/B** operate on the selected rows. The clear button displays `OK?`
for three seconds and requires a second click. Load-next removes the first queue
entry and loads it without beginning playback.

**OUTPUT A/B** performs the V0.2 transition mode, `CUT`: the old deck stops, the
selected loaded deck becomes active, and its output begins. There is no gain ramp
or implied beat synchronization. Master gain remains the single stage volume;
native output does not expose a live gain control because that backend cannot apply
one safely to an existing sound instance.
