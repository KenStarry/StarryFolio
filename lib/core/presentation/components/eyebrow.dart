import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// The small letterspaced label that opens each block — `— INTRODUCTION`.
///
/// The leading dash is a real element rather than a character so its length and
/// weight stay consistent regardless of the font's em dash metrics.
class Eyebrow extends StatelessComponent {
  const Eyebrow(this.label, {this.classes = '', super.key});

  final String label;
  final String classes;

  @override
  Component build(BuildContext context) {
    return p(
      classes: 'type-eyebrow flex items-center gap-3 font-mono '
          'text-ink-400 $classes',
      [
        const span(classes: 'h-px w-6 bg-iris-500', []),
        span([Component.text(label)]),
      ],
    );
  }
}
