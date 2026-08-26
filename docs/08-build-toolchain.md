# 8. Build toolchain

Everything between source and deployed site — plus the failures that cost real time on this
project, so they cost you none.

## Setup on a fresh machine

Three things must be on `PATH`:

```bash
# 1. a real Dart SDK (not a Flutter wrapper — see below)
export PATH="$(dirname $(which flutter))/cache/dart-sdk/bin:$PATH"

# 2. the Jaspr CLI
dart pub global activate jaspr_cli
export PATH="$PATH:$HOME/.pub-cache/bin"

# 3. the standalone Tailwind CLI
curl -sLo ~/.local/bin/tailwindcss \
  https://github.com/tailwindlabs/tailwindcss/releases/download/v4.3.3/tailwindcss-macos-arm64
chmod +x ~/.local/bin/tailwindcss
export PATH="$PATH:$HOME/.local/bin"

dart pub get
```

Put the exports in `~/.zshrc`. On Linux, swap `tailwindcss-macos-arm64` for
`tailwindcss-linux-x64`.

## Daily commands

```bash
jaspr serve                        # localhost:8080, hot reload
dart analyze                       # must be clean
dart run build_runner build --delete-conflicting-outputs
jaspr build --sitemap-domain https://kenstarry.com --sitemap-exclude '^/404'
```

`jaspr serve` runs codegen in watch mode, so you rarely invoke `build_runner` by hand — only
after adding a `@riverpod` controller if the watcher missed it.

## What the build actually does

```
lib/**/*.dart
   │
   ├─ jaspr_builder ──────> *.g.dart, main.{server,client}.options.dart, island registry
   ├─ riverpod_generator ─> *_controller.g.dart
   ├─ jaspr_tailwind ─────> web/styles.css   (shells out to `tailwindcss`)
   └─ build_web_compilers > main.client.dart.js   (dart2js, release)
                    │
              jaspr renders every route
                    │
              build/jaspr/**/*.html + sitemap.xml
```

Roughly 20 seconds cold, a few seconds warm.

## Version pins — read before bumping

### `build_web_compilers: >=4.4.19 <4.5.0`

This is load-bearing and the constraint is deliberate.

It compiles the `@client` components to JavaScript. **Without it in `pubspec.yaml` at all**,
no `main.client.dart.js` is emitted, the `<script>` tag 404s, and the site renders perfectly
but never hydrates — the theme toggle and mobile menu become dead buttons. Nothing in the
build output says so. That was the original state of this project.

Adding it unpinned hits the other wall:

```
Builders build_web_compilers:module_library and build_modules:module_library
outputs collide: package:collection/collection.module.library
```

From 4.5.0 it inlines the `build_modules` builders, which collide with the copy
`jaspr_tailwind` pulls in. 4.4.19 is the last version using the external package.

**Unpin only once `jaspr_tailwind` drops its `build_modules` dependency.** After any change
here, confirm the bundle still exists:

```bash
ls -l build/jaspr/main.client.dart.js    # expect ~176 KB
```

### `dartz` is unusable

Its constraint caps at Dart `<3.0.0`; this project is on 3.12. `fpdart` provides `Either`.

## Failures you will hit

### "failed to verify the surrounding Dart SDK"

```
Found Dart executable at "/opt/homebrew/bin/dart", but failed to verify
the surrounding Dart SDK.
```

`which dart` resolves to a Flutter *wrapper*, not a real SDK directory. The Jaspr CLI checks
for a `version` file next to `bin/` and gives up. Fix with export #1 above.

### `PathNotFoundException: …/web/styles.css`

The `tailwindcss` binary is not on `PATH`. `jaspr_tailwind` shells out to it and **discards
its stderr**, so a missing CLI surfaces only as a missing output file. Fix with export #3.

### A build that fails impossibly

`build_runner` caches enough state to keep replaying an error you already fixed. When the
failure makes no sense:

```bash
rm -rf .dart_tool/build
```

This genuinely happened during this project's setup — a fixed Tailwind error kept reappearing
until the cache was cleared.

### Tailwind classes silently missing

Tailwind v4 auto-detects source files **relative to the current working directory** —
verified: run it with `cwd` at the project root and you get 36 KB of CSS; run it from
elsewhere and you get 8 KB of baseline with none of your utilities. `build_runner` runs from
the project root, which is why this works at all. Also confirmed: it does read `.dart` files,
including arbitrary values like `tracking-[0.18em]`.

The corollary is [doc 4](./04-styling-with-tailwind.md)'s rule — classes must be literals in
the source.

### Everything renders but nothing is interactive

The client bundle is missing or 404ing. Check `main.client.dart.js` exists in the build
output and that `build_web_compilers` is still in `pubspec.yaml`.

## Deploying

`netlify.toml` installs both toolchains, because Netlify's image ships neither Dart nor
Tailwind:

```toml
[build]
  publish = "build/jaspr"
  command = """
    set -e
    curl -sL https://storage.googleapis.com/dart-archive/channels/stable/release/$DART_VERSION/sdk/dartsdk-linux-x64-release.zip -o dart.zip
    unzip -q dart.zip -d "$HOME"
    curl -sL https://github.com/tailwindlabs/tailwindcss/releases/download/v$TAILWIND_VERSION/tailwindcss-linux-x64 -o "$HOME/tailwindcss"
    chmod +x "$HOME/tailwindcss"
    export PATH="$HOME/dart-sdk/bin:$HOME:$PATH"
    dart pub global activate jaspr_cli
    export PATH="$PATH:$HOME/.pub-cache/bin"
    jaspr build --sitemap-domain https://kenstarry.com --sitemap-exclude '^/404'
  """

[build.environment]
  DART_VERSION = "3.12.2"
  TAILWIND_VERSION = "4.3.3"

[[redirects]]
  from = "/*"
  to = "/404/index.html"
  status = 404
```

Versions are pinned rather than tracking `latest`, so a deploy cannot break because an
upstream release changed. The `set -e` matters — without it a failed download would let the
build continue and publish a site with no CSS.

> **Not yet verified against Netlify's real build image.** The logic is sound and the pinned
> URLs resolve, but this has not run in CI. Do a test deploy before trusting it.

The output is plain files, so Cloudflare Pages, Vercel and GitHub Pages all work too —
publish `build/jaspr` and replicate the 404 rule.

## Before you push

```bash
dart analyze                                            # No issues found!
jaspr build --sitemap-domain https://kenstarry.com --sitemap-exclude '^/404'

grep -c "Case study" build/jaspr/index.html             # 3
grep -c "<h1" build/jaspr/projects/index.html           # 1
ls -l build/jaspr/main.client.dart.js                   # exists
grep -o '<loc>[^<]*' build/jaspr/sitemap.xml            # no /404
```

---

Next: [Cookbook →](./09-cookbook.md)
