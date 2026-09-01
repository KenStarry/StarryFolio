import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../domain/model/experience_model.dart';

/// A role as a compact card — the whole of a career in one scannable row.
///
/// Built for the home page, where the About band has no business running a
/// timeline: four of these say *five years, four teams, this is the shape of
/// it* in about twenty words, where the prose version took a hundred and
/// eighty and still had to be read in order.
///
/// The entry is a *company* now rather than a single role, so the card leads
/// with the most recent title held there. On the home band that is the right
/// summary: four cards saying where the work happened and what he was called
/// while it did, with the full progression one click away on `/about`.
///
/// It borrows the project cards' floating object — a real surface, a hairline,
/// lift and accent on hover — but nothing else. A project card leads with a
/// cover image; a role has no image, so the company's own initial is ghosted
/// across the card instead. That is the difference in style: same family of
/// object, different way of filling it.
class RoleCard extends StatelessComponent {
  const RoleCard({required this.role, super.key});

  final ExperienceModel role;

  @override
  Component build(BuildContext context) {
    return div(
      // `isolate` keeps the monogram's `-z-10` inside the card rather than
      // dropping it behind the section's own background.
      classes: 'float-card reveal group relative isolate flex min-h-[10.5rem] '
          'flex-col overflow-hidden border border-ink-700 bg-ink-850 p-6',
      [
        span(
          classes: 'ghost-mono pointer-events-none absolute -bottom-4 -right-2 '
              '-z-10 select-none font-display font-extrabold '
              'text-ink-100/[0.055]',
          attributes: const {'aria-hidden': 'true'},
          [Component.text(role.company.isEmpty ? '' : role.company.substring(0, 1))],
        ),

        div(
          classes: 'flex items-center gap-2.5',
          [
            if (role.current)
              const span(
                classes: 'h-1.5 w-1.5 shrink-0 rounded-full bg-iris-400 '
                    'dot-live',
                [],
              ),
            span(
              classes: 'font-mono text-[11px] tracking-tight '
                  '${role.current ? 'text-iris-400' : 'text-ink-500'}',
              [Component.text(role.period)],
            ),
          ],
        ),

        // Pushes the name block to the bottom, so four cards share one
        // baseline no matter how the period line wraps.
        const div(classes: 'flex-1 min-h-8', []),

        h3(
          classes: 'font-display text-lg font-bold tracking-tight text-ink-100',
          [Component.text(role.company)],
        ),

        p(
          classes: 'mt-1 text-xs leading-snug text-ink-400',
          [Component.text(role.roles.isEmpty ? '' : role.roles.first.title)],
        ),
      ],
    );
  }
}
