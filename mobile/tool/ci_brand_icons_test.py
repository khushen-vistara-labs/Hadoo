"""Icon-generation regression tests: run after gen_lokal_launcher_icons.py."""
import unittest
from pathlib import Path
from PIL import Image
import io

# Import through the repository package so unittest works from the repo root
# (including `python -m unittest tool/ci_brand_icons_test.py` in release CI).
from tool.gen_lokal_launcher_icons import HUB_SHIFT, SIZE, source_bytes

class BrandIconsTest(unittest.TestCase):
    def test_sticker_mask_alignment_and_square_art(self):
        base = Image.open("assets/branding/lokal_icon.png").convert("RGBA")
        mask = Image.open("assets/branding/lokal_icon_sticker.png").convert("RGBA")
        self.assertEqual(base.size, (512, 512))
        self.assertEqual(mask.size, base.size)
        self.assertEqual(base.getpixel((0, 0))[3], 255)  # full bleed
        self.assertEqual(mask.getpixel((0, 0))[3], 0)
        self.assertEqual(mask.getpixel((445, 255))[3], 255)
        self.assertEqual(mask.getpixel((260, 256))[3], 0)

    def test_hub_and_sticker_are_recentered_together(self):
        # The existing master has its outer hub ring roughly at (254.5,246.5).
        # Move it to (256.5,256.5) without changing the CD's proportions.
        self.assertEqual(HUB_SHIFT, (2, 10))
        source = Image.open(io.BytesIO(source_bytes())).convert("RGBA")
        source = source.resize((SIZE, SIZE), Image.Resampling.LANCZOS)
        aligned = Image.open("assets/branding/lokal_icon.png").convert("RGBA")
        dx, dy = HUB_SHIFT
        # A central hub pixel must be sampled from the shifted source.
        self.assertEqual(aligned.getpixel((256, 256)),
                         source.getpixel((256 - dx, 256 - dy)))
        # The upper-left corner remains solid full bleed, never white/clear.
        self.assertEqual(aligned.getpixel((0, 0)),
                         source.getpixel((dx - 1, dy - 1)))
        # Sticker mask should be translated by the identical displacement.
        sticker = Image.open("assets/branding/lokal_icon_sticker.png").convert("RGBA")
        self.assertEqual(sticker.getpixel((360, 185))[3], 0)
        self.assertEqual(sticker.getpixel((380, 210))[3], 255)

    def test_android_accent_variants_and_transparency(self):
        root = Path("android/app/src/main/res")
        for color in ("lime", "purple", "blue", "orange", "chartreuse"):
            icon = Image.open(root / f"drawable-xxxhdpi/ic_lokal_fg_{color}.png").convert("RGBA")
            self.assertEqual(icon.size, (432, 432))
            self.assertEqual(icon.getpixel((0, 0))[3], 0)
        lime = Image.open(root / "drawable-xxxhdpi/ic_lokal_fg_lime.png").convert("RGBA")
        blue = Image.open(root / "drawable-xxxhdpi/ic_lokal_fg_blue.png").convert("RGBA")
        self.assertNotEqual(lime.getpixel((335, 215)), blue.getpixel((335, 215)))
        self.assertEqual(lime.getpixel((216, 216)), blue.getpixel((216, 216)))

    def test_lokal_monochrome_notification_and_widget_icons(self):
        # Status icons must be alpha-only small drawables, not inset adaptive
        # launcher foregrounds or the original dotted Flick mark.
        import xml.etree.ElementTree as ET

        res = Path("android/app/src/main/res")
        drawable = res / "drawable"
        icon_path = drawable / "ic_notification.xml"
        self.assertTrue(icon_path.is_file())
        self.assertFalse((drawable / "ic_notification.png").exists())
        root = ET.parse(icon_path).getroot()
        android = "{http://schemas.android.com/apk/res/android}"
        self.assertEqual(root.tag, "vector")
        self.assertEqual(root.get(android + "viewportWidth"), "24")
        paths = root.findall("path")
        self.assertGreaterEqual(len(paths), 4)
        self.assertTrue(all(path.get(android + "fillColor") in ("#FFFFFFFF", "#00000000") for path in paths))

        for source in (
            "MusicNotificationService.kt",
            "FileCopyService.kt",
            "LokalLibrarySyncNotification.kt",
        ):
            content = (Path("android/app/src/main/kotlin/com/mossapps/flick") / source).read_text()
            self.assertIn(".setSmallIcon(R.drawable.ic_notification)", content)
            self.assertNotIn(".setSmallIcon(R.drawable.ic_lokal_fg_mono)", content)

        placeholder = (drawable / "widget_default_art.xml").read_text()
        self.assertIn("@drawable/ic_notification", placeholder)
        self.assertNotIn("@drawable/widget_flick_logo", placeholder)
        # Retain resource aliases for any older consumers, but their graphics
        # must no longer contain the original Flick-dot symbol.
        for legacy in ("widget_flick_logo.xml", "widget_ic_flick_logo.xml"):
            self.assertEqual((drawable / legacy).read_text(), icon_path.read_text())

    def test_legacy_corners_and_themed_monochrome(self):
        root = Path("android/app/src/main/res")
        square = Image.open(root / "mipmap-xxxhdpi/launcher_icon.png").convert("RGBA")
        self.assertEqual(square.getpixel((0, 0))[3], 255)
        mono = Image.open(root / "drawable-xxxhdpi/ic_lokal_fg_mono.png").convert("RGBA")
        self.assertEqual(mono.getpixel((0, 0))[3], 0)
        self.assertGreater(mono.getpixel((216, 153))[3], 0)

if __name__ == "__main__":
    unittest.main()
