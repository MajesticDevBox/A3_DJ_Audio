// A portable Windows runtime artifact, not a developer-local build directory.
let dll = HEMTT_RFS.join("extensions/miniaudio/bin/edj_miniaudio_x64.dll");
if !dll.is_file() { fatal("Missing miniaudio runtime. Run tools/build_miniaudio.ps1 before packaging."); }
if !dll.copy(HEMTT_OUT.join("edj_miniaudio_x64.dll")) { fatal("Cannot package miniaudio runtime"); }
