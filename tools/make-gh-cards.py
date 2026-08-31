#!/usr/bin/env python3
"""Generate the GitHub profile's project showcase cards, `web/images/gh-card-*.svg`.

These are the wide bands under **Shipped** on the profile README, mirroring the
site's featured showcase: a raised ink ground, a hairline, the project's own
name set enormous and barely there behind it, and the device mockup floating
unframed and bleeding off the bottom edge.

The mockups carry alpha, which is why they cannot be dropped into a README
directly: GitHub renders them on the reader's theme background, so a device
authored for a dark ground becomes a floating silhouette on white.
Compositing them onto the card's own ink ground here makes each card
self-contained and theme-independent. The image is embedded as a base64 data
URI, so the card is a single request with nothing to 404 alongside it.

**Camo caches these hard.** To change the art, change the FILENAME (append -2)
and update the reference in `docs/github-profile-readme.md`, or the profile
keeps serving the old card for days. Keep the previous filename alive with
corrected art until the README is republished, so the live profile never
shows a broken image.

Requires: dwebp + cwebp (libwebp) and sips (macOS).
Run from the repo root:  python3 tools/make-gh-cards.py
"""
import base64
import html
import pathlib
import shutil
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
IMG = ROOT / 'web' / 'images'
W, H = 1200, 400

# `out` is the filename to write. It carries a version suffix whenever the art
# has changed since the README was last published, for the camo reason above.
CARDS = [
    dict(slug='healthx', out='gh-card-healthx.svg', ghost='healthx',
         name='HealthX', tagline='Care, a pharmacy and a doctor, in one app.',
         meta='ANDROID · IOS · 2026',
         stack=['Flutter', 'Riverpod 3', 'GoRouter', 'Dio']),
    dict(slug='flow', out='gh-card-flow-2.svg', ghost='flow',
         name='Flow Music Player',
         tagline='Offline music, endlessly tunable and genuinely pretty.',
         meta='ANDROID · 2026',
         stack=['Flutter', 'BLoC', 'flutter_soloud', 'Hive']),
    dict(slug='rezq', out='gh-card-rezq.svg', ghost='rezq',
         name='RezQ', tagline='Resume building, the right way round.',
         meta='ANDROID · 2026',
         stack=['Flutter', 'Riverpod 3', 'GoRouter', 'Hive']),
]


def chips(items, x, y):
    out, cx = [], x
    for label in items:
        w = 15 + len(label) * 8.1
        out.append(
            f'<rect x="{cx:.0f}" y="{y}" width="{w:.0f}" height="30" rx="15" '
            f'fill="#282739" stroke="#434659" stroke-width="1"/>'
            f'<text class="m" x="{cx + w/2:.0f}" y="{y+20}" text-anchor="middle" '
            f'font-size="12.5" fill="#8A8EA8">{html.escape(label)}</text>')
        cx += w + 9
    return '\n      '.join(out)


def build(c, b64):
    name = html.escape(c['name'])
    tag = html.escape(c['tagline'])
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" role="img" aria-label="{name}: {tag}">
  <title>{name} · {tag}</title>
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#35364A"/><stop offset="1" stop-color="#282739"/>
    </linearGradient>
    <clipPath id="card"><rect width="{W}" height="{H}" rx="18"/></clipPath>
  </defs>
  <style>
    .f {{ font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, 'Helvetica Neue', Arial, sans-serif; }}
    .m {{ font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }}
    .r {{ animation: r .8s cubic-bezier(.2,.7,.3,1) backwards; }}
    .d1{{animation-delay:.05s}} .d2{{animation-delay:.15s}} .d3{{animation-delay:.25s}} .d4{{animation-delay:.35s}}
    @keyframes r {{ from {{ opacity:0; transform:translateY(12px); }} }}
    .m0 {{ animation: m0 1s cubic-bezier(.2,.7,.3,1) .2s backwards; }}
    @keyframes m0 {{ from {{ opacity:0; transform:translateY(26px); }} }}
    @media (prefers-reduced-motion: reduce) {{ .r, .m0 {{ animation:none; }} }}
  </style>

  <g clip-path="url(#card)">
    <rect width="{W}" height="{H}" fill="url(#g)"/>

    <!-- The ghost wordmark: texture, never content. Echoes the heading beside it. -->
    <text class="f" x="44" y="392" font-size="176" font-weight="800" letter-spacing="-6"
          fill="#E9EBF7" opacity="0.03">{html.escape(c['ghost'])}</text>

    <!-- Device, unframed, bleeding off the bottom the way the flat treatment does. -->
    <image class="m0" href="data:image/webp;base64,{b64}"
           x="812" y="46" width="330" height="433" preserveAspectRatio="xMidYMin meet"/>

    <text class="m r d1" x="64" y="86" font-size="13" letter-spacing="3" fill="#8A8EA8">{c['meta']}</text>
    <text class="f r d2" x="64" y="168" font-size="54" font-weight="800" fill="#E9EBF7" letter-spacing="-1">{name}</text>
    <text class="f r d3" x="64" y="216" font-size="23" font-weight="500" fill="#8A8EA8">{tag}</text>

    <g class="r d4">
      {chips(c['stack'], 64, 264)}
    </g>

    <text class="m r d4" x="64" y="348" font-size="13" letter-spacing="1.6" fill="#D0D4ED">Read the case study  &#8594;</text>
  </g>
  <rect x="0.5" y="0.5" width="{W-1}" height="{H-1}" rx="18" fill="none" stroke="#434659" stroke-width="1"/>
</svg>
'''


def main():
    for binary in ('dwebp', 'cwebp', 'sips'):
        if not shutil.which(binary):
            sys.exit(f'{binary} not found on PATH')

    with tempfile.TemporaryDirectory() as td:
        tmp = pathlib.Path(td)
        for c in CARDS:
            src = IMG / f"{c['slug']}-mockup.webp"
            if not src.exists():
                sys.exit(f'{src} missing')
            # Renders 330px wide on the card; 760 keeps it sharp on a 2x screen.
            subprocess.run(['dwebp', '-quiet', str(src), '-o', str(tmp / 'a.png')], check=True)
            subprocess.run(['sips', '-Z', '760', str(tmp / 'a.png'), '--out', str(tmp / 'b.png')],
                           check=True, capture_output=True)
            subprocess.run(['cwebp', '-quiet', '-q', '82', '-alpha_q', '90',
                            str(tmp / 'b.png'), '-o', str(tmp / 'c.webp')], check=True)
            b64 = base64.b64encode((tmp / 'c.webp').read_bytes()).decode()

            out = IMG / c['out']
            out.write_text(build(c, b64))
            print(f"  {c['out']:26} {out.stat().st_size:>8,}B")
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
