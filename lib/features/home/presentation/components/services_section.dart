import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/presentation/components/error_notice.dart';
import '../../../../core/presentation/components/section_block.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../services/domain/model/service_model.dart';
import '../../../services/presentation/components/service_card.dart';

/// Home overview of the services — a teaser for `/services`.
///
/// Mirrors the structure of the work section rather than inventing a third
/// layout: three cards and a tile through to the full page. The remaining
/// offerings are named in that tile rather than hidden behind a count, since
/// "Web · Desktop · Consultancy" tells a visitor more than "03 more" does when
/// the items are capabilities rather than case studies.
///
/// Receives already-resolved services rather than fetching: the home page owns
/// its awaits, so the whole page renders in one pass.
class ServicesSection extends StatelessComponent {
  const ServicesSection({
    required this.services,
    this.error,
    super.key,
  });

  final List<ServiceModel> services;

  /// Set when the repository returned a `Left`. Renders a real block instead of
  /// silently dropping the section out of the page.
  final String? error;

  @override
  Component build(BuildContext context) {
    final shown = services.take(3).toList(growable: false);
    final rest = services.skip(3).toList(growable: false);

    return SectionBlock(
      id: 'services',
      eyebrow: 'Services',
      heading: 'What I do,\nand how deep.',
      tone: SectionTone.raised,
      lead: 'Six things I get hired for — usually several at once, which is '
          'the point. One person across design, build and release is how the '
          'seams disappear.',
      children: [
        if (error != null)
          ErrorNotice(message: error!)
        else ...[
          div(
            classes: 'grid gap-5 md:grid-cols-3',
            [
              for (final (i, service) in shown.indexed)
                ServiceCard(service: service, index: i),
            ],
          ),
          if (rest.isNotEmpty) _moreTile(rest),
        ],
      ],
    );
  }

  /// The link through to the full page, naming what is not shown above.
  static Component _moreTile(List<ServiceModel> rest) => Link(
        to: RoutePaths.services,
        classes: 'reveal group mt-5 flex flex-col gap-6 border '
            'border-dashed border-ink-700 p-7 transition-colors duration-500 '
            'ease-soft hover:border-iris-500/50 hover:bg-ink-850 '
            'sm:flex-row sm:items-center sm:justify-between sm:gap-10',
        children: [
          div([
            const p(
              classes: 'type-eyebrow font-mono text-ink-500',
              [Component.text('Also')],
            ),
            p(
              classes: 'mt-3 font-display text-lg font-bold tracking-tight '
                  'text-ink-100 sm:text-xl',
              [
                Component.text(
                  rest.map((item) => item.plainTitle).join('  ·  '),
                ),
              ],
            ),
          ]),
          div(
            classes: 'flex shrink-0 items-center gap-2.5 text-sm font-medium '
                'text-ink-200 transition-colors duration-300 '
                'group-hover:text-iris-300',
            [
              const Component.text('All services'),
              span(
                classes: 'transition-transform duration-500 ease-soft '
                    'group-hover:translate-x-1.5',
                [AppIcons.arrow()],
              ),
            ],
          ),
        ],
      );
}
