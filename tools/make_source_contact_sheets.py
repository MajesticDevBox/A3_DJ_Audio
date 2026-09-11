"""Build labeled contact sheets from source inventory thumbnails."""

from __future__ import annotations

import json
import pathlib
from PIL import Image, ImageDraw, ImageFont

ROOT = pathlib.Path(__file__).resolve().parents[1] / "asset_work" / "validation" / "source-previews"
FONT = ImageFont.load_default(size=14)

for pack_dir in sorted(path for path in ROOT.iterdir() if path.is_dir()):
    index = json.loads((pack_dir / "index.json").read_text(encoding="utf-8"))
    items = [record for record in index["records"] if record.get("thumbnail")]
    for page_no, start in enumerate(range(0, len(items), 20), start=1):
        page = items[start : start + 20]
        sheet = Image.new("RGB", (5 * 300, 4 * 310), "#22262b")
        draw = ImageDraw.Draw(sheet)
        for offset, record in enumerate(page):
            x = (offset % 5) * 300
            y = (offset // 5) * 310
            thumb = Image.open(pack_dir / record["thumbnail"]).convert("RGBA")
            bg = Image.new("RGBA", thumb.size, "#d5d8dc")
            bg.alpha_composite(thumb)
            sheet.paste(bg.convert("RGB"), (x + 22, y + 4))
            dims = " x ".join(str(value) for value in record["dimensions"])
            draw.text((x + 8, y + 264), record["name"][:34], fill="white", font=FONT)
            draw.text((x + 8, y + 284), dims[:38], fill="#b8c2cc", font=FONT)
        out = ROOT / f"{pack_dir.name}_{page_no:02d}.jpg"
        sheet.save(out, quality=90)
        print(out)
