import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/presentation/components/cta_button.dart';
import '../../../../core/presentation/components/eyebrow.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/seo/page_meta.dart';

/// Where a **no-JavaScript** submission lands.
///
/// The form posts natively when the island has not hydrated, and the function
/// answers with a 303 to here — so a browser with scripting off still gets a
/// real confirmation page rather than a screenful of JSON.
///
/// `noIndex`, because a confirmation is a dead end for a searcher: it has no
/// content of its own and arriving here from a search result would be
/// meaningless. It is kept out of the sitemap for the same reason.
class ThanksPage extends StatelessComponent {
  const ThanksPage({super.key});

  @override
  Component build(BuildContext context) {
    return const section(
      classes: 'bg-ink-900 py-32 sm:py-40',
      [
        PageMeta(
          path: RoutePaths.thanks,
          title: 'Message sent — ${SiteConfig.name}',
          description: 'Your message has been sent.',
          noIndex: true,
        ),
        div(
          classes: 'mx-auto w-full max-w-6xl px-6 sm:px-8 lg:px-12',
          [
            div(
              classes: 'max-w-xl',
              [
                Eyebrow('Message sent'),
                h1(
                  classes: 'type-section mt-5 font-display font-extrabold '
                      'text-ink-100',
                  [Component.text('Got it — thank you.')],
                ),
                p(
                  classes: 'mt-6 text-sm leading-relaxed text-ink-400',
                  [
                    Component.text(
                      'It has landed in my inbox and I usually reply within a '
                      'day. If it is urgent, email me directly and it will '
                      'reach the same place.',
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
