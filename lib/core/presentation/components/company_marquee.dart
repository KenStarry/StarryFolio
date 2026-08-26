import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../config/site_config.dart';
import '../../domain/model/company.dart';

/// A slow, muted ticker of the places the work has been done.
///
/// The track holds the list **twice** and animates to `translateX(-50%)`, which
/// lands exactly on the start of the duplicate — that is what makes the loop
/// seamless rather than snapping back. With only a handful of companies the
/// duplicate is what keeps the strip full at any viewport width.
///
/// The second copy is `aria-hidden`, so a screen reader hears each name once,
/// and the whole strip pauses on hover so a name can actually be read.
///
/// Wordmarks are the default rather than a fallback: a set of mismatched
/// client logos at different weights and crops is usually *worse* looking than
/// clean type. Setting [Company.logo] swaps one in without touching layout.
class CompanyMarquee extends StatelessComponent {
  const CompanyMarquee({this.companies = SiteConfig.companies, super.key});

  final List<Company> companies;

  @override
  Component build(BuildContext context) {
    if (companies.isEmpty) return const div([]);

    return div(
      classes: 'marquee edge-fade relative overflow-hidden py-2',
      [
        div(
          classes: 'marquee-track',
          [_run(), _run(duplicate: true)],
        ),
      ],
    );
  }

  Component _run({bool duplicate = false}) => div(
        classes: 'flex shrink-0 items-center',
        attributes: duplicate ? const {'aria-hidden': 'true'} : null,
        [
          for (final company in companies) _item(company),
        ],
      );

  Component _item(Company company) {
    final logo = company.logo;

    final inner = <Component>[
      if (logo != null)
        img(
          src: '/$logo',
          alt: company.name,
          attributes: const {'loading': 'lazy', 'decoding': 'async'},
          classes: 'h-7 w-auto opacity-60 transition-opacity duration-500 '
              'group-hover/co:opacity-100',
        )
      else
        span(
          classes: 'whitespace-nowrap font-display text-2xl font-extrabold '
              'tracking-tight text-ink-600 transition-colors duration-500 '
              'group-hover/co:text-ink-100 sm:text-3xl',
          [Component.text(company.name)],
        ),
      if (company.role != null)
        span(
          classes: 'type-eyebrow whitespace-nowrap font-mono text-ink-700 '
              'opacity-0 transition-opacity duration-500 '
              'group-hover/co:text-iris-400 group-hover/co:opacity-100',
          [Component.text(company.role!)],
        ),
    ];

    // Named group, so hovering one item cannot light up its neighbours.
    const wrapper = 'group/co flex shrink-0 items-center gap-4 px-8';

    return company.url == null
        ? div(classes: wrapper, inner)
        : a(
            href: company.url!,
            target: Target.blank,
            attributes: const {'rel': 'noopener'},
            classes: wrapper,
            inner,
          );
  }
}
