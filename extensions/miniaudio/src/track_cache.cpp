#include "track_cache.h"

namespace edj {

TrackCache& TrackCache::Instance() {
    static TrackCache instance;
    return instance;
}

void TrackCache::Put(const std::string& trackId, TrackInfo info) {
    std::lock_guard<std::mutex> lock(mutex_);
    tracks_[trackId] = std::move(info);
}

bool TrackCache::Contains(const std::string& trackId) const {
    std::lock_guard<std::mutex> lock(mutex_);
    return tracks_.find(trackId) != tracks_.end();
}

bool TrackCache::Get(const std::string& trackId, TrackInfo& out) const {
    std::lock_guard<std::mutex> lock(mutex_);
    auto it = tracks_.find(trackId);
    if (it == tracks_.end()) {
        return false;
    }
    out = it->second;
    return true;
}

void TrackCache::Release(const std::string& trackId) {
    std::lock_guard<std::mutex> lock(mutex_);
    tracks_.erase(trackId);
}

} // namespace edj
