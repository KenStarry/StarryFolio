import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../domain/model/document_model.dart';

/// The visual for a document that is deliberately not published.
///
/// The design problem: a blurred or redacted *image* of a certificate would be
/// a lie — it implies a file is sitting there behind a filter, and on a static
/// site it would be, one URL guess away. So there is no image. There is no
/// file on the server at all.
///
/// What is here instead is the **credential stated in full**, set as a formal
/// record: institution, qualification, classification, year. That is the part
/// that is not sensitive — it is already on the CV and in the page's JSON-LD.
/// What is withheld is only the scan, which carries a signature and a
/// registration number and belongs in a reply, not on a crawler's index.
///
/// The seal is drawn, not photographed, for the same reason: an ornament that
/// represents a document is honest; a picture of one that you cannot have is
/// not.
class SealedDocument extends StatelessComponent {
  const SealedDocument({required this.document, super.key});

  final DocumentModel document;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'sealed-doc relative mx-auto w-full max-w-sm overflow-hidden '
          'border border-ink-700 bg-ink-850 px-8 py-12 text-center',
      [
        // The guilloche-ish hairline frame every certificate has. Two insets
        // rather than one, because a single border reads as a card and two
        // read as a document.
        const div(
          classes: 'pointer-events-none absolute inset-3 border '
              'border-ink-700/70',
          [],
        ),
        const div(
          classes: 'pointer-events-none absolute inset-[0.875rem] border '
              'border-ink-700/40',
          [],
        ),

        div(
          classes: 'relative',
          [
            // The seal.
            div(
              classes: 'seal mx-auto flex h-20 w-20 items-center '
                  'justify-center rounded-full border border-iris-500/40 '
                  'text-iris-400/70',
              [AppIcons.byName('seal', classes: 'h-9 w-9')],
            ),

            const p(
              classes: 'type-eyebrow mt-8 font-mono text-ink-500',
              [Component.text('Conferred')],
            ),

            const p(
              classes: 'mt-4 font-display text-xl font-extrabold leading-tight '
                  'tracking-tight text-ink-100',
              [Component.text('First Class Honours')],
            ),

            const p(
              classes: 'mt-2 font-mono text-[11px] uppercase '
                  'tracking-[0.14em] text-ink-400',
              [Component.text('BSc Computer Science')],
            ),

            const div(classes: 'mx-auto mt-7 h-px w-16 bg-ink-700', []),

            if (document.issuer.isNotEmpty)
              p(
                classes: 'mx-auto mt-7 max-w-[14rem] text-xs leading-relaxed '
                    'text-ink-400',
                [Component.text(document.issuer)],
              ),

            if (document.updated.isNotEmpty)
              p(
                classes: 'mt-3 font-mono text-sm text-ink-300',
                [Component.text(document.updated)],
              ),

            // Says plainly why there is no preview, rather than leaving the
            // absence to be read as an oversight.
            div(
              classes: 'mt-10 inline-flex items-center gap-2 border '
                  'border-ink-700 px-3 py-1.5 font-mono text-[10px] '
                  'uppercase tracking-wider text-ink-500',
              [
                AppIcons.byName('lock', classes: 'h-3.5 w-3.5'),
                const Component.text('Scan not published'),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
