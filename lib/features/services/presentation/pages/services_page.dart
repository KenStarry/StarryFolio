import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/presentation/components/cta_button.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/page_header.dart';
import '../../../../core/presentation/components/section_block.dart';
import '../../../../core/presentation/components/section_rail.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';
import '../../../../core/seo/structured_data.dart';
import '../../../projects/domain/enum/project_collection.dart';
import '../../../projects/domain/model/project_model.dart';
import '../../domain/model/service_model.dart';
import '../components/service_band.dart';
import '../components/service_index.dart';

/// The services index.
///
/// An [AsyncStatelessComponent] so the repository is awaited *during*
/// pre-rendering — the generated HTML contains every band. Reaching for a
/// Riverpod async provider here instead would ship a loading state to crawlers.
///
/// Structurally a sibling of `/projects` without being a copy of it: same band
/// rhythm, jump pills and section rail, but a service has no screenshot, so
/// each band is anchored by a ghosted numeral and a deliverables panel rather
/// than a device mockup. Every band carries its own call to action.
class ServicesPage extends AsyncStatelessComponent {
  const ServicesPage({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    final result = await Locator.services.getServices();

    // Resolved here rather than in the band: a service names its collection by
    // slug so the services domain never imports the projects one, and this is
    // the one place that knows about both. Two examples per band — the point
    // is a glimpse, and a third would start competing with the deliverables.
    final projects = (await Locator.projects.getProjects())
        .getOrElse((_) => const []);

    return result.fold(
      (error) => Component.fragment([
        const _Meta(),
        SectionBlock(
          eyebrow: 'Services',
          heading: 'Services',
          isPageHeading: true,
          children: [ErrorNotice(message: error)],
        ),
      ]),
      (services) => Component.fragment([
        const _Meta(),
        StructuredData(
          id: 'ld-services',
          SchemaOrg.serviceList(
            items: [
              for (final item in services)
                (name: item.plainTitle, description: item.blurb, slug: item.slug),
            ],
          ),
        ),
        StructuredData(
          id: 'ld-breadcrumbs',
          SchemaOrg.breadcrumbs(const [
            (label: 'Home', path: RoutePaths.home),
            (label: 'Services', path: RoutePaths.services),
          ]),
        ),

        _Header(services: services),
        _Index(services: services),

        // `timeline-scope` publishes the bands' timeline names to this
        // element's subtree only, so the fixed rail has to live inside the
        // same wrapper as the bands rather than beside it.
        div(
          classes: 'rail-scope',
          [
            for (final band in _bands(services, projects)) band,

            SectionRail(
              path: RoutePaths.services,
              stops: [
                for (final item in services)
                  (anchor: item.slug, label: item.plainTitle),
              ],
            ),
          ],
        ),

        const _Close(),
      ]),
    );
  }
}

/// Page header, on the shared [PageHeader] template.
class _Header extends StatelessComponent {
  const _Header({required this.services});

  final List<ServiceModel> services;

  @override
  Component build(BuildContext context) {
    return PageHeader(
      trail: 'Services',
      ghost: 'Services',
      path: RoutePaths.services,
      meta: SiteConfig.availabilityLabel,
      title: 'What I build,',
      titleTail: 'and how I work.',
      lead: 'Six things people hire me for, usually several at once, which '
          'is sort of the whole point. One person across design, build and '
          'release means nothing gets lost in the handover, mostly because '
          'there is not one.',
      facts: [
        (
          value: services.length.toString().padLeft(2, '0'),
          label: 'Services',
        ),
        (value: '5+', label: 'Years shipping'),
        (value: '02', label: 'App stores'),
        (value: '100%', label: 'Of the stack owned'),
      ],
    );
  }
}

/// Builds one band per service, resolving each one's collection into the two
/// examples it shows and the link through to the rest.
///
/// A free function rather than an inline `Builder`: Jaspr's takes a
/// `Component Function(BuildContext)`, so a generator body does not fit, and
/// the work here is pure data anyway — no context involved.
List<Component> _bands(
  List<ServiceModel> services,
  List<ProjectModel> projects,
) {
  // Collections overlap by design — HealthX is mobile *and* design — so
  // taking the first two of each would print the same pair of cards twice on
  // one page and read as a bug rather than as breadth. Preferring what has not
  // been shown yet spreads the work across the bands, and falling back keeps
  // every strip at two rather than leaving a half-empty grid.
  final shown = <String>{};

  return [
    for (final (i, service) in services.indexed)
      () {
        final collection = ProjectCollection.fromSlug(service.collectionSlug);
        final all = collection?.from(projects) ?? const <ProjectModel>[];

        // Only entries carrying artwork: `ProjectMiniCard` falls back to a
        // letter without one, and two lettered tiles under a heading that
        // promises shipped work is a worse answer than showing nothing.
        final withArt = [
          for (final item in all)
            if (item.mockupImage != null || item.coverImage != null) item,
        ];
        final picked = <ProjectModel>[
          for (final item in withArt)
            if (!shown.contains(item.slug)) item,
        ].take(2).toList();
        for (final item in withArt) {
          if (picked.length >= 2) break;
          if (!picked.contains(item)) picked.add(item);
        }
        shown.addAll(picked.map((item) => item.slug));

        return ServiceBand(
          service: service,
          index: i + 1,
          raised: i.isEven,
          timeline: i < SectionRail.maxTracked ? 'tl-${i + 1}' : '',
          work: picked,
          collectionPath: collection == null
              ? ''
              : RoutePaths.collection(collection.slug),
          collectionLabel: collection?.collective ?? '',
          collectionCount: all.length,
        );
      }(),
  ];
}

/// The capability index, between the header and the bands.
///
/// It replaced the header's jump pills. Those carried a label and nothing
/// else, so a reader had to scroll six full-width bands to learn what any of
/// them meant; these rows carry the blurb that was already written, so the
/// whole offering is legible before the first band. They still anchor down the
/// page, so nothing was lost by dropping the pills.
class _Index extends StatelessComponent {
  const _Index({required this.services});

  final List<ServiceModel> services;

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'bg-ink-900 pb-16 sm:pb-20',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            const p(
              classes: 'type-eyebrow reveal font-mono text-ink-500',
              [Component.text('The whole list')],
            ),
            div(
              classes: 'mt-6',
              [ServiceIndex(services: services)],
            ),
          ],
        ),
      ],
    );
  }
}

/// Closing band, for readers who got here without a specific service in mind.
class _Close extends StatelessComponent {
  const _Close();

  @override
  Component build(BuildContext context) {
    return const section(
      classes: 'bg-ink-950 py-20 sm:py-28',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 text-center sm:px-8 lg:px-12',
          [
            div(
              classes: 'reveal mx-auto max-w-xl',
              [
                h2(
                  classes: 'type-section font-display font-bold text-ink-100',
                  [Component.text('Not sure which one you need?')],
                ),
                p(
                  classes: 'mx-auto mt-6 max-w-md text-sm leading-relaxed '
                      'text-ink-400',
                  [
                    Component.text(
                      'Most projects are two or three of these at once, and '
                      'the boundaries matter less than you think. Tell me what '
                      'your users keep coming back for and I will tell you '
                      'what it actually takes, including the parts you were '
                      'hoping to skip.',
                    ),
                  ],
                ),
              ],
            ),
            div(
              classes: 'reveal mt-10 flex flex-wrap justify-center gap-3',
              [
                CtaButton(
                  label: 'Start a project',
                  href: 'mailto:${SiteConfig.email}',
                ),
                CtaButton(
                  label: 'See the work',
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
  const _Meta();

  @override
  Component build(BuildContext context) => const PageMeta(
        path: RoutePaths.services,
        title: 'Flutter App Development Services in Kenya · '
            '${SiteConfig.name}',
        description: 'Hire a Flutter developer in Kenya for mobile and web '
            'apps, UI/UX design, desktop builds and release engineering. One '
            'engineer owning the whole surface, design system to store listing.',
      );
}
