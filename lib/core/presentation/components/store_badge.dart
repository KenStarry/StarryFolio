import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../domain/model/app_link.dart';
import 'app_icons.dart';

/// A store badge — `Get it on Google Play`, `Download on the App Store`.
///
/// Built in the site's own language rather than dropping in Apple's and
/// Google's official artwork: those badges are fixed-radius black or white
/// pills with their own typography, and either one would sit on this flat
/// two-tone page like a sticker. The silhouette and the wordmark still make
/// each one instantly readable.
///
/// The visible text is two stacked lines, which a screen reader would run
/// together as "Get it on Google Play" mid-sentence with no context — so the
/// anchor carries an explicit [AppLink.accessibleLabel] naming the product, and
/// the text itself is hidden from the accessibility tree.
class StoreBadge extends StatelessComponent {
  const StoreBadge({
    required this.link,
    required this.product,
    this.compact = false,
    super.key,
  });

  final AppLink link;

  /// Product name, used only to build the accessible label.
  final String product;

  /// Single-line form for tight spaces such as a card footer. Drops the
  /// overline — at card width the two-line badge wraps and looks broken.
  final bool compact;

  @override
  Component build(BuildContext context) {
    return a(
      href: link.url,
      target: Target.blank,
      attributes: {
        'rel': 'noopener',
        'aria-label': link.accessibleLabel(product),
      },
      classes: compact ? 'store-badge-sm above-stretch group' : 'store-badge group',
      [
        span(
          classes: 'store-badge-glyph',
          attributes: const {'aria-hidden': 'true'},
          [
            AppIcons.byName(
              link.type.icon,
              classes: compact ? 'h-4 w-4' : 'h-6 w-6',
            ),
          ],
        ),
        span(
          classes: 'flex min-w-0 flex-col leading-none',
          attributes: const {'aria-hidden': 'true'},
          [
            if (!compact)
              span(
                classes: 'store-badge-overline',
                [Component.text(link.overline)],
              ),
            span(
              classes: 'store-badge-title',
              [Component.text(link.title)],
            ),
          ],
        ),
      ],
    );
  }
}

/// A row of [StoreBadge]s for one product.
///
/// Orders store links first, then everything else, so `Google Play` and
/// `App Store` always lead regardless of how the data was authored — a portal
/// link ahead of the stores would bury the primary action.
class StoreBadgeRow extends StatelessComponent {
  const StoreBadgeRow({
    required this.links,
    required this.product,
    this.compact = false,
    this.limit,
    this.classes = '',
    super.key,
  });

  final List<AppLink> links;
  final String product;
  final bool compact;

  /// Caps how many badges are shown. A card footer has room for two; the
  /// remainder stay reachable on the case-study page.
  final int? limit;

  final String classes;

  @override
  Component build(BuildContext context) {
    if (links.isEmpty) return const div([]);

    final ordered = [
      ...links.where((l) => l.isStore),
      ...links.where((l) => !l.isStore),
    ];
    final shown = limit == null ? ordered : ordered.take(limit!).toList();

    return div(
      classes: 'flex flex-wrap items-stretch gap-3 $classes',
      [
        for (final link in shown)
          StoreBadge(link: link, product: product, compact: compact),
      ],
    );
  }
}
