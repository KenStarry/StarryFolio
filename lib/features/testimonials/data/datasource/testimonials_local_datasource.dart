import '../../domain/model/testimonial_model.dart';

/// The testimonials, as compile-time constants.
///
/// ─────────────────────────────────────────────────────────────────────────
/// **Everything below is placeholder content, and every entry is marked
/// `draft: true`.**
///
/// While that flag is set, `TestimonialBand` renders a visible *Sample
/// content* marker beside the heading. That is the safeguard: `git push` to
/// `main` deploys this site, and a fabricated endorsement that looks real is
/// the thing to avoid. One that labels itself is just a layout fixture.
///
/// The people and companies here are invented. **No real person or
/// organisation is quoted**, deliberately — attributing an invented sentence
/// to a real client would be a fabricated endorsement no matter what the
/// comments around it say.
///
/// Replacing them:
///
/// 1. Swap `quote`, `name`, `role` and `company` for the real ones.
/// 2. Set `source` to where it can be verified — a LinkedIn recommendation,
///    a public review. A checkable quote is worth several unverifiable ones.
/// 3. Point `projectSlug` at the case study the work belongs to.
/// 4. Set `emphasis` on the featured entry to the clause worth reading if you
///    only read one — a **verbatim substring** of `quote`. It is set bright
///    against the rest; get it wrong and the whole quote just renders bright,
///    which is the safe failure.
/// 5. **Delete `draft: true`.** The sample marker disappears on its own.
///
/// The lengths here are chosen to exercise the layout: one long quote for the
/// flat featured slot, then shorter ones that have to sit level in a grid.
/// Real quotes that run much longer or shorter will change how the band sits.
/// ─────────────────────────────────────────────────────────────────────────
abstract final class TestimonialsLocalDatasource {
  static const List<TestimonialModel> testimonials = [
    TestimonialModel(
      slug: 'sample-featured',
      quote: 'He took a brief that was half a slide deck and came back with a '
          'shipped product. Design system, architecture, both store listings, '
          'all of it, without needing a second engineer or a project manager '
          'to sit between him and the work.',
      // Must be a verbatim substring of `quote` — this is the clause set
      // bright against the rest.
      emphasis: 'came back with a shipped product',
      name: 'Placeholder Name',
      role: 'Head of Product',
      company: 'Sample Company',
      projectSlug: 'healthx',
      featured: true,
      draft: true,
    ),
    TestimonialModel(
      slug: 'sample-two',
      quote: 'The rebuild moved our store rating a full point. Same features, '
          'a codebase the team could actually reason about.',
      name: 'Placeholder Name',
      role: 'Engineering Manager',
      company: 'Sample Company',
      projectSlug: 'britam-app',
      draft: true,
    ),
    TestimonialModel(
      slug: 'sample-three',
      quote: 'Turned up with opinions about the empty states. That is the '
          'part nobody scopes and everybody notices.',
      name: 'Placeholder Name',
      role: 'Design Lead',
      company: 'Sample Company',
      draft: true,
    ),
    TestimonialModel(
      slug: 'sample-four',
      quote: 'Handed over documentation we are still using a year later. '
          'Rare, and worth saying out loud.',
      name: 'Placeholder Name',
      role: 'CTO',
      company: 'Sample Company',
      projectSlug: 'flow',
      draft: true,
    ),
  ];
}
