import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A pointer dot with a trailing ring.
///
/// ## Why this is a `<script>` and not a `@client` island
///
/// An island exists to hydrate *stateful UI* — it costs a `ProviderScope`, a
/// place in the client bundle, and compilation for both the server and the
/// browser (CLAUDE.md §6). This is none of that: it owns no application state,
/// renders nothing the server needs to know about, and would be dead weight in
/// the Dart bundle. Twenty lines of DOM in a `<script>` is the honest shape,
/// and it keeps `NavBar` as the site's only island.
///
/// ## The rules it follows
///
/// * **The native cursor is only hidden once the script confirms it is
///   running**, by adding `.has-cursor` to `<body>`. If the script never
///   executes, the real pointer is untouched — the failure mode is "no custom
///   cursor", never "no cursor at all".
/// * **Off on coarse pointers.** A touch device has no pointer to decorate.
/// * **Off under `prefers-reduced-motion`.** A lagging ring is exactly the kind
///   of continuous motion that setting exists to suppress. The stylesheet
///   enforces this a second time with `display: none`, so a stray class can
///   never strand someone without a pointer.
/// * **Text inputs keep the native caret**, because a dot floating over a
///   field tells you nothing about where the text will land — the pair fades
///   out over one entirely.
/// * **The geometry never changes.** Hover, press and idle are all the same
///   two shapes at the same two sizes; only colour, fill and bloom differ. A
///   cursor that resizes under the hand stops reading as a cursor, and it
///   makes precise targeting harder exactly when you are aiming at something.
///
/// Positioning is written to `transform` and the stylesheet owns `translate`
/// for centring, so the script and the CSS can never overwrite each other.
/// Nothing writes `scale`.
class CustomCursor extends StatelessComponent {
  const CustomCursor({super.key});

  @override
  Component build(BuildContext context) {
    return const Component.fragment([
      div(
        id: 'cursor-ring',
        classes: 'cursor-ring',
        attributes: {'aria-hidden': 'true'},
        [],
      ),
      div(
        id: 'cursor-dot',
        classes: 'cursor-dot',
        attributes: {'aria-hidden': 'true'},
        [],
      ),
      RawText('<script>$_script</script>'),
    ]);
  }
}

/// Kept as one `const` string so it is emitted verbatim into every page and
/// costs no request. Written in ES5-compatible style — it runs before anything
/// else on the page and has no build step to transpile it.
const String _script = '''
(function(){
  var mq = window.matchMedia;
  if (!mq) return;
  if (mq('(pointer: coarse)').matches) return;
  if (mq('(prefers-reduced-motion: reduce)').matches) return;

  var dot = document.getElementById('cursor-dot');
  var ring = document.getElementById('cursor-ring');
  if (!dot || !ring) return;

  var body = document.body;
  body.classList.add('has-cursor');

  var mx = 0, my = 0, rx = 0, ry = 0, ready = false, frame = 0;

  // The ring eases toward the pointer at a fixed fraction per frame. 0.19 is
  // slow enough to read as a trail and fast enough that it never feels
  // detached from the hand.
  function loop() {
    rx += (mx - rx) * 0.19;
    ry += (my - ry) * 0.19;
    ring.style.transform = 'translate3d(' + rx + 'px,' + ry + 'px,0)';
    if (Math.abs(mx - rx) > 0.15 || Math.abs(my - ry) > 0.15) {
      frame = requestAnimationFrame(loop);
    } else {
      frame = 0;
    }
  }

  var INTERACTIVE = 'a,button,[role="button"],label,summary,input,textarea,select,[tabindex]:not([tabindex="-1"])';
  var TEXTUAL = 'input,textarea,select';

  document.addEventListener('mousemove', function (e) {
    mx = e.clientX;
    my = e.clientY;

    if (!ready) {
      // Snap the ring to the first known position rather than letting it fly
      // in from 0,0.
      ready = true;
      rx = mx;
      ry = my;
      body.classList.add('cursor-ready');
    }

    dot.style.transform = 'translate3d(' + mx + 'px,' + my + 'px,0)';
    body.classList.remove('cursor-gone');
    if (!frame) frame = requestAnimationFrame(loop);

    var el = e.target;
    var hit = el && el.closest ? el.closest(INTERACTIVE) : null;
    var textual = !!(hit && hit.matches(TEXTUAL));
    // A text field is not also "active": it fades the pair out, and
    // lighting them up on the way would be a flicker.
    body.classList.toggle('cursor-active', !!hit && !textual);
    body.classList.toggle('cursor-text', textual);
  }, { passive: true });

  document.addEventListener('mousedown', function () {
    body.classList.add('cursor-down');
  }, { passive: true });

  document.addEventListener('mouseup', function () {
    body.classList.remove('cursor-down');
  }, { passive: true });

  // Leaving the window, and returning to a tab that moved on without us.
  document.addEventListener('mouseleave', function () {
    body.classList.add('cursor-gone');
  });

  window.addEventListener('blur', function () {
    body.classList.add('cursor-gone');
    body.classList.remove('cursor-down');
  });
})();
''';
