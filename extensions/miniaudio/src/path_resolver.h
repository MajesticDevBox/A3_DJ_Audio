#pragma once

#include <cstdint>
#include <mutex>
#include <string>
#include <unordered_map>
#include <vector>

namespace edj {

enum class ResolvedKind { None, LooseFile, PboEntry };

struct ResolvedTrack {
    ResolvedKind kind = ResolvedKind::None;
    std::string looseFilePath; // valid when kind == LooseFile
    std::string pboPath;       // valid when kind == PboEntry
    std::string pboEntryName;  // valid when kind == PboEntry
};

// Solves the gap noted in the extension README: Arma config files reference
// audio by a *virtual* addon path (e.g. "\z\edj\addons\example_music_pack"
// + "\audio\groove.ogg"), but this extension needs a real path on disk. There is
// no general, automatic way to ask Arma for a mod's install directory (see
// the project chat history for what was checked), so the caller registers
// one or more real "search roots" up front -- typically the folder a HEMTT
// dev build links to, or the `addons` folder of a deployed mod.
//
// For each registered root, resolution tries two things, in order:
//   1. A loose file at root + the virtual path (minus its mod-root prefix).
//      This covers HEMTT dev/file-patching builds, where the files backing
//      the virtual tree are plain files on disk, not packed into a PBO yet.
//   2. A PBO in that root whose internal "prefix" property is the longest
//      matching prefix of the virtual path. This covers a normally deployed,
//      packed mod.
class PathResolver {
public:
    static PathResolver& Instance();

    // Scans `rootPath` for *.pbo files and indexes their "prefix" properties.
    // Safe to call more than once for the same root (re-scans). Returns the
    // number of PBOs successfully indexed, or -1 with outError set on a
    // hard failure (root itself unreadable).
    int RegisterSearchRoot(const std::string& rootPath, std::string& outError);

    ResolvedTrack Resolve(const std::string& virtualPath) const;

private:
    PathResolver() = default;

    struct Root {
        std::string path;
        // Normalized PBO "prefix" property -> absolute path of that PBO.
        std::unordered_map<std::string, std::string> pboPrefixes;
    };

    static std::string NormalizePath(const std::string& virtualPath);

    mutable std::mutex mutex_;
    std::vector<Root> roots_;
};

} // namespace edj
