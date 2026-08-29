import 'package:fpdart/fpdart.dart';

import '../../domain/model/testimonial_model.dart';
import '../../domain/repository/testimonials_repository.dart';

/// Canned data behind an artificial delay, for exercising the band's layout
/// without real quotes.
///
/// **Never wire this up at the composition root.** It exists so the component
/// can be developed against something; the names in it are placeholders and
/// putting them on the live site would be publishing invented endorsements.
/// Swap it in locally, look at the layout, swap it back out.
class TestimonialsMockRepository implements TestimonialsRepository {
  const TestimonialsMockRepository({
    this.delay = const Duration(milliseconds: 600),
  });

  final Duration delay;

  @override
  Future<Either<String, List<TestimonialModel>>> getTestimonials() async {
    await Future<void>.delayed(delay);
    return const Right([
      TestimonialModel(
        slug: 'sample-one',
        quote: 'PLACEHOLDER, layout only. Replace with a real quote before '
            'this is ever wired up at the composition root.',
        name: 'Sample Name',
        role: 'Sample Role',
        company: 'Sample Co',
        featured: true,
      ),
      TestimonialModel(
        slug: 'sample-two',
        quote: 'PLACEHOLDER, layout only.',
        name: 'Sample Name',
        role: 'Sample Role',
      ),
    ]);
  }
}
