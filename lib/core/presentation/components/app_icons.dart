import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// Inline SVG icons. Kept as raw markup so they inherit `currentColor`
/// and cost zero extra network requests.
class AppIcons {
  const AppIcons._();

  static Component star({String classes = 'h-5 w-5'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">'
        '<path d="M12 2l2.6 6.6L21.5 10l-5.2 4.1 1.1 6.9L12 17.6 6.6 21l1.1-6.9L2.5 10l6.9-1.4z"/>'
        '</svg>',
      );

  static Component sun({String classes = 'h-4 w-4'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" fill="none" stroke="currentColor" '
        'stroke-width="1.8" stroke-linecap="round" aria-hidden="true">'
        '<circle cx="12" cy="12" r="4"/>'
        '<path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>'
        '</svg>',
      );

  static Component moon({String classes = 'h-4 w-4'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" fill="none" stroke="currentColor" '
        'stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">'
        '<path d="M21 12.8A9 9 0 1111.2 3a7 7 0 009.8 9.8z"/>'
        '</svg>',
      );

  static Component menu({String classes = 'h-5 w-5'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" fill="none" stroke="currentColor" '
        'stroke-width="1.8" stroke-linecap="round" aria-hidden="true">'
        '<path d="M4 7h16M4 12h16M4 17h16"/>'
        '</svg>',
      );

  static Component close({String classes = 'h-5 w-5'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" fill="none" stroke="currentColor" '
        'stroke-width="1.8" stroke-linecap="round" aria-hidden="true">'
        '<path d="M6 6l12 12M18 6L6 18"/>'
        '</svg>',
      );

  static Component arrow({String classes = 'h-4 w-4'}) => RawText(
        '<svg class="$classes" viewBox="0 0 24 24" fill="none" stroke="currentColor" '
        'stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">'
        '<path d="M5 12h14M13 6l6 6-6 6"/>'
        '</svg>',
      );
}
