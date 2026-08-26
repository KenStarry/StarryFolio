import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/di/locator.dart';
import '../../../../core/presentation/components/cta_button.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/presentation/components/jump_nav.dart';
import '../../../../core/presentation/components/section_block.dart';
import '../../../../core/presentation/components/section_rail.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';
import '../../../../core/seo/structured_data.dart';
import '../../domain/model/service_model.dart';
import '../components/service_band.dart';

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

        // `timeline-scope` publishes the bands' timeline names to this
        // element's subtree only, so the fixed rail has to live inside the
        // same wrapper as the bands rather than beside it.
        div(
          classes: 'rail-scope',
          [
            for (final (i, service) in services.indexed)
              ServiceBand(
                service: service,
                index: i + 1,
                reversed: i.isOdd,
                raised: i.isEven,
                timeline: i < SectionRail.maxTracked ? 'tl-${i + 1}' : '',
              ),
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

/// Page header. Owns the `<h1>`, and carries the jump pills.
class _Header extends StatelessComponent {
  const _Header({required this.services});

  final List<ServiceModel> services;

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'bg-ink-900 pb-16 pt-16 sm:pb-20 sm:pt-24',
      [
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            const div(
              classes: 'reveal max-w-2xl',
              [
                Eyebrow('Services'),
                h1(
                  classes: 'type-section mt-5 font-display font-extrabold '
                      'text-ink-100',
                  [
                    Component.text('What I build,'),
                    br(),
                    Component.text('and how I work.'),
                  ],
                ),
                p(
                  classes: 'mt-6 max-w-lg text-sm leading-relaxed text-ink-400 '
                      'sm:text-[0.9375rem]',
                  [
                    Component.text(
                      'Six things I get hired for — usually several at once, '
                      'which is the point. One person across design, build and '
                      'release is how the seams disappear.',
                    ),
                  ],
                ),
              ],
            ),
            const div(classes: 'divider mt-12', []),
            div(
              classes: 'mt-8',
              [
                JumpNav(
                  path: RoutePaths.services,
                  label: 'Jump to a service',
                  stops: [
                    for (final item in services)
                      (anchor: item.slug, label: item.plainTitle, count: 0),
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
                      'Most projects are two or three of these at once. Tell me '
                      'what your users keep coming back for and I will tell you '
                      'what it actually takes.',
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
        title: 'Services — ${SiteConfig.name}',
        description: 'Mobile and web development, UI/UX design, desktop apps, '
            'release engineering and consultancy — from a Flutter engineer who '
            'owns the whole surface, design system through store listing.',
      );
}
