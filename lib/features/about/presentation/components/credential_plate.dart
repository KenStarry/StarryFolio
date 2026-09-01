import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../domain/model/education_model.dart';

/// One credential, as a framed plate.
///
/// ## Why this is not the experience band
///
/// The section directly above presents a job as a body of evidence: full
/// width, figures at stat scale, the work that came out of it. A credential is
/// a different kind of claim — a thing somebody signed — and presenting it the
/// same way would flatten the difference and make the page repeat itself.
///
/// So this borrows the language `/documents` already uses for the degree: a
/// double hairline frame, the institution's mark embossed through the ground,
/// type set centre, and the year ruled either side the way a certificate dates
/// itself. Two of these side by side read as a wall of framed certificates.
///
/// ## The mark
///
/// [EducationModel.crest] is a **stencil** — alpha only, no colour — so
/// `currentColor` is painted through it and the mark takes whatever tone the
/// element is set to. That is the only way a two-colour third-party logo can
/// enter a palette of two tones and no accent hue (CLAUDE.md).
///
/// Where there is no cleared stencil, a seal is drawn from the institution's
/// initial. Deliberate rather than a placeholder: a mark nobody has the rights
/// to is worse than a letter, and because the seal is built from the palette it
/// never reads as a logo that failed to load.
///
/// The mark appears twice at different scales, which is what a real
/// certificate does — struck at the head, and again large and barely there
/// through the paper. Both are `aria-hidden`: the institution is named in text
/// directly beneath, and a screen reader announcing the crest would be
/// repeating it.
class CredentialPlate extends StatelessComponent {
  const CredentialPlate({required this.education, super.key});

  final EducationModel education;

  @override
  Component build(BuildContext context) {
    final e = education;

    // Both marks fix a height and derive their width, so a landscape lockup
    // and a portrait shield sit on one baseline the way seals on a page do.
    // Sizes match `.plate-seal` (4rem) and `.plate-watermark` (18rem) — the
    // heights stay in CSS; only the width, which is data, comes from here.
    final sealWidth = e.crestBoxWidth(4);
    final markWidth = e.crestBoxWidth(18);

    final meta = <String>[
      e.period,
      if (e.location.isNotEmpty) e.location,
    ];

    return div(
      classes: 'plate reveal group',
      [
        const div(
          classes: 'plate-frame',
          attributes: {'aria-hidden': 'true'},
          [],
        ),

        // The watermark, only where there is a real mark to emboss. A drawn
        // initial at this scale would be a very large letter behind the text
        // rather than a watermark, so entries without a crest simply do not
        // get one.
        if (e.crest case final crest?)
          div(
            classes: 'plate-watermark',
            attributes: {
              'aria-hidden': 'true',
              // Inline because both values vary per institution: a Tailwind
              // class built by interpolation would be purged by the scanner,
              // which reads source literals. See CLAUDE.md §8.
              'style': "-webkit-mask-image: url('/$crest'); "
                  "mask-image: url('/$crest'); "
                  "width: ${markWidth}rem;",
            },
            [],
          ),

        // ── The seal ──
        if (e.crest case final crest?)
          div(
            classes: 'plate-seal plate-seal-crest mx-auto',
            attributes: {
              'aria-hidden': 'true',
              'style': "-webkit-mask-image: url('/$crest'); "
                  "mask-image: url('/$crest'); "
                  "width: ${sealWidth}rem;",
            },
            [],
          )
        else
          div(
            classes: 'plate-seal',
            attributes: const {'aria-hidden': 'true'},
            [
              span(
                classes: 'plate-seal-mark',
                [Component.text(e.initial)],
              ),
            ],
          ),

        if (e.kind.isNotEmpty)
          p(
            classes: 'type-eyebrow mt-8 font-mono text-ink-500',
            [Component.text(e.kind)],
          ),

        h3(
          classes: 'mt-4 font-display text-xl font-extrabold leading-tight '
              'tracking-tight text-ink-100 sm:text-2xl',
          [Component.text(e.qualification)],
        ),

        if (e.honours.isNotEmpty)
          p(
            classes: 'mt-2 font-display text-base font-bold text-iris-300',
            [Component.text(e.honours)],
          ),

        div(classes: 'plate-year mt-7', [Component.text(meta.join('  ·  '))]),

        p(
          classes: 'mx-auto mt-6 max-w-xs text-sm leading-relaxed text-ink-200',
          [Component.text(e.institution)],
        ),

        if (e.note.isNotEmpty)
          p(
            classes: 'mx-auto mt-4 max-w-sm text-sm leading-relaxed '
                'text-ink-500',
            [Component.text(e.note)],
          ),

        if (e.focus.isNotEmpty)
          div(
            classes: 'mt-8 flex flex-wrap justify-center gap-2',
            [
              for (final subject in e.focus)
                span(classes: 'pill', [Component.text(subject)]),
            ],
          ),

        // Says out loud that the detail is authored rather than confirmed.
        // Clearing `draft` in the datasource removes it.
        if (e.draft)
          const p(
            classes: 'mt-6 font-mono text-[10px] uppercase tracking-[0.14em] '
                'text-ink-600',
            [Component.text('details to confirm')],
          ),
      ],
    );
  }
}
