"""Generate the compact solid-color PAA palette used for source material slots."""
from __future__ import annotations

import pathlib
import subprocess

from PIL import Image

REPO = pathlib.Path(__file__).resolve().parents[1]
WORK = REPO / "asset_work" / "textures" / "palette"
OUTPUT = REPO / "addons" / "assets" / "data"
IMAGE_TO_PAA = pathlib.Path(
    r"C:\Program Files (x86)\Steam\steamapps\common\Arma 3 Tools\ImageToPAA\ImageToPAA.exe"
)

COLORS = {
    "black": (9, 10, 12, 255),
    "charcoal": (23, 27, 32, 255),
    "darkgray": (46, 52, 60, 255),
    "gray": (97, 107, 120, 255),
    "lightgray": (173, 184, 194, 255),
    "white": (230, 235, 240, 255),
    "red": (122, 9, 11, 255),
    "green": (20, 122, 36, 255),
    "blue": (20, 51, 158, 255),
    "yellow": (184, 117, 9, 255),
}


def main() -> None:
    if not IMAGE_TO_PAA.is_file():
        raise SystemExit(f"ImageToPAA not found: {IMAGE_TO_PAA}")
    WORK.mkdir(parents=True, exist_ok=True)
    OUTPUT.mkdir(parents=True, exist_ok=True)
    for name, color in COLORS.items():
        source = WORK / f"palette_{name}_co.tga"
        target = OUTPUT / f"palette_{name}_co.paa"
        Image.new("RGBA", (16, 16), color).save(source)
        subprocess.run([str(IMAGE_TO_PAA), str(source), str(target)], check=True)
        print(f"EDJ_PALETTE={target.relative_to(REPO)}")


if __name__ == "__main__":
    main()
