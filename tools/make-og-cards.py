#!/usr/bin/env python3
"""Generate the per-project Open Graph share cards in `web/images/og-*.jpg`.

Every case study but one used to fall back to the site's single default
`og.jpg`, so four different links shared one picture on LinkedIn, X, Slack and
WhatsApp. The exception, `flutter_extend`, carried a `.webp`, which several
scrapers including LinkedIn's decline to render at all, so it effectively had
none either.

These are the fix: one 1200x630 card per case study, in the site's own visual
language, exported as **JPEG** because that is the format every scraper reads.

Two templates, because the two kinds of project photograph differently:

  * A **product** has screens, so it gets its device mockup. The mockups carry
    alpha and are composited onto the card's ink ground here, which is also
    what makes them safe to share anywhere.
  * A **package** has no screens at all. Showing it a blank phone would be a
    lie about what it is, so it gets its call sites instead, which is what a
    library is actually judged on.

Wire the output up by setting `ogCard` on the project in
`projects_local_datasource.dart`. See `ProjectModel.ogCard`.

Requires: dwebp + cwebp (libwebp), sips (macOS), and Chrome for rendering.
Run from the repo root:  python3 tools/make-og-cards.py
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
W, H = 1200, 630

CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'

PRODUCTS = {
    'healthx': dict(ghost='healthx', name='HealthX', namesz=62,
                    tagline='Care, a pharmacy and a doctor, in one app.',
                    meta='ANDROID · IOS · 2026',
                    stack=['Flutter', 'Riverpod 3', 'GoRouter', 'Dio']),
    'flow': dict(ghost='flow', name='Flow Music Player', namesz=56,
                 tagline='Offline music, endlessly tunable and genuinely pretty.',
                 meta='ANDROID · 2026',
                 stack=['Flutter', 'BLoC', 'flutter_soloud', 'Hive']),
    'rezq': dict(ghost='rezq', name='RezQ', namesz=62,
                 tagline='Resume building, the right way round.',
                 meta='ANDROID · 2026',
                 stack=['Flutter', 'Riverpod 3', 'GoRouter', 'Hive']),
}

PACKAGE = dict(slug='flutter-extend', ghost='extend', name='flutter_extend',
               tagline='The boilerplate you stop writing.',
               meta='DART PACKAGE · PUB.DEV · 2025',
               lines=[('context.pushScreen(Home());', '#D0D4ED'),
                      ("Text('hi').padding();", '#D0D4ED'),
                      ('context.colorScheme;', '#D0D4ED'),
                      ('email.isValidEmail;', '#8A8EA8')])


POSTS = {
    'multi-wayed-svg-styling': dict(
        ghost='writing', meta='WRITING · FLUTTER · APR 2024',
        title=['Multi-wayed SVG', 'styling in Flutter'],
        dek='Four ways to colour an SVG in Flutter, and why the '
            'obvious one falls apart the moment the artwork gets interesting.',
        tags=['Flutter', 'SVG', 'CustomPaint', 'Shaders']),
}


def head(ghost, alt, ghostsz):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" role="img" aria-label="{html.escape(alt)}">
  <title>{html.escape(alt)}</title>
  <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#35364A"/><stop offset="1" stop-color="#1E1F2B"/>
  </linearGradient><clipPath id="c"><rect width="{W}" height="{H}"/></clipPath></defs>
  <style>
    .f {{ font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, 'Helvetica Neue', Arial, sans-serif; }}
    .m {{ font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }}
  </style>
  <g clip-path="url(#c)">
    <rect width="{W}" height="{H}" fill="url(#g)"/>
    <text class="f" x="40" y="612" font-size="{ghostsz}" font-weight="800" letter-spacing="-7"
          fill="#E9EBF7" opacity="0.03">{html.escape(ghost)}</text>
'''


def foot(ruley, urly):
    return f'''    <rect x="72" y="{ruley}" width="86" height="2.5" rx="1.25" fill="#D0D4ED"/>
    <text class="m" x="72" y="{urly}" font-size="20" letter-spacing="1.4" fill="#E9EBF7">kenstarry.com</text>
  </g>
</svg>
'''


def chips(items, x, y):
    out, cx = [], x
    for label in items:
        w = 17 + len(label) * 8.6
        out.append(
            f'<rect x="{cx:.0f}" y="{y}" width="{w:.0f}" height="33" rx="16.5" fill="#282739" stroke="#434659"/>'
            f'<text class="m" x="{cx + w/2:.0f}" y="{y+22}" text-anchor="middle" font-size="13" fill="#8A8EA8">{html.escape(label)}</text>')
        cx += w + 10
    return '\n    '.join(out)


def build_product(cfg, mock_b64):
    return (head(cfg['ghost'], f"{cfg['name']}: {cfg['tagline']}", 200)
            + f'''    <image href="data:image/webp;base64,{mock_b64}" x="742" y="86" width="430" height="565" preserveAspectRatio="xMidYMin meet"/>
    <text class="m" x="72" y="108" font-size="14" letter-spacing="3.2" fill="#8A8EA8">{cfg['meta']}</text>
    <text class="f" x="72" y="206" font-size="{cfg['namesz']}" font-weight="800" fill="#E9EBF7" letter-spacing="-1.4">{html.escape(cfg['name'])}</text>
    <text class="f" x="72" y="262" font-size="26" font-weight="500" fill="#8A8EA8">{html.escape(cfg['tagline'])}</text>
    {chips(cfg['stack'], 72, 316)}
''' + foot(470, 524))


def build_package(cfg):
    # Panel spans y 330..500; four lines on a 32 rhythm from 378 end at 474.
    code = '\n    '.join(
        f'<text class="m" x="104" y="{378 + i*32}" font-size="19" fill="{col}">{html.escape(t)}</text>'
        for i, (t, col) in enumerate(cfg['lines']))
    return (head(cfg['ghost'], f"{cfg['name']}: {cfg['tagline']}", 176)
            + f'''    <text class="m" x="72" y="108" font-size="14" letter-spacing="3.2" fill="#8A8EA8">{cfg['meta']}</text>
    <text class="m" x="72" y="196" font-size="56" font-weight="700" fill="#E9EBF7">{html.escape(cfg['name'])}</text>
    <text class="f" x="72" y="252" font-size="26" font-weight="500" fill="#8A8EA8">{html.escape(cfg['tagline'])}</text>
    <rect x="72" y="330" width="1056" height="170" rx="14" fill="#1E1F2B" stroke="#434659"/>
    {code}
''' + foot(548, 596))


def wrap(text, limit):
    """Break `text` into two lines at the last word boundary before `limit`."""
    if len(text) <= limit:
        return text, ''
    cut = text.rfind(' ', 0, limit + 1)
    if cut == -1:
        cut = limit
    return text[:cut], text[cut + 1:]


def build_post(cfg):
    """A written piece has no product shot and no call sites.

    Its cover art is authored for the page, at the page's aspect ratio, so
    cropping it into a 1.91:1 share frame lands somewhere arbitrary. The title
    is the thing worth showing, set across two lines the way the site's
    display headings are.
    """
    lines = '\n    '.join(
        f'<text class="f" x="72" y="{206 + i*62}" font-size="54" font-weight="{800 if i else 600}" '
        f'fill="{"#E9EBF7" if i else "#8A8EA8"}" letter-spacing="-1.2">{html.escape(t)}</text>'
        for i, t in enumerate(cfg['title']))
    dek1, dek2 = wrap(cfg['dek'], 64)
    return (head(cfg['ghost'], ' '.join(cfg['title']), 190)
            + f'''    <text class="m" x="72" y="108" font-size="14" letter-spacing="3.2" fill="#8A8EA8">{cfg['meta']}</text>
    {lines}
    <text class="f" x="72" y="368" font-size="24" font-weight="400" fill="#8A8EA8">{html.escape(dek1)}</text>
    <text class="f" x="72" y="402" font-size="24" font-weight="400" fill="#8A8EA8">{html.escape(dek2)}</text>
    {chips(cfg['tags'], 72, 446)}
''' + foot(548, 596))


def render(svg_path, out_jpg, tmp):
    """Supersample at 2x, resample down, then JPEG.

    Flat vector type and a photographic device share the frame, so rendering
    straight at 1x leaves the type crunchy.
    """
    png2x, png1x = tmp / 'x2.png', tmp / 'x1.png'
    subprocess.run([CHROME, '--headless', '--disable-gpu', f'--screenshot={png2x}',
                    f'--window-size={W},{H}', '--force-device-scale-factor=2',
                    '--virtual-time-budget=3000', f'file://{svg_path}'],
                   check=True, capture_output=True)
    subprocess.run(['sips', '-z', str(H), str(W), str(png2x), '--out', str(png1x)],
                   check=True, capture_output=True)
    subprocess.run(['sips', '-s', 'format', 'jpeg', '-s', 'formatOptions', '86',
                    str(png1x), '--out', str(out_jpg)], check=True, capture_output=True)


def main():
    for binary in ('dwebp', 'cwebp', 'sips'):
        if not shutil.which(binary):
            sys.exit(f'{binary} not found on PATH')
    if not pathlib.Path(CHROME).exists():
        sys.exit(f'Chrome not found at {CHROME}')

    with tempfile.TemporaryDirectory() as td:
        tmp = pathlib.Path(td)

        for slug, cfg in PRODUCTS.items():
            src = IMG / f'{slug}-mockup.webp'
            if not src.exists():
                sys.exit(f'{src} missing')
            # Decode, downscale to ~900px (it renders 430 wide at 2x), re-encode.
            subprocess.run(['dwebp', '-quiet', str(src), '-o', str(tmp / 'a.png')], check=True)
            subprocess.run(['sips', '-Z', '900', str(tmp / 'a.png'), '--out', str(tmp / 'b.png')],
                           check=True, capture_output=True)
            subprocess.run(['cwebp', '-quiet', '-q', '84', '-alpha_q', '90',
                            str(tmp / 'b.png'), '-o', str(tmp / 'c.webp')], check=True)
            b64 = base64.b64encode((tmp / 'c.webp').read_bytes()).decode()

            svg = tmp / f'{slug}.svg'
            svg.write_text(build_product(cfg, b64))
            out = IMG / f'og-{slug}.jpg'
            render(svg, out, tmp)
            print(f'  og-{slug}.jpg  {out.stat().st_size:,}B')

        for slug, cfg in POSTS.items():
            svg = tmp / f'post-{slug}.svg'
            svg.write_text(build_post(cfg))
            out = IMG / f'og-post-{slug}.jpg'
            render(svg, out, tmp)
            print(f'  og-post-{slug}.jpg  {out.stat().st_size:,}B')

        svg = tmp / 'pkg.svg'
        svg.write_text(build_package(PACKAGE))
        out = IMG / f"og-{PACKAGE['slug']}.jpg"
        render(svg, out, tmp)
        print(f"  og-{PACKAGE['slug']}.jpg  {out.stat().st_size:,}B")

    return 0


if __name__ == '__main__':
    raise SystemExit(main())
