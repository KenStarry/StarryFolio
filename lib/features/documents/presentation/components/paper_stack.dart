import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../domain/model/document_model.dart';

/// A document's real pages, fanned as a physical stack.
///
/// This is the documents hub's answer to the device mockup that carries every
/// project showcase — and it follows the same rule: **show the actual
/// artefact.** The images are rendered straight out of the PDF (see
/// `DocumentsLocalDatasource`), so the preview cannot flatter a layout the
/// download does not have. A generic paper illustration would be decoration;
/// this is the thing itself.
///
/// It reuses the hero's `.stack` motif rather than inventing a second one, so
/// the fan-on-hover reads as the same gesture the site already has. What
/// differs is direction: the hero's layers fan *left*, and these fan *right*,
/// because the stack sits on the opposite side of its band and a fan into the
/// copy column would collide with the text.
///
/// Purely presentational — `aria-hidden`, because the pages carry no
/// information a screen reader can use that the copy beside them does not
/// already state, and announcing "image, image, image" is worse than silence.
class PaperStack extends StatelessComponent {
  const PaperStack({required this.document, super.key});

  final DocumentModel document;

  @override
  Component build(BuildContext context) {
    final pages = document.pages;
    if (pages.isEmpty) return const div([]);

    // Back to front, so the front page is last in source order and needs no
    // z-index of its own.
    final behind = pages.skip(1).take(2).toList(growable: false);

    return div(
      classes: 'stack relative mx-auto w-full max-w-sm',
      attributes: const {'aria-hidden': 'true'},
      [
        const div(
          classes: 'bloom pointer-events-none absolute inset-0 -m-10',
          [],
        ),

        // The sheets behind, in reverse so the deepest is drawn first.
        for (final (i, page) in behind.indexed.toList().reversed)
          div(
            classes: 'paper-layer stack-layer stack-layer-${behind.length - i} '
                'absolute inset-0 overflow-hidden border border-ink-700 '
                'bg-ink-850',
            [
              img(
                src: '/$page',
                alt: '',
                classes: 'h-full w-full object-cover object-top opacity-40',
                attributes: const {'loading': 'lazy', 'decoding': 'async'},
              ),
            ],
          ),

        div(
          classes: 'stack-front paper-sheet relative overflow-hidden border '
              'border-ink-600 bg-ink-100',
          [
            img(
              src: '/${pages.first}',
              alt: '',
              classes: 'w-full',
              attributes: const {'loading': 'lazy', 'decoding': 'async'},
            ),
            // A single soft sheen across the page, so it reads as paper caught
            // under a light rather than as a flat screenshot pasted on.
            const div(
              classes: 'paper-sheen pointer-events-none absolute inset-0',
              [],
            ),
          ],
        ),

        // Page count, sitting on the corner of the stack. It is the one label
        // that makes the fan legible as *a document* rather than as three
        // overlapping images.
        if (document.pageCount > 1)
          div(
            classes: 'absolute -bottom-4 -right-4 flex h-14 w-14 '
                'items-center justify-center rounded-full border '
                'border-ink-700 bg-ink-900 font-mono text-[11px] text-ink-300',
            [
              Component.text(
                '${document.pageCount}pp',
              ),
            ],
          ),
      ],
    );
  }
}
