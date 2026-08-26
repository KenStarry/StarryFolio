#!/usr/bin/env bash
#
# Production build for Cloudflare Pages.
#
# Cloudflare's build image has no Dart and no Tailwind binary, so both are
# fetched here. Kept in the repo rather than pasted into the dashboard so the
# build is reviewable and versioned alongside the code it builds.
#
# Cloudflare Pages settings:
#   Build command       ./scripts/build.sh
#   Output directory    build/jaspr
set -euo pipefail

DART_VERSION="${DART_VERSION:-3.12.2}"
TAILWIND_VERSION="${TAILWIND_VERSION:-4.3.3}"
SITE="${SITE_DOMAIN:-https://kenstarry.com}"

echo "→ Dart $DART_VERSION"
curl -sSfL \
  "https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-x64-release.zip" \
  -o /tmp/dart.zip
unzip -q /tmp/dart.zip -d "$HOME"
export PATH="$HOME/dart-sdk/bin:$PATH"

# jaspr_tailwind shells out to this binary and discards its stderr, so a missing
# one surfaces only as `PathNotFoundException: .../web/styles.css`.
echo "→ Tailwind $TAILWIND_VERSION"
curl -sSfL \
  "https://github.com/tailwindlabs/tailwindcss/releases/download/v${TAILWIND_VERSION}/tailwindcss-linux-x64" \
  -o "$HOME/tailwindcss"
chmod +x "$HOME/tailwindcss"
export PATH="$HOME:$PATH"

echo "→ jaspr_cli"
dart pub global activate jaspr_cli >/dev/null
export PATH="$PATH:$HOME/.pub-cache/bin"

echo "→ building"
# /404 and /thanks are both noindex; a noindex page listed in the sitemap is a
# crawl-budget contradiction.
jaspr build --sitemap-domain "$SITE" --sitemap-exclude '^/(404|thanks)'

OUT="build/jaspr"

# ── Prune build-tool debris ───────────────────────────────────────────────────
# `jaspr build` copies a `packages/` tree into the output containing the test
# runner, the DDC dev-compiler, analyzer assets and live-reload scripts — around
# 1.3 MB, more than half the artefact, none of it referenced by a single shipped
# page. `main.client.dart.js` is a self-contained dart2js bundle.
#
# `packages/starry/` is deliberately left alone: it is this package's own
# builder metadata, it is a few KB, and it is the one subtree where a future
# Jaspr version could plausibly want something at runtime.
if [ -d "$OUT/packages" ]; then
  before=$(du -sk "$OUT" | cut -f1)
  find "$OUT/packages" -mindepth 1 -maxdepth 1 -not -name 'starry' -exec rm -rf {} +
  after=$(du -sk "$OUT" | cut -f1)
  echo "→ pruned tooling debris: ${before}KB → ${after}KB"
fi

# ── Cloudflare conventions ────────────────────────────────────────────────────
# Pages serves `/404.html` for unmatched routes. Jaspr emits `404/index.html`,
# so publish it under both names — the directory form keeps /404 working as a
# real URL, the file form is what Pages looks for.
if [ -f "$OUT/404/index.html" ]; then
  cp "$OUT/404/index.html" "$OUT/404.html"
  echo "→ wrote 404.html"
fi

# Only /api/* should reach the Worker. Without this every static request is
# billed an invocation and pays the cold-start.
cat > "$OUT/_routes.json" <<'JSON'
{
  "version": 1,
  "include": ["/api/*"],
  "exclude": []
}
JSON
echo "→ wrote _routes.json"

echo "✓ $(find "$OUT" -type f | wc -l | tr -d ' ') files, $(du -sh "$OUT" | cut -f1)"
