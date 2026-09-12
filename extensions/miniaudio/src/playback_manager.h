#pragma once

#include <cstdint>
#include <memory>
#include <mutex>
#include <string>
#include <unordered_map>
#include <vector>

#include "miniaudio.h"

namespace edj {

// One ma_sound per Event DJ stage, keyed by stageId. This is what finally
// gives local ("native") tracks the live per-source volume control that only
// the Carpinchos stream provider had before -- SetVolume() below changes a
// playing sound's gain in place via ma_sound_set_volume, no stop/restart.
//
// Directional attenuation itself is not computed here. It reuses the exact
// scalar-gain-over-time approach the project already uses for stream cones
// (addons/audio/functions/fn_streamGain.sqf, pushed periodically through
// SetVolume) rather than adding a second, engine-side spatialization model.
// This class's own spatialization (position + distance attenuation via
// ma_sound_set_position/ma_sound_set_max_distance) only handles falloff with
// distance from the listener, which is why SetListenerPosition must be
// called periodically too -- see the extension README for the current
// (1 Hz, via fn_audioTick.sqf) update rate and its trade-offs.
class PlaybackManager {
public:
    static PlaybackManager& Instance();

    // Takes ownership of `encodedBytes` (the original OGG/WAV/MP3 file
    // bytes). Replaces any existing sound already playing for this stageId.
    // Decoding happens synchronously on the calling thread -- see the
    // extension README for why this is a known, documented limitation
    // rather than the intended final design.
    bool Play(const std::string& stageId, std::vector<uint8_t> encodedBytes, float gain,
              double offsetSeconds, float x, float y, float z, float range,
              std::string& outError);

    void Stop(const std::string& stageId);
    void StopAll();

    bool SetVolume(const std::string& stageId, float gain, std::string& outError);
    bool SetPosition(const std::string& stageId, float x, float y, float z, std::string& outError);

    // "playing" | "stopped" | "missing"
    std::string Status(const std::string& stageId) const;
    std::string Debug(const std::string& stageId) const;
    std::string Control(const std::string& stageId, const std::string& operation, double seconds = 0);

    bool SetListener(float x, float y, float z, float dirX, float dirY, float dirZ,
                      std::string& outError);

private:
    PlaybackManager() = default;

    struct ActiveSound {
        ma_decoder decoder{};
        ma_sound sound{};
        std::vector<uint8_t> encodedBytes;
        bool decoderInitialized = false;
        bool soundInitialized = false;
        uint64_t serial = 0;
        ~ActiveSound();
    };

    // Caller must hold mutex_.
    void DestroyLocked(const std::string& stageId);

    mutable std::mutex mutex_;
    std::unordered_map<std::string, std::unique_ptr<ActiveSound>> sounds_;
    uint64_t nextSerial_ = 0;
};

} // namespace edj
