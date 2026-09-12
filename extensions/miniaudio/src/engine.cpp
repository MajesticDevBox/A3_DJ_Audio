#include "engine.h"

namespace edj {

AudioEngine& AudioEngine::Instance() {
    static AudioEngine instance;
    return instance;
}

AudioEngine::~AudioEngine() {
    Shutdown();
}

bool AudioEngine::Init() {
    std::lock_guard<std::mutex> lock(mutex_);
    if (initialized_) {
        return true;
    }

    ma_engine_config config = ma_engine_config_init();
    // No listeners are attached until per-stage playback lands; the engine
    // still needs at least the default listener slot to initialize cleanly.
    config.listenerCount = 1;
    // Decoding happens off the Arma scripting thread per the design in the
    // project docs; miniaudio's own mixing thread covers that already, so no
    // extra worker pool is configured here yet.
    config.noAutoStart = MA_FALSE;

    ma_result result = ma_engine_init(&config, &engine_);
    if (result != MA_SUCCESS) {
        lastError_ = std::string("ma_engine_init failed: ") + ma_result_description(result);
        initialized_ = false;
        return false;
    }

    lastError_.clear();
    initialized_ = true;
    return true;
}

void AudioEngine::Shutdown() {
    std::lock_guard<std::mutex> lock(mutex_);
    if (!initialized_) {
        return;
    }
    ma_engine_uninit(&engine_);
    initialized_ = false;
}

bool AudioEngine::IsInitialized() const {
    std::lock_guard<std::mutex> lock(mutex_);
    return initialized_;
}

const std::string& AudioEngine::LastError() const {
    std::lock_guard<std::mutex> lock(mutex_);
    return lastError_;
}

} // namespace edj
