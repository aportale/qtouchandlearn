#!/usr/bin/env python3
"""
Generates the app icons from the SVG files.

src/ios/AppIcon.svg is a square, whose corners iOS rounds. It gives the iOS app icons in
src/ios and the icon that the WebAssembly page has on the iOS Home Screen,
src/wasm/apple-touch-icon.png. src/touchandlearn.svg has its own rounded corners. It gives
the Windows icon src/icon.ico and the favicon of the WebAssembly page src/wasm/favicon.ico.

Inkscape renders the SVG files directly at each pixel size, and optipng compresses the PNG
images. Only the Python standard library is needed.

Requirements:
  - Inkscape (https://inkscape.org), either in PATH or passed with --inkscape
  - optipng (https://optipng.sourceforge.net), either in PATH or passed with --optipng

Usage:
  python generateicons.py
"""

import argparse
import shutil
import struct
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SQUARE_SVG = ROOT / "src" / "ios" / "AppIcon.svg"
ROUNDED_SVG = ROOT / "src" / "touchandlearn.svg"
IOS_DIR = ROOT / "src" / "ios"
TOUCH_ICON = ROOT / "src" / "wasm" / "apple-touch-icon.png"
WINDOWS_ICON = ROOT / "src" / "icon.ico"
FAVICON = ROOT / "src" / "wasm" / "favicon.ico"

IOS_ICON_SIZES = [29, 40, 57, 60, 72, 76]  # In points
WINDOWS_ICON_SIZES = [16, 24, 32, 48]
FAVICON_SIZES = [16, 32, 48]

ICO_HEADER = struct.Struct("<HHH")      # Reserved, type (1 = icon), image count
ICO_ENTRY = struct.Struct("<BBBBHHII")  # Width, height, palette size, reserved, color planes,
                                        # bits per pixel, data size, data offset


def ios_icons():
    """Returns (path, size in pixels) tuples."""
    result = []
    for size in IOS_ICON_SIZES:
        for scale, scale_suffix in ((1, ""), (2, "@2x")):
            for device_suffix in ("", "~ipad"):
                name = f"AppIcon{size}x{size}{scale_suffix}{device_suffix}.png"
                result.append((IOS_DIR / name, size * scale))
    result.append((TOUCH_ICON, 180))  # 60x60@3x
    return result


def render(inkscape, svg, pixels, color_mode, path):
    subprocess.run([inkscape, "-w", str(pixels), "-h", str(pixels),
                    f"--export-png-color-mode={color_mode}", "-o", str(path), str(svg)],
                   check=True)


def write_ico(path, images):
    """Writes (size in pixels, PNG data) pairs to an ICO file. Windows Vista and newer, and
    the browsers, read PNG images in ICO files."""
    offset = ICO_HEADER.size + ICO_ENTRY.size * len(images)
    data = bytearray(ICO_HEADER.pack(0, 1, len(images)))
    for pixels, png in images:
        data += ICO_ENTRY.pack(pixels, pixels, 0, 0, 1, 32, len(png), offset)
        offset += len(png)
    for _, png in images:
        data += png
    path.write_bytes(data)


def main():
    parser = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    parser.add_argument("--inkscape", default="inkscape", help="Inkscape executable")
    parser.add_argument("--optipng", default="optipng", help="optipng executable")
    args = parser.parse_args()

    inkscape = shutil.which(args.inkscape)
    if not inkscape:
        parser.error(f"Inkscape not found: {args.inkscape}")
    optipng = shutil.which(args.optipng)
    if not optipng:
        parser.error(f"optipng not found: {args.optipng}")

    # iOS fills transparent pixels with black, so leave out the alpha channel.
    for path, pixels in ios_icons():
        render(inkscape, SQUARE_SVG, pixels, "RGB_8", path)
        subprocess.run([optipng, "-quiet", str(path)], check=True)
        print(path)

    # The PNG images in ICO files keep 32 bit RGBA, which Windows expects.
    with tempfile.TemporaryDirectory() as work_dir:
        for path, sizes in ((WINDOWS_ICON, WINDOWS_ICON_SIZES), (FAVICON, FAVICON_SIZES)):
            images = []
            for pixels in sizes:
                png = Path(work_dir) / f"{path.stem}-{pixels}.png"
                render(inkscape, ROUNDED_SVG, pixels, "RGBA_8", png)
                subprocess.run([optipng, "-quiet", "-nx", str(png)], check=True)
                images.append((pixels, png.read_bytes()))
            write_ico(path, images)
            print(path)


if __name__ == "__main__":
    main()
