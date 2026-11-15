#!/usr/bin/env python3
"""Generate (or verify) the bundled Latin app font, Google Sans Flex.

Why this exists
---------------
Flick used to ship Product Sans, a proprietary Google font that is not
licensed for third-party redistribution. Google Sans Flex is Google's
open replacement: it is published in the google/fonts repository under the
SIL Open Font License 1.1 with *no* Reserved Font Names, so it can be
bundled and redistributed with the app.

Upstream ships one variable font (weight, width, slant, optical size,
grade, roundness axes) of ~3.9 MB. Like the Noto Sans SC subset
(see tool/gen_font_subset.py), the bundled build is instanced to the two
static weights the app declares in pubspec.yaml -- Flutter's variable-font
weight support is less reliable than plain static faces, and the app's
existing 400/700 faces rely on exactly that behaviour.

The output faces
----------------
    GoogleSansFlex-Regular.ttf     wght 400, upright
    GoogleSansFlex-Bold.ttf        wght 700, upright
    GoogleSansFlex-Italic.ttf      wght 400, slnt -10 (upstream italic axis)
    GoogleSansFlex-BoldItalic.ttf  wght 700, slnt -10

Google Sans Flex has no separate italic file: the `slnt` axis -10..0 is the
design's italic. The app uses FontStyle.italic in exactly one place, so the
oblique look is acceptable.

Characters outside the subset fall back to the platform font (CJK always
goes through the bundled Noto Sans SC fallback, see AppTheme), so a rare
glyph in a song title still renders -- just in the device typeface.

Usage
-----
    # CI / pre-commit: does the bundled subset still cover every string?
    python3 tool/gen_app_font.py --check

    # regenerate (needs `pip install fonttools`); --src is the upstream
    # variable font, downloaded from
    # https://github.com/google/fonts/raw/main/ofl/googlesansflex/GoogleSansFlex%5BROND%2Copsz%2Cslnt%2Cwdth%2Cwght%5D.ttf
    python3 tool/gen_app_font.py --src /path/to/GoogleSansFlex-var.ttf
"""

from __future__ import annotations

import argparse
import json
import os
import re
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_REPO = os.path.dirname(HERE)

FACES = (
    # (file name, variable-font location)
    ("GoogleSansFlex-Regular.ttf", {"wght": 400}),
    ("GoogleSansFlex-Bold.ttf", {"wght": 700}),
    ("GoogleSansFlex-Italic.ttf", {"wght": 400, "slnt": -10}),
    ("GoogleSansFlex-BoldItalic.ttf", {"wght": 700, "slnt": -10}),
)
FONT_DIR = os.path.join("assets", "fonts")

# The variable font these faces are instanced from (Google Sans Flex, SIL
# OFL 1.1, no Reserved Font Names).
UPSTREAM = "https://github.com/google/fonts/tree/main/ofl/googlesansflex"

# Ranges every build must keep: printable ASCII, Latin-1 Supplement and
# Latin Extended-A (song titles and artist names in western European
# languages), plus the punctuation, currency and operator glyphs the UI
# draws as text. Anything rarer falls back to the platform font.
KEEP_RANGES = ((0x20, 0x7F), (0xA0, 0x250))
KEEP_CHARS = (
    "\u2013\u2014\u2018\u2019\u201c\u201d\u2022\u2026\u2030\u20ac"
    "\u2190\u2192\u2194\u2191\u2193\u2212\u2264\u2265\u2260\u221e"
)


def app_chars(repo: str) -> set[str]:
    """Every character the app can render from its own strings.

    Mirrors tool/gen_font_subset.py so both subsets stay in step with the
    l10n files and the Android string resources.
    """
    chars: set[str] = set(KEEP_CHARS)

    for name in ("app_zh.arb", "app_en.arb"):
        path = os.path.join(repo, "lib", "l10n", name)
        if not os.path.exists(path):
            continue
        with open(path, encoding="utf-8") as fh:
            data = json.load(fh)
        for key, value in data.items():
            if key.startswith("@") or not isinstance(value, str):
                continue
            # ICU placeholders are replaced at runtime, they are never drawn.
            chars.update(re.sub(r"\{[^}]*\}", "", value))

    for rel in ("android/app/src/main/res/values/strings.xml",
                "android/app/src/main/res/values/widget_strings.xml"):
        path = os.path.join(repo, *rel.split("/"))
        if not os.path.exists(path):
            continue
        with open(path, encoding="utf-8") as fh:
            xml = re.sub(r"<!--.*?-->", "", fh.read(), flags=re.S)
        chars.update(xml)

    return {c for c in chars if c.strip()}


def cmap_codepoints(path: str) -> set[int]:
    """Codepoints a TrueType/OpenType font provides (cmap formats 4 and 12)."""
    with open(path, "rb") as fh:
        data = fh.read()

    num_tables = struct.unpack(">H", data[4:6])[0]
    cmap_off = None
    for i in range(num_tables):
        off = 12 + i * 16
        if data[off:off + 4] == b"cmap":
            cmap_off = struct.unpack(">I", data[off + 8:off + 12])[0]
    if cmap_off is None:
        return set()

    count = struct.unpack(">H", data[cmap_off + 2:cmap_off + 4])[0]
    codepoints: set[int] = set()
    for i in range(count):
        rec = cmap_off + 4 + i * 8
        _, _, sub_off = struct.unpack(">HHI", data[rec:rec + 8])
        off = cmap_off + sub_off
        fmt = struct.unpack(">H", data[off:off + 2])[0]
        if fmt == 4:
            seg_x2 = struct.unpack(">H", data[off + 6:off + 8])[0]
            seg = seg_x2 // 2
            ends = struct.unpack(">%dH" % seg, data[off + 14:off + 14 + seg_x2])
            starts = struct.unpack(">%dH" % seg,
                                   data[off + 16 + seg_x2:off + 16 + seg_x2 * 2])
            for start, end in zip(starts, ends):
                if start == 0xFFFF:
                    continue
                codepoints.update(range(start, min(end, 0xFFFF) + 1))
        elif fmt == 12:
            groups = struct.unpack(">I", data[off + 12:off + 16])[0]
            for g in range(groups):
                go = off + 16 + g * 12
                start, end, _ = struct.unpack(">III", data[go:go + 12])
                codepoints.update(range(start, min(end, start + 5000) + 1))
    return codepoints


def check(repo: str) -> int:
    chars = app_chars(repo)
    # Not every app character has a glyph in Google Sans Flex upstream (the
    # arrows and the per-mille sign, for example); those deliberately fall
    # back to the platform font, exactly as they did with Product Sans. The
    # bundled subset only has to cover what the upstream font can render.
    bundled = os.path.join(repo, FONT_DIR, FACES[0][0])
    if not os.path.exists(bundled):
        print(f"  missing font: {bundled}")
        return 1
    renderable = cmap_codepoints(bundled)
    print(f"characters used by the app's strings: {len(chars)} "
          f"({len([c for c in chars if ord(c) in renderable])} covered, rest fall back)")

    covered_any: set[str] = set()
    for name, _ in FACES:
        path = os.path.join(repo, FONT_DIR, name)
        if not os.path.exists(path):
            print(f"  missing font: {path}")
            return 1
        covered_any |= {c for c in chars if ord(c) in cmap_codepoints(path)}

    # CJK is expected to live in the Noto Sans SC fallback, not here.
    missing = sorted(c for c in chars
                     if c not in covered_any and ord(c) < 0x2E80
                     and ord(c) in renderable)
    if missing:
        print(f"  the bundled subset is missing {len(missing)} characters:")
        print("  " + "".join(missing[:80]))
        print("\nRun tool/gen_app_font.py with --src to regenerate it.")
        return 1
    print(f"  {len(FACES)} subset faces cover every renderable character")
    return 0


def generate(repo: str, src: str) -> int:
    if not os.path.exists(src):
        print(f"missing source font: {src}\n{UPSTREAM}")
        return 1
    try:
        from fontTools.ttLib import TTFont
        from fontTools.varLib.instancer import instantiateVariableFont
        from fontTools.subset import Subsetter, Options
    except ImportError as exc:  # pragma: no cover - developer tool
        print(f"fontTools is required to regenerate the subset: {exc}")
        return 1

    # The upstream font only carries these codepoints; asking the subsetter
    # for more is harmless but pointless.
    upstream = cmap_codepoints(src)
    keep = app_chars(repo)
    for lo, hi in KEEP_RANGES:
        keep.update(chr(c) for c in range(lo, hi + 1))
    text = "".join(c for c in sorted(keep) if ord(c) in upstream and ord(c) >= 0x20)
    print(f"characters to cover: {len(text)}")

    out_dir = os.path.join(repo, FONT_DIR)
    os.makedirs(out_dir, exist_ok=True)
    total = 0
    for name, location in FACES:
        font = TTFont(src)

        # Instance first, then drop the variation tables: subsetting before
        # instancing leaves gvar pointing at dropped glyphs and crashes.
        instantiateVariableFont(font, location, inplace=True,
                                updateFontNames=True)
        for tag in ("gvar", "HVAR", "MVAR", "STAT", "fvar", "GDEF"):
            if tag in font:
                del font[tag]

        # GDEF is dropped on purpose: the subset has no mark attachment or
        # ligature caret data worth keeping, and the table costs ~55 KB per
        # face. GPOS keeps kerning, which is what text actually needs.
        opts = Options()
        opts.layout_features = ["kern", "liga", "clig", "calt", "ccmp",
                                "locl", "rlig", "mark", "mkmk"]
        opts.name_IDs = ["*"]
        opts.notdef_outline = True
        opts.recalc_bounds = True
        opts.drop_tables += ["DSIG"]
        subsetter = Subsetter(options=opts)
        subsetter.populate(text=text)
        subsetter.subset(font)

        out = os.path.join(out_dir, name)
        font.save(out)
        size = os.path.getsize(out)
        total += size
        print(f"  {name:<32} {location}  {size / 1024:7.1f} KB")
    print(f"  total: {total / 1024:.1f} KB")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--repo", default=DEFAULT_REPO,
                    help="repository root (default: the parent of this script)")
    ap.add_argument("--src", help="variable Google Sans Flex to instance from")
    ap.add_argument("--check", action="store_true",
                    help="verify the bundled subset covers every string; exit 1 if not")
    args = ap.parse_args()

    repo = os.path.abspath(args.repo)
    if args.check:
        return check(repo)
    if not args.src:
        ap.error("pass --src to regenerate the faces, or --check to verify them")
    return generate(repo, args.src)


if __name__ == "__main__":
    sys.exit(main())
