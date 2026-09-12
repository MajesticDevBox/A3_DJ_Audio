#include "playback_manager.h"

#include "engine.h"

namespace edj {

PlaybackManager::ActiveSound::~ActiveSound() {
    if (soundInitialized) {
        ma_sound_uninit(&sound);
    }
    if (decoderInitialized) {
        ma_decoder_uninit(&decoder);
    }
}

PlaybackManager& PlaybackManager::Instance() {
    static PlaybackManager instance;
    return instance;
}

void PlaybackManager::DestroyLocked(const std::string& stageId) {
    sounds_.erase(stageId); // ~ActiveSound() tears down sound + decoder in order
}

bool PlaybackManager::Play(const std::string& stageId, std::vector<uint8_t> encodedBytes,
                            float gain, double offsetSeconds, float x, float y, float z,
                            float range, std::string& outError) {
    AudioEngine& engineWrapper = AudioEngine::Instance();
    if (!engineWrapper.IsInitialized()) {
        outError = "engine_not_initialized";
        return false;
    }

    auto active = std::make_unique<ActiveSound>();
    active->encodedBytes = std::move(encodedBytes);

    ma_decoder_config decoderConfig = ma_decoder_config_init_default();
    ma_result result = ma_decoder_init_memory(active->encodedBytes.data(),
                                               active->encodedBytes.size(), &decoderConfig,
                                               &active->decoder);
    if (result != MA_SUCCESS) {
        outError = std::string("decode_failed:") + ma_result_description(result);
        return false;
    }
    active->decoderInitialized = true;

    // MA_SOUND_FLAG_DECODE fully decodes up front on this (the calling)
    // thread. That means a Play() call briefly blocks on decode time --
    // acceptable for the short tracks this has been tested with, but a real
    // async path (decode on a worker thread, report back through the
    // already-wired RVExtensionRegisterCallback) is still a follow-up for
    // longer music files. See the extension README.
    bool initFailed = false;
    engineWrapper.WithEngine([&](ma_engine* engine) {
        if (engine == nullptr) {
            initFailed = true;
            return;
        }
        result = ma_sound_init_from_data_source(engine, (ma_data_source*)&active->decoder,
                                                 MA_SOUND_FLAG_DECODE, nullptr, &active->sound);
    });
    if (initFailed) {
        outError = "engine_not_initialized";
        return false;
    }
    if (result != MA_SUCCESS) {
        outError = std::string("sound_init_failed:") + ma_result_description(result);
        return false;
    }
    active->soundInitialized = true;

    ma_sound_set_position(&active->sound, x, y, z);
    ma_sound_set_volume(&active->sound, gain);
    ma_sound_set_attenuation_model(&active->sound, ma_attenuation_model_inverse);
    ma_sound_set_max_distance(&active->sound, range > 0.0f ? range : 1000.0f);
    ma_sound_set_rolloff(&active->sound, 1.0f);

    if (offsetSeconds > 0.0) {
        const ma_uint64 frame =
            static_cast<ma_uint64>(offsetSeconds * static_cast<double>(active->decoder.outputSampleRate));
        ma_sound_seek_to_pcm_frame(&active->sound, frame);
    }

    result = ma_sound_start(&active->sound);
    if (result != MA_SUCCESS) {
        outError = std::string("start_failed:") + ma_result_description(result);
        return false;
    }

    std::lock_guard<std::mutex> lock(mutex_);
    DestroyLocked(stageId); // replace anything already playing for this stage
    sounds_[stageId] = std::move(active);
    return true;
}

void PlaybackManager::Stop(const std::string& stageId) {
    std::lock_guard<std::mutex> lock(mutex_);
    DestroyLocked(stageId);
}

bool PlaybackManager::SetVolume(const std::string& stageId, float gain, std::string& outError) {
    std::lock_guard<std::mutex> lock(mutex_);
    auto it = sounds_.find(stageId);
    if (it == sounds_.end()) {
        outError = "stage_not_playing";
        return false;
    }
    // The whole point: change gain on the already-running sound, no restart.
    ma_sound_set_volume(&it->second->sound, gain);
    return true;
}

bool PlaybackManager::SetPosition(const std::string& stageId, float x, float y, float z,
                                   std::string& outError) {
    std::lock_guard<std::mutex> lock(mutex_);
    auto it = sounds_.find(stageId);
    if (it == sounds_.end()) {
        outError = "stage_not_playing";
        return false;
    }
    ma_sound_set_position(&it->second->sound, x, y, z);
    return true;
}

std::string PlaybackManager::Status(const std::string& stageId) const {
    std::lock_guard<std::mutex> lock(mutex_);
    auto it = sounds_.find(stageId);
    if (it == sounds_.end()) {
        return "missing";
    }
    return ma_sound_is_playing(&it->second->sound) ? "playing" : "stopped";
}

bool PlaybackManager::SetListener(float x, float y, float z, float dirX, float dirY, float dirZ,
                                   std::string& outError) {
    AudioEngine& engineWrapper = AudioEngine::Instance();
    bool ok = false;
    engineWrapper.WithEngine([&](ma_engine* engine) {
        if (engine == nullptr) {
            return;
        }
        ma_engine_listener_set_position(engine, 0, x, y, z);
        ma_engine_listener_set_direction(engine, 0, dirX, dirY, dirZ);
        ok = true;
    });
    if (!ok) {
        outError = "engine_not_initialized";
    }
    return ok;
}

} // namespace edj
