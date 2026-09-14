#include "array_node.h"
#include <algorithm>
#include <cstring>

namespace edj {
bool ArrayNode::Init(ma_engine* engine) {
    auto lc = ma_spatializer_listener_config_init(2);
    if (ma_spatializer_listener_init(&lc, nullptr, &listener) != MA_SUCCESS) return false;
    listenerInitialized = true;
    listenerParameters[5].store(-1);
    for (auto& spatializer : spatializers) {
        auto config = ma_spatializer_config_init(1, 2);
        config.attenuationModel = ma_attenuation_model_linear;
        config.minDistance = 1;
        config.maxDistance = 500;
        config.dopplerFactor = 0; // all emitters retain the same sample timeline
        config.gainSmoothTimeInFrames = 2400; // 50ms at the engine's 48kHz
        if (ma_spatializer_init(&config, nullptr, &spatializer) != MA_SUCCESS) return false;
        ++initializedSpatializers;
    }
    static ma_node_vtable vtable = {Process, nullptr, 1, 1, 0};
    ma_uint32 channels = 2;
    auto config = ma_node_config_init();
    config.vtable = &vtable; config.pInputChannels = &channels; config.pOutputChannels = &channels;
    if (ma_node_init(ma_engine_get_node_graph(engine), &config, nullptr, &base) != MA_SUCCESS) return false;
    initialized = true;
    return ma_node_attach_output_bus(&base, 0, ma_engine_get_endpoint(engine), 0) == MA_SUCCESS;
}
void ArrayNode::Uninit() {
    if (initialized) {ma_node_uninit(&base, nullptr); initialized = false;}
    for (unsigned i = 0; i < initializedSpatializers; ++i) ma_spatializer_uninit(&spatializers[i], nullptr);
    initializedSpatializers = 0;
    if (listenerInitialized) {ma_spatializer_listener_uninit(&listener, nullptr); listenerInitialized = false;}
}
void ArrayNode::Set(const std::vector<float>& values) {
    for (unsigned i = 0; i < values.size(); ++i) parameters[i].store(values[i], std::memory_order_relaxed);
    count.store(static_cast<unsigned>(values.size() / 8), std::memory_order_release);
}
void ArrayNode::Process(ma_node* node, const float** input, ma_uint32*, float** output, ma_uint32* framesOut) {
    auto* self = reinterpret_cast<ArrayNode*>(node);
    const auto n = self->count.load(std::memory_order_acquire);
    if (!n) {std::memcpy(output[0], input[0], *framesOut * 2 * sizeof(float)); return;}
    ma_spatializer_listener_set_position(&self->listener, self->listenerParameters[0], self->listenerParameters[1], self->listenerParameters[2]);
    ma_spatializer_listener_set_direction(&self->listener, self->listenerParameters[3], self->listenerParameters[4], self->listenerParameters[5]);
    std::fill_n(output[0], *framesOut * 2, 0.0f);
    float mono[256], stereo[512]; // bounded stack scratch, no callback allocation
    for (ma_uint32 start = 0; start < *framesOut; start += 256) {
        const auto frames = std::min<ma_uint32>(256, *framesOut - start);
        for (ma_uint32 f = 0; f < frames; ++f) mono[f] = (input[0][(start+f)*2] + input[0][(start+f)*2+1]) * 0.5f;
        for (unsigned i = 0; i < n; ++i) {
            auto& p = self->parameters; auto& s = self->spatializers[i]; const auto k = i*8;
            ma_spatializer_set_position(&s, p[k], p[k+1], p[k+2]);
            ma_spatializer_set_direction(&s, p[k+3], p[k+4], p[k+5]);
            ma_spatializer_set_max_distance(&s, p[k+6]);
            const float angle = p[k+7] * 0.01745329252f;
            ma_spatializer_set_cone(&s, angle, std::min(6.283185307f, angle * 1.5f), 0.1f);
            ma_spatializer_process_pcm_frames(&s, &self->listener, stereo, mono, frames);
            for (ma_uint32 f = 0; f < frames * 2; ++f) output[0][start*2+f] += stereo[f] / n;
        }
    }
}
}
