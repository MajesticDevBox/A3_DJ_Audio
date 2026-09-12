#include "pbo_cache.h"

namespace edj {

PboCache& PboCache::Instance() {
    static PboCache instance;
    return instance;
}

PboArchive* PboCache::GetOrOpen(const std::string& path, std::string& outError) {
    std::lock_guard<std::mutex> lock(mutex_);
    auto it = archives_.find(path);
    if (it != archives_.end()) {
        return it->second.get();
    }

    std::string error;
    std::unique_ptr<PboArchive> archive = PboArchive::Open(path, error);
    if (!archive) {
        outError = error;
        return nullptr;
    }

    PboArchive* raw = archive.get();
    archives_[path] = std::move(archive);
    return raw;
}

void PboCache::Invalidate(const std::string& path) {
    std::lock_guard<std::mutex> lock(mutex_);
    archives_.erase(path);
}

} // namespace edj
