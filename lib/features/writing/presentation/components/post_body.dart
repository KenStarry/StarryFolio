import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../domain/model/post_block.dart';

/// Renders a post's [PostBlock] list into the article column.
///
/// The `switch` over the sealed hierarchy is exhaustive by construction — add a
/// block type and this file stops compiling until it is handled, which is the
/// point of modelling the body as types rather than as a string of HTML.
///
/// Nothing here is a client component. The whole article is emitted during the
/// static build, so every word, every code sample and every caption is in the
/// pre-rendered HTML. See CLAUDE.md §0.
class PostBody extends StatelessComponent {
  const PostBody({required this.blocks, super.key});

  final List<PostBlock> blocks;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'prose-col',
      [for (final block in blocks) renderBlock(block)],
    );
  }
}

/// One block. Exposed so [PostSteps] can render its nested children through the
/// same path — a code sample inside a step must look identical to one outside.
///
/// [nested] drops the block's own vertical margins: a step already spaces its
/// children, and the two rhythms fighting is what makes a nested figure sit
/// visibly wrong inside its step.
Component renderBlock(PostBlock block, {bool nested = false}) {
  return switch (block) {
    PostHeading(:final text, :final level, :final anchor) => _heading(
        text,
        level,
        anchor,
      ),
    PostProse(:final text) => p(
        classes: 'reveal prose-p',
        inline(text),
      ),
    PostCode(:final code, :final language, :final filename) => _code(
        code,
        language,
        filename,
        nested,
      ),
    PostImage(:final src, :final alt, :final caption, :final inset) => _figure(
        src,
        alt,
        caption,
        inset,
        nested,
      ),
    PostList(:final items, :final ordered) => _list(items, ordered),
    PostNote(:final text, :final tone) => _note(text, tone, nested),
    PostSteps(:final steps) => _steps(steps),
  };
}

// ── Blocks ──────────────────────────────────────────────────────────────────

/// Body headings are `h2`/`h3` only — the article's `h1` is its title, and a
/// second one would split the page's topic for crawlers (CLAUDE.md §4).
///
/// Each carries its own anchor and a hover-revealed `#`, so a reader can link
/// someone straight to the section that answered their question.
Component _heading(String text, int level, String anchor) {
  final inner = [
    a(
      href: '#$anchor',
      classes: 'group/anchor no-underline',
      [
        Component.text(text),
        const span(
          classes: 'ml-3 select-none font-mono text-iris-500/0 '
              'transition-colors duration-300 group-hover/anchor:text-iris-500/70',
          attributes: {'aria-hidden': 'true'},
          [Component.text('#')],
        ),
      ],
    ),
  ];

  return level >= 3
      ? h3(id: anchor, classes: 'reveal prose-h3 scroll-mt-28', inner)
      : h2(id: anchor, classes: 'reveal prose-h2 scroll-mt-28', inner);
}

Component _code(String source, String language, String? filename, bool nested) {
  return div(
    classes: 'reveal prose-code-block ${nested ? 'my-0' : ''}',
    [
      div(
        classes: 'flex items-center justify-between gap-4 border-b '
            'border-ink-700 bg-ink-850 px-4 py-2.5',
        [
          span(
            classes: 'font-mono text-[11px] text-ink-300',
            [Component.text(filename ?? language)],
          ),
          span(
            classes: 'type-eyebrow font-mono text-ink-500',
            [Component.text(language)],
          ),
        ],
      ),
      // `pre` preserves the newlines the source authored; the horizontal
      // scroll is on this element so a long line never widens the page body.
      pre(
        classes: 'overflow-x-auto px-4 py-4',
        [
          code(
            classes: 'font-mono text-[0.8125rem] leading-relaxed text-ink-200',
            [Component.text(source)],
          ),
        ],
      ),
    ],
  );
}

Component _figure(
  String src,
  String alt,
  String? caption,
  bool inset,
  bool nested,
) {
  return figure(
    classes: 'reveal ${nested ? 'my-0' : 'my-10'}',
    [
      div(
        classes: 'overflow-hidden border border-ink-700 bg-ink-850 '
            '${inset ? 'mx-auto max-w-xs p-6' : ''}',
        [
          img(
            src: '/$src',
            alt: alt,
            classes: 'w-full',
            attributes: const {'loading': 'lazy', 'decoding': 'async'},
          ),
        ],
      ),
      if (caption != null)
        figcaption(
          classes: 'mt-3 text-center font-mono text-[11px] text-ink-500',
          [Component.text(caption)],
        ),
    ],
  );
}

Component _list(List<String> items, bool ordered) {
  final children = [
    for (final (i, item) in items.indexed)
      li(
        classes: 'prose-li',
        [
          span(
            classes: 'prose-li-mark',
            attributes: const {'aria-hidden': 'true'},
            [Component.text(ordered ? '${i + 1}.' : '—')],
          ),
          span(inline(item)),
        ],
      ),
  ];

  return ordered
      ? ol(classes: 'reveal prose-list', children)
      : ul(classes: 'reveal prose-list', children);
}

Component _note(String text, PostNoteTone tone, bool nested) {
  // Tone is carried by the label and a left rule, not by a hue — the palette is
  // two tones plus iris, and a green "tip" box would be a third (CLAUDE.md §8).
  final label = switch (tone) {
    PostNoteTone.note => 'Note',
    PostNoteTone.tip => 'Tip',
    PostNoteTone.warning => 'Careful',
  };

  return aside(
    classes: 'reveal border-l-2 border-iris-500/50 bg-ink-850/60 '
        'py-5 pl-6 pr-5 ${nested ? 'my-0' : 'my-9'}',
    [
      span(
        classes: 'type-eyebrow font-mono text-iris-400',
        [Component.text(label)],
      ),
      p(
        classes: 'mt-3 text-[0.9375rem] leading-relaxed text-ink-300',
        inline(text),
      ),
    ],
  );
}

Component _steps(List<PostStep> steps) {
  return ol(
    classes: 'reveal my-10 space-y-0',
    [
      for (final (i, step) in steps.indexed)
        li(
          // The spine: a hairline down the left with the step number sitting on
          // it. The last step stops the rule short so the sequence closes
          // rather than trailing into the next section.
          classes: 'relative pb-10 pl-14 '
              '${i == steps.length - 1 ? '' : 'border-l border-ink-700'} '
              '${i == steps.length - 1 ? 'ml-[0.6875rem] pl-[3.0625rem]' : ''}',
          [
            span(
              classes: 'absolute left-0 top-0 flex h-6 w-6 items-center '
                  'justify-center border border-ink-600 bg-ink-900 '
                  'font-mono text-[11px] text-iris-400 '
                  '${i == steps.length - 1 ? '-ml-[0.6875rem]' : '-translate-x-1/2'}',
              [Component.text('${i + 1}')],
            ),
            h4(
              classes: 'font-display text-base font-bold tracking-tight '
                  'text-ink-100',
              [Component.text(step.title)],
            ),
            div(
              classes: 'mt-4 space-y-4',
              [for (final b in step.blocks) renderBlock(b, nested: true)],
            ),
          ],
        ),
    ],
  );
}

// ── Inline syntax ───────────────────────────────────────────────────────────

/// Matches the three inline forms, in one pass so they cannot nest ambiguously:
/// `` `code` ``, `**bold**`, `[label](href)`.
final _inlinePattern = RegExp(
  r'`([^`]+)`'
  r'|\*\*([^*]+)\*\*'
  r'|\[([^\]]+)\]\(([^)]+)\)',
);

/// Turns authored prose into components.
///
/// Deliberately small. A full Markdown parser would let an author write
/// anything, including markup this design has no styling for — and every
/// unstyled construct that reaches the page is a visual regression nobody
/// notices until it ships. Three forms cover what the writing uses; a fourth
/// should be a [PostBlock], not a new escape sequence.
///
/// Text outside a match is emitted through `Component.text`, which escapes it —
/// so authored content can never inject markup into the document.
List<Component> inline(String source) {
  final out = <Component>[];
  var cursor = 0;

  for (final match in _inlinePattern.allMatches(source)) {
    if (match.start > cursor) {
      out.add(Component.text(source.substring(cursor, match.start)));
    }

    if (match.group(1) case final literal?) {
      out.add(
        code(classes: 'prose-code-inline', [Component.text(literal)]),
      );
    } else if (match.group(2) case final bold?) {
      out.add(
        strong(
          classes: 'font-semibold text-ink-100',
          [Component.text(bold)],
        ),
      );
    } else if (match.group(3) case final label?) {
      final href = match.group(4)!;
      final external = href.startsWith('http');
      out.add(
        a(
          href: href,
          target: external ? Target.blank : null,
          attributes: external ? const {'rel': 'noopener'} : null,
          classes: 'link-line text-ink-100 decoration-iris-500/60',
          [Component.text(label)],
        ),
      );
    }

    cursor = match.end;
  }

  if (cursor < source.length) {
    out.add(Component.text(source.substring(cursor)));
  }

  return out;
}
