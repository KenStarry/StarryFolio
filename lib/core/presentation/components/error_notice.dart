import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// Rendered when a repository returns a `Left`.
///
/// Every page that awaits data folds into one of these, so a data failure
/// produces a real, styled page rather than a blank section — and, because it
/// is pre-rendered, never a page that looks empty to a crawler.
class ErrorNotice extends StatelessComponent {
  const ErrorNotice({required this.message, super.key});

  final String message;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'mx-auto max-w-2xl rounded-2xl border border-ink-200/70 '
          'bg-white/60 px-6 py-10 text-center '
          'dark:border-ink-800 dark:bg-ink-900/50',
      [
        const p(
          classes: 'font-display text-lg font-semibold text-ink-900 dark:text-ink-50',
          [Component.text('That did not load')],
        ),
        p(
          classes: 'mt-2 text-sm leading-relaxed text-ink-500 dark:text-ink-300',
          [Component.text(message)],
        ),
      ],
    );
  }
}
