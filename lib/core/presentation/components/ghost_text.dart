import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// Size steps for [GhostText].
enum GhostSize {
  /// Behind a device or a page hero.
  hero('showcase-ghost'),

  /// Behind a band heading.
  band('ghost-band'),

  /// Behind a smaller block — a closing CTA, a card.
  small('ghost-sm');

  const GhostSize(this.className);

  final String className;
}

/// Oversized type sitting behind content as texture.
///
/// The motif documented in CLAUDE.md as the golden standard, in one place so it
/// cannot drift. Three rules are baked in rather than left to call sites:
///
/// * **Always `aria-hidden` and `select-none`.** It repeats text that is
///   already a real heading nearby, so it must never enter the document
///   outline, be read aloud, or be selectable as if it were content.
/// * **Always `pointer-events-none`.** It routinely overlaps interactive
///   elements and must never intercept a click.
/// * **Barely there.** 3.5% by default. If it can be read consciously it is
///   competing with the copy rather than supporting it.
///
/// Callers position it; this only ever renders the mark itself.
class GhostText extends StatelessComponent {
  const GhostText(
    this.text, {
    this.size = GhostSize.band,
    this.classes = '',
    this.faint = false,
    super.key,
  });

  /// The canonical placement for a band's ghost: hung off the bottom-left
  /// corner and bleeding past it.
  ///
  /// One constant rather than a string retyped at a dozen call sites, because
  /// the motif only reads as a system if the placement never varies. What the
  /// *word* is depends on the band:
  ///
  /// * On the home page it is **wayfinding** — each band names the page it
  ///   leads to, and each destination's own `PageHeader` ghosts the same word,
  ///   so the door and the room share a watermark.
  /// * On `/services` it is the band's numeral, and on `/about` the company
  ///   name. Both echo a marker printed a few pixels away, which is the rule
  ///   the motif actually asks for: texture that repeats something real.
  ///
  /// A section using it needs `relative isolate overflow-hidden`: `isolate`
  /// gives `-z-10` a stacking context to sit in rather than dropping the mark
  /// behind the section's own background, and `overflow-hidden` is what does
  /// the bleeding.
  static const String bandCorner =
      'absolute -bottom-6 -left-4 -z-10 sm:-left-8';

  final String text;
  final GhostSize size;

  /// Positioning from the caller — absolute placement, offsets, alignment.
  final String classes;

  /// Dials the opacity down further, for a band that already carries a device
  /// or where the ghost sits close under live copy.
  final bool faint;

  @override
  Component build(BuildContext context) {
    return span(
      classes: 'pointer-events-none select-none font-display font-extrabold '
          '${size.className} '
          '${faint ? 'text-ink-100/[0.025]' : 'text-ink-100/[0.035]'} '
          '$classes',
      attributes: const {'aria-hidden': 'true'},
      [Component.text(text)],
    );
  }
}
