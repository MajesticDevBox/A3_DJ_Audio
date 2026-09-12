#include "engine.h"
#include <algorithm>
#include <cmath>
#include <sstream>

namespace edj {

AudioEngine& AudioEngine::Instance() {
    static AudioEngine instance;
    return instance;
}

AudioEngine::~AudioEngine() {
    // PlaybackManager is constructed after this singleton and destroys its
    // sounds first at process teardown. Explicit shutdown drains it at the ABI.
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
    config.channels = 2;
    config.sampleRate = 48000;
    config.pProcessUserData = this;
    config.onProcess = [](void* context, float* samples, ma_uint64 frames) {
        auto self = static_cast<AudioEngine*>(context);
        float peak = 0;
        for (ma_uint64 i = 0; i < frames * 2; ++i) peak = std::max(peak, std::abs(samples[i]));
        self->peak_.store(peak);
        self->renderedFrames_.fetch_add(frames);
    };
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

std::string AudioEngine::Meter() {
    std::lock_guard<std::mutex> lock(mutex_);
    if (!initialized_) return "0:engine_not_initialized";
    const auto device = ma_engine_get_device(&engine_);
    std::ostringstream out;
    out << "1:" << (device ? ma_get_backend_name(device->pContext->backend) : "no_device")
        << ':' << peak_.load() << ':' << renderedFrames_.load()
        << ':' << (device && ma_device_is_started(device));
    return out.str();
}

} // namespace edj
