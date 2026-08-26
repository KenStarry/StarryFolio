# 9. Cookbook

Recipes for the changes you will actually make. Every one ends with a verification step,
because in a static site a green build does not prove the content shipped.

---

## Add a project

Edit `lib/features/projects/data/datasource/projects_local_datasource.dart`:

```dart
ProjectModel(
  slug: 'my-app',                          // becomes /projects/my-app
  name: 'My App',
  tagline: 'One line that says what it does.',
  year: '2026',
  status: ProjectStatus.shipped,
  gradient: 'from-sky-400/25 to-star-400/10',   // literal Tailwind classes
  stack: ['Flutter', 'Riverpod', 'Firebase'],
  summary: [
    'A paragraph on what it is and who it is for.',
    'A paragraph on what was hard.',
  ],
  highlights: [
    'Something specific you built',
    'A constraint you designed around',
  ],
  repoUrl: 'https://github.com/KenStarry/MyApp',
  // liveUrl, storeUrl, coverImage are optional
),
```

That is the whole change. You get: a card on the home page, a card on `/projects`, a
pre-rendered `/projects/my-app` page, `CreativeWork` + breadcrumb JSON-LD, and a sitemap
entry.

```bash
jaspr build --sitemap-domain https://kenstarry.com --sitemap-exclude '^/404'
ls build/jaspr/projects/my-app/index.html
grep -c "<h1" build/jaspr/projects/my-app/index.html    # 1
```

**Order matters** — the list is display order, and `getFeaturedProjects()` takes the first
three for the home page.

---

## Update your bio, socials or toolkit

All of it is in `lib/core/config/site_config.dart`. One edit propagates to the page copy,
the `<title>`, the meta description, the Open Graph tags **and** the `Person` JSON-LD —
they cannot drift apart.

Adding a social link also adds a `sameAs` entry to the structured data and a `rel="me"` link
in the footer and contact section.

---

## Add a page

1. **Path** — `lib/core/routing/route_paths.dart`:
   ```dart
   static const String uses = '/uses';
   ```

2. **Page** — `lib/features/uses/presentation/pages/uses_page.dart`. Stateless if it needs no
   data:
   ```dart
   class UsesPage extends StatelessComponent {
     const UsesPage({super.key});

     @override
     Component build(BuildContext context) {
       return Component.fragment([
         const PageMeta(
           path: RoutePaths.uses,
           title: 'Uses — ${SiteConfig.name}',
           description: 'The hardware, editor and tools behind the work.',
         ),
         SectionBlock(
           eyebrow: 'Setup',
           heading: 'What I use',
           isPageHeading: true,          // this section IS the page -> <h1>
           children: [ /* … */ ],
         ),
       ]);
     }
   }
   ```

3. **Route** — `lib/app.dart`:
   ```dart
   Route(
     path: RoutePaths.uses,
     title: 'Uses — ${SiteConfig.name}',
     builder: (context, state) => const AppLayout(child: UsesPage()),
   ),
   ```

4. **Verify** — `build/jaspr/uses/index.html` exists, has one `<h1>`, one canonical, and
   appears in `sitemap.xml`.

Add it to `_links` in `core/presentation/components/nav/nav_bar.dart` if it belongs in the nav.

---

## Add a page that loads data

Extend `AsyncStatelessComponent` and `fold` both branches:

```dart
class PostsPage extends AsyncStatelessComponent {
  const PostsPage({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    final result = await Locator.posts.getPosts();

    return result.fold(
      (error) => Component.fragment([
        const _Meta(),
        SectionBlock(heading: 'Writing', isPageHeading: true,
                     children: [ErrorNotice(message: error)]),
      ]),
      (posts) => Component.fragment([
        const _Meta(),
        SectionBlock(heading: 'Writing', isPageHeading: true, children: [
          div([for (final post in posts) PostCard(post: post)]),
        ]),
      ]),
    );
  }
}
```

**Never** reach for `context.watch(someFutureProvider)` here — see
[doc 2](./02-rendering-and-hydration.md). It compiles, it looks right in the browser, and it
ships a spinner to Google.

The error branch must render a real page. It is baked into a file; an empty branch bakes an
empty page.

---

## Add a whole feature

Following `features/projects/` as the template:

```
features/<name>/
├── domain/
│   ├── model/<name>_model.dart            immutable + defensive fromMap
│   ├── enum/<name>_status.dart            if needed, with fromName(orElse:)
│   └── repository/<name>_repository.dart  abstract, Future<Either<String, T>>
├── data/
│   ├── datasource/<name>_local_datasource.dart
│   └── repository/
│       ├── <name>_repository_impl.dart
│       └── <name>_mock_repository.dart
└── presentation/
    ├── pages/<name>_page.dart             AsyncStatelessComponent
    └── components/<name>_card.dart
```

Then register it in `core/di/locator.dart`:

```dart
static PostsRepository posts = const PostsRepositoryImpl();
```

...and add the route. Shared components go in `core/presentation/components/` once used twice.

---

## Switch to real API data

The layering exists for this. Nothing in `presentation/` changes.

1. `dart pub add dio`
2. Write `data/datasource/projects_remote_datasource.dart` using Dio.
3. Write a new impl against the **same** interface:
   ```dart
   class ProjectsApiRepository implements ProjectsRepository {
     ProjectsApiRepository(this._dio);
     final Dio _dio;

     @override
     Future<Either<String, List<ProjectModel>>> getProjects() async {
       try {
         final res = await _dio.get('/projects');
         final list = res.data['data'] as List<dynamic>? ?? [];
         return Right(list.map((e) => ProjectModel.fromMap(e)).toList());
       } catch (e) {
         return Left(_parseError(e));
       }
     }
     // …
   }
   ```
4. Point the locator at it.
5. Give the router a slug list — static generation still needs every URL synchronously, at
   build time. For a static site that means fetching the list during the build; if content
   changes without a rebuild, switch `mode: server`.

---

## Test against mock data

```dart
// core/di/locator.dart
static ProjectsRepository projects = const ProjectsMockRepository();
```

Canned data behind an 800ms delay — useful for checking loading and error paths. Revert
before committing, or call `Locator.reset()`.

To see the error branch, make the mock return a `Left`.

---

## Add interactivity

If it fits in the nav, add it inside the existing island. Otherwise:

1. Controller in `core/state/controllers/`:
   ```dart
   @riverpod
   class SearchController extends _$SearchController {
     @override
     String build() => '';
     void update(String q) => state = q;
   }
   ```
2. `dart run build_runner build --delete-conflicting-outputs`
3. Outermost interactive component gets `@client` **and its own `ProviderScope`**:
   ```dart
   @client
   class SearchBox extends StatelessComponent {
     @override
     Component build(BuildContext context) =>
         const ProviderScope(child: _SearchBoxView());
   }
   ```
4. Children read with `context.watch` / `context.read`. **No nested `@client`.**
5. Guard browser APIs with `kIsWeb` — islands pre-render too.
6. Rebuild: the island must still render correctly as static markup.

---

## Change the colour scheme

`web/styles.tw.css`, the `@theme` block:

```css
--color-star-400: #f6c85a;   /* change this, the accent moves everywhere */
```

Every `bg-star-400`, `text-star-400`, `border-star-400`, `from-star-400` follows. Never
hardcode a hex in a component.

---

## Change the domain

1. `SiteConfig.siteUrl` and `SiteConfig.domain`
2. `--sitemap-domain` in `netlify.toml` **and** `README.md`
3. `web/robots.txt`

Canonical URLs, OG tags and JSON-LD all derive from `SiteConfig.absolute()`, so they follow.

---

## Debug something that renders locally but not in the build

```bash
jaspr build --sitemap-domain https://kenstarry.com --sitemap-exclude '^/404'
grep "your content" build/jaspr/index.html
```

Missing? Work down this list:

1. Is the component behind an async provider read? → convert to `AsyncStatelessComponent` +
   repository.
2. Is a Tailwind class built by string concatenation? → make it a literal.
3. Is a browser API called without a `kIsWeb` guard?
4. `rm -rf .dart_tool/build` and rebuild.

---

## Quick reference

| Task | File |
|---|---|
| Add/edit a project | `features/projects/data/datasource/projects_local_datasource.dart` |
| Bio, socials, stats, toolkit | `core/config/site_config.dart` |
| Colours, fonts, easing | `web/styles.tw.css` |
| Add a route | `core/routing/route_paths.dart` + `app.dart` |
| Nav links | `core/presentation/components/nav/nav_bar.dart` |
| Footer | `core/presentation/components/site_footer.dart` |
| Per-page SEO tags | `core/seo/page_meta.dart` |
| JSON-LD | `core/seo/structured_data.dart` |
| Swap a repository | `core/di/locator.dart` |
| Site-wide `<head>` | `main.server.dart` |
