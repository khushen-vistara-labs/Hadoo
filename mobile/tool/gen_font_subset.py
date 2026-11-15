#!/usr/bin/env python3
"""Generate (or verify) the bundled Simplified Chinese fallback font.

Why this exists
---------------
The app font is Google Sans Flex, which is Latin/Greek only and carries no CJK
glyphs. Android would happily fall back to the device font, but then Chinese
renders in a different typeface from the Latin text around it. Registering a
subset of Noto Sans SC in `pubspec.yaml` fixes that with no Dart changes: Skia
resolves a missing character by searching every font registered in the app
manifest (`FontCollection::onMatchFamilyStyleCharacter`), so the fallback is
automatic.

A full Noto Sans SC would add ~17 MB to the APK, so this script cuts it down to
the characters the app's own strings actually use:

  1. instance the variable font to static 400 and 700 (Flutter's variable-font
     weight support is less reliable than plain static faces);
  2. subset to the characters found in `lib/l10n/app_*.arb` plus the Android
     string resources, plus a fixed set of punctuation and symbols.

Characters outside the subset keep falling back to the platform font, so a rare
glyph in a song title still renders -- just in the device typeface instead.

The subset therefore goes stale whenever new strings are added. `--check` is
meant for CI; it only needs the standard library.

Usage
-----
    # CI / pre-commit: does the bundled subset still cover every string?
    python3 tool/gen_font_subset.py --check

    # regenerate after adding strings (needs `pip install fonttools`)
    python3 tool/gen_font_subset.py --src /path/to/NotoSansSC-var.ttf
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

SUBSET_FONTS = ("NotoSansSC-Regular.ttf", "NotoSansSC-Bold.ttf")
FONT_DIR = os.path.join("assets", "fonts")

# The variable font this subset is cut from (Noto Sans SC, SIL OFL 1.1).
UPSTREAM = "https://github.com/notofonts/noto-cjk/releases (Sans/Variable/TTF/Subset)"

# Always keep these, whatever the strings happen to use: ASCII, CJK punctuation
# and the symbols the UI draws as text.
EXTRA = (
    "".join(chr(c) for c in range(0x20, 0x7F))
    + "　、。〈〉《》「」『』【】〔〕（）［］｛｝"
    + "，．：；！？…—–·～￥％＃＠＆＊＋－＝／＼｜"
    + "０１２３４５６７８９"
    + "“”‘’′″℃°±×÷≤≥≠∞√∑∏∫≈∝∈∉⊂⊃∪∩"
    + "①②③④⑤⑥⑦⑧⑨⑩"
    + "←→↑↓↔⇄⇅▶◀■□●○◆◇★☆♩♪♫♬"
)


def required_chars(repo: str) -> set[str]:
    """Every character the app can render from its own strings."""
    chars: set[str] = set(EXTRA)

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

    # Native-side strings are user visible too; XML comments are not.
    for rel in ("android/app/src/main/res/values-zh-rCN/strings.xml",
                "android/app/src/main/res/values-zh-rCN/widget_strings.xml"):
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
    need = required_chars(repo)
    print(f"characters used by the app's strings: {len(need)}")
    covered_any: set[str] = set()
    for name in SUBSET_FONTS:
        path = os.path.join(repo, FONT_DIR, name)
        if not os.path.exists(path):
            print(f"  missing font: {path}")
            return 1
        codepoints = cmap_codepoints(path)
        covered_any |= {c for c in need if ord(c) in codepoints}
    missing = sorted(c for c in need if c not in covered_any)
    if missing:
        print(f"  the bundled subset is missing {len(missing)} characters:")
        print("  " + "".join(missing[:80]))
        print("\nRun tool/gen_font_subset.py with --src to regenerate it.")
        return 1
    print(f"  {len(SUBSET_FONTS)} subset fonts cover all of them")
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

    text = "".join(sorted(required_chars(repo)))
    out_dir = os.path.join(repo, FONT_DIR)
    os.makedirs(out_dir, exist_ok=True)
    print(f"characters to cover: {len(text)}")

    for weight, name in ((400, SUBSET_FONTS[0]), (700, SUBSET_FONTS[1])):
        font = TTFont(src)
        instantiateVariableFont(font, {"wght": weight}, inplace=True,
                                updateFontNames=True)
        opts = Options()
        opts.layout_features = ["*"]
        opts.name_IDs = ["*"]
        opts.notdef_outline = True
        opts.recalc_bounds = True
        opts.drop_tables += ["DSIG"]
        subsetter = Subsetter(options=opts)
        subsetter.populate(text=text)
        subsetter.subset(font)
        out = os.path.join(out_dir, name)
        font.save(out)
        print(f"  {name:<26} wght={weight}  {os.path.getsize(out) / 1024:8.1f} KB")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--repo", default=DEFAULT_REPO,
                    help="repository root (default: the parent of this script)")
    ap.add_argument("--src", help="variable Noto Sans SC to cut the subset from")
    ap.add_argument("--check", action="store_true",
                    help="verify the bundled subset covers every string; exit 1 if not")
    args = ap.parse_args()

    repo = os.path.abspath(args.repo)
    if args.check:
        return check(repo)
    if not args.src:
        ap.error("pass --src to regenerate the subset, or --check to verify it")
    return generate(repo, args.src)


if __name__ == "__main__":
    sys.exit(main())
