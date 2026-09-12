#include "pbo_reader.h"

#include <algorithm>
#include <cctype>
#include <cstring>

namespace edj {

namespace {

// FourCC integers are stored little-endian, not as the printed tag text.
constexpr unsigned char kMagicVers[4] = {'s', 'r', 'e', 'V'};
constexpr unsigned char kMagicCprs[4] = {'s', 'r', 'p', 'C'};
constexpr unsigned char kMagicNone[4] = {0, 0, 0, 0};

bool ReadCString(std::ifstream& file, std::string& out) {
    out.clear();
    char c;
    while (file.get(c)) {
        if (c == '\0') {
            return true;
        }
        out.push_back(c);
        // Guard against a corrupt/non-PBO file with no null terminator ever
        // appearing: bail rather than reading the whole file into a "name".
        if (out.size() > 4096) {
            return false;
        }
    }
    return false; // hit EOF before a terminator
}

bool ReadRaw4(std::ifstream& file, unsigned char out[4]) {
    file.read(reinterpret_cast<char*>(out), 4);
    return static_cast<bool>(file);
}

bool ReadU32(std::ifstream& file, uint32_t& out) {
    unsigned char bytes[4];
    if (!ReadRaw4(file, bytes)) {
        return false;
    }
    // PBO fields are little-endian; both of this project's real targets
    // (Windows x64, and the Linux dev-build host) are little-endian too, so
    // a direct memcpy is correct without a byte-swap step.
    std::memcpy(&out, bytes, 4);
    return true;
}

} // namespace

std::string PboArchive::NormalizeName(const std::string& name) {
    std::string result;
    result.reserve(name.size());
    for (char c : name) {
        char lower = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
        result.push_back(lower == '/' ? '\\' : lower);
    }
    return result;
}

const PboEntry* PboArchive::Find(const std::string& entryName) const {
    const std::string target = NormalizeName(entryName);
    for (const auto& entry : entries_) {
        if (NormalizeName(entry.name) == target) {
            return &entry;
        }
    }
    return nullptr;
}

std::unique_ptr<PboArchive> PboArchive::Open(const std::string& path, std::string& outError) {
    std::ifstream file(path, std::ios::binary);
    if (!file.is_open()) {
        outError = "cannot_open_file";
        return nullptr;
    }

    auto archive = std::unique_ptr<PboArchive>(new PboArchive());
    archive->path_ = path;
    file.seekg(0, std::ios::end);
    const auto end = file.tellg();
    if (end < 21) { outError = "truncated_archive"; return nullptr; }
    const uint64_t fileSize = static_cast<uint64_t>(end);
    file.seekg(0);

    bool first = true;
    for (;;) {
        std::string name;
        if (!ReadCString(file, name)) {
            outError = "truncated_entry_name";
            return nullptr;
        }

        unsigned char magic[4];
        uint32_t originalSize = 0, reserved = 0, timestamp = 0, dataSize = 0;
        if (!ReadRaw4(file, magic) || !ReadU32(file, originalSize) ||
            !ReadU32(file, reserved) || !ReadU32(file, timestamp) || !ReadU32(file, dataSize)) {
            outError = "truncated_entry_header";
            return nullptr;
        }

        const bool isVers = std::memcmp(magic, kMagicVers, 4) == 0;
        const bool isNone = std::memcmp(magic, kMagicNone, 4) == 0;
        const bool isCprs = std::memcmp(magic, kMagicCprs, 4) == 0;

        if (name.empty() && isVers && first) {
            // Properties block: null-terminated key/value string pairs,
            // terminated by an empty key. Not a real file entry.
            for (;;) {
                std::string key;
                if (!ReadCString(file, key)) {
                    outError = "truncated_properties";
                    return nullptr;
                }
                if (key.empty()) {
                    break;
                }
                std::string value;
                if (!ReadCString(file, value)) {
                    outError = "truncated_properties";
                    return nullptr;
                }
                archive->properties_[key] = value;
                if (archive->properties_.size() > 256) { outError = "too_many_properties"; return nullptr; }
            }
            first = false;
            continue;
        }

        first = false;

        if (name.empty() && isNone && originalSize == 0 && reserved == 0 && timestamp == 0 &&
            dataSize == 0) {
            // Sentinel: end of the header table. Data blocks for every real
            // entry collected so far follow immediately, in order.
            break;
        }

        if (!isNone && !isCprs) {
            // Not a packing method this reader understands (and not the
            // "Vers" case, which is only legal as the very first entry).
            outError = "unknown_packing_method:" + name;
            return nullptr;
        }

        PboEntry entry;
        entry.name = name;
        entry.compressed = isCprs;
        entry.originalSize = originalSize;
        entry.dataSize = dataSize;
        entry.timestamp = timestamp;
        archive->entries_.push_back(std::move(entry));
        if (archive->entries_.size() > 100000) { outError = "too_many_entries"; return nullptr; }
    }

    // Data blocks are concatenated immediately after the sentinel, in the
    // same order as the header table.
    uint64_t offset = static_cast<uint64_t>(file.tellg());
    for (auto& entry : archive->entries_) {
        if (offset > fileSize || entry.dataSize > fileSize - offset) {
            outError = "entry_out_of_bounds"; return nullptr;
        }
        entry.dataOffset = offset;
        offset += entry.dataSize;
    }

    return archive;
}

PboExtractResult PboArchive::Extract(const std::string& entryName) const {
    PboExtractResult result;
    const PboEntry* entry = Find(entryName);
    if (entry == nullptr) {
        result.error = "entry_not_found";
        return result;
    }
    if (entry->compressed) {
        // See the class comment: decompression is intentionally not
        // implemented until the "Cprs" LZSS scheme has been verified against
        // a real HEMTT-built PBO. Returning a clear error beats risking
        // silently corrupted audio.
        result.error = "compressed_entry_unsupported";
        return result;
    }

    std::ifstream file(path_, std::ios::binary);
    if (!file.is_open()) {
        result.error = "cannot_open_file";
        return result;
    }

    file.seekg(static_cast<std::streamoff>(entry->dataOffset));
    if (!file) {
        result.error = "seek_failed";
        return result;
    }

    if (entry->dataSize > 64 * 1024 * 1024) { result.error = "track_too_large"; return result; }
    result.data.resize(entry->dataSize);
    if (entry->dataSize > 0) {
        file.read(reinterpret_cast<char*>(result.data.data()), entry->dataSize);
        if (!file) {
            result.error = "short_read";
            result.data.clear();
            return result;
        }
    }

    result.success = true;
    return result;
}

} // namespace edj
