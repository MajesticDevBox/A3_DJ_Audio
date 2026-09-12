#pragma once

#include <cstdint>
#include <mutex>
#include <string>
#include <unordered_map>
#include <vector>

namespace edj {

// Info about a successfully loaded track, gathered by briefly decoding its
// header via miniaudio right after PBO extraction. This both proves the
// extracted bytes are valid audio and gives the SQF side numbers it can
// already use (duration for UI, etc.) well before real playback exists.
struct TrackInfo {
    std::vector<uint8_t> bytes; // original file bytes (OGG/WAV/MP3), as extracted from the PBO
    double durationSeconds = 0.0;
    uint32_t sampleRate = 0;
    uint32_t channels = 0;
};

// Process-wide cache of loaded tracks, keyed by a caller-supplied id (the
// SQF side is expected to use something stable like the stage id or track
// config name). Deliberately dumb: no LRU, no size cap yet -- callers must
// Release() what they Load() once a later milestone wires up real stop/
// cleanup paths. Fine for now since nothing calls Load() except the smoke
// test and manual console testing.
class TrackCache {
public:
    static TrackCache& Instance();

    // Stores `info` under `trackId`, replacing any existing entry.
    void Put(const std::string& trackId, TrackInfo info);

    bool Contains(const std::string& trackId) const;

    // Copies out the cached info. Returns false if trackId is not loaded.
    bool Get(const std::string& trackId, TrackInfo& out) const;

    void Release(const std::string& trackId);

private:
    TrackCache() = default;

    mutable std::mutex mutex_;
    std::unordered_map<std::string, TrackInfo> tracks_;
};

} // namespace edj
