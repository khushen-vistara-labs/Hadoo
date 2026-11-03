// SPDX-License-Identifier: GPL-3.0-only
import java.awt.image.BufferedImage;

class BrandingQualityTest {
    private static void require(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
    }

    private static void thinStrokesContributeToReducedPixels() {
        BufferedImage source = new BufferedImage(100, 100, BufferedImage.TYPE_INT_ARGB);
        for (int y = 0; y < 100; y++) {
            for (int x = 0; x < 100; x++) source.setRGB(x, y, x == 0 ? 0xffffffff : 0xff000000);
        }
        BufferedImage reduced = Branding.resizeForExport(source, 10, 10);
        for (int y = 0; y < 10; y++) {
            int first = reduced.getRGB(0, y);
            require((first >>> 24) == 255, "Opaque artwork became translucent");
            require((first & 255) == 26, "A thin source stroke was skipped instead of area averaged");
            require((reduced.getRGB(1, y) & 0xffffff) == 0, "The stroke leaked into an adjacent footprint");
        }
    }

    private static void transparentPixelsDoNotCreateColorFringes() {
        BufferedImage source = new BufferedImage(2, 1, BufferedImage.TYPE_INT_ARGB);
        source.setRGB(0, 0, 0xffffffff);
        source.setRGB(1, 0, 0x000000ff);
        int reduced = Branding.resizeForExport(source, 1, 1).getRGB(0, 0);
        require((reduced >>> 24) == 128, "Coverage was not averaged correctly");
        require((reduced & 0xffffff) == 0xffffff, "Transparent RGB introduced a dark or colored halo");
    }

    private static void recoloringAlsoRecolorsAntialiasedEdges() {
        BufferedImage source = new BufferedImage(4, 1, BufferedImage.TYPE_INT_ARGB);
        source.setRGB(0, 0, 0xff283264); // Solid navy ink.
        source.setRGB(1, 0, 0xff94a0b2); // An antialiased edge on white paper.
        source.setRGB(2, 0, 0xfffaf9fb); // Near-white paper texture.
        source.setRGB(3, 0, 0x00283264); // Already transparent.
        BufferedImage mask = Branding.wordmarkInk(source);
        require((mask.getRGB(0, 0) >>> 24) == 255, "Solid lettering lost its weight");
        require((mask.getRGB(1, 0) >>> 24) == 128, "The antialiased edge lost its coverage");
        for (int x = 0; x < 2; x++) {
            require((mask.getRGB(x, 0) & 0xffffff) == 0xf5f5f5, "A navy fringe survived recoloring");
        }
        require((mask.getRGB(2, 0) >>> 24) == 0, "Paper noise remained visible");
        require((mask.getRGB(3, 0) >>> 24) == 0, "Transparent artwork became visible");
    }

    public static void main(String[] args) {
        thinStrokesContributeToReducedPixels();
        transparentPixelsDoNotCreateColorFringes();
        recoloringAlsoRecolorsAntialiasedEdges();
        System.out.println("Branding quality regressions passed.");
    }
}
