import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../../../core/routing/route_paths.dart';
import '../../domain/enum/project_collection.dart';

/// A doorway into one collection.
///
/// Used twice: as the set of entry points on `/projects`, and as the sideways
/// links closing every collection page. One component so the two cannot
/// describe the same collection differently — the copy comes off the enum
/// either way, which is the same reason `ProjectCategory` carries its own
/// section heading.
///
/// The count is passed in rather than resolved here. This component is
/// rendered inside a page that has already awaited the repository, and a
/// second read would either need the whole list threading through or an async
/// component in the middle of a grid.
class CollectionTile extends StatelessComponent {
  const CollectionTile({required this.collection, this.count, super.key});

  final ProjectCollection collection;

  /// How many projects are in it. Omitted where the surrounding page has not
  /// resolved them — a tile with no number still works, a tile with a wrong
  /// one does not.
  final int? count;

  @override
  Component build(BuildContext context) {
    return Link(
      to: RoutePaths.collection(collection.slug),
      classes: 'card reveal group relative flex flex-col justify-between '
          'overflow-hidden p-6 sm:p-7',
      children: [
        div([
          div(
            classes: 'flex items-baseline justify-between gap-4',
            [
              h3(
                classes: 'font-display text-lg font-bold tracking-tight '
                    'text-ink-100 transition-colors duration-300 '
                    'group-hover:text-iris-300',
                [Component.text(collection.label)],
              ),
              if (count case final n?)
                span(
                  classes: 'font-mono text-[11px] text-ink-500',
                  [Component.text(n.toString().padLeft(2, '0'))],
                ),
            ],
          ),
          p(
            classes: 'mt-3 text-sm leading-relaxed text-ink-400',
            [Component.text(collection.blurb)],
          ),
        ]),

        div(
          classes: 'mt-8 flex items-center gap-2.5 text-ink-500 '
              'transition-colors duration-300 group-hover:text-iris-400',
          [
            const span(
              classes: 'type-eyebrow font-mono',
              [Component.text('Open')],
            ),
            span(
              classes: 'transition-transform duration-500 ease-soft '
                  'group-hover:translate-x-1',
              [AppIcons.arrow(classes: 'h-3.5 w-3.5')],
            ),
          ],
        ),
      ],
    );
  }
}
