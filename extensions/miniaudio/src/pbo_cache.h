#pragma once

#include <memory>
#include <mutex>
#include <string>
#include <unordered_map>

#include "pbo_reader.h"

namespace edj {

// Keeps parsed PboArchive header tables around by path so repeated
// read_track/list_entries calls against the same PBO (the common case --
// one music pack, many tracks) don't re-read and re-parse the header table
// every time.
class PboCache {
public:
    static PboCache& Instance();

    // Returns the cached archive for `path`, opening and parsing it first if
    // needed. Returns nullptr and fills outError on failure. The returned
    // pointer is owned by the cache and remains valid until the process
    // exits or Invalidate() is called for that path.
    PboArchive* GetOrOpen(const std::string& path, std::string& outError);

    void Invalidate(const std::string& path);

private:
    PboCache() = default;

    mutable std::mutex mutex_;
    std::unordered_map<std::string, std::unique_ptr<PboArchive>> archives_;
};

} // namespace edj
