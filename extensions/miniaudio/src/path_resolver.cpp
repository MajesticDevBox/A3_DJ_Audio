#include "path_resolver.h"

#include <algorithm>
#include <filesystem>
#include <fstream>

#include "pbo_cache.h"
#include "pbo_reader.h"

namespace fs = std::filesystem;

namespace edj {

std::string PathResolver::NormalizePath(const std::string& virtualPath) {
    std::string s = virtualPath;
    // Strip a single leading slash/backslash -- config `file` values are
    // written like "\z\edj\addons\..." per docs/MUSIC_PACKS.md.
    if (!s.empty() && (s.front() == '\\' || s.front() == '/')) {
        s.erase(s.begin());
    }
    for (char& c : s) {
        c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
        if (c == '/') {
            c = '\\';
        }
    }
    return s;
}

PathResolver& PathResolver::Instance() {
    static PathResolver instance;
    return instance;
}

int PathResolver::RegisterSearchRoot(const std::string& rootPath, std::string& outError) {
    std::error_code ec;
    if (!fs::is_directory(rootPath, ec) || ec) {
        outError = "search_root_not_a_directory";
        return -1;
    }

    Root root;
    root.path = rootPath;

    int indexed = 0;
    for (const auto& entry : fs::directory_iterator(rootPath, ec)) {
        if (ec) {
            break;
        }
        if (!entry.is_regular_file()) {
            continue;
        }
        std::string ext = entry.path().extension().string();
        for (char& c : ext) {
            c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
        }
        if (ext != ".pbo") {
            continue;
        }

        std::string pboPath = entry.path().string();
        std::string pboError;
        PboArchive* archive = PboCache::Instance().GetOrOpen(pboPath, pboError);
        if (archive == nullptr) {
            // A malformed/unrelated .pbo in the folder shouldn't block
            // registration of the ones that do parse.
            continue;
        }

        auto it = archive->Properties().find("prefix");
        if (it == archive->Properties().end()) {
            continue;
        }
        root.pboPrefixes[NormalizePath(it->second)] = pboPath;
        ++indexed;
    }

    std::lock_guard<std::mutex> lock(mutex_);
    // Replace any prior registration of the same root rather than duplicate it.
    roots_.erase(std::remove_if(roots_.begin(), roots_.end(),
                                 [&](const Root& r) { return r.path == rootPath; }),
                 roots_.end());
    roots_.push_back(std::move(root));
    return indexed;
}

ResolvedTrack PathResolver::Resolve(const std::string& virtualPath) const {
    const std::string normalized = NormalizePath(virtualPath);
    if (normalized.empty() || normalized.front() == '\\' || normalized.find(':') != std::string::npos ||
        normalized.find("..") != std::string::npos || normalized.find('"') != std::string::npos) return {};

    std::lock_guard<std::mutex> lock(mutex_);
    for (const auto& root : roots_) {
        // 1) Loose file, for HEMTT dev/file-patching builds: rebuild the
        // virtual path's separators as the platform's own separator and look
        // for it directly under this root.
        std::string relative = normalized;
        std::replace(relative.begin(), relative.end(), '\\',
                     static_cast<char>(fs::path::preferred_separator));
        fs::path loosePath = fs::path(root.path) / relative;
        // Canonical containment also prevents a file-patching symlink from
        // turning a registered audio root into arbitrary filesystem access.
        std::error_code fileEc;
        if (fs::is_regular_file(loosePath, fileEc) && !fileEc) {
            const auto base = fs::weakly_canonical(root.path, fileEc);
            const auto target = fs::weakly_canonical(loosePath, fileEc);
            const auto rel = target.lexically_relative(base);
            if (fileEc || rel.empty() || *rel.begin() == "..") continue;
            ResolvedTrack result;
            result.kind = ResolvedKind::LooseFile;
            result.looseFilePath = loosePath.string();
            return result;
        }

        // 2) Longest-matching PBO prefix.
        const std::string* bestPrefix = nullptr;
        const std::string* bestPbo = nullptr;
        for (const auto& kv : root.pboPrefixes) {
            const std::string& prefix = kv.first;
            const bool matches = normalized.size() > prefix.size() + 1 &&
                                  normalized.compare(0, prefix.size(), prefix) == 0 &&
                                  normalized[prefix.size()] == '\\';
            if (matches && (bestPrefix == nullptr || prefix.size() > bestPrefix->size())) {
                bestPrefix = &prefix;
                bestPbo = &kv.second;
            }
        }
        if (bestPrefix != nullptr) {
            ResolvedTrack result;
            result.kind = ResolvedKind::PboEntry;
            result.pboPath = *bestPbo;
            result.pboEntryName = normalized.substr(bestPrefix->size() + 1);
            return result;
        }
    }

    return ResolvedTrack{};
}

} // namespace edj
