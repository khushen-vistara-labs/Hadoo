// SPDX-License-Identifier: GPL-3.0-only
// Deterministic Android resource exporter. The original logo files are never changed.
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import javax.imageio.ImageIO;

class Branding {
    private static final String[] DENSITIES = {"mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi"};
    private static final int[] ICON_SIZES = {108, 162, 216, 324, 432};
    private static final int[] NOTIFICATION_SIZES = {24, 36, 48, 72, 96};
    private static final int[][] HEADER_SIZES = {{121, 36}, {160, 48}, {240, 72}, {320, 96}};

    private static BufferedImage read(Path path) throws IOException {
        BufferedImage image = ImageIO.read(path.toFile());
        if (image == null) throw new IOException("Unreadable logo: " + path);
        return image;
    }

    // Remove the near-white scan background at export time, preserving colored logo ink.
    private static BufferedImage ink(BufferedImage source, boolean darkHeader) {
        if (darkHeader) return wordmarkInk(source);
        BufferedImage output = new BufferedImage(source.getWidth(), source.getHeight(), BufferedImage.TYPE_INT_ARGB);
        for (int y = 0; y < source.getHeight(); y++) {
            for (int x = 0; x < source.getWidth(); x++) {
                int pixel = source.getRGB(x, y);
                int r = (pixel >>> 16) & 255, g = (pixel >>> 8) & 255, b = pixel & 255;
                int alpha = pixel >>> 24;
                int saturation = Math.max(r, Math.max(g, b)) - Math.min(r, Math.min(g, b));
                int minimum = Math.min(r, Math.min(g, b));
                if (saturation < 22 && minimum > 220) {
                    alpha = alpha * Math.max(0, 248 - minimum) / 28;
                }
                output.setRGB(x, y, (Math.min(255, alpha) << 24) | (r << 16) | (g << 8) | b);
            }
        }
        return output;
    }

    // Recover coverage from the original dark ink on white paper. Recolor every
    // covered pixel, including antialiased edges, so no navy/white fringe survives.
    // The symbol in this mask is discarded when the wordmark is cropped below.
    static BufferedImage wordmarkInk(BufferedImage source) {
        BufferedImage output = canvas(source.getWidth(), source.getHeight());
        for (int y = 0; y < source.getHeight(); y++) {
            for (int x = 0; x < source.getWidth(); x++) {
                int pixel = source.getRGB(x, y);
                int minimum = Math.min((pixel >>> 16) & 255, Math.min((pixel >>> 8) & 255, pixel & 255));
                double coverage = Math.clamp((248.0 - minimum) / 200.0, 0.0, 1.0);
                int alpha = (int) Math.round((pixel >>> 24) * coverage);
                output.setRGB(x, y, (alpha << 24) | 0xf5f5f5);
            }
        }
        return output;
    }

    private static BufferedImage crop(BufferedImage source) {
        int minX = source.getWidth(), minY = source.getHeight(), maxX = -1, maxY = -1;
        for (int y = 0; y < source.getHeight(); y++) {
            for (int x = 0; x < source.getWidth(); x++) {
                if ((source.getRGB(x, y) >>> 24) > 32) {
                    minX = Math.min(minX, x); minY = Math.min(minY, y);
                    maxX = Math.max(maxX, x); maxY = Math.max(maxY, y);
                }
            }
        }
        if (maxX < 0) throw new IllegalArgumentException("The logo has no visible artwork.");
        return source.getSubimage(minX, minY, maxX - minX + 1, maxY - minY + 1);
    }

    private static BufferedImage canvas(int width, int height) {
        return new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
    }

    private static Graphics2D graphics(BufferedImage image) {
        Graphics2D g = image.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
        g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.setRenderingHint(RenderingHints.KEY_ALPHA_INTERPOLATION, RenderingHints.VALUE_ALPHA_INTERPOLATION_QUALITY);
        return g;
    }

    // A single bicubic draw samples only a few source pixels even during a large
    // reduction. Integrate the complete footprint in premultiplied-alpha space
    // instead, retaining thin strokes without aliasing or transparent-edge halos.
    static BufferedImage resizeForExport(BufferedImage source, int width, int height) {
        if (width <= 0 || height <= 0) throw new IllegalArgumentException("Image dimensions must be positive.");
        if (width == source.getWidth() && height == source.getHeight()) return source;
        BufferedImage output = canvas(width, height);
        if (width > source.getWidth() || height > source.getHeight()) {
            Graphics2D g = graphics(output);
            g.drawImage(source, 0, 0, width, height, null);
            g.dispose();
            return output;
        }
        double stepX = source.getWidth() / (double) width;
        double stepY = source.getHeight() / (double) height;
        double area = stepX * stepY;
        for (int y = 0; y < height; y++) {
            double top = y * stepY, bottom = (y + 1) * stepY;
            for (int x = 0; x < width; x++) {
                double left = x * stepX, right = (x + 1) * stepX;
                double alpha = 0, red = 0, green = 0, blue = 0;
                for (int sy = (int) Math.floor(top); sy < Math.min(source.getHeight(), (int) Math.ceil(bottom)); sy++) {
                    double weightY = Math.min(bottom, sy + 1) - Math.max(top, sy);
                    for (int sx = (int) Math.floor(left); sx < Math.min(source.getWidth(), (int) Math.ceil(right)); sx++) {
                        double weight = weightY * (Math.min(right, sx + 1) - Math.max(left, sx));
                        int pixel = source.getRGB(sx, sy);
                        double coveredArea = (pixel >>> 24) * weight;
                        alpha += coveredArea;
                        red += ((pixel >>> 16) & 255) * coveredArea;
                        green += ((pixel >>> 8) & 255) * coveredArea;
                        blue += (pixel & 255) * coveredArea;
                    }
                }
                int a = Math.clamp((int) Math.round(alpha / area), 0, 255);
                if (a > 0) {
                    int r = Math.clamp((int) Math.round(red / alpha), 0, 255);
                    int g = Math.clamp((int) Math.round(green / alpha), 0, 255);
                    int b = Math.clamp((int) Math.round(blue / alpha), 0, 255);
                    output.setRGB(x, y, (a << 24) | (r << 16) | (g << 8) | b);
                }
            }
        }
        return output;
    }

    private static void fit(Graphics2D g, BufferedImage source, double x, double y, double width, double height) {
        double scale = Math.min(width / source.getWidth(), height / source.getHeight());
        int w = Math.max(1, (int) Math.round(source.getWidth() * scale));
        int h = Math.max(1, (int) Math.round(source.getHeight() * scale));
        g.drawImage(resizeForExport(source, w, h), (int) Math.round(x + (width - w) / 2), (int) Math.round(y + (height - h) / 2), null);
    }

    private static void save(BufferedImage image, Path path) throws IOException {
        Files.createDirectories(path.getParent());
        if (!ImageIO.write(image, "PNG", path.toFile())) throw new IOException("PNG writer unavailable.");
    }

    private static BufferedImage silhouette(BufferedImage source) {
        BufferedImage output = canvas(source.getWidth(), source.getHeight());
        for (int y = 0; y < source.getHeight(); y++) {
            for (int x = 0; x < source.getWidth(); x++) {
                output.setRGB(x, y, (source.getRGB(x, y) & 0xff000000) | 0xffffff);
            }
        }
        return output;
    }

    // Compact vector silhouette for Android's wallpaper-tinted adaptive icon.
    private static String vector(BufferedImage source) {
        BufferedImage mask = canvas(108, 108);
        Graphics2D g = graphics(mask);
        fit(g, source, 25, 25, 58, 58);
        g.dispose();
        StringBuilder path = new StringBuilder();
        for (int y = 0; y < 108; y++) {
            int start = -1;
            for (int x = 0; x <= 108; x++) {
                boolean opaque = x < 108 && (mask.getRGB(x, y) >>> 24) >= 96;
                if (opaque && start < 0) start = x;
                if (!opaque && start >= 0) {
                    path.append("M").append(start).append(',').append(y).append('h').append(x - start)
                        .append("v1h-").append(x - start).append('z');
                    start = -1;
                }
            }
        }
        return "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
            + "<vector xmlns:android=\"http://schemas.android.com/apk/res/android\" android:width=\"108dp\" android:height=\"108dp\" android:viewportWidth=\"108\" android:viewportHeight=\"108\">\n"
            + "  <path android:fillColor=\"#FFFFFFFF\" android:pathData=\"" + path + "\"/>\n</vector>\n";
    }

    private static void export(BufferedImage mark, BufferedImage logo, Path out) throws IOException {
        for (int i = 0; i < DENSITIES.length; i++) {
            int size = ICON_SIZES[i];
            BufferedImage foreground = canvas(size, size);
            Graphics2D fg = graphics(foreground);
            fit(fg, mark, size * 25.0 / 108, size * 25.0 / 108, size * 58.0 / 108, size * 58.0 / 108);
            fg.dispose();
            BufferedImage background = canvas(size, size);
            Graphics2D bg = graphics(background);
            bg.setColor(Color.WHITE); bg.fillRect(0, 0, size, size); bg.dispose();
            Path mipmap = out.resolve("icons/mipmap-" + DENSITIES[i]);
            save(foreground, mipmap.resolve("morphe_adaptive_foreground_custom.png"));
            save(background, mipmap.resolve("morphe_adaptive_background_custom.png"));
            int notificationSize = NOTIFICATION_SIZES[i];
            BufferedImage notification = canvas(notificationSize, notificationSize);
            Graphics2D ng = graphics(notification);
            fit(ng, silhouette(mark), 1, 1, notificationSize - 2, notificationSize - 2); ng.dispose();
            save(notification, out.resolve("icons/drawable-" + DENSITIES[i] + "/morphe_notification_icon_custom.png"));
        }
        Path monochrome = out.resolve("icons/drawable/morphe_adaptive_monochrome_custom.xml");
        Files.createDirectories(monochrome.getParent());
        Files.writeString(monochrome, vector(mark));

        // The full original artwork stacks the symbol above the wordmark. Use its bottom
        // wordmark section next to the original mark for a readable horizontal app header.
        int wordmarkTop = -1;
        for (int y = (int) (logo.getHeight() * 0.55); y < (int) (logo.getHeight() * 0.88); y++) {
            boolean empty = true;
            for (int x = 0; x < logo.getWidth(); x++) {
                if ((logo.getRGB(x, y) >>> 24) > 32) { empty = false; break; }
            }
            if (empty) wordmarkTop = y + 1;
        }
        if (wordmarkTop < 0) throw new IllegalArgumentException("Cannot find the gap above the Hadoo wordmark.");
        BufferedImage wordmark = crop(logo.getSubimage(0, wordmarkTop, logo.getWidth(), logo.getHeight() - wordmarkTop));
        for (int i = 0; i < HEADER_SIZES.length; i++) {
            int w = HEADER_SIZES[i][0], h = HEADER_SIZES[i][1];
            BufferedImage header = canvas(w, h);
            Graphics2D g = graphics(header);
            fit(g, mark, 0, h * 0.08, h * 0.92, h * 0.84);
            fit(g, wordmark, h * 1.05, h * 0.14, w - h * 1.12, h * 0.72);
            g.dispose();
            save(header, out.resolve("header/drawable-" + DENSITIES[i + 1] + "/morphe_header_custom_dark.png"));
        }

        BufferedImage preview = canvas(800, 260);
        Graphics2D g = graphics(preview);
        g.setColor(new Color(17, 18, 24)); g.fillRect(0, 0, 800, 260);
        g.setColor(Color.WHITE); g.fillRoundRect(35, 35, 190, 190, 48, 48);
        fit(g, mark, 58, 58, 144, 144);
        BufferedImage header = read(out.resolve("header/drawable-xxxhdpi/morphe_header_custom_dark.png"));
        fit(g, header, 285, 80, 460, 100); g.dispose();
        save(preview, out.resolve("preview.png"));
        System.out.println("Exported Hadoo adaptive icons, notification icons and YouTube Music headers.");
    }

    public static void main(String[] args) throws IOException {
        if (args.length != 3) throw new IllegalArgumentException("Usage: Branding.java mark.png logo.png output-directory");
        export(crop(ink(read(Path.of(args[0])), false)), crop(ink(read(Path.of(args[1])), true)), Path.of(args[2]));
    }
}
