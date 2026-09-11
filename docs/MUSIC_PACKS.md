# Event DJ music packs

Music packs are separate addons. They require no mission script and no Event DJ
source edit. A typical deployment loads `@EventDJ` and `@MyEventMusicPack` on the
server and every player who needs local-track playback.

## Layout

```text
MyEventMusicPack/
├── config.cpp
├── $PBOPREFIX$
└── audio/
    ├── song01.ogg
    └── song02.ogg
```

Pack the directory as its own PBO. Its prefix must match the absolute paths used
below.

```cpp
class CfgPatches {
 class MyEventMusicPack {
  units[] = {};
  weapons[] = {};
  requiredVersion = 2.20;
  requiredAddons[] = {"EDJ_audio"};
 };
};
class CfgEventDJTracks {
 class MyPack_Song01 {
  id = "mypack.song01";               // globally unique public ID
  title = "Original Song";             // required
  artist = "Pack Author";              // recommended
  album = "Event Set";                 // optional
  genre = "Electronic";                // optional
  duration = 243;                       // required, seconds, greater than zero
  bpm = 128;                            // optional; omit when unknown
  sourceType = "addon";
  backend = "native";
  file = "\mypack\audio\song01.ogg";   // required absolute addon path
  originatingAddon = "MyEventMusicPack";
  artwork = "";                         // reserved for a later visual consumer
  compatibilityVersion = 2;
 };
};
```

IDs may contain letters, digits, `_`, `-`, and `.` and must be unique across every
loaded pack. Event DJ skips malformed definitions and duplicate addon IDs with a
useful RPT warning. The UI uses title and artist; it never exposes config class names
as the operator workflow. All clients need the same pack. A missing pack leaves the
server state coherent, prevents only that client's local playback, and displays a
missing-source warning.

Use OGG Vorbis at 44.1 or 48 kHz, stereo, with a practical music bitrate such as
128–192 kbps. Record exact duration after encoding because pause, seek, progress,
completion, and JIP position depend on it. Test PLAY, STOP, PAUSE, RESUME, several
seek offsets, cue, end-of-track, and a JIP client before publishing.

Publish music packs as separate Workshop items so subscribers opt into their size
and licensing terms. Upload only recordings and artwork you created or have explicit
rights to redistribute. A streaming license or personal copy does not grant Workshop
redistribution rights.

`addons/example_music_pack` is a working source template. It produces the removable
`edj_example_music_pack.pbo` with two original synthesized development signals and
demonstrates every required field. It is test material, not commercial music.

Streams use the common library but retain live behavior:

```cpp
class CfgEventDJStreams {
 class MyPack_Station {
  id = "mypack.station";
  displayName = "My Station";
  description = "Public event stream";
  backend = "carpinchos";
  url = "https://radio.example/live.mp3";
  compatibilityVersion = 2;
 };
};
```

Do not embed credentials or tokens. Streams have no deterministic duration, BPM,
seek, or native cue unless a future provider truthfully advertises those features.
