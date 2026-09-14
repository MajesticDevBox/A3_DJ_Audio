#pragma once
#include "miniaudio.h"
#include <array>
#include <atomic>
#include <vector>

namespace edj {
// One decoded stream enters this node. All arrays spatialize the same PCM block,
// with no delay lines, independent cursors, resampling or cabinet-level voices.
struct ArrayNode {
    ma_node_base base{}; // must be first for the miniaudio callback cast
    static constexpr unsigned MaxArrays = 8;
    std::array<ma_spatializer, MaxArrays> spatializers{};
    ma_spatializer_listener listener{};
    std::array<std::atomic<float>, MaxArrays * 8> parameters{};
    std::array<std::atomic<float>, 6> listenerParameters{};
    std::atomic<unsigned> count{0};
    unsigned initializedSpatializers = 0;
    bool initialized = false, listenerInitialized = false;
    bool Init(ma_engine* engine);
    void Uninit();
    void Set(const std::vector<float>& values);
    static void Process(ma_node* node, const float** input, ma_uint32* framesIn, float** output, ma_uint32* framesOut);
};
}
