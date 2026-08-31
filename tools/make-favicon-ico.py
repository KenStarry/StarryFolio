#!/usr/bin/env python3
"""Build `web/favicon.ico` from `web/favicon-48.png`.

Google will only use a favicon in a search result if it is square with sides a
multiple of 48px, and it probes `/favicon.ico` independently of whatever the
document head declares. This writes that file.

The icon carries exactly **one** 48x48 entry, stored as an embedded PNG. That
is deliberate on both counts:

  * PNG payloads have been legal inside .ico since Vista, so there is no need
    for a BMP encoder and no dependency on Pillow or ImageMagick.
  * The customary 16/32/48 multi-size icon would hand Google a non-compliant
    option to pick, which is the exact bug this file was written to fix.
    Browsers downscale a 48 for a tab without complaint.

Regenerate the source first, then run this:

    sips -z 48 48 web/favicon-192.png --out web/favicon-48.png
    python3 tools/make-favicon-ico.py

See docs/05-seo.md.
"""

import pathlib
import struct
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / 'web' / 'favicon-48.png'
OUT = ROOT / 'web' / 'favicon.ico'

PNG_MAGIC = b'\x89PNG\r\n\x1a\n'
ICONDIR = 6      # reserved(2) + type(2) + count(2)
ICONDIRENTRY = 16


def main() -> int:
    if not SRC.exists():
        sys.exit(f'{SRC} missing. Run the sips command in the module docstring first.')

    png = SRC.read_bytes()
    if png[:8] != PNG_MAGIC:
        sys.exit(f'{SRC} is not a PNG.')

    # Width and height live in the IHDR chunk, which is always first.
    width, height = struct.unpack('>II', png[16:24])
    if (width, height) != (48, 48):
        sys.exit(
            f'{SRC} is {width}x{height}, expected 48x48. Google requires a square '
            'favicon whose sides are a multiple of 48.'
        )

    ico = (
        struct.pack('<HHH', 0, 1, 1)
        + struct.pack(
            '<BBBBHHII',
            width, height,
            0,               # palette size, 0 for truecolour
            0,               # reserved
            1,               # colour planes
            32,              # bits per pixel
            len(png),
            ICONDIR + ICONDIRENTRY,
        )
        + png
    )
    OUT.write_bytes(ico)
    print(f'wrote {OUT.relative_to(ROOT)}: {len(ico)} bytes, one {width}x{height} PNG entry')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
