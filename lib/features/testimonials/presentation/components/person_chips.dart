import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../core/presentation/components/app_icons.dart';
import '../../domain/model/person_link.dart';

/// A contributor's own profiles, as chips.
///
/// **Never `rel="me"`.** That attribute asserts the linked profile and this
/// site are the same identity, and these belong to somebody else — using it
/// here would claim Ken owns their LinkedIn and pollute the `sameAs` graph
/// that `SiteConfig.socials` builds. Plain `noopener` is correct, and
/// [PersonLink] exists as a separate type precisely so the two can never be
/// rendered by the same code path.
///
/// This is the part of the page that pays a contributor back: they said
/// something kind, and they get a real, followable link out of it rather than
/// a name in grey text.
class PersonChips extends StatelessComponent {
  const PersonChips({required this.links, required this.name, this.classes = '', super.key});

  final List<PersonLink> links;

  /// Whose profiles these are. Used only for the accessible label — "LinkedIn"
  /// repeated across three cards tells a screen reader nothing about which
  /// person it belongs to.
  final String name;

  final String classes;

  @override
  Component build(BuildContext context) {
    if (links.isEmpty) return const div([]);

    return div(
      classes: 'flex flex-wrap gap-2 $classes',
      [
        for (final link in links)
          a(
            href: link.url,
            target: Target.blank,
            attributes: {
              'rel': 'noopener',
              'aria-label': '$name on ${link.label}',
            },
            classes: 'person-link press',
            [
              span(
                classes: 'text-ink-500',
                [AppIcons.byName(link.icon, classes: 'h-3.5 w-3.5')],
              ),
              Component.text(link.label),
            ],
          ),
      ],
    );
  }
}
