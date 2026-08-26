# 7. Architecture

Feature-based clean architecture, adapted where Jaspr's constraints demanded it.

## The tree

```
lib/
├── app.dart                      route table
├── main.server.dart              <html> document, site-wide head, theme boot script
├── main.client.dart              hydration entrypoint
│
├── core/                         shared by 2+ features
│   ├── config/site_config.dart   build-time identity
│   ├── di/locator.dart           composition root
│   ├── domain/model/             shared models (SocialLink)
│   ├── presentation/components/  AppLayout, SectionBlock, SiteFooter, AppIcons, ErrorNotice
│   │   └── nav/                  NavBar (the island) + ThemeToggle
│   ├── routing/route_paths.dart  every path
│   ├── seo/                      PageMeta + StructuredData
│   └── state/controllers/        @riverpod controllers
│
└── features/
    ├── home/         presentation/{pages,components}
    ├── projects/     domain/ · data/ · presentation/
    └── not_found/    presentation/pages
```

**Core vs feature:** content-agnostic goes in `core/`; domain-specific stays in the feature.
Promote to `core/` once something is used in two places — not before.

## Layers

```
presentation  ──depends on──>  domain  <──implements──  data
```

- **domain** — models, enums, and the *abstract* repository. Knows nothing about HTTP, JSON,
  or where data lives.
- **data** — datasources and repository implementations. Depends on domain.
- **presentation** — pages and components. Depends on the **abstract** repository only,
  never on `*_impl`.

The point is that presentation cannot tell where data came from. Swapping a local list for
an HTTP call touches `data/` and nothing else.

## Walkthrough: the projects feature

Every layer, top to bottom.

### `domain/enum/project_status.dart`

```dart
enum ProjectStatus {
  shipped('Shipped', 'bg-emerald-500/15 text-emerald-600 dark:text-emerald-400'),
  building('Building', 'bg-star-400/15 text-star-500 dark:text-star-300'),
  archived('Archived', 'bg-ink-500/15 text-ink-500 dark:text-ink-300');

  const ProjectStatus(this.label, this.classes);
  final String label;
  final String classes;

  static ProjectStatus fromName(String? value) =>
      values.firstWhere((s) => s.name == value, orElse: () => ProjectStatus.building);
}
```

`fromName` has an `orElse` so an unknown status from a future API degrades instead of
throwing. Full Tailwind class strings, for the reason in [doc 4](./04-styling-with-tailwind.md).

### `domain/model/project_model.dart`

Immutable, with `fromMap` / `toMap` / value equality on `slug`. `fromMap` parses defensively:

```dart
factory ProjectModel.fromMap(Map<String, dynamic> map) => ProjectModel(
      slug: map['slug']?.toString() ?? '',
      status: ProjectStatus.fromName(map['status']?.toString()),
      stack: _stringList(map['stack']),
      // …
    );
```

Nothing consumes `fromMap` today — the data is `const`. It exists so the model is already
API-ready, and so the shape of the wire format is decided now rather than under pressure.

### `domain/repository/projects_repository.dart`

The contract:

```dart
abstract class ProjectsRepository {
  Future<Either<String, List<ProjectModel>>> getProjects();
  Future<Either<String, ProjectModel>> getProject(String slug);
  Future<Either<String, List<ProjectModel>>> getFeaturedProjects({int limit = 3});
}
```

`Either<String, T>` (from **fpdart**) makes failure part of the return type. `Left` is a
message ready to render; `Right` is the data. No exceptions to forget to catch — the compiler
makes you handle both via `fold`.

> `dartz` is the usual choice for this and **cannot be used here**: its constraint caps at
> Dart `<3.0.0` and this project is on 3.12. `fpdart` is the modern equivalent.

Async even though today's data is synchronous. That is the whole point — the signature
already matches what an HTTP implementation needs, so pages never change.

### `data/datasource/projects_local_datasource.dart`

The content, as compile-time constants. **This is the file you edit to add a project.**

```dart
abstract final class ProjectsLocalDatasource {
  static const List<ProjectModel> projects = [ /* … */ ];

  /// Consumed by the router to pre-render one static page per project.
  static List<String> get slugs => projects.map((p) => p.slug).toList(growable: false);
}
```

`slugs` is the one synchronous escape hatch, for the reason in [doc 3](./03-routing.md):
static generation must enumerate URLs before any `await` is possible.

### `data/repository/projects_repository_impl.dart`

```dart
class ProjectsRepositoryImpl implements ProjectsRepository {
  const ProjectsRepositoryImpl();

  @override
  Future<Either<String, ProjectModel>> getProject(String slug) async {
    final match =
        ProjectsLocalDatasource.projects.where((p) => p.slug == slug).firstOrNull;
    if (match == null) return Left('No project found for "$slug".');
    return Right(match);
  }
  // …
}
```

There is also a `ProjectsMockRepository` — canned data behind an artificial delay, for
exercising loading and error states. Not wired up by default; swap it in at the locator.

### `presentation/pages/projects_page.dart`

```dart
class ProjectsPage extends AsyncStatelessComponent {
  @override
  Future<Component> build(BuildContext context) async {
    final result = await Locator.projects.getProjects();

    return result.fold(
      (error) => Component.fragment([
        const _Meta(),
        SectionBlock(heading: 'Projects', isPageHeading: true,
                     children: [ErrorNotice(message: error)]),
      ]),
      (projects) => Component.fragment([
        const _Meta(),
        StructuredData(id: 'ld-projects', SchemaOrg.itemList(…)),
        SectionBlock(heading: 'Projects', isPageHeading: true, children: [
          div(classes: 'grid gap-6 sm:grid-cols-2 lg:grid-cols-3',
              [for (final p in projects) ProjectCard(project: p)]),
        ]),
      ]),
    );
  }
}
```

**Both branches render a real page.** The error branch keeps the heading, the meta tags and
the layout — a data failure produces a styled page, never a blank one. Since this is
pre-rendered, an empty error branch would bake an empty page into the build output.

## Dependency injection

`core/di/locator.dart`:

```dart
abstract final class Locator {
  static ProjectsRepository projects = const ProjectsRepositoryImpl();

  static void reset() {
    projects = const ProjectsRepositoryImpl();
  }
}
```

Twenty lines, no package. Riverpod would normally own this — and cannot, because provider
reads are illegal in `AsyncStatelessComponent`. Fields are mutable so a test, or a UI session
against the mock, can swap an implementation in one line:

```dart
Locator.projects = const ProjectsMockRepository();
```

If bindings multiply, `get_it` slots in behind the same call sites.

## Data flow, end to end

```
ProjectsLocalDatasource   const list
        │
ProjectsRepositoryImpl    wraps it in Future<Either<…>>
        │
Locator.projects          picks the implementation
        │
ProjectsPage              await + fold           ← AsyncStatelessComponent
        │
ProjectCard               presentation
        │
build/jaspr/projects/index.html                  ← what a crawler reads
```

To move to a CMS: write `ProjectsRemoteDatasource` with Dio, a new `ProjectsRepositoryImpl`,
point `Locator.projects` at it, and feed the router a slug list. **No page changes.**

## Where the Flutter spec was bent

Against `~/.claude/flutter_architecture_spec.md`:

| Spec | Here | Why |
|---|---|---|
| Riverpod everywhere | Client islands only | Cannot resolve during pre-render — kills SEO |
| `ConsumerWidget` + `ref` | `context.watch/read` | `jaspr_riverpod` has no `WidgetRef` |
| `dartz` | `fpdart` | `dartz` caps at Dart `<3.0.0` |
| `go_router` | `jaspr_router` | Jaspr's own; drives static page enumeration |
| `get_it` + Riverpod DI | `core/di/locator.dart` | Providers unreachable in the content path |
| `dio` | none yet | No network calls; slots in behind the repository unchanged |
| `ThemeExtension<AppColors>` | Tailwind `@theme` | CSS tokens are the web equivalent |
| Hive, secure storage, `flutter_animate`, `JourneyStepper` | n/a | No Flutter runtime |

What survived intact: feature-based modules, three-layer separation, the repository triad,
`Either` error handling, DRY via `core/`, and the naming conventions.

---

Next: [Build toolchain →](./08-build-toolchain.md)
