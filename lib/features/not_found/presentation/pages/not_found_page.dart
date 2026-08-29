import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/presentation/components/cta_button.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';

class NotFoundPage extends StatelessComponent {
  const NotFoundPage({super.key});

  @override
  Component build(BuildContext context) {
    return const section(
      classes: 'bg-ink-900 py-32 sm:py-40',
      [
        PageMeta(
          path: RoutePaths.notFound,
          title: 'Not found · ${SiteConfig.name}',
          description: 'That page does not exist.',
          noIndex: true,
        ),
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'max-w-xl',
              [
                Eyebrow('404'),
                h1(
                  classes: 'type-section mt-5 font-display font-bold '
                      'text-ink-100',
                  [Component.text('This page drifted off.')],
                ),
                p(
                  classes: 'mt-6 text-sm leading-relaxed text-ink-400',
                  [
                    Component.text(
                      'The link may be old, or the page may have moved. '
                      'Either way, the work is still worth a look.',
                    ),
                  ],
                ),
                div(
                  classes: 'mt-10 flex flex-wrap gap-3',
                  [
                    CtaButton(label: 'Back home', href: RoutePaths.home),
                    CtaButton(
                      label: 'See the work',
                      href: RoutePaths.projects,
                      variant: CtaVariant.outline,
                      icon: false,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
