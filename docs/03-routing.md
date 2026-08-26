# 3. Routing

## The route table

One file, `lib/app.dart`, lists every URL the site has. In static mode this list is also the
list of pages that get generated.

```dart
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return Router(
      routes: [
        Route(
          path: RoutePaths.home,
          title: '${SiteConfig.name} — ${SiteConfig.role}',
          builder: (context, state) => const AppLayout(child: HomePage()),
        ),
        Route(
          path: RoutePaths.projects,
          title: 'Projects — ${SiteConfig.name}',
          builder: (context, state) => const AppLayout(child: ProjectsPage()),
        ),
        for (final slug in ProjectsLocalDatasource.slugs)
          Route(
            path: RoutePaths.projectDetail(slug),
            builder: (context, state) => AppLayout(child: ProjectDetailPage(slug: slug)),
          ),
        Route(
          path: RoutePaths.notFound,
          title: 'Not found — ${SiteConfig.name}',
          builder: (context, state) => const AppLayout(child: NotFoundPage()),
        ),
      ],
    );
  }
}
```

`Route` takes:

| Parameter | Purpose |
|---|---|
| `path` | The URL. Supports params: `/projects/:slug` |
| `title` | Sets `<title>`; overrides the one on `Document` |
| `builder` | `(context, state) => Component` |
| `name` | Optional label for `pushNamed` |
| `redirect` | Send this path elsewhere |
| `routes` | Nested child routes |

`state` is a `RouteState` carrying path parameters, query parameters and any `extra` payload.

## Paths live in one place

Every path is a constant in `core/routing/route_paths.dart`:

```dart
class RoutePaths {
  const RoutePaths._();

  static const String home = '/';
  static const String projects = '/projects';
  static const String notFound = '/404';

  static String projectDetail(String slug) => '$projects/$slug';
}
```

This is not ceremony. The same path is needed by the route table, the nav links, the
canonical URL, the breadcrumb JSON-LD and the sitemap. A typo in any one of them produces a
canonical tag pointing at a 404 — the kind of bug that costs rankings and shows up nowhere in
a build log. One constant makes that class of drift impossible.

## Why project routes are enumerated from the datasource

Notice the loop reads `ProjectsLocalDatasource.slugs` **directly**, not through the
repository — the one place in the codebase that reaches past the repository layer.

Static generation has to know the complete list of URLs *before* it can render anything, and
`build` here is synchronous — there is nowhere to `await`. So the slug list must be available
synchronously.

The split is deliberate:

- **Which URLs exist** → the datasource, synchronously, at route-build time.
- **What is on each page** → the repository, asynchronously, inside the page.

`ProjectDetailPage` therefore takes a `slug`, not a resolved model, and does its own lookup:

```dart
Route(
  path: RoutePaths.projectDetail(slug),
  builder: (context, state) => AppLayout(child: ProjectDetailPage(slug: slug)),
)
```

That keeps content out of the route table, and means a future CMS only has to supply a slug
list to the router — everything else already flows through the repository.

## Links

Use `Link` for internal navigation and a plain `a` for external.

```dart
Link(
  to: RoutePaths.projects,
  classes: 'inline-flex items-center gap-2 …',
  children: [const Component.text('See the work'), AppIcons.arrow()],
)
```

`Link` renders a real `<a href="…">` — crawlable, middle-clickable, keyboard accessible —
and additionally intercepts the click on the client to navigate without a full reload. Best
of both.

External links get the plain element plus `rel`:

```dart
a(
  href: social.url,
  target: Target.blank,
  attributes: const {'rel': 'me noopener'},
  [Component.text(social.label)],
)
```

`noopener` is a security requirement with `target="_blank"`. `me` marks the link as an
identity claim, corroborating the `sameAs` entries in the Person JSON-LD — see
[doc 5](./05-seo.md).

Programmatic navigation is available on `context` (`push`, `replace`, `pop`, `pushNamed`),
but it only works inside a hydrated island, so this codebase does not use it.

## URLs to files

```
/                    →  build/jaspr/index.html
/projects            →  build/jaspr/projects/index.html
/projects/flow       →  build/jaspr/projects/flow/index.html
/404                 →  build/jaspr/404/index.html
```

Directory-with-`index.html` means clean URLs with no server rewrites and no trailing-slash
ambiguity.

## The 404

Static hosting cannot "route" an unknown path — the host has to be told what to serve. In
`netlify.toml`:

```toml
[[redirects]]
  from = "/*"
  to = "/404/index.html"
  status = 404
```

Anything unmatched serves the pre-rendered 404 page with a genuine `404` status code, which
matters: a "soft 404" that returns `200` gets the missing page indexed.

The page itself is marked `noindex, follow` and excluded from the sitemap via
`--sitemap-exclude '^/404'`. Listing a `noindex` page in a sitemap is a contradiction that
wastes crawl budget.

## Adding a route

1. Add the path to `RoutePaths`.
2. Add a `Route` to `app.dart`, wrapped in `AppLayout`.
3. Have the page render a `PageMeta` (see [doc 5](./05-seo.md)).
4. Build, and confirm the new `.html` file exists and contains your content.

---

Next: [Styling with Tailwind →](./04-styling-with-tailwind.md)
