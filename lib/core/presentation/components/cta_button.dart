import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'app_icons.dart';

enum CtaVariant {
  /// Pale fill, dark text. The inversion — one per screen.
  solid,

  /// Hairline border on the section ground.
  outline,

  /// Text and a rule, no box. The reference's `My story →`.
  quiet,
}

/// The site's call to action.
///
/// Renders a router [Link] for in-app paths and a plain `<a>` for anything
/// else, because handing `mailto:` or an external URL to the router would have
/// it try to resolve a route that does not exist. Hash links are excluded too:
/// the router resolves a path, so `/#contact` would navigate to `/` and drop
/// the fragment. The distinction is inferred from the href rather than passed
/// in, so a caller cannot get it wrong.
class CtaButton extends StatelessComponent {
  const CtaButton({
    required this.label,
    required this.href,
    this.variant = CtaVariant.solid,
    this.icon = true,
    this.anchor = false,
    this.classes = '',
    super.key,
  });

  final String label;
  final String href;
  final CtaVariant variant;
  final bool icon;

  /// Forces a plain `<a>` even for an in-app path.
  ///
  /// Required inside a `@client` island: an island hydrates as its own root
  /// with no [Router] above it, so a [Link] there would look for a router that
  /// is not in the tree. The nav bar is the one place this applies.
  final bool anchor;

  final String classes;

  bool get _isInternal =>
      !anchor && href.startsWith('/') && !href.contains('#');

  @override
  Component build(BuildContext context) {
    final styles = switch (variant) {
      CtaVariant.solid => '$_base $_solid',
      CtaVariant.outline => '$_base $_outline',
      CtaVariant.quiet => _quiet,
    };

    final children = <Component>[
      span([Component.text(label)]),
      if (icon)
        span(
          classes: 'transition-transform duration-500 ease-soft '
              'group-hover:translate-x-1',
          [AppIcons.arrow(classes: 'h-4 w-4')],
        ),
    ];

    if (_isInternal) {
      return Link(to: href, classes: '$styles $classes', children: children);
    }

    final external = href.startsWith('http');
    return a(
      href: href,
      classes: '$styles $classes',
      target: external ? Target.blank : null,
      attributes: external ? const {'rel': 'noopener'} : null,
      children,
    );
  }

  static const String _base =
      'group inline-flex items-center justify-center gap-2.5 px-7 py-3.5 '
      'text-sm font-medium transition-colors duration-400 ease-soft';

  static const String _solid = 'bg-ink-200 text-ink-900 hover:bg-ink-100';

  static const String _outline =
      'border border-ink-600 text-ink-200 hover:border-ink-400 hover:bg-ink-800';

  static const String _quiet =
      'link-line group inline-flex items-center gap-3 text-sm font-medium '
      'text-ink-200 transition-colors duration-300 hover:text-ink-100';
}
