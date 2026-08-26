import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../domain/model/service_model.dart';

/// One card in the services row.
///
/// The [ServiceModel.featured] card inverts — pale ground, dark text — while
/// the rest stay one step up from the section. That inversion is the page's
/// single focal moment and replaces the reference's filled accent block. Three
/// identically weighted cards read as a pricing table; one inverted card turns
/// the row into a composition.
class ServiceCard extends StatelessComponent {
  const ServiceCard({
    required this.service,
    required this.index,
    super.key,
  });

  final ServiceModel service;

  /// Zero-based position, rendered as the `01` / `02` / `03` marker.
  final int index;

  @override
  Component build(BuildContext context) {
    final featured = service.featured;
    final number = (index + 1).toString().padLeft(2, '0');

    return div(
      classes: 'reveal group flex min-h-[19rem] flex-col p-8 sm:p-9 '
          '${featured ? 'card-invert' : 'card'}',
      [
        div(
          classes: 'flex items-start justify-between',
          [
            span(
              classes: featured ? 'text-ink-900' : 'text-iris-400',
              [AppIcons.byName(service.icon)],
            ),
            span(
              classes: 'font-mono text-[11px] tracking-[0.18em] '
                  '${featured ? 'text-ink-900/45' : 'text-ink-500'}',
              [Component.text(number)],
            ),
          ],
        ),

        // Pushes the title block to the bottom so every card in the row shares
        // one baseline regardless of blurb length.
        const div(classes: 'flex-1 min-h-12', []),

        // Short rule above the title, echoing the section divider motif.
        div(
          classes: 'mb-6 h-px w-10 '
              '${featured ? 'bg-ink-900/25' : 'bg-iris-500'}',
          [],
        ),

        h3(
          classes: 'font-display text-2xl font-bold leading-[1.15] '
              'tracking-tight ${featured ? 'text-ink-900' : 'text-ink-100'}',
          // Titles carry deliberate line breaks so the display type sets as a
          // tight two-line block instead of wrapping wherever the box ends.
          _titleLines(service.title),
        ),

        p(
          classes: 'mt-4 text-sm leading-relaxed '
              '${featured ? 'text-ink-900/70' : 'text-ink-400'}',
          [Component.text(service.blurb)],
        ),

        if (service.tags.isNotEmpty)
          p(
            classes: 'mt-6 font-mono text-[11px] tracking-wide '
                '${featured ? 'text-ink-900/55' : 'text-ink-500'}',
            [Component.text(service.tags.join('  ·  '))],
          ),
      ],
    );
  }

  /// Splits on the newlines authored in the datasource into `<br>`-separated
  /// text, so the copy owns its own line breaks.
  static List<Component> _titleLines(String title) {
    final lines = title.split('\n');
    return [
      for (final (i, line) in lines.indexed) ...[
        if (i > 0) const br(),
        Component.text(line),
      ],
    ];
  }
}
