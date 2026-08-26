import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/config/site_config.dart';
import '../../../../core/presentation/components/section_block.dart';

class AboutSection extends StatelessComponent {
  const AboutSection({super.key});

  @override
  Component build(BuildContext context) {
    return SectionBlock(
      id: 'about',
      eyebrow: 'About',
      heading: 'The short version',
      children: [
        div(
          classes: 'grid gap-12 lg:grid-cols-[1.2fr_1fr]',
          [
            div(
              classes: 'space-y-5',
              [
                for (final para in SiteConfig.bio)
                  p(
                    classes: 'text-base leading-relaxed text-ink-500 dark:text-ink-300',
                    [Component.text(para)],
                  ),
              ],
            ),
            div(
              classes: 'space-y-6',
              [
                for (final group in SiteConfig.toolkit)
                  div([
                    h3(
                      classes: 'font-mono text-xs uppercase tracking-[0.18em] '
                          'text-ink-400 dark:text-ink-400',
                      [Component.text(group.group)],
                    ),
                    div(
                      classes: 'mt-2 flex flex-wrap gap-2',
                      [
                        for (final item in group.items)
                          span(
                            classes: 'rounded-md bg-ink-100 px-2.5 py-1 text-xs '
                                'text-ink-600 dark:bg-ink-800 dark:text-ink-200',
                            [Component.text(item)],
                          ),
                      ],
                    ),
                  ]),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
