# 2. Rendering & hydration

This is the doc that explains why the codebase looks the way it does.

## Three modes

Jaspr projects pick one, in `pubspec.yaml`:

```yaml
jaspr:
  mode: static     # <- this project
```

| Mode | What happens | Output |
|---|---|---|
| `static` | Every route rendered to HTML **at build time** | a folder of `.html` files |
| `server` | HTML rendered **per request** by a Dart server | a running process |
| `client` | No pre-render; the browser builds the DOM (an SPA) | `index.html` + JS |

We use **static**. A portfolio's content changes when you edit the code, not per visitor, so
rendering it once at build time is strictly better: it is faster, it cannot break at 3am, and
it hosts anywhere that serves files.

## What "pre-rendered" means

Run the build and look at what a crawler receives:

```bash
jaspr build --sitemap-domain https://kenstarry.com --sitemap-exclude '^/404'
```

```
build/jaspr/
  index.html                    25 KB   ← the entire home page, as markup
  projects/index.html           15 KB
  projects/flow/index.html      11 KB
  projects/criblynk/index.html  11 KB
  projects/eduflow/index.html   10 KB
  404/index.html                 7 KB
  main.client.dart.js          176 KB   ← only the nav island
  styles.css                    30 KB
  sitemap.xml
```

`index.html` already contains every heading, paragraph and project card as real HTML. Disable
JavaScript and the site still reads perfectly. The 176 KB of JS exists solely to make the
theme toggle and mobile menu work.

## Islands

Most of the page is inert HTML. Interactive pieces are opted in individually with `@client`:

```dart
@client
class NavBar extends StatelessComponent { … }
```

That annotation tells the build to (a) compile this component and its imports to JavaScript
and (b) mark its position in the HTML so the browser can take over that subtree — and only
that subtree. This is the **islands architecture** (Astro popularised the name).

In the generated HTML:

```html
<!--@nav_bar-->
<!--${}-->
<header class="sticky top-0 z-50 …">…</header>
<!--/@nav_bar-->
```

- `<!--@nav_bar-->` … `<!--/@nav_bar-->` bracket the island.
- `<!--${}-->` carries the component's constructor parameters, JSON-encoded. `NavBar` takes
  none, so it is an empty map. Parameters get serialised on the server and decoded on the
  client, which is how props cross the boundary — they must be serialisable, and the build
  generates the codecs.

Note that the island is **still fully rendered in the HTML**. Hydration attaches behaviour to
existing markup; it does not create it. That is why the nav is visible instantly and why the
theme toggle already has the right `aria-label` before any JS runs.

The registry the client uses is generated into `lib/main.client.options.dart`:

```dart
ClientOptions get defaultClientOptions => ClientOptions(
  clients: {
    'nav_bar': ClientLoader((p) => _nav_bar.NavBar(), loader: _nav_bar.loadLibrary),
  },
);
```

One entry. That is the whole interactive surface of the site.

> **Do not nest `@client` inside `@client`.** `ThemeToggle` lives inside `NavBar` and has no
> annotation of its own. Adding one would hydrate it as a *second, independent* root —
> outside the `ProviderScope` that `NavBar` owns — and its provider reads would fail.

## Async pre-rendering, and the trap

Here is the part worth internalising.

A page often needs data before it can render. In static mode that fetch has to finish
**before** the HTML is serialised, or the file gets written without the content.

Jaspr's answer is `AsyncStatelessComponent`:

```dart
class ProjectsPage extends AsyncStatelessComponent {
  @override
  Future<Component> build(BuildContext context) async {
    final result = await Locator.projects.getProjects();
    return result.fold(
      (error)    => /* a real error page */,
      (projects) => /* the grid */,
    );
  }
}
```

The framework awaits `build` before writing the file. Content lands in the HTML. 

### What does not work

The obvious instinct — reach for a Riverpod async provider, like you would in Flutter — is
wrong here, and it fails **silently**. These were measured on this project:

| Attempt | Result |
|---|---|
| `AsyncStatelessComponent` awaiting a repository | ✅ real content in the HTML |
| `context.watch(someFutureProvider)` in a `StatelessComponent` | ❌ ships `AsyncLoading<T>` — a spinner |
| `await context.watch(p.future)` inside `AsyncStatelessComponent` | 💥 `Bad state: context.watch can only be used within the build method` |

The middle row is the dangerous one. The build **succeeds**. The page looks right in a
browser, because the provider resolves after hydration. But the `.html` file on disk contains
a loading state, and that is the only thing a crawler ever sees.

The third row fails because `AsyncStatelessElement.buildAsync` does not set the "currently
building" flag `jaspr_riverpod` checks — and after an `await` you have left the synchronous
build phase regardless. Moving the `watch` before the `await` does not help; it was tried.

**There is no arrangement of Riverpod and async pre-rendering that works.** Hence the rule:

```
Content path  (SEO-critical)          Interaction path  (islands)
────────────────────────────          ───────────────────────────
AsyncStatelessComponent               @client + ProviderScope
  await Locator.<repo>.method()         context.watch / context.read
  result.fold(error, data)              @riverpod controllers
  → pre-rendered into HTML              → hydrates after load
```

Anything reachable from a `Route` builder is the content path. Repositories are resolved
through `core/di/locator.dart` — a plain composition root — precisely because providers are
unreachable there.

## Verifying it yourself

Never trust a green build. After any change to a page, check the artefact:

```bash
jaspr build --sitemap-domain https://kenstarry.com --sitemap-exclude '^/404'

grep -c "Case study" build/jaspr/index.html          # 3 project cards
grep -c "<h1" build/jaspr/projects/index.html        # exactly 1
grep -c "AsyncLoading" build/jaspr/index.html        # must be 0
```

If content renders in the browser but is missing from `build/jaspr/**/*.html`, it is invisible
to search engines and to every link preview. That is a regression regardless of how clean the
code is.

---

Next: [Routing →](./03-routing.md)
