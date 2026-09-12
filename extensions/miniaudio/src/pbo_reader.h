#pragma once

#include <cstdint>
#include <fstream>
#include <memory>
#include <string>
#include <unordered_map>
#include <vector>

namespace edj {

// One file entry in a PBO's header table.
struct PboEntry {
    std::string name;       // Internal path as stored, e.g. "audio\\groove.ogg"
    bool compressed = false; // true => packing method was the LZSS-based "Cprs" scheme
    uint32_t originalSize = 0; // decompressed size
    uint32_t dataSize = 0;     // bytes actually occupying the data section
    uint32_t timestamp = 0;
    uint64_t dataOffset = 0;   // absolute offset into the file of this entry's data block
};

// Result of extracting one entry's bytes.
struct PboExtractResult {
    bool success = false;
    std::string error;              // set when success == false
    std::vector<uint8_t> data;      // the entry's original (decompressed) bytes on success
};

// Reads the BI PBO container format: a null-terminated-name + 5x uint32 header
// per entry (packing method, original size, reserved, timestamp, data size),
// an optional leading "Vers" properties entry, a sentinel empty entry marking
// the end of the header table, and then the concatenated data blocks in
// header order.
//
// Only the "uncompressed" (packing method 0) storage form is supported for
// extraction. Entries using the "Cprs" LZSS packing method are recognized
// (Entries() reports them via `compressed`) but Extract() deliberately
// refuses to decompress them -- see README.md for why. Most Arma audio
// (OGG/WAV/WSS) is not PBO-compressed in the first place since it is already
// a compressed media format, but this has not been verified against a HEMTT-
// built PBO on real hardware, so guessing at the decompression algorithm
// risked shipping silently-corrupted audio instead of a clear error.
class PboArchive {
public:
    // Parses the header table. Returns nullptr and fills outError on failure
    // (missing file, truncated/malformed header, etc). Does not read any
    // entry data yet -- that happens lazily in Extract().
    static std::unique_ptr<PboArchive> Open(const std::string& path, std::string& outError);

    const std::vector<PboEntry>& Entries() const { return entries_; }
    const std::unordered_map<std::string, std::string>& Properties() const { return properties_; }

    // Case-insensitive, slash-normalized lookup by internal entry name.
    const PboEntry* Find(const std::string& entryName) const;

    PboExtractResult Extract(const std::string& entryName) const;

private:
    PboArchive() = default;

    std::string path_;
    std::vector<PboEntry> entries_;
    std::unordered_map<std::string, std::string> properties_;

    static std::string NormalizeName(const std::string& name);
};

} // namespace edj
