"""Windows ABI/PBO checks. Does not claim in-game or audible acceptance."""
import argparse
import ctypes
import pathlib
import struct
import tempfile


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dll", type=pathlib.Path, required=True)
    parser.add_argument("--pbo", type=pathlib.Path, required=True)
    args = parser.parse_args()
    lib = ctypes.WinDLL(str(args.dll.resolve()))
    call = lib.RVExtensionArgs
    call.argtypes = [ctypes.c_char_p, ctypes.c_int, ctypes.c_char_p,
                     ctypes.POINTER(ctypes.c_char_p), ctypes.c_int]
    call.restype = ctypes.c_int

    def invoke(op, *values):
        # Mirror Arma's serialized STRING arguments, including literal slashes.
        values = [('"' + str(v).replace('"', '""') + '"').encode() for v in values]
        argv = (ctypes.c_char_p * len(values))(*values)
        output = ctypes.create_string_buffer(8192)
        assert call(output, len(output), op.encode(), argv, len(values)) == 0
        return output.value.decode()

    passed = 0
    def check(name, ok, detail=""):
        nonlocal passed
        assert ok, f"FAIL {name}: {detail}"
        passed += 1
        print(f"PASS {name}: {detail}")

    result = invoke("list_entries", args.pbo.resolve())
    check("real_hemtt_header", result.startswith("1:") and "edj_test_tone_a.ogg" in result, result)
    result = invoke("read_track", "real", args.pbo.resolve(), r"audio\edj_test_tone_a.ogg")
    check("real_ogg_decode", result.startswith("1:"), result)
    check("real_ogg_duration", abs(float(result.split(":")[1]) - 12) < 0.05, result)
    check("cache_loaded", invoke("track_status", "real") == "loaded")
    check("release", invoke("release_track", "real") == "1" and invoke("track_status", "real") == "missing")
    result = invoke("register_search_root", args.pbo.resolve().parent)
    check("index_real_mod", result.startswith("1:") and int(result[2:]) > 0, result)
    result = invoke("resolve_track", r"\z\edj\addons\example_music_pack\audio\edj_test_tone_a.ogg")
    check("resolve_virtual_track", result.startswith("1:pbo:"), result)
    check("missing_track", invoke("read_track", "bad", args.pbo.resolve(), "missing.ogg") == "0:entry_not_found")
    check("missing_pbo", invoke("list_entries", args.pbo.parent / "missing.pbo") == "0:cannot_open_file")
    check("bad_args", invoke("play") == "0:missing_args")
    check("nonfinite", invoke("volume", "main", "nan") == "0:invalid_arguments")
    check("numeric_suffix", invoke("volume", "main", "1junk") == "0:invalid_arguments")
    check("traversal", invoke("resolve_track", r"\..\..\config.cpp") == "0:not_found")
    check("absolute_path", invoke("resolve_track", r"C:\Windows\win.ini") == "0:not_found")
    with tempfile.TemporaryDirectory(prefix="edj-m1-") as temp:
        root = pathlib.Path(temp)
        def fixture(name, method, data, declared=None):
            path = root / name
            entry = b"audio.ogg\0" + struct.pack("<IIIII", method, len(data), 0, 0, len(data) if declared is None else declared)
            path.write_bytes(entry + bytes(21) + data)
            return path
        compressed = fixture("compressed.pbo", 0x43707273, b"xxxx")
        check("compressed_rejected", invoke("read_track", "bad", compressed, "audio.ogg") == "0:compressed_entry_unsupported")
        invalid = fixture("invalid_audio.pbo", 0, b"not an audio file")
        result = invoke("read_track", "bad", invalid, "audio.ogg")
        check("decoder_error", result.startswith("0:decode_failed:"), result)
        truncated = fixture("truncated.pbo", 0, b"xx", 4096)
        check("bounds", invoke("list_entries", truncated) == "0:entry_out_of_bounds")
        empty = root / "empty.pbo"
        empty.write_bytes(b"")
        check("empty", invoke("list_entries", empty) == "0:truncated_archive")
    check("shutdown_idempotent", invoke("shutdown") == "1" and invoke("shutdown") == "1")
    print(f"{passed} PASS; no audio-device or Arma assertions in this test.")


if __name__ == "__main__":
    main()
