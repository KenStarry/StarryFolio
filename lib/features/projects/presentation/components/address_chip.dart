import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/presentation/components/app_icons.dart';

/// A project's live address, as a small plate above its section title.
///
/// The surviving half of a drawn browser frame that used to wrap web
/// showcases. The frame was wrong — every mockup in this repo is a device
/// render, so chrome around one was a frame inside a frame — but the address
/// bar was the best thing in it: a URL is the one label that proves a thing is
/// *running* rather than described. On its own, and clickable, it does that
/// job better than it did inside a fake window.
///
/// It renders nothing without a URL. Most apps have no web destination, and a
/// store link is not an address — setting `play.google.com/store/apps/...` in
/// a chrome-style plate would be dressing a download button as a location.
class AddressChip extends StatelessComponent {
  const AddressChip({
    required this.url,
    required this.href,
    this.label = '',
    this.classes = '',
    super.key,
  });

  /// Display form — host and path, no scheme. See `ProjectModel.liveUrl`.
  final String url;

  /// The real destination, with its scheme.
  final String href;

  /// What the address belongs to, for the accessible name. Without it a
  /// screen reader announces a bare hostname with no idea whose it is.
  final String label;

  final String classes;

  @override
  Component build(BuildContext context) {
    return a(
      href: href,
      target: Target.blank,
      attributes: {
        'rel': 'noopener',
        if (label.isNotEmpty) 'aria-label': 'Open $label at $url',
      },
      classes: 'address-chip $classes',
      [
        // The live dot, shared with the hero's availability marker: the
        // address says reachable, the dot says now.
        const span(
          classes: 'address-chip-dot dot-live',
          attributes: {'aria-hidden': 'true'},
          [],
        ),
        span(classes: 'address-chip-url', [Component.text(url)]),
        span(
          classes: 'shrink-0 text-ink-600 transition-transform duration-500 '
              'ease-soft',
          attributes: const {'aria-hidden': 'true'},
          [AppIcons.arrowUpRight(classes: 'h-3 w-3')],
        ),
      ],
    );
  }
}
