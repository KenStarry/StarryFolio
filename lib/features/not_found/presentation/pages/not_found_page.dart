import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';

class NotFoundPage extends StatelessComponent {
  const NotFoundPage({super.key});

  @override
  Component build(BuildContext context) {
    return const div(
      classes: 'mx-auto flex max-w-3xl flex-col items-center px-5 py-32 text-center',
      [
        PageMeta(
          path: RoutePaths.notFound,
          title: 'Not found — ${SiteConfig.name}',
          description: 'That page does not exist.',
          noIndex: true,
        ),
        p(
          classes: 'font-mono text-sm uppercase tracking-[0.3em] text-star-500 '
              'dark:text-star-400',
          [Component.text('404')],
        ),
        h1(
          classes: 'mt-6 font-display text-4xl font-semibold tracking-tight '
              'text-ink-900 sm:text-5xl dark:text-ink-50',
          [Component.text('This page drifted off')],
        ),
        p(
          classes: 'mt-4 max-w-md text-base leading-relaxed text-ink-500 '
              'dark:text-ink-300',
          [
            Component.text(
              'The link may be old, or the page may have moved. Either way, '
              'the work is still worth a look.',
            ),
          ],
        ),
        div(
          classes: 'mt-10 flex flex-wrap justify-center gap-3',
          [
            Link(
              to: RoutePaths.home,
              classes: 'inline-flex items-center gap-2 rounded-full bg-ink-900 px-6 py-3 '
                  'text-sm font-medium text-ink-50 transition-transform duration-300 '
                  'ease-expo hover:-translate-y-0.5 dark:bg-star-400 dark:text-ink-950',
              children: [Component.text('Back home')],
            ),
            Link(
              to: RoutePaths.projects,
              classes: 'inline-flex items-center gap-2 rounded-full border '
                  'border-ink-200 px-6 py-3 text-sm font-medium text-ink-700 '
                  'transition-colors hover:border-star-400 hover:text-star-500 '
                  'dark:border-ink-700 dark:text-ink-200 dark:hover:text-star-300',
              children: [Component.text('See the work')],
            ),
          ],
        ),
      ],
    );
  }
}
