import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../components/page_meta.dart';
import '../data/profile.dart';

class NotFoundPage extends StatelessComponent {
  const NotFoundPage({super.key});

  @override
  Component build(BuildContext context) {
    return const div(
      classes: 'mx-auto flex max-w-3xl flex-col items-center px-5 py-32 text-center',
      [
        PageMeta(
          path: '/404',
          title: 'Not found — ${Profile.name}',
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
              'text-ink-900 dark:text-ink-50',
          [Component.text('Lost in space')],
        ),
        p(
          classes: 'mt-4 text-base text-ink-500 dark:text-ink-300',
          [Component.text('That page drifted out of orbit. Let us get you back.')],
        ),
        Link(
          to: '/',
          classes: 'mt-10 rounded-full bg-ink-900 px-6 py-3 text-sm font-medium '
              'text-ink-50 dark:bg-star-400 dark:text-ink-950',
          children: [Component.text('Back home')],
        ),
      ],
    );
  }
}
