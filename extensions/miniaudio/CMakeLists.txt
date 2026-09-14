cmake_minimum_required(VERSION 3.15)
project(edj_miniaudio CXX C)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

# ---------------------------------------------------------------------------
# Event DJ local-audio adapter extension.
#
# Ships as a Windows DLL loaded by Arma 3 via callExtension / RVExtensionArgs
# (Arma clients are Windows-only per docs/DEVELOPMENT.md). This CMake project
# also builds a .so on Linux/macOS purely so the adapter logic can be compiled
# and smoke-tested outside a Windows toolchain during development; that build
# is not a shippable artifact.
#
# Scope of this file: build plumbing + the extension entry points + miniaudio
# engine lifecycle only. No PBO reading, no SQF-facing operations, and no
# per-stage playback yet -- see README.md for what's intentionally NOT here.
# ---------------------------------------------------------------------------

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# Arma 3 is 64-bit by default; the extension name must end in _x64 on Windows
# so the engine loads it for the 64-bit client. Override with -DEDJ_ARCH=... if
# a 32-bit build is ever needed for legacy servers.
set(EDJ_ARCH "x64" CACHE STRING "Target architecture suffix used in the output name")

set(EDJ_TARGET_NAME "edj_miniaudio")
if(WIN32)
  set(EDJ_TARGET_NAME "edj_miniaudio_${EDJ_ARCH}")
endif()

add_library(${EDJ_TARGET_NAME} SHARED
  src/ma_impl.cpp
  src/engine.cpp
  src/pbo_reader.cpp
  src/pbo_cache.cpp
  src/track_cache.cpp
  src/path_resolver.cpp
  src/playback_manager.cpp
  src/array_node.cpp
  src/extension_api.cpp
)

target_include_directories(${EDJ_TARGET_NAME} PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/vendor
  ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# miniaudio pulls in the platform audio backends directly; on Linux that means
# dl/pthread/m for the runtime backend probing used by the ma_impl.cpp build.
if(UNIX AND NOT APPLE)
  find_package(Threads REQUIRED)
  target_link_libraries(${EDJ_TARGET_NAME} PRIVATE Threads::Threads dl m)
endif()

if(WIN32)
  target_compile_definitions(${EDJ_TARGET_NAME} PRIVATE
    EDJ_PLATFORM_WINDOWS=1
    WIN32_LEAN_AND_MEAN
    NOMINMAX
  )
  target_link_libraries(${EDJ_TARGET_NAME} PRIVATE ole32 winmm shell32)
  set_target_properties(${EDJ_TARGET_NAME} PROPERTIES PREFIX "")
else()
  target_compile_definitions(${EDJ_TARGET_NAME} PRIVATE EDJ_PLATFORM_WINDOWS=0)
endif()

target_compile_definitions(${EDJ_TARGET_NAME} PRIVATE
  MA_NO_ENCODING
  MA_NO_GENERATION
)

if(MSVC)
  target_compile_options(${EDJ_TARGET_NAME} PRIVATE /W4 /permissive-)
else()
  target_compile_options(${EDJ_TARGET_NAME} PRIVATE -Wall -Wextra -Wno-unused-parameter)
endif()

install(TARGETS ${EDJ_TARGET_NAME} RUNTIME DESTINATION .)
