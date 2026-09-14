#pragma once

#include <cstdint>
#include <memory>
#include <mutex>
#include <string>
#include <unordered_map>
#include <vector>

#include "miniaudio.h"
#include "array_node.h"

namespace edj {

// One ma_sound/decoder per stage (plus a separate local cue key). ArrayNode
// spatializes shared PCM into up to eight array emitters without extra clocks.
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
    std::string SetArrays(const std::string& stageId, const std::vector<float>& values);

    bool SetListener(float x, float y, float z, float dirX, float dirY, float dirZ,
                      std::string& outError);

private:
    PlaybackManager() = default;

    struct ActiveSound {
        ma_decoder decoder{};
        ma_sound sound{};
        ArrayNode arrays;
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
