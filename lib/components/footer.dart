import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../data/profile.dart';

class SiteFooter extends StatelessComponent {
  const SiteFooter({super.key});

  @override
  Component build(BuildContext context) {
    return footer(
      classes: 'border-t border-ink-200/60 dark:border-ink-800/80',
      [
        div(
          classes: 'mx-auto flex max-w-6xl flex-col gap-4 px-5 py-10 sm:flex-row '
              'sm:items-center sm:justify-between sm:px-8',
          [
            const p(
              classes: 'text-sm text-ink-400 dark:text-ink-400',
              [
                Component.text('© 2026 ${Profile.name}. Built with Dart + Jaspr.'),
              ],
            ),
            div(
              classes: 'flex flex-wrap gap-5',
              [
                for (final s in Profile.socials)
                  a(
                    href: s.url,
                    target: Target.blank,
                    classes: 'text-sm text-ink-500 transition-colors hover:text-star-500 '
                        'dark:text-ink-300 dark:hover:text-star-300',
                    [Component.text(s.label)],
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
