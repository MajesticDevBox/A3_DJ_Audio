"""Create small original material swatches used by the Event DJ production props."""

from __future__ import annotations

import pathlib
import struct


REPO = pathlib.Path(__file__).resolve().parents[1]
OUTPUT = REPO / "asset_work" / "textures"
COLORS = {
    "metal_co.tga": (126, 135, 143),
    "deck_co.tga": (74, 74, 72),
    "light_co.tga": (15, 17, 20),
    "speaker_generic_co.tga": (24, 27, 31),
    "equipment_co.tga": (18, 21, 26),
    "equipment_nohq.tga": (128, 128, 255),
}


def write_tga(path: pathlib.Path, color: tuple[int, int, int], size: int = 64) -> None:
    header = struct.pack("<BBBHHBHHHHBB", 0, 0, 2, 0, 0, 0, 0, 0, size, size, 24, 0x20)
    blue, green, red = color[2], color[1], color[0]
    path.write_bytes(header + bytes((blue, green, red)) * size * size)


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    for name, color in COLORS.items():
        write_tga(OUTPUT / name, color)
        print(OUTPUT / name)


if __name__ == "__main__":
    main()
