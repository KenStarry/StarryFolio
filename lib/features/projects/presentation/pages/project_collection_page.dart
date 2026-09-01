import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/presentation/components/cta_button.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/presentation/components/page_header.dart';
import '../../../../core/presentation/components/section_block.dart';
import '../../../../core/presentation/components/section_rail.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';
import '../../../../core/seo/structured_data.dart';
import '../../domain/enum/project_collection.dart';
import '../../domain/enum/project_status.dart';
import '../../domain/model/project_model.dart';
import '../components/address_chip.dart';
import '../components/collection_tile.dart';
import '../components/design_case.dart';
import '../components/package_feature.dart';
import '../components/project_bento.dart';
import '../components/project_showcase.dart';

/// One collection under Works — `/projects/mobile`, `/projects/design`, …
///
/// ## One page class, four presentations
///
/// The skeleton is shared, because four pages that each invented their own
/// header would be four ideas of what a page is. What differs is how the work
/// is *shown*, and that difference is the point of splitting them at all:
///
/// | Collection | Shown as |
/// |---|---|
/// | `mobile` | a full-width showcase per flagship, then the bento grid |
/// | `web` | the bento grid — no device mockup exists for a portal |
/// | `design` | [DesignCase] bands: problem, system, what shipped |
/// | `packages` | [PackageFeature], leading with the maintenance record |
///
/// A `switch` on the collection rather than a flag per behaviour, so adding a
/// fifth is a compile error until its presentation is decided rather than a
/// silent fall-through to the grid.
///
/// ## Duplication is handled by the copy, not by hiding things
///
/// HealthX appears on `mobile` and on `design`. That is honest — it is both —
/// and the two pages avoid being duplicates because `design` reads from a
/// [ProjectDesign] block that exists nowhere else. The canonical URL of each
/// page is its own, and the case study each links to is the single canonical
/// write-up of the build.
class ProjectCollectionPage extends AsyncStatelessComponent {
  const ProjectCollectionPage({required this.collection, super.key});

  final ProjectCollection collection;

  @override
  Future<Component> build(BuildContext context) async {
    final result = await Locator.projects.getProjects();

    return result.fold(
      (error) => Component.fragment([
        _Meta(collection: collection),
        SectionBlock(
          eyebrow: 'Work',
          heading: collection.label,
          isPageHeading: true,
          children: [ErrorNotice(message: error)],
        ),
      ]),
      (all) {
        final projects = collection.from(all);

        return Component.fragment([
          _Meta(collection: collection),
          if (projects.isNotEmpty)
            StructuredData(
              id: 'ld-collection',
              SchemaOrg.itemList(
                items: [
                  for (final item in projects)
                  (name: item.name, slug: item.slug),
                ],
              ),
            ),
          StructuredData(
            id: 'ld-breadcrumbs',
            SchemaOrg.breadcrumbs([
              (label: 'Home', path: RoutePaths.home),
              (label: 'Work', path: RoutePaths.projects),
              (
                label: collection.label,
                path: RoutePaths.collection(collection.slug),
              ),
            ]),
          ),

          _Header(collection: collection, projects: projects),

          if (projects.isEmpty)
            _Empty(collection: collection)
          else
            _Body(collection: collection, projects: projects),

          _Close(collection: collection),
        ]);
      },
    );
  }
}

/// Page header, on the shared template so all four match the rest of the site.
class _Header extends StatelessComponent {
  const _Header({required this.collection, required this.projects});

  final ProjectCollection collection;
  final List<ProjectModel> projects;

  @override
  Component build(BuildContext context) {
    // Named `item`, not `p`: `p` is the paragraph element helper, and
    // shadowing it inside a build method reads as the element to anyone
    // skimming — the same trap `post_body.dart` hit with `path`.
    final shipped = projects
        .where((item) => item.status == ProjectStatus.shipped)
        .length;
    final platforms = <String>{
      for (final item in projects)
        for (final platform in item.platforms) platform.label,
    };

    return PageHeader(
      trail: collection.label,
      ghost: collection.ghost,
      path: RoutePaths.collection(collection.slug),
      meta: 'Part of the work',
      title: collection.title,
      titleTail: collection.titleTail,
      lead: collection.lead,
      facts: [
        (
          value: projects.length.toString().padLeft(2, '0'),
          label: collection == ProjectCollection.design ? 'Case studies' : 'Projects',
        ),
        (value: shipped.toString().padLeft(2, '0'), label: 'Shipped'),
        (
          value: platforms.length.toString().padLeft(2, '0'),
          label: 'Platforms',
        ),
        (value: '5+', label: 'Years'),
      ],
      actions: const [
        CtaButton(
          label: 'All work',
          href: RoutePaths.projects,
          variant: CtaVariant.outline,
        ),
      ],
      jumpStops: [
          for (final item in projects)
          (anchor: item.slug, label: item.name, count: 0),
      ],
      jumpLabel: 'Jump to a project',
    );
  }
}

/// The work itself, presented the way this collection wants to be read.
class _Body extends StatelessComponent {
  const _Body({required this.collection, required this.projects});

  final ProjectCollection collection;
  final List<ProjectModel> projects;

  @override
  Component build(BuildContext context) {
    return switch (collection) {
      // A design case is an argument, so each one gets a band and the rail
      // tracks them — the same shape `/services` uses for the same reason.
      ProjectCollection.design => div(
          classes: 'rail-scope',
          [
            for (final (i, item) in projects.indexed)
              DesignCase(
                project: item,
                index: i + 1,
                reversed: i.isOdd,
                raised: i.isEven,
                timeline: i < SectionRail.maxTracked ? 'tl-${i + 1}' : '',
              ),
            SectionRail(
              path: RoutePaths.collection(collection.slug),
              stops: [
                for (final item in projects)
                  (anchor: item.slug, label: item.name),
              ],
            ),
          ],
        ),

      // A library has no screenshot worth leading with, so each one is a wide
      // record card rather than a tile in a grid.
      ProjectCollection.packages => section(
          classes: 'bg-ink-900 py-20 sm:py-24',
          [
            div(
              classes: 'mx-auto w-full max-w-6xl space-y-8 px-6 sm:px-8 '
                  'lg:px-12',
              [
                for (final item in projects)
                  PackageFeature(project: item),
              ],
            ),
          ],
        ),

      // Products. A flagship with a device render leads full width; everything
      // else fills the bento. A portal has no mockup, so `web` simply never
      // takes the first branch and the page is a grid — which is correct
      // rather than a fallback.
      ProjectCollection.mobile || ProjectCollection.web => _ProductBody(
          collection: collection,
          projects: projects,
        ),
    };
  }
}

class _ProductBody extends StatelessComponent {
  const _ProductBody({required this.collection, required this.projects});

  final ProjectCollection collection;
  final List<ProjectModel> projects;

  /// Whether [item] has enough substance to carry a full-width band.
  bool _canLead(ProjectModel item) {
    // A showcase is built around a device render and has nothing to draw
    // without one, so this is the floor on every collection.
    if (item.mockupImage == null) return false;

    // On `web` the render alone is enough: there are few enough entries that
    // anything with artwork deserves the full band. Everywhere else it also
    // has to be a portfolio flagship, or the mobile page would open on six
    // consecutive full-width showcases.
    return collection == ProjectCollection.web || item.featured;
  }

  @override
  Component build(BuildContext context) {
    // What leads is decided **by the collection**, not by the global
    // `featured` flag.
    //
    // `featured` means "flagship of the whole portfolio" — it is what the
    // `/projects` index leads with, and borrowing it here would have promoted
    // two web entries onto that page as a side effect of arranging this one.
    // "Worth leading this section" is a different question, so it gets its own
    // answer.
    //
    // The test is whether there is a device render to build the band around,
    // plus how selective the collection needs to be — see [_canLead].
    final showcases = [
      for (final item in projects)
        if (_canLead(item)) item,
    ];
    final rest = [
      for (final item in projects)
        if (!showcases.contains(item)) item,
    ];

    return div(
      classes: 'rail-scope',
      [
        for (final (i, item) in showcases.indexed)
          _ShowcaseBand(
            project: item,
            index: i + 1,
            reversed: i.isOdd,
            raised: i.isEven,
            timeline: i < SectionRail.maxTracked ? 'tl-${i + 1}' : '',
          ),

        if (rest.isNotEmpty)
          section(
            classes: 'relative ${showcases.length.isEven ? 'bg-ink-900' : 'bg-ink-800'} '
                'py-20 sm:py-24',
            [
              div(
                classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
                [
                  Eyebrow(showcases.isEmpty ? collection.label : 'Also'),
                  h2(
                    classes: 'type-section mt-5 max-w-xl font-display '
                        'font-bold text-ink-100',
                    [
                      Component.text(
                        showcases.isEmpty
                            ? 'Everything here'
                            : 'The rest of it',
                      ),
                    ],
                  ),
                  const div(classes: 'divider mt-10', []),
                  div(
                    classes: 'mt-12',
                    [ProjectBento(projects: rest)],
                  ),
                ],
              ),
            ],
          ),

        SectionRail(
          path: RoutePaths.collection(collection.slug),
          stops: [
            for (final item in showcases)
              (anchor: item.slug, label: item.name),
          ],
        ),
      ],
    );
  }
}

/// Shown when a collection resolves to nothing.
///
/// Every collection has entries today, so this is a guard rather than a state
/// anyone will see — but a filter that silently produces a page with a header
/// and no body is the kind of thing that ships unnoticed.
class _Empty extends StatelessComponent {
  const _Empty({required this.collection});

  final ProjectCollection collection;

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'bg-ink-900 py-20 sm:py-24',
      [
        div(
          classes: 'mx-auto w-full max-w-2xl px-6 text-center sm:px-8',
          [
            div(
              classes: 'reveal border border-dashed border-ink-700 px-7 py-12',
              [
                const p(
                  classes: 'font-display text-xl font-bold text-ink-100',
                  [Component.text('Nothing here yet.')],
                ),
                p(
                  classes: 'mx-auto mt-4 max-w-sm text-sm leading-relaxed '
                      'text-ink-400',
                  [
                    Component.text(
                      '${collection.label} has not been written up yet. The '
                      'rest of the work is worth a look in the meantime.',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Closing band, pointing sideways rather than down a dead end.
class _Close extends StatelessComponent {
  const _Close({required this.collection});

  final ProjectCollection collection;

  @override
  Component build(BuildContext context) {
    final others = [
      for (final other in ProjectCollection.values)
        if (other != collection) other,
    ];

    return section(
      classes: 'bg-ink-950 py-20 sm:py-24',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            const Eyebrow('Elsewhere in the work'),
            div(
              classes: 'mt-8 grid gap-4 sm:grid-cols-3',
              [
                for (final other in others)
                  CollectionTile(collection: other),
              ],
            ),
            const div(
              classes: 'reveal mt-12 flex flex-wrap items-center gap-3',
              [
                CtaButton(
                  label: 'Start a project',
                  href: 'mailto:${SiteConfig.email}',
                ),
                CtaButton(
                  label: 'All work',
                  href: RoutePaths.projects,
                  variant: CtaVariant.outline,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _Meta extends StatelessComponent {
  const _Meta({required this.collection});

  final ProjectCollection collection;

  @override
  Component build(BuildContext context) => PageMeta(
        path: RoutePaths.collection(collection.slug),
        title: '${collection.label} · ${SiteConfig.name}',
        description: collection.lead,
      );
}

/// A flagship, full width, with the device render doing the talking.
///
/// ## The header says what the showcase cannot
///
/// This band used to print the project name at section scale and its tagline
/// underneath — and then [ProjectShowcase] printed the same name and the same
/// tagline again, a few pixels below. Two headings, identical words, one on
/// top of the other.
///
/// The fix is not to delete one. A band needs a header, and the showcase needs
/// its own title. What was missing was a *reason* for the header to exist, so
/// it now leads with the one fact neither the name nor the tagline carries:
/// what field the thing is in. `Healthcare`, then HealthX. `Music`, then Flow.
/// A reader scanning the page gets the shape of the work from the headers
/// alone, which is what a header is for.
///
/// Where a project has no `domain` the band falls back to its platform line,
/// so the header is never empty and never a repeat.
class _ShowcaseBand extends StatelessComponent {
  const _ShowcaseBand({
    required this.project,
    required this.index,
    required this.reversed,
    required this.raised,
    required this.timeline,
  });

  final ProjectModel project;
  final int index;
  final bool reversed;
  final bool raised;

  /// `tl-N` utility naming this band's view-timeline, which the matching rail
  /// dot animates on.
  final String timeline;

  @override
  Component build(BuildContext context) {
    final number = index.toString().padLeft(2, '0');
    final platforms = project.platforms.map((item) => item.label).join(' · ');

    // The domain set at display scale is the header; the name is not repeated
    // here because the showcase directly below sets it as its own heading.
    final headline =
        project.domain.isNotEmpty ? project.domain : project.name;

    return section(
      id: project.slug,
      classes: '$timeline relative scroll-mt-24 '
          '${raised ? 'bg-ink-800' : 'bg-ink-900'} py-20 sm:py-28',
      [
        div(
          classes: 'relative mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            // The live address, above the title. It is the one label that
            // proves the thing is running rather than written about, so it
            // leads the band where a project has one.
            if (project.live case final live?)
              div(
                classes: 'reveal mb-5',
                [
                  AddressChip(
                    url: live.display,
                    href: live.href,
                    label: project.name,
                  ),
                ],
              ),

            div(
              classes: 'reveal flex flex-wrap items-baseline gap-x-5 gap-y-3',
              [
                span(
                  classes: 'type-eyebrow font-mono text-ink-500',
                  [Component.text(number)],
                ),

                // `<h2>` because it is the band's real heading — the showcase
                // inside sets the project name as an `<h3>`, so the outline
                // reads domain → project rather than two peers.
                h2(
                  classes: 'type-section font-display font-extrabold '
                      'text-ink-100',
                  [Component.text(headline)],
                ),

                if (platforms.isNotEmpty)
                  span(
                    classes: 'type-eyebrow font-mono text-iris-400',
                    [Component.text(platforms)],
                  ),
              ],
            ),

            div(
              classes: 'mt-12',
              [ProjectShowcase(project: project, reversed: reversed)],
            ),
          ],
        ),
      ],
    );
  }
}
