import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../domain/enum/skill_level.dart';
import '../../domain/model/skill_group_model.dart';
import '../../domain/model/skill_model.dart';

/// The toolkit, as a matrix of ruled rows with a depth meter against each.
///
/// Pills were the previous pass and they say only *that* a tool is known. Four
/// ruled columns with three-dot meters say how deeply, which is the honest and
/// far more interesting claim — and it is scannable without reading a single
/// label, because the filled dots draw the shape of where someone is strong.
///
/// The legend is rendered once, above the matrix. A meter with no legend is a
/// decoration; a legend repeated four times is noise.
class SkillMatrix extends StatelessComponent {
  const SkillMatrix({required this.groups, super.key});

  final List<SkillGroupModel> groups;

  @override
  Component build(BuildContext context) {
    if (groups.isEmpty) return const div([]);

    return div([
      _legend(),

      div(
        classes: 'mt-10 grid gap-x-12 gap-y-12 sm:grid-cols-2 lg:grid-cols-4',
        [
          for (final group in groups)
            div(
              classes: 'reveal',
              [
                h3(
                  classes: 'font-display text-lg font-bold tracking-tight '
                      'text-ink-100',
                  [Component.text(group.name)],
                ),
                if (group.note.isNotEmpty)
                  p(
                    classes: 'mt-2 text-xs leading-relaxed text-ink-500',
                    [Component.text(group.note)],
                  ),

                div(
                  classes: 'mt-6',
                  [
                    for (final skill in group.skills) _row(skill),
                  ],
                ),
              ],
            ),
        ],
      ),
    ]);
  }

  /// One skill: the name, and its depth as filled dots against a fixed track.
  ///
  /// The meter is `aria-hidden` and the level is exposed to assistive tech as
  /// text instead — three dots of varying fill mean nothing read aloud.
  static Component _row(SkillModel skill) => div(
        classes: 'skill-row',
        [
          span([Component.text(skill.name)]),
          span(
            classes: 'meter',
            attributes: const {'aria-hidden': 'true'},
            [
              for (var i = 0; i < SkillLevel.track; i++)
                span(
                  classes: i < skill.level.dots
                      ? 'meter-dot meter-dot-on'
                      : 'meter-dot',
                  [],
                ),
            ],
          ),
          span(
            classes: 'sr-only',
            [Component.text(skill.level.label)],
          ),
        ],
      );

  /// Reads left to right in the same direction the dots fill.
  static Component _legend() => div(
        classes: 'reveal flex flex-wrap items-center gap-x-7 gap-y-3',
        [
          for (final level in SkillLevel.values)
            div(
              classes: 'inline-flex items-center gap-2.5',
              [
                span(
                  classes: 'meter',
                  attributes: const {'aria-hidden': 'true'},
                  [
                    for (var i = 0; i < SkillLevel.track; i++)
                      span(
                        classes: i < level.dots
                            ? 'meter-dot meter-dot-on'
                            : 'meter-dot',
                        [],
                      ),
                  ],
                ),
                span(
                  classes: 'font-mono text-[11px] uppercase tracking-[0.14em] '
                      'text-ink-500',
                  [Component.text(level.label)],
                ),
              ],
            ),
        ],
      );
}
