import '../../domain/model/post_block.dart';
import '../../domain/model/post_model.dart';

/// The written pieces, as compile-time constants.
///
/// Deliberately `const` and synchronous for the same reason as the projects
/// source: the static build has to resolve this during pre-render, and the
/// repository on top exists so the page never learns where the data came from.
///
/// **Only a post with a body gets a route.** [slugs] filters on
/// `PostModel.hasBody`, and `app.dart` enumerates it — so a planned piece
/// listed here renders as an unlinked card and cannot produce a dead URL. Give
/// one a `body` and its page exists on the next build; nothing else changes.
abstract final class WritingLocalDatasource {
  /// Newest first. The index and the home teaser both render in this order, so
  /// the list *is* the running order — there is no sort step to disagree with.
  static const List<PostModel> posts = [
    _svgStyling,
    _riverpodPrerender,
    _lastTenPercent,
    _offlineFirst,
  ];

  /// The slugs that have a page. Read directly by the route table.
  static List<String> get slugs => [
        for (final post in posts)
          if (post.hasBody) post.slug,
      ];

  // ── The pieces ────────────────────────────────────────────────────────────

  /// Originally published on the Mintlify docs site and ported here whole.
  ///
  /// The Flutter Shape Maker section is the one edit: the generator emits
  /// roughly 1,500 lines of `Path` calls, which is not reading material. A
  /// representative excerpt stands in and the full file is linked, which is
  /// what the original did at the foot of the piece anyway.
  static const PostModel _svgStyling = PostModel(
    slug: 'multi-wayed-svg-styling',
    title: 'Multi-wayed SVG styling in Flutter',
    topic: 'Flutter',
    date: 'Apr 2024',
    dateIso: '2024-04-06',
    readMinutes: 8,
    excerpt: 'Four ways to colour an SVG in Flutter — and why the obvious one '
        'falls apart the moment the artwork gets interesting.',
    dek: 'Can you name four different ways to style an SVG in Flutter? Most '
        'people get to two. The gap between them is where the good-looking '
        'work lives.',
    coverImage: 'images/writing/svg-styling-cover.webp',
    coverAlt: 'Flutter SVG styling — the article cover',
    tags: ['Flutter', 'SVG', 'CustomPaint', 'Shaders'],
    sourceUrl:
        'https://github.com/KenStarry/Multi_Wayed_Flutter/tree/main/lib/svg_styling',
    sourceLabel: 'Full source on GitHub',
    body: [
      PostProse(
        'It never gets as basic as this. And yet — while working with SVGs '
        'seems simple enough, can you tell me four different ways of styling '
        'one?',
      ),
      PostProse(
        'I like the way you are looking at the ceiling trying to think of the '
        'possible ways. Let me make it easier.',
      ),
      PostProse(
        'Throughout this piece we work with the SVG below, from '
        '[undraw.co](https://undraw.co), and try to restyle it by changing its '
        'colour properties four different ways.',
      ),
      PostImage(
        'images/writing/svg-styling-1.webp',
        alt: 'The undraw pancakes illustration in its original colours',
        inset: true,
      ),

      // ── 1 ──
      PostHeading('1. The flutter_svg package'),
      PostProse(
        'You have almost certainly met this one — it is the popular choice in '
        'the Flutter world. The `flutter_svg` package lets us work with SVGs '
        'in a straightforward way.',
      ),
      PostSteps([
        (
          title: 'Add the asset',
          blocks: [
            PostProse(
              'Add an `assets` folder in your project root, then an `images` '
              'sub-folder, and drop the SVG in there.',
            ),
          ],
        ),
        (
          title: 'Declare it in pubspec.yaml',
          blocks: [
            PostProse(
              'Add the package, then register the folder so Flutter bundles '
              'it.',
            ),
            PostCode(
              'dependencies:\n'
              '  flutter_svg: ^2.0.9',
              language: 'yaml',
              filename: 'pubspec.yaml',
            ),
            PostCode(
              'flutter:\n'
              '  uses-material-design: true\n'
              '\n'
              '  assets:\n'
              '    - assets/images/',
              language: 'yaml',
              filename: 'pubspec.yaml',
            ),
          ],
        ),
        (
          title: 'Style it',
          blocks: [
            PostProse(
              '`SvgPicture` ships with `semanticsLabel`, `colorFilter`, '
              '`width` and `height` built in. `colorFilter` is the one that '
              'changes the colour.',
            ),
            PostCode(
              'return Scaffold(\n'
              '  body: Center(\n'
              '    child: SvgPicture.asset(\n'
              "      'assets/images/undraw_pancakes.svg',\n"
              '      colorFilter: const ColorFilter.mode(\n'
              '        Colors.red,\n'
              '        BlendMode.srcIn,\n'
              '      ),\n'
              "      semanticsLabel: 'Sweet Pancakes',\n"
              '      width: 200,\n'
              '      height: 200,\n'
              '    ),\n'
              '  ),\n'
              ');',
              filename: 'home.dart',
            ),
          ],
        ),
        (
          title: 'The result',
          blocks: [
            PostImage(
              'images/writing/svg-styling-2.webp',
              alt: 'The illustration flattened to a single red silhouette',
              inset: true,
            ),
          ],
        ),
      ]),
      PostProse(
        'Yeah — not as pleasing as you had hoped. That is the limitation. '
        '`BlendMode.srcIn` replaces **every** painted pixel, so the whole '
        'illustration collapses into one silhouette. For an icon that is '
        'exactly right. For artwork with more than one colour in it, you have '
        'just thrown the artwork away.',
      ),

      // ── 2 ──
      PostHeading('2. The ColorFiltered widget'),
      PostProse(
        'You can also wrap `SvgPicture.asset` in a `ColorFiltered` widget. '
        'Same result as above, by a different route.',
      ),
      PostCode(
        'return Scaffold(\n'
        '  body: Center(\n'
        '    child: ColorFiltered(\n'
        '      colorFilter: const ColorFilter.mode(\n'
        '        Colors.red,\n'
        '        BlendMode.srcIn,\n'
        '      ),\n'
        '      child: SvgPicture.asset(\n'
        "        'assets/images/undraw_pancakes.svg',\n"
        "        semanticsLabel: 'Sweet Pancakes',\n"
        '        width: 200,\n'
        '        height: 200,\n'
        '      ),\n'
        '    ),\n'
        '  ),\n'
        ');',
        filename: 'home.dart',
      ),
      PostImage(
        'images/writing/svg-styling-2.webp',
        alt: 'The same red silhouette produced by ColorFiltered',
        inset: true,
      ),
      PostProse(
        'It is a little more flexible, though — `ColorFiltered` wraps *any* '
        'widget, not just an SVG. Which of the two you reach for is mostly '
        'preference.',
      ),

      // ── 3 ──
      PostHeading('3. Flutter Shape Maker'),
      PostProse(
        'For simpler SVGs like icons, `ColorFiltered` and `colorFilter` work '
        'absolutely great. More complex artwork needs a finer-grained '
        'approach — and that is where Flutter Shape Maker comes in.',
      ),
      PostNote(
        'Flutter Shape Maker auto-generates responsive `CustomPaint` code for '
        'Flutter directly from a canvas or an SVG.',
        tone: PostNoteTone.note,
      ),
      PostSteps([
        (
          title: 'Open the tool',
          blocks: [
            PostProse(
              'Visit [fluttershapemaker.com](https://fluttershapemaker.com/) '
              'and hit the icon at the top right, then **SVG To Custom Paint** '
              'to open the import window.',
            ),
            PostImage(
              'images/writing/svg-styling-3.webp',
              alt: 'The Flutter Shape Maker canvas with the import button',
            ),
          ],
        ),
        (
          title: 'Import and generate',
          blocks: [
            PostProse(
              'Click **Pick SVG File** at the bottom left and choose your '
              'image.',
            ),
            PostImage(
              'images/writing/svg-styling-4.webp',
              alt: 'The Pick SVG File dialog',
            ),
            PostProse('Then click **Generate Code**.'),
            PostImage(
              'images/writing/svg-styling-5.webp',
              alt: 'The Generate Code button',
            ),
            PostNote(
              'Toggle it to **Responsive** for the best results — the '
              'generated paths are then expressed as fractions of `size`, so '
              'the shape scales instead of clipping.',
              tone: PostNoteTone.tip,
            ),
            PostProse('Copy the generated code out.'),
            PostImage(
              'images/writing/svg-styling-6.webp',
              alt: 'The generated CustomPaint code, ready to copy',
            ),
          ],
        ),
        (
          title: 'Paste in the painter',
          blocks: [
            PostProse(
              'Drop it into a new Dart file. Below is a snippet of the '
              'generated class — the real one runs to roughly 1,500 lines, one '
              '`Path` and one `Paint` per shape in the drawing.',
            ),
            PostCode(
              "import 'package:flutter/material.dart';\n"
              '\n'
              'class FlutterShapeMakerCustomPaint extends CustomPainter {\n'
              '  @override\n'
              '  void paint(Canvas canvas, Size size) {\n'
              '    Path path_0 = Path();\n'
              '    path_0.moveTo(size.width * 0.8613445, size.height);\n'
              '    path_0.lineTo(size.width * 0.1386555, size.height);\n'
              '    path_0.cubicTo(size.width * 0.06220183, size.height, 0,\n'
              '        size.height * 0.9873417, 0, size.height * 0.8904919);\n'
              '\n'
              '    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;\n'
              '    paint_0_fill.color = const Color(0xffF2F2F2);\n'
              '    canvas.drawPath(path_0, paint_0_fill);\n'
              '\n'
              '    // …and so on, one path and one paint per shape.\n'
              '  }\n'
              '\n'
              '  @override\n'
              '  bool shouldRepaint(covariant CustomPainter oldDelegate) =>\n'
              '      true;\n'
              '}',
              filename: 'flutter_shape_maker_custom_paint.dart',
            ),
            PostProse(
              'This is the whole point of the technique: every shape now has '
              'its **own** `Paint`. Change `paint_0_fill.color` and you have '
              'recoloured exactly one part of the illustration, leaving the '
              'rest alone — which is the thing neither of the first two '
              'methods can do.',
            ),
          ],
        ),
        (
          title: 'Size it',
          blocks: [
            PostProse(
              'The generated widget expects a `WIDTH`. Set it, and let the '
              'height follow the aspect ratio the generator worked out.',
            ),
            PostCode(
              'CustomPaint(\n'
              '  size: Size(250, (250 * 0.7894034777284248).toDouble()),\n'
              '  painter: FlutterShapeMakerCustomPaint(),\n'
              '),',
            ),
          ],
        ),
        (
          title: 'The result',
          blocks: [
            PostProse('Isn\'t it just crazy how cool this looks?'),
            PostImage(
              'images/writing/svg-styling-7.webp',
              alt: 'The illustration recoloured per-shape, detail intact',
              inset: true,
            ),
          ],
        ),
      ]),

      // ── 4 ──
      PostHeading('4. SVG + ShaderMask'),
      PostProse(
        'Congratulations, you made it this far. It only gets cooler.',
      ),
      PostProse(
        'So far we have only added solid colours. What about a **gradient**? '
        'That is the job of `ShaderMask`.',
      ),
      PostCode(
        'ShaderMask(\n'
        '  shaderCallback: (bounds) {\n'
        '    return const LinearGradient(\n'
        '      begin: Alignment.topCenter,\n'
        '      end: Alignment.bottomCenter,\n'
        '      colors: [Colors.red, Colors.blue],\n'
        '    ).createShader(bounds);\n'
        '  },\n'
        '  child: SvgPicture.asset(\n'
        "    'assets/images/undraw_pancakes.svg',\n"
        "    semanticsLabel: 'Sweet Pancakes',\n"
        '    width: 200,\n'
        '    height: 200,\n'
        '  ),\n'
        ')',
        filename: 'shader_mask.dart',
      ),
      PostList([
        '`child` — the widget to apply the gradient to. Any widget, not just '
            'an SVG.',
        '`shaderCallback` — returns the gradient you want: `LinearGradient`, '
            '`SweepGradient`, `RadialGradient`.',
        '`bounds` — the size constraints of the child. Here, the SVG\'s '
            '200×200.',
      ]),
      PostImage(
        'images/writing/svg-styling-8.webp',
        alt: 'The illustration under a red-to-blue vertical gradient',
        inset: true,
      ),
      PostProse('Yes, I was amazed myself.'),
      PostNote(
        'For a deeper look at `ShaderMask`, this '
        '[Medium article](https://medium.com/flutter-community/an-overview-on-shadermask-89201539ba8d) '
        'is worth the ten minutes.',
        tone: PostNoteTone.note,
      ),

      // ── Close ──
      PostHeading('So which one?'),
      PostProse(
        'Each has its advantages, and a lot of it comes down to preference — '
        'but not all of it:',
      ),
      PostList([
        '**One-colour icons** — `colorFilter` on `SvgPicture`. Nothing else '
            'is worth the typing.',
        '**Recolouring a non-SVG widget** — `ColorFiltered`, because it wraps '
            'anything.',
        '**Complex artwork you need real control over** — Flutter Shape '
            'Maker. It is the only one that keeps the shapes separable.',
        '**Gradients** — `ShaderMask`, over whichever of the above got you '
            'the shape.',
      ]),
      PostProse(
        'It is never one way. If you know a fifth, I want to hear it.',
      ),
    ],
  );

  // ── Planned ───────────────────────────────────────────────────────────────
  // No body, no url — these render as unlinked cards and generate no route.
  // Give one a `body` and its page appears on the next build.

  static const PostModel _riverpodPrerender = PostModel(
    slug: 'riverpod-cannot-prerender',
    title: 'Why Riverpod cannot live in a pre-rendered page',
    topic: 'Architecture',
    date: 'Coming',
    readMinutes: 6,
    excerpt: 'A provider read is only legal inside a synchronous build. Once '
        'you await, you are somewhere else entirely — and the crawler gets a '
        'spinner.',
    tags: ['Jaspr', 'Riverpod', 'SEO'],
  );

  static const PostModel _lastTenPercent = PostModel(
    slug: 'last-ten-percent',
    title: 'The last 10% is the whole product',
    topic: 'Craft',
    date: 'Coming',
    readMinutes: 4,
    excerpt: 'Empty states, error copy, the easing curve on a sheet. Nobody '
        'scopes them and everybody notices them.',
    tags: ['Design', 'Craft'],
  );

  static const PostModel _offlineFirst = PostModel(
    slug: 'offline-first-kenya',
    title: 'Offline-first is not a feature here',
    topic: 'Flutter',
    date: 'Coming',
    readMinutes: 8,
    excerpt: 'Building for mid-range phones on unreliable networks changes '
        'what "done" means. The write queue is the architecture.',
    tags: ['Flutter', 'Offline', 'HealthX'],
  );
}
