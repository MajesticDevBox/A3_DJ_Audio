// Isolated implementation translation unit for the vendored miniaudio +
// stb_vorbis pair. Nothing else in this project should define
// MINIAUDIO_IMPLEMENTATION or pull in stb_vorbis.c directly -- everyone else
// just includes "miniaudio.h" for declarations and links against this file.
//
// The header-only-then-implementation double include of stb_vorbis.c is the
// pairing miniaudio.h itself expects (it gates its optional Vorbis decoding
// backend behind STB_VORBIS_INCLUDE_STB_VORBIS_H, which stb_vorbis.c defines
// as its own header guard).

#define STB_VORBIS_HEADER_ONLY
#include "stb_vorbis.c"

#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#undef STB_VORBIS_HEADER_ONLY
#include "stb_vorbis.c"
