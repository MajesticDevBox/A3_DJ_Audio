# Event DJ — V0.2.6

Arma 3 event-production framework with server-owned Deck A/B state, a searchable
config-driven music/stream library, queue, native finite-track controls and DJ-local
cue, AE3 workstation integration, and a Carpinchos streaming adapter. Version
**0.2.6** (HEMTT numeric version `0.2.6.0`).

## Build

Install HEMTT 1.21.0 and run from this directory:

```powershell
hemtt check
hemtt build
hemtt launch
hemtt release
```

Current HEMTT uses `.hemtt/project.toml`; a root `hemtt.toml` is obsolete.
See [development setup](docs/DEVELOPMENT.md) for installation and launch details.

### Add the local release to Arma Launcher

`hemtt release` creates ZIP archives under `releases`; the `releases` directory is
not itself an Arma mod folder. Extract `edj-0.2.6.0.zip`, then choose the contained
`releases\@edj` folder in **Mods → Local mod**. The selected folder must directly
contain `addons`, `keys`, and `mod.cpp`.

## Dependencies

| Dependency | Role |
| --- | --- |
| [CBA_A3](https://steamcommunity.com/sharedfiles/filedetails/?id=450814997) | Hard core dependency: local events and scheduling |
| [ACE3](https://steamcommunity.com/sharedfiles/filedetails/?id=463939057) | Required in the full workstation stack; AE3 dependency |
| [Advanced Equipment](https://steamcommunity.com/workshop/filedetails/?id=2888888564) | Full stack workstation; guarded adapter allows core-only operation |
| [Carpinchos Radio](https://steamcommunity.com/sharedfiles/filedetails/?id=3464681191) | Full stack streaming provider; optional for native playback |

No dependency code, binaries, models, or music are bundled. Install mods on the
server and all clients. The stream extension runs on interactive clients only.
Licensing for this repository remains **pending**; see LICENSE.

## Configure one stage

For synchronization-based PA setup, grouped speaker props, fullscreen workstations,
and the new Eden/Zeus radio module, see [audio modules](docs/AUDIO_MODULES.md).
The scripted setup below remains supported.

Place an AE3 laptop in Eden, set its interface to GUI/Both, and name it
`edjLaptop`. Place `EDJ: Add Event DJ Workstation` from the `Event DJ` module
category and synchronize it to that laptop. Place a separate PA prop named `edjPA`.
Give the laptop an AE3 user and power using the AE3 workflow. Add this to
`initServer.sqf`:

```sqf
["main", edjLaptop, edjPA, "groove", "carpinchos", []] call EDJ_fnc_registerStage;
```

An empty UID list permits any nearby player to claim an unoccupied workstation.
For a restricted event, replace `[]` with the permitted Steam UID strings.
Open **Event DJ** from the laptop's armaOS dock or Applications menu, click CLAIM,
then select a library entry and load Deck A or B. Remain within five metres to retain
control. Provider-aware controls show the actions each source actually supports.
Standalone development UI: `["main"] call EDJ_fnc_open` on a client.

The mission contains configuration only. The default source is an external public
SomaFM stream; availability is outside this project's control. The separate example
music-pack PBO contains two original synthesized development signals. No commercial
music is included and mission PBOs contain no music.

## Status and scope

V0.2 is runtime accepted. See the [V0.2 validation report](docs/V0.2_VALIDATION.md)
and [runtime procedure](docs/TESTING.md) for the recorded evidence.
Passing compilation does not prove audible playback or dedicated multiplayer.
V0.2.5 includes a separate asset PBO. Its reviewed production catalog contains
six RaveSpace speaker assemblies plus a media player, dual-deck controller,
digital mixing console, and performance keyboard. Previous stage, truss,
lighting, screen, production, and individual speaker props remain excluded;
their source library is preserved for later stage selection. Visual speaker
props remain separate from Event DJ audio emitters. Human in-game
acceptance is tracked in [V0.2.5 validation](docs/V0.2.5_VALIDATION.md).

Documentation: [architecture](docs/ARCHITECTURE.md), [multiplayer/security](docs/MULTIPLAYER.md),
[audio](docs/AUDIO_ARCHITECTURE.md), [AE3](docs/AE3_INTEGRATION.md),
[Carpinchos](docs/CARPINCHOS_INTEGRATION.md), [music packs](docs/MUSIC_PACKS.md),
[asset pipeline](docs/ASSET_PIPELINE.md), [asset manifest](docs/ASSET_MANIFEST.md),
[credits](docs/ASSET_CREDITS.md), [UI](docs/UI.md), [roadmap](docs/ROADMAP.md).
