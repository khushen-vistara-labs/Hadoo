"""Generate theme-matching launcher icons from Lokal's full-bleed CD artwork.

The same artwork is vendored in both repositories; its SHA-256 is verified
before generation and the build requires no network access.
  python3 tool/gen_lokal_launcher_icons.py

Keep STICKER_RECT and ROUNDED_RADIUS in sync with desktop's
scripts/generate-brand-icons.cjs. Never restore the old jewel-case graphic.
"""
from __future__ import annotations

import hashlib
import io
from pathlib import Path

from PIL import Image, ImageDraw

SOURCE = Path("assets/branding/lokal_cd_source.webp")
SOURCE_SHA256 = "1cc34114b178d7983dbfc8d5b4418769f22254237d542c101fa2c7cd74a5c7c3"
LOGO = Path("assets/branding/lokal_icon.png")
STICKER = Path("assets/branding/lokal_icon_sticker.png")
RES = Path("android/app/src/main/res")

# Must match LokalAccent.presets in lib/core/theme/lokal_tokens.dart.
ACCENTS = {
    "lime": "#C8FF57",
    "purple": "#7C6AFF",
    "pink": "#FF57C8",
    "orange": "#FF9F43",
    "blue": "#57B8FF",
    "red": "#FF5757",
    "teal": "#57FFD4",
    "white": "#FFFFFF",
    "yellow": "#FFEC57",
    "cyan": "#57FFEC",
    "magenta": "#FF57EC",
    "gray": "#888888",
    "chartreuse": "#E8FF57",
    "midnight": "#58A6FF",
    "rosegold": "#FFB7C5",
    "neon": "#FF00FF",
}
DEFAULT = "lime"
BACKGROUND = "#0A0A0A"
DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
SIZE = 512
# Calibrated from the outer hub ring in the current 512px source: center
# approximately (254.5, 246.5). Shift *the complete artwork AND the tint mask*
# to the canvas center rather than nudging only the visible hub.
HUB_SHIFT = (2, 10)
# Android adaptive masks crop the artwork, so retain the existing safe zone.
SCALE = 0.72
# Fractions of the source artwork (must match the desktop script).
STICKER_RECT = (0.703, 0.358, 0.287, 0.270, 0.050)


def source_bytes() -> bytes:
    # The source binary is checked into both repos, so offline local and CI
    # builds generate identical icons without network dependencies.
    data = SOURCE.read_bytes()
    if hashlib.sha256(data).hexdigest() != SOURCE_SHA256:
        raise ValueError("Lokal CD artwork has changed without updating its checksum")
    return data

def recenter_with_reflected_edges(image: Image.Image) -> Image.Image:
    """Move hub to canvas center without introducing white/transparent seams.

    The reflected 2px left and 10px top bands continue existing pixels at
    the boundaries; the original graphic is full-bleed. All other branding
    layers are shifted by the same HUB_SHIFT, avoiding sticker mismatch.
    """
    dx, dy = HUB_SHIFT
    if not (0 <= dx < image.width and 0 <= dy < image.height):
        raise ValueError("Hub offset must fit in the icon")
    shifted = Image.new(image.mode, image.size)
    shifted.paste(image, (dx, dy))
    if dy:
        shifted.paste(
            image.crop((0, 0, image.width, dy)).transpose(Image.Transpose.FLIP_TOP_BOTTOM),
            (dx, 0),
        )
    if dx:
        shifted.paste(
            image.crop((0, 0, dx, image.height)).transpose(Image.Transpose.FLIP_LEFT_RIGHT),
            (0, dy),
        )
    if dx and dy:
        shifted.paste(
            image.crop((0, 0, dx, dy)).transpose(Image.Transpose.ROTATE_180),
            (0, 0),
        )
    return shifted


def build_master() -> tuple[Image.Image, Image.Image]:
    base = Image.open(io.BytesIO(source_bytes())).convert("RGBA")
    base = base.resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    base = recenter_with_reflected_edges(base)
    LOGO.parent.mkdir(parents=True, exist_ok=True)
    base.save(LOGO, optimize=True)

    # Supersampled anti-aliased mask precisely covers only the sticker.
    aa = 4
    mask = Image.new("L", (SIZE * aa, SIZE * aa), 0)
    x, y, width, height, radius = STICKER_RECT
    coords = (
        round(x * SIZE * aa), round(y * SIZE * aa),
        round((x + width) * SIZE * aa), round((y + height) * SIZE * aa),
    )
    ImageDraw.Draw(mask).rounded_rectangle(
        coords, radius=round(radius * SIZE * aa), fill=255,
    )
    mask = mask.resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    aligned_mask = Image.new("L", (SIZE, SIZE), 0)
    aligned_mask.paste(mask, HUB_SHIFT)
    mask = aligned_mask
    sticker = Image.new("RGBA", (SIZE, SIZE), "white")
    sticker.putalpha(mask)
    sticker.save(STICKER, optimize=True)
    return base, sticker


def place(image: Image.Image, px: int, scale: float = SCALE) -> Image.Image:
    canvas = Image.new("RGBA", (px, px), (0, 0, 0, 0))
    side = round(px * scale)
    scaled = image.resize((side, side), Image.Resampling.LANCZOS)
    offset = (px - side) // 2
    canvas.alpha_composite(scaled, (offset, offset))
    return canvas


def tinted(base: Image.Image, sticker: Image.Image, color: str) -> Image.Image:
    foreground = base.copy()
    tint = Image.new("RGBA", base.size, color)
    tint.putalpha(sticker.getchannel("A"))
    foreground.alpha_composite(tint)
    return foreground


def monochrome(px: int) -> Image.Image:
    # Android's monochrome themed icon should retain the CD hub and sticker,
    # not degenerate into a completely filled white square.
    aa = 4
    image = Image.new("L", (px * aa, px * aa), 0)
    draw = ImageDraw.Draw(image)
    def point(n: float) -> int:
        return round(n * px * aa)
    draw.ellipse(
        (point(.35), point(.35), point(.65), point(.65)),
        outline=255, width=max(1, point(.020)),
    )
    draw.ellipse(
        (point(.40), point(.40), point(.60), point(.60)),
        outline=185, width=max(1, point(.020)),
    )
    draw.rounded_rectangle(
        (point(.70), point(.41), point(.86), point(.59)),
        radius=point(.025), fill=255,
    )
    a = image.resize((px, px), Image.Resampling.LANCZOS)
    result = Image.new("RGBA", (px, px), "white")
    result.putalpha(a)
    return result


def main() -> None:
    base, sticker = build_master()
    for name, factor in DENSITIES.items():
        px = round(108 * factor)
        folder = RES / f"drawable-{name}"
        folder.mkdir(parents=True, exist_ok=True)

        for obsolete in ("base", "sticker"):
            (folder / f"ic_lokal_fg_{obsolete}.png").unlink(missing_ok=True)

        for accent, color in ACCENTS.items():
            place(tinted(base, sticker, color), px).save(
                folder / f"ic_lokal_fg_{accent}.png", optimize=True
            )

        monochrome(px).save(folder / "ic_lokal_fg_mono.png", optimize=True)

        # Legacy launchers must show the full square artwork with no dark
        # padding, jewel case, circular disc outline, or white corners.
        legacy_px = round(48 * factor)
        mipmap = RES / f"mipmap-{name}"
        mipmap.mkdir(parents=True, exist_ok=True)
        tinted(base, sticker, ACCENTS[DEFAULT]).resize(
            (legacy_px, legacy_px), Image.Resampling.LANCZOS
        ).save(mipmap / "launcher_icon.png", optimize=True)

    anydpi = RES / "mipmap-anydpi-v26"
    anydpi.mkdir(parents=True, exist_ok=True)
    drawable = RES / "drawable"
    for accent in ACCENTS:
        (drawable / f"ic_lokal_fg_{accent}.xml").unlink(missing_ok=True)
        icon = (
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<!-- Generated by tool/gen_lokal_launcher_icons.py -->\n'
            '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@color/lokal_icon_background" />\n'
            f'    <foreground android:drawable="@drawable/ic_lokal_fg_{accent}" />\n'
            '    <monochrome android:drawable="@drawable/ic_lokal_fg_mono" />\n'
            '</adaptive-icon>\n'
        )
        (anydpi / f"ic_lokal_{accent}.xml").write_text(icon)
        if accent == DEFAULT:
            (anydpi / "launcher_icon.xml").write_text(icon)


if __name__ == "__main__":
    main()
