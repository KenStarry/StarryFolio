import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// Rendered when a repository returns a `Left`.
///
/// Every page that awaits data folds into one of these, so a data failure
/// produces a real, styled block rather than an empty section — and, because it
/// is pre-rendered, never a page that looks blank to a crawler.
class ErrorNotice extends StatelessComponent {
  const ErrorNotice({required this.message, super.key});

  final String message;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'mx-auto max-w-xl border border-ink-700 bg-ink-800 px-7 py-10 '
          'text-center',
      [
        const p(
          classes: 'font-display text-lg font-bold text-ink-100',
          [Component.text('That did not load')],
        ),
        p(
          classes: 'mt-2.5 text-sm leading-relaxed text-ink-400',
          [Component.text(message)],
        ),
      ],
    );
  }
}
