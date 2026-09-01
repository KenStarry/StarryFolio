import '../../domain/model/testimonial_model.dart';

/// The testimonials, as compile-time constants.
///
/// ─────────────────────────────────────────────────────────────────────────
/// **Only real quotes belong in this list.**
///
/// `git push` to `main` deploys this site, so a fabricated endorsement that
/// looks real is the thing to avoid. Anything authored as a stand-in must
/// carry `draft: true`, which makes `TestimonialBand` render a visible
/// *Sample content* marker beside the heading, and it must never name a real
/// person or organisation.
///
/// Adding one:
///
/// 1. Paste the quote verbatim. The only edit permitted is punctuation, to
///    house style: this site does not use em dashes, so one inside a quote
///    becomes a full stop or a comma. Never reword what somebody said.
/// 2. `source` should point at somewhere it can be checked, where such a
///    place exists. A verifiable quote is worth several unverifiable ones.
/// 3. `projectSlug` links it to the build it came out of, if it came out of
///    one.
/// 4. `emphasis` is the clause set bright against the rest, and must be a
///    **verbatim substring** of `quote`.
/// ─────────────────────────────────────────────────────────────────────────
abstract final class TestimonialsLocalDatasource {
  static const List<TestimonialModel> testimonials = [_sheilla];

  /// The first one in, and deliberately not dressed up as something it is
  /// not. The attribution says plainly that this is a supporter rather than a
  /// client, because a reader works that out anyway and a quote that is
  /// honest about its source is worth more than one pretending to be a
  /// reference.
  ///
  /// Verbatim except for one em dash in `development isn't a career—it's a
  /// calling`, which house style turns into a full stop. No word changed.
  static const TestimonialModel _sheilla = TestimonialModel(
    slug: 'sheilla',
    quote: 'Ken is a rare breed of creator who builds with genuine soul. '
        'Having been around his creative energy and witnessed how he builds, '
        "I've watched his brilliant mind take abstract thoughts and "
        'effortlessly translate them into clean, beautiful architecture. To '
        "Ken, development isn't a career. It's a calling. He possesses an "
        'inspiring dedication to the user, choosing true craftsmanship over '
        "shortcuts to ensure every app is fulfilling. He doesn't just build "
        'software people need; he creates unique experiences that people '
        'love. His passion is completely captivating, and his heart for his '
        'work makes him a truly remarkable person to know.',
    // Still a verbatim substring, and one word was not changed — but a
    // longer span than the original, because `emphasis` now does two jobs.
    // Inside the full quote it is the clause set bright; on the home band it
    // stands *alone* as the pull-quote. A fragment starting mid-sentence on a
    // lowercase `he` reads fine in context and loses its subject out of it.
    emphasis: "He doesn't just build software people need; he creates unique "
        'experiences that people love.',
    name: 'Sheilla',
    role: 'Day 1 supporter, and forever a fan',
    featured: true,
  );
}
