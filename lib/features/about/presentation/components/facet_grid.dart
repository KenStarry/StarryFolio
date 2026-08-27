import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../domain/model/facet_model.dart';

/// The closing band — the part that is not about work.
///
/// Kept quiet on purpose: hairline cards, small type, no inversion. Ending a
/// page about a person on the loudest block on it would be the wrong note, and
/// the inverted card has already been spent higher up. One focal moment per
/// screen.
class FacetGrid extends StatelessComponent {
  const FacetGrid({required this.facets, super.key});

  final List<FacetModel> facets;

  @override
  Component build(BuildContext context) {
    if (facets.isEmpty) return const div([]);

    return div(
      classes: 'stagger grid gap-5 sm:grid-cols-2',
      [
        for (final facet in facets)
          div(
            classes: 'card group flex flex-col p-7 sm:p-8',
            [
              div(
                classes: 'flex items-start justify-between gap-6',
                [
                  span(
                    classes: 'text-iris-400 transition-transform duration-500 '
                        'ease-spring group-hover:scale-110',
                    [AppIcons.byName(facet.icon, classes: 'h-6 w-6')],
                  ),
                  if (facet.marker.isNotEmpty)
                    span(
                      classes: 'font-mono text-[10px] uppercase '
                          'tracking-[0.16em] text-ink-500',
                      [Component.text(facet.marker)],
                    ),
                ],
              ),

              h3(
                classes: 'mt-8 font-display text-lg font-bold leading-snug '
                    'tracking-tight text-ink-100',
                [Component.text(facet.title)],
              ),

              p(
                classes: 'mt-3 text-sm leading-relaxed text-ink-400',
                [Component.text(facet.blurb)],
              ),
            ],
          ),
      ],
    );
  }
}
