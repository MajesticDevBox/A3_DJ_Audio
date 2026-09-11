# Advanced Equipment integration

Inspected upstream HEAD `de4f65c151d42b0f2ffa8228e69f2d5416259dcc` and the locally installed
Workshop PBOs on 2026-09-07.
Source: https://github.com/y0014984/Advanced-Equipment
Contract: https://github.com/y0014984/Advanced-Equipment/blob/de4f65c151d42b0f2ffa8228e69f2d5416259dcc/wiki/Examples/Register-Desktop-Apps.md

The physical RPT loads `D:\SteamLibrary\steamapps\common\Arma 3\!Workshop\@Advanced
Equipment\addons\ae3_desktop.pbo` and `ae3_armaos.pbo`, both version `2.0.0.0`.
The relevant unpacked files match upstream HEAD after normalizing line endings.

This build contains two separate desktop application systems. The native SQF
desktop uses display `17000`, `CfgAE3Apps`/`registerApp`, `app_list`, and
`wm_createWindow`. The normal armaOS GUI uses the CEF/web display `17010` and a
JavaScript registry populated through `registerExtApp`. Its renderer never reads
`CfgAE3Apps`. That is why `EDJ_EventDJ` appeared in `app_list` with
`showOnDesktop=true` while the physical laptop's Applications/Desktop UI omitted it.

EDJ now registers a web launcher through AE3's public `registerExtApp` API with
`requiresVar = ["EDJ_isWorkstation", true]`. The installed `jsRouter` applies this
filter against the active laptop before sending external apps to the browser, so
ordinary AE3 laptops do not receive Event DJ. The launcher's `openCommand` is
handled through AE3's public `registerCmd`/`jsReply` extension path. It closes the
web display, opens AE3's native desktop for the same laptop, and calls
`["EDJ_EventDJ"] call AE3_desktop_fnc_wm_createWindow`.

The installed `extapps.js` accepts a `showOnDesktop` property, but its
`desktop.js` surface only renders three fixed system icons plus entries stored in
the logged-in user's `~/Desktop` filesystem folder. It does not enumerate external
apps there. External applications are supported in the Applications registry and
dock through `showInMenu` and `showInDock`; EDJ enables both. Creating filesystem
launchers for every possible AE3 user would couple EDJ to private filesystem state,
so this V0.1 bridge stays on the documented extension API.

`wm_createWindow` still requires an entry in the native registry. EDJ therefore
registers one client-local native helper with display name `Event DJ`, entry
`EDJ_fnc_ae3App`, size `{1, 1}`, `showOnDesktop=false`, and `singleton=true`.
The old global `CfgAE3Apps` declaration was removed. The hidden helper cannot add
an icon to ordinary native desktops and exists only to preserve the current Event
DJ window behind the laptop-filtered web launcher.

In a web session, calling `wm_createWindow` directly returns `-1` because no native
`AE3_desktop_session` exists. After `desktop_open` establishes display `17000`, the
same call opens the existing Event DJ window; the engine smoke covers that bridge
and three close/reopen cycles.

Native callback arguments are `[winId, ctrlGroup, computer, args]`; EDJ returns
a HashMap and mounts its shared UI in the group. The computer's EDJ_stageId routes
requests, but never grants authority. Missing stage shows a disabled explanatory UI.
Missing AE3 leaves the core and standalone dashboard usable.

## Eden workstation module

Place `EDJ: Add Event DJ Workstation` from the `Event DJ` module category and
synchronize it to exactly one AE3 laptop. The server validates the target using
the installed AE3 device configuration and public `AE3_armaos_fnc_device_ensureInit`
API, then publishes `EDJ_isWorkstation=true` on that laptop. Object variables
published by the server are available to current clients and JIP clients.

Zero targets, multiple targets, and non-AE3 objects are rejected and logged as
`[EDJ][WARN] Invalid AE3 workstation target`. A valid laptop logs
`[EDJ][INFO] Event DJ workstation configured`. Clients log the native/web registry
and launch result as `[EDJ][DEBUG] AE3 application availability [...]` when EDJ
debug logging is enabled.

If a Workshop update changes either application contract, revalidate this adapter.
Set up users/filesystem and laptop power through AE3 before opening the desktop.
Follow upstream dedicated-server file-extension settings when using its web content.

Power contract inspected in `wiki/Reference/Power-API.md`: numeric
AE3_power_powerState is 0 off, 1 on, 2 standby, 3 crashed. getPowerState returns
localized text. `[consumer, provider] call AE3_power_fnc_createPowerConnection`
waits for device initialization; turnOnDevice/turnOffDevice control equipment.
No Event DJ consumer load is registered in V0.1. Future power integration belongs
here and should publish a server power transition, not poll client UI for authority.
AE3 source/assets are neither copied nor modified.

Remote policy: the inspected AE3 source supplies no CfgRemoteExec whitelist. The
V0.1 mission template permits the two functions used by native desktop open/close:
`AE3_main_fnc_sendVarToRemote` and
`AE3_interaction_fnc_manageAce3Interactions`, both server-only. Other AE3 apps,
inventory props, flash drives, web desktop, Zeus and power/network administration
invoke additional functions or commands. Audit and explicitly permit only those
workflows a mission enables. Do not switch to unrestricted mode to mask failures.
