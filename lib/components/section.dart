import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A consistently spaced page section with an optional eyebrow + heading.
class Section extends StatelessComponent {
  const Section({
    required this.children,
    this.id,
    this.eyebrow,
    this.heading,
    this.lead,
    this.classes = '',
    super.key,
  });

  final List<Component> children;
  final String? id;
  final String? eyebrow;
  final String? heading;
  final String? lead;
  final String classes;

  @override
  Component build(BuildContext context) {
    return section(
      id: id,
      classes: 'mx-auto max-w-6xl px-5 py-20 sm:px-8 sm:py-28 $classes',
      [
        if (eyebrow != null)
          p(
            classes: 'font-mono text-xs uppercase tracking-[0.2em] text-star-500 '
                'dark:text-star-400',
            [Component.text(eyebrow!)],
          ),
        if (heading != null)
          h2(
            classes: 'mt-3 font-display text-3xl font-semibold tracking-tight '
                'text-ink-900 sm:text-4xl dark:text-ink-50',
            [Component.text(heading!)],
          ),
        if (lead != null)
          p(
            classes: 'mt-4 max-w-2xl text-base leading-relaxed text-ink-500 '
                'dark:text-ink-300',
            [Component.text(lead!)],
          ),
        div(classes: heading != null ? 'mt-12' : '', children),
      ],
    );
  }
}
