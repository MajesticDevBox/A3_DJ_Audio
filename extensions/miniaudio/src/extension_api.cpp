// Arma 3 extension entry points (the BIS RVExtension ABI). This file wires
// those entry points to the ma_engine lifecycle in engine.h/.cpp, the PBO
// reader in pbo_reader.h/.cpp, the virtual-path resolver in
// path_resolver.h/.cpp, and the per-stage playback manager in
// playback_manager.h/.cpp. See README.md for what's still not implemented
// (async decode, the "Cprs" compressed PBO entries, engine-side directional
// cones).
//
// Supported operations (RVExtensionArgs unless noted):
//   "version"           -> extension version string (also via plain RVExtension)
//   "init"              -> starts the miniaudio engine; "1" on success, "0:<reason>" on failure
//   "shutdown"          -> stops the miniaudio engine; always "1"
//   "status"            -> "running" or "stopped"
//   "list_entries"      args [pboPath]
//                       -> "1:<count>:<name1>|<name2>|..." (capped list) or "0:<error>"
//   "read_track"        args [trackId, pboPath, entryName]
//                       -> extracts the entry, validates it decodes, caches the
//                          bytes under trackId; "1:<durationSeconds>:<sampleRate>:<channels>"
//                          or "0:<error>"
//   "track_status"      args [trackId] -> "loaded" or "missing"
//   "release_track"     args [trackId] -> frees the cached bytes; always "1"
//   "register_search_root" args [rootPath]
//                       -> indexes any *.pbo in rootPath by their "prefix" property
//                          for later virtual-path resolution; "1:<pboCount>" or "0:<error>"
//   "resolve_track"     args [virtualPath]
//                       -> "1:loose:<path>" / "1:pbo:<pboPath>:<entryName>" / "0:not_found"
//   "play"              args [stageId, virtualPath, gain, offsetSeconds, x, y, z, range]
//                       -> resolves + loads (if not already cached) + plays; "1" or "0:<error>"
//   "stop"              args [stageId] -> stops and frees that stage's sound; always "1"
//   "volume"            args [stageId, gain] -> live volume change, no restart; "1" or "0:<error>"
//   "set_position"      args [stageId, x, y, z] -> live position update; "1" or "0:<error>"
//   "set_listener"      args [x, y, z, dirX, dirY, dirZ] -> "1" or "0:<error>"
//   "playback_status"   args [stageId] -> "playing" / "stopped" / "missing"
// Anything else, or a required arg missing, returns "0:<error>"/"unsupported".
// This mirrors the [success, status] shape the SQF-side provider contract
// uses (see addons/audio/functions/fn_audioCall.sqf).

#include "engine.h"
#include "path_resolver.h"
#include "pbo_cache.h"
#include "pbo_reader.h"
#include "playback_manager.h"
#include "track_cache.h"

#include "miniaudio.h"

#include <cstddef>
#include <cstring>
#include <fstream>
#include <mutex>
#include <sstream>
#include <string>
#include <vector>
#include <filesystem>
#include <cmath>
#include <stdexcept>
#if defined(EDJ_PLATFORM_WINDOWS) && EDJ_PLATFORM_WINDOWS
#include <windows.h>
#include <shellapi.h>
#endif

#if defined(EDJ_PLATFORM_WINDOWS) && EDJ_PLATFORM_WINDOWS
    #define EDJ_EXPORT __declspec(dllexport)
    #define EDJ_STDCALL __stdcall
#else
    #define EDJ_EXPORT __attribute__((visibility("default")))
    #define EDJ_STDCALL
#endif

namespace {

using CallbackFn = int(EDJ_STDCALL*)(const char* name, const char* function, const char* data);

constexpr const char* kExtensionName = "edj_miniaudio";
// Extension's own version, independent of the mod version in CHANGELOG.md --
// this number only tracks the extension ABI/lifecycle, which is all that
// exists so far.
constexpr const char* kExtensionVersion = "0.1.0-dev";

std::mutex g_callbackMutex;
CallbackFn g_callback = nullptr;
std::mutex g_dispatchMutex;

// Arma serializes string arguments with surrounding quotes. Backslashes in
// SQF strings are literal; do not apply JSON/C escaping to virtual paths.
std::string Unquote(std::string value) {
    if (value.size() >= 2 && value.front() == '"' && value.back() == '"') {
        value = value.substr(1, value.size() - 2);
        for (std::size_t pos = 0; (pos = value.find("\"\"", pos)) != std::string::npos; ++pos) value.erase(pos, 1);
    }
    return value;
}

std::string Discover() {
    namespace fs = std::filesystem;
    std::vector<fs::path> roots;
#if defined(EDJ_PLATFORM_WINDOWS) && EDJ_PLATFORM_WINDOWS
    HMODULE module = nullptr;
    if (GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
        reinterpret_cast<LPCWSTR>(&Discover), &module)) {
        wchar_t path[32768];
        const auto len = GetModuleFileNameW(module, path, 32768);
        if (len > 0 && len < 32768) roots.push_back(fs::path(std::wstring(path, len)).parent_path() / L"addons");
    }
    int count = 0;
    auto argv = CommandLineToArgvW(GetCommandLineW(), &count);
    if (argv != nullptr) {
        for (int i = 1; i < count; ++i) {
            std::wstring arg(argv[i]);
            if (arg.rfind(L"-mod=", 0) != 0) continue;
            std::wistringstream list(arg.substr(5));
            std::wstring part;
            while (std::getline(list, part, L';')) {
                if (!part.empty()) roots.push_back(fs::path(part) / L"addons");
            }
        }
        LocalFree(argv);
    }
#endif
    int indexed = 0;
    for (const auto& root : roots) {
        std::string error;
        const int n = edj::PathResolver::Instance().RegisterSearchRoot(root.string(), error);
        if (n > 0) indexed += n;
    }
    return indexed > 0 ? "1:" + std::to_string(indexed) : "0:no_music_pack_roots";
}

void CopyToOutput(char* output, int outputSize, const std::string& value) {
    if (output == nullptr || outputSize <= 0) {
        return;
    }
    const std::size_t maxLen = static_cast<std::size_t>(outputSize) - 1;
    const std::size_t len = value.size() < maxLen ? value.size() : maxLen;
    std::memcpy(output, value.data(), len);
    output[len] = '\0';
}

// Decodes just enough of `bytes` to confirm it's valid audio and to report
// duration/sampleRate/channels. Does not touch the ma_engine -- this is pure
// validation, independent of whether the engine has been Init()'d yet.
bool ValidateAndDescribe(const std::vector<uint8_t>& bytes, double& outDuration,
                          uint32_t& outSampleRate, uint32_t& outChannels, std::string& outError) {
    ma_decoder decoder;
    ma_decoder_config config = ma_decoder_config_init_default();
    ma_result result = ma_decoder_init_memory(bytes.data(), bytes.size(), &config, &decoder);
    if (result != MA_SUCCESS) {
        outError = std::string("decode_failed:") + ma_result_description(result);
        return false;
    }

    ma_uint64 frameCount = 0;
    result = ma_decoder_get_length_in_pcm_frames(&decoder, &frameCount);
    outSampleRate = decoder.outputSampleRate;
    outChannels = decoder.outputChannels;
    ma_decoder_uninit(&decoder);

    if (result != MA_SUCCESS || outSampleRate == 0) {
        outError = "duration_query_failed";
        return false;
    }

    outDuration = static_cast<double>(frameCount) / static_cast<double>(outSampleRate);
    return true;
}

std::string OpListEntries(const std::vector<std::string>& args) {
    if (args.empty()) {
        return "0:missing_args";
    }
    std::string error;
    edj::PboArchive* archive = edj::PboCache::Instance().GetOrOpen(args[0], error);
    if (archive == nullptr) {
        return "0:" + error;
    }

    const auto& entries = archive->Entries();
    std::ostringstream out;
    out << "1:" << entries.size() << ":";
    const std::size_t shown = entries.size() < 20 ? entries.size() : 20;
    for (std::size_t i = 0; i < shown; ++i) {
        if (i > 0) {
            out << "|";
        }
        out << entries[i].name;
    }
    return out.str();
}

std::string OpReadTrack(const std::vector<std::string>& args) {
    if (args.size() < 3) {
        return "0:missing_args";
    }
    const std::string& trackId = args[0];
    const std::string& pboPath = args[1];
    const std::string& entryName = args[2];

    std::string error;
    edj::PboArchive* archive = edj::PboCache::Instance().GetOrOpen(pboPath, error);
    if (archive == nullptr) {
        return "0:" + error;
    }

    edj::PboExtractResult extracted = archive->Extract(entryName);
    if (!extracted.success) {
        return "0:" + extracted.error;
    }

    double duration = 0.0;
    uint32_t sampleRate = 0, channels = 0;
    if (!ValidateAndDescribe(extracted.data, duration, sampleRate, channels, error)) {
        return "0:" + error;
    }

    edj::TrackInfo info;
    info.bytes = std::move(extracted.data);
    info.durationSeconds = duration;
    info.sampleRate = sampleRate;
    info.channels = channels;
    edj::TrackCache::Instance().Put(trackId, std::move(info));

    std::ostringstream out;
    out << "1:" << duration << ":" << sampleRate << ":" << channels;
    return out.str();
}

std::string OpTrackStatus(const std::vector<std::string>& args) {
    if (args.empty()) {
        return "0:missing_args";
    }
    return edj::TrackCache::Instance().Contains(args[0]) ? "loaded" : "missing";
}

std::string OpReleaseTrack(const std::vector<std::string>& args) {
    if (args.empty()) {
        return "0:missing_args";
    }
    edj::TrackCache::Instance().Release(args[0]);
    return "1";
}

float ParseFloat(const std::string& s, float fallback) {
    (void)fallback;
    std::size_t used = 0;
    const float value = std::stof(s, &used);
    if (used != s.size() || !std::isfinite(value)) throw std::invalid_argument("invalid_number");
    return value;
}

double ParseDouble(const std::string& s, double fallback) {
    (void)fallback;
    std::size_t used = 0;
    const double value = std::stod(s, &used);
    if (used != s.size() || !std::isfinite(value)) throw std::invalid_argument("invalid_number");
    return value;
}

std::string OpRegisterSearchRoot(const std::vector<std::string>& args) {
    if (args.empty()) {
        return "0:missing_args";
    }
    std::string error;
    int count = edj::PathResolver::Instance().RegisterSearchRoot(args[0], error);
    if (count < 0) {
        return "0:" + error;
    }
    return "1:" + std::to_string(count);
}

std::string DescribeResolution(const edj::ResolvedTrack& resolved) {
    switch (resolved.kind) {
        case edj::ResolvedKind::LooseFile:
            return "1:loose:" + resolved.looseFilePath;
        case edj::ResolvedKind::PboEntry:
            return "1:pbo:" + resolved.pboPath + ":" + resolved.pboEntryName;
        case edj::ResolvedKind::None:
        default:
            return "0:not_found";
    }
}

std::string OpResolveTrack(const std::vector<std::string>& args) {
    if (args.empty()) {
        return "0:missing_args";
    }
    return DescribeResolution(edj::PathResolver::Instance().Resolve(args[0]));
}

// Shared by "play": returns cached bytes for `virtualPath` if already
// loaded, otherwise resolves it (loose file or PBO entry), extracts,
// validates, and caches it before returning. `virtualPath` itself is used
// as the TrackCache key, since it's already the natural stable identifier
// for a given track's audio content.
bool GetOrLoadTrackBytes(const std::string& virtualPath, std::vector<uint8_t>& outBytes,
                          std::string& outError) {
    edj::TrackInfo cached;
    if (edj::TrackCache::Instance().Get(virtualPath, cached)) {
        outBytes = cached.bytes;
        return true;
    }

    edj::ResolvedTrack resolved = edj::PathResolver::Instance().Resolve(virtualPath);
    std::vector<uint8_t> bytes;
    switch (resolved.kind) {
        case edj::ResolvedKind::LooseFile: {
            std::ifstream file(resolved.looseFilePath, std::ios::binary | std::ios::ate);
            if (!file.is_open()) {
                outError = "cannot_open_file";
                return false;
            }
            const std::streamsize size = file.tellg();
            if (size <= 0 || size > 64 * 1024 * 1024) { outError = "invalid_track_size"; return false; }
            file.seekg(0);
            bytes.resize(static_cast<std::size_t>(size));
            if (size > 0 && !file.read(reinterpret_cast<char*>(bytes.data()), size)) {
                outError = "short_read";
                return false;
            }
            break;
        }
        case edj::ResolvedKind::PboEntry: {
            std::string pboError;
            edj::PboArchive* archive = edj::PboCache::Instance().GetOrOpen(resolved.pboPath, pboError);
            if (archive == nullptr) {
                outError = pboError;
                return false;
            }
            edj::PboExtractResult extracted = archive->Extract(resolved.pboEntryName);
            if (!extracted.success) {
                outError = extracted.error;
                return false;
            }
            bytes = std::move(extracted.data);
            break;
        }
        case edj::ResolvedKind::None:
        default:
            outError = "track_not_found";
            return false;
    }

    double duration = 0.0;
    uint32_t sampleRate = 0, channels = 0;
    if (!ValidateAndDescribe(bytes, duration, sampleRate, channels, outError)) {
        return false;
    }

    edj::TrackInfo info;
    info.bytes = bytes;
    info.durationSeconds = duration;
    info.sampleRate = sampleRate;
    info.channels = channels;
    edj::TrackCache::Instance().Put(virtualPath, std::move(info));

    outBytes = std::move(bytes);
    return true;
}

std::string OpPlay(const std::vector<std::string>& args) {
    if (args.size() < 8) {
        return "0:missing_args";
    }
    const std::string& stageId = args[0];
    const std::string& virtualPath = args[1];
    const float gain = ParseFloat(args[2], 1.0f);
    const double offsetSeconds = ParseDouble(args[3], 0.0);
    const float x = ParseFloat(args[4], 0.0f);
    const float y = ParseFloat(args[5], 0.0f);
    const float z = ParseFloat(args[6], 0.0f);
    const float range = ParseFloat(args[7], 0.0f);
    if (stageId.empty() || stageId.size() > 96 || gain < 0 || gain > 10 || offsetSeconds < 0 || offsetSeconds > 86400 || range < 1 || range > 5000) return "0:invalid_play_arguments";

    std::vector<uint8_t> bytes;
    std::string error;
    if (!GetOrLoadTrackBytes(virtualPath, bytes, error)) {
        return "0:" + error;
    }

    if (!edj::PlaybackManager::Instance().Play(stageId, std::move(bytes), gain, offsetSeconds, x,
                                                y, z, range, error)) {
        return "0:" + error;
    }
    return "1";
}

std::string OpStop(const std::vector<std::string>& args) {
    if (args.empty()) {
        return "0:missing_args";
    }
    edj::PlaybackManager::Instance().Stop(args[0]);
    return "1";
}

std::string OpVolume(const std::vector<std::string>& args) {
    if (args.size() < 2) {
        return "0:missing_args";
    }
    std::string error;
    const float gain = ParseFloat(args[1], 1.0f);
    if (gain < 0 || gain > 10) return "0:invalid_gain";
    if (!edj::PlaybackManager::Instance().SetVolume(args[0], gain, error)) {
        return "0:" + error;
    }
    return "1";
}

std::string OpSetPosition(const std::vector<std::string>& args) {
    if (args.size() < 4) {
        return "0:missing_args";
    }
    std::string error;
    const float x = ParseFloat(args[1], 0.0f);
    const float y = ParseFloat(args[2], 0.0f);
    const float z = ParseFloat(args[3], 0.0f);
    if (!edj::PlaybackManager::Instance().SetPosition(args[0], x, y, z, error)) {
        return "0:" + error;
    }
    return "1";
}

std::string OpSetListener(const std::vector<std::string>& args) {
    if (args.size() < 6) {
        return "0:missing_args";
    }
    std::string error;
    const float x = ParseFloat(args[0], 0.0f);
    const float y = ParseFloat(args[1], 0.0f);
    const float z = ParseFloat(args[2], 0.0f);
    const float dirX = ParseFloat(args[3], 0.0f);
    const float dirY = ParseFloat(args[4], 0.0f);
    const float dirZ = ParseFloat(args[5], -1.0f);
    if (!edj::PlaybackManager::Instance().SetListener(x, y, z, dirX, dirY, dirZ, error)) {
        return "0:" + error;
    }
    return "1";
}

std::string OpPlaybackStatus(const std::vector<std::string>& args) {
    if (args.empty()) {
        return "0:missing_args";
    }
    return edj::PlaybackManager::Instance().Status(args[0]);
}

std::string Dispatch(const std::string& function, const std::vector<std::string>& args) {
    edj::AudioEngine& engine = edj::AudioEngine::Instance();

    if (function == "version") {
        return kExtensionVersion;
    }
    if (function == "meter") return engine.Meter();
    if (function == "set_arrays") {
        if (args.size() != 2) return "0:missing_args";
        std::istringstream input(args[1]); std::string token; std::vector<float> values;
        while (std::getline(input, token, ',')) {
            if (values.size() >= edj::ArrayNode::MaxArrays * 8) return "0:too_many_arrays";
            values.push_back(ParseFloat(token, 0));
        }
        return edj::PlaybackManager::Instance().SetArrays(args[0], values);
    }
    if (function == "pause" || function == "resume" || function == "seek" || function == "duration" || function == "position" || function == "cue_mode" || function == "arrays") {
        if (args.empty() || (function == "seek" && args.size() != 2)) return "0:missing_args";
        return edj::PlaybackManager::Instance().Control(args[0], function, function == "seek" ? ParseDouble(args[1], 0) : 0);
    }
    if (function == "debug_source") return args.empty() ? "0:missing_args" : edj::PlaybackManager::Instance().Debug(args[0]);
    if (function == "init") {
        if (engine.Init()) {
            return "1";
        }
        return std::string("0:") + engine.LastError();
    }
    if (function == "shutdown") {
        edj::PlaybackManager::Instance().StopAll();
        engine.Shutdown();
        return "1";
    }
    if (function == "status") {
        return engine.IsInitialized() ? "running" : "stopped";
    }
    if (function == "discover") return Discover();
    if (function == "list_entries") {
        return OpListEntries(args);
    }
    if (function == "read_track") {
        return OpReadTrack(args);
    }
    if (function == "track_status") {
        return OpTrackStatus(args);
    }
    if (function == "release_track") {
        return OpReleaseTrack(args);
    }
    if (function == "register_search_root") {
        return OpRegisterSearchRoot(args);
    }
    if (function == "resolve_track") {
        return OpResolveTrack(args);
    }
    if (function == "play") {
        return OpPlay(args);
    }
    if (function == "stop") {
        return OpStop(args);
    }
    if (function == "volume") {
        return OpVolume(args);
    }
    if (function == "set_position") {
        return OpSetPosition(args);
    }
    if (function == "set_listener") {
        return OpSetListener(args);
    }
    if (function == "playback_status") {
        return OpPlaybackStatus(args);
    }
    return "unsupported";
}

} // namespace

extern "C" {

EDJ_EXPORT void EDJ_STDCALL RVExtension(char* output, int outputSize, const char* function) {
    std::lock_guard<std::mutex> lock(g_dispatchMutex);
    try { CopyToOutput(output, outputSize, Dispatch(function != nullptr ? function : "", {})); }
    catch (const std::exception&) { CopyToOutput(output, outputSize, "0:extension_exception"); }
    catch (...) { CopyToOutput(output, outputSize, "0:extension_exception"); }
}

EDJ_EXPORT int EDJ_STDCALL RVExtensionArgs(char* output, int outputSize, const char* function,
                                            const char** argv, int argc) {
    std::lock_guard<std::mutex> lock(g_dispatchMutex);
    try {
    if (argc < 0 || argc > 16 || (argc > 0 && argv == nullptr)) throw std::invalid_argument("invalid_arguments");
    std::vector<std::string> args;
    args.reserve(argc > 0 ? static_cast<std::size_t>(argc) : 0);
    for (int i = 0; i < argc; ++i) {
        args.emplace_back(Unquote(argv[i] != nullptr ? argv[i] : ""));
        if (args.back().size() > 32768) throw std::invalid_argument("argument_too_long");
    }
    CopyToOutput(output, outputSize, Dispatch(function != nullptr ? function : "", args));
    } catch (const std::invalid_argument&) { CopyToOutput(output, outputSize, "0:invalid_arguments"); }
    catch (const std::exception&) { CopyToOutput(output, outputSize, "0:extension_exception"); }
    catch (...) { CopyToOutput(output, outputSize, "0:extension_exception"); }
    return 0;
}

EDJ_EXPORT void EDJ_STDCALL RVExtensionVersion(char* output, int outputSize) {
    CopyToOutput(output, outputSize, kExtensionVersion);
}

// Stored for future async decode/status callbacks (see docs/DEVELOPMENT.md
// discussion of decoding off the scripting thread). Nothing invokes this yet.
EDJ_EXPORT void EDJ_STDCALL RVExtensionRegisterCallback(CallbackFn callbackProc) {
    std::lock_guard<std::mutex> lock(g_callbackMutex);
    g_callback = callbackProc;
    (void)kExtensionName;
}

} // extern "C"
