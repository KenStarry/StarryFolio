/// The body of a written piece, as a list of typed blocks.
///
/// A post is not a string of HTML. Storing it as one would mean either trusting
/// authored markup straight into the document, or parsing it at render time —
/// and this site renders once, at build time, into files that must be correct
/// forever. A sealed hierarchy gives the renderer an exhaustive `switch`: a new
/// block type is a compile error until every renderer handles it, which is the
/// only way a content model stays honest as it grows.
///
/// Prose carries a **tiny inline syntax** rather than nested inline nodes —
/// `` `code` ``, `**bold**` and `[label](href)`. Three forms cover everything
/// the writing actually uses, and keeping them as plain text means an entry
/// reads like the sentence it is when you are authoring it. See `PostBody` for
/// the parser.
sealed class PostBlock {
  const PostBlock();

  /// Builds a block from a decoded map, for when this content moves behind a
  /// CMS. Returns null on an unrecognised or malformed entry so a bad block
  /// drops out of the article instead of taking the page down with it.
  static PostBlock? fromMap(Map<String, dynamic> map) {
    final text = map['text']?.toString() ?? '';
    return switch (map['type']?.toString()) {
      'heading' => PostHeading(
          text,
          level: int.tryParse(map['level']?.toString() ?? '') ?? 2,
        ),
      'prose' => PostProse(text),
      'code' => PostCode(
          map['code']?.toString() ?? '',
          language: map['language']?.toString() ?? 'dart',
          filename: map['filename']?.toString(),
        ),
      'image' => PostImage(
          map['src']?.toString() ?? '',
          alt: map['alt']?.toString() ?? '',
          caption: map['caption']?.toString(),
          inset: map['inset'] == true,
        ),
      'list' => PostList(
          switch (map['items']) {
            final List<Object?> raw => [for (final i in raw) i.toString()],
            _ => const <String>[],
          },
          ordered: map['ordered'] == true,
        ),
      'note' => PostNote(
          text,
          tone: PostNoteTone.values.firstWhere(
            (t) => t.name == map['tone']?.toString(),
            orElse: () => PostNoteTone.note,
          ),
        ),
      'steps' => PostSteps(
          switch (map['steps']) {
            final List<Object?> raw => [
                for (final entry in raw)
                  if (entry is Map<String, dynamic>)
                    (
                      title: entry['title']?.toString() ?? '',
                      blocks: switch (entry['blocks']) {
                        final List<Object?> inner => [
                            for (final b in inner)
                              if (b is Map<String, dynamic>)
                                if (PostBlock.fromMap(b) case final block?)
                                  block,
                          ],
                        _ => const <PostBlock>[],
                      },
                    ),
              ],
            _ => const <PostStep>[],
          },
        ),
      _ => null,
    };
  }
}

/// A section heading. Always `h2` or `h3` — the article's `h1` is the title in
/// the post header, and a body heading that competed with it would give the
/// page two topics. See CLAUDE.md §4.
class PostHeading extends PostBlock {
  const PostHeading(this.text, {this.level = 2});

  final String text;
  final int level;

  /// Anchor id, so the contents rail can link to it. Derived from the text
  /// rather than authored, because a hand-written id drifts the moment the
  /// heading is reworded.
  String get anchor => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-');
}

/// A paragraph. Carries the inline syntax described on [PostBlock].
class PostProse extends PostBlock {
  const PostProse(this.text);

  final String text;
}

/// A fenced code sample.
class PostCode extends PostBlock {
  const PostCode(this.code, {this.language = 'dart', this.filename});

  final String code;
  final String language;

  /// Shown in the block's title bar. Null renders the bar with the language
  /// alone rather than an empty label.
  final String? filename;
}

/// A figure. [src] is a path under `web/`.
class PostImage extends PostBlock {
  const PostImage(this.src, {required this.alt, this.caption, this.inset = false});

  final String src;
  final String alt;
  final String? caption;

  /// Screenshots of *results* are small and square-ish; screenshots of tooling
  /// are wide. `inset` caps the width so a 200px render is not stretched across
  /// the column and left looking soft.
  final bool inset;
}

class PostList extends PostBlock {
  const PostList(this.items, {this.ordered = false});

  final List<String> items;
  final bool ordered;
}

enum PostNoteTone { note, tip, warning }

/// An aside — the pulled-out remark that would break the flow inline.
class PostNote extends PostBlock {
  const PostNote(this.text, {this.tone = PostNoteTone.note});

  final String text;
  final PostNoteTone tone;
}

typedef PostStep = ({String title, List<PostBlock> blocks});

/// A numbered walkthrough.
///
/// The reason the body model bothers with nesting at all: a tutorial's steps
/// are a single ordered unit, and flattening them into headings loses the fact
/// that step 3 only makes sense after step 2.
class PostSteps extends PostBlock {
  const PostSteps(this.steps);

  final List<PostStep> steps;
}
