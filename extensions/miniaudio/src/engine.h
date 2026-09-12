#pragma once

#include <mutex>
#include <string>
#include <utility>
#include <atomic>

#include "miniaudio.h"

namespace edj {

// Owns the single ma_engine instance for the process. One Arma client process
// hosts one extension instance, so this is a process-wide singleton rather
// than something threaded through per-call state.
//
// Scope note: this only stands the engine up and tears it down. It does not
// yet expose sound creation/playback -- that lands with the PBO reader and
// the SQF-facing play/stop/volume operations, once the file-access story is
// decided (see docs in the repo root README for this extension).
class AudioEngine {
public:
    static AudioEngine& Instance();

    AudioEngine(const AudioEngine&) = delete;
    AudioEngine& operator=(const AudioEngine&) = delete;

    // Idempotent: returns true if the engine is already running. On failure,
    // the engine remains uninitialized and LastError() explains why.
    bool Init();

    // Idempotent: safe to call when not initialized.
    void Shutdown();

    bool IsInitialized() const;
    std::string Meter();

    // Human-readable reason the most recent Init() call failed, if any.
    const std::string& LastError() const;

    // Raw handle for future playback code. Callers must hold IsInitialized()
    // true and are expected to coordinate with this class's mutex themselves
    // via WithEngine() rather than caching the pointer.
    template <typename Fn>
    auto WithEngine(Fn&& fn) -> decltype(fn(std::declval<ma_engine*>())) {
        std::lock_guard<std::mutex> lock(mutex_);
        return fn(initialized_ ? &engine_ : nullptr);
    }

private:
    AudioEngine() = default;
    ~AudioEngine();

    mutable std::mutex mutex_;
    ma_engine engine_{};
    bool initialized_ = false;
    std::string lastError_;
    std::atomic<float> peak_{0};
    std::atomic<uint64_t> renderedFrames_{0};
};

} // namespace edj
