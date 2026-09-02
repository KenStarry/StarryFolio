import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../domain/model/experience_model.dart';

/// The career as a ledger: one row per company, newest first.
///
/// ## Why not the four cards this replaced
///
/// Four cards of equal weight in a row read as a grid, and a grid has no
/// subject — the eye lands nowhere and the whole band flattens. A ledger has a
/// subject: the row you are on now. It also reads in one downward glance the
/// way a contents page does, where four boxes have to be visited in turn.
///
/// ## Every row is a door
///
/// Each is a link into `/about#experience`, which makes the whole band a way
/// through rather than a heading with a doorway bolted to the corner. The
/// anchor carries its path because `<base href="/">` makes a bare fragment
/// resolve against the site root — see [RoutePaths.anchor].
///
/// ## The fourth treatment, deliberately
///
/// This site presents the same career four ways: ruled figures in `/about`'s
/// header, full-width bands with metrics on `/about`, framed plates for
/// education, and this. Reusing the band here would make the home page a
/// preview of a page rather than a door to it, which is a different and worse
/// relationship.
class CareerLedger extends StatelessComponent {
  const CareerLedger({required this.experience, super.key});

  final List<ExperienceModel> experience;

  @override
  Component build(BuildContext context) {
    if (experience.isEmpty) return const div([]);

    return div(
      classes: 'stagger',
      [
        for (final entry in experience) _row(entry),
      ],
    );
  }

  static Component _row(ExperienceModel xp) {
    final title = xp.roles.isEmpty ? '' : xp.roles.first.title;

    return Link(
      to: RoutePaths.anchor(RoutePaths.about, 'experience'),
      classes: xp.current ? 'ledger-row ledger-row-now' : 'ledger-row',
      attributes: {'aria-label': '$title at ${xp.company}'},
      children: [
        div(
          classes: 'ledger-mark',
          attributes: const {'aria-hidden': 'true'},
          [
            if (xp.logo case final logo?)
              img(
                src: '/$logo',
                alt: '',
                classes: 'h-5 w-5 object-contain',
                attributes: const {'loading': 'lazy', 'decoding': 'async'},
              )
            else
              Component.text(xp.initial),
          ],
        ),

        // The years sit in their own column on wide screens so the ledger
        // aligns down the page, and fold under the company name on narrow
        // ones where a third column would crush the type.
        div(
          classes: 'col-start-2 flex items-center gap-2 sm:col-start-2',
          [
            if (xp.current)
              const span(
                classes: 'h-1.5 w-1.5 shrink-0 rounded-full bg-iris-400 '
                    'dot-live',
                [],
              ),
            span(classes: 'ledger-years', [Component.text(xp.yearSpan)]),
          ],
        ),

        div(
          classes: 'col-start-2 sm:col-start-3',
          [
            p(classes: 'ledger-company', [Component.text(xp.company)]),
            if (title.isNotEmpty)
              p(classes: 'ledger-role', [Component.text(title)]),
          ],
        ),
      ],
    );
  }
}
