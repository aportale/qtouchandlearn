#!/usr/bin/env python3
"""
Optimizes the SVG files of originaldata/graphics for the app.

scour removes the editor metadata, the comments and the unused IDs, shortens the other IDs
and rounds the numbers. The IDs with the prefix id_ stay, because the image provider looks
up the elements by these IDs. Only the Python standard library is needed.

Requirements:
  - scour (https://github.com/scour-project/scour), e.g. installed with "pip install scour",
    either in PATH or passed with --scour

Usage:
  python optimizesvg.py [--output DIR]
"""

import argparse
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE_DIR = ROOT / "originaldata" / "graphics"
DEFAULT_OUTPUT = ROOT / "src" / "TouchAndLearn" / "data" / "graphics"

NOT_BUNDLED = {"particle.svg"}  # The app uses particle.png

SCOUR_OPTIONS = [
    "--enable-id-stripping",
    "--shorten-ids",
    "--protect-ids-prefix=id_",
    "--remove-metadata",
    "--strip-xml-prolog",
    "--enable-comment-stripping",
    "--create-groups",
    "--indent=none",
    "--set-precision=4",
    "--quiet",
]


def main():
    parser = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    parser.add_argument("--scour", default="scour", help="scour executable")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT, help="Output directory")
    args = parser.parse_args()

    scour = shutil.which(args.scour)
    if not scour:
        parser.error(f"scour not found: {args.scour}")
    args.output.mkdir(parents=True, exist_ok=True)

    for svg in sorted(SOURCE_DIR.glob("*.svg")):
        if svg.name in NOT_BUNDLED:
            continue
        output = args.output / svg.name
        subprocess.run([scour, *SCOUR_OPTIONS, "-i", str(svg), "-o", str(output)], check=True)
        print(output)


if __name__ == "__main__":
    main()
