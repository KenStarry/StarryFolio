import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/presentation/components/section_block.dart';

class ContactSection extends StatelessComponent {
  const ContactSection({super.key});

  @override
  Component build(BuildContext context) {
    return SectionBlock(
      id: 'contact',
      eyebrow: 'Contact',
      heading: 'Got something worth building?',
      lead: 'Tell me what your users keep coming back for. If an app makes that '
          'easier, I would like to hear about it.',
      children: [
        div(
          classes: 'flex flex-col gap-8 sm:flex-row sm:items-center sm:justify-between',
          [
            const a(
              href: 'mailto:${SiteConfig.email}',
              classes: 'font-display text-2xl font-semibold tracking-tight '
                  'text-ink-900 underline decoration-star-400 decoration-2 '
                  'underline-offset-8 transition-colors hover:text-star-500 '
                  'sm:text-3xl dark:text-ink-50 dark:hover:text-star-300',
              [Component.text(SiteConfig.email)],
            ),
            div(
              classes: 'flex flex-wrap gap-3',
              [
                for (final social in SiteConfig.socials)
                  a(
                    href: social.url,
                    target: Target.blank,
                    attributes: const {'rel': 'me noopener'},
                    classes: 'rounded-full border border-ink-200 px-4 py-2 text-sm '
                        'text-ink-600 transition-colors hover:border-star-400 '
                        'hover:text-star-500 dark:border-ink-700 dark:text-ink-200 '
                        'dark:hover:text-star-300',
                    [Component.text(social.label)],
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
