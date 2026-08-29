import 'package:fpdart/fpdart.dart';

import '../../domain/model/testimonial_model.dart';
import '../../domain/repository/testimonials_repository.dart';
import '../datasource/testimonials_local_datasource.dart';

/// Reads from the bundled [TestimonialsLocalDatasource].
///
/// `async` even though the source is synchronous: that keeps the contract
/// identical to what an HTTP-backed implementation would expose, so the page
/// never has to change when the data moves.
class TestimonialsRepositoryImpl implements TestimonialsRepository {
  const TestimonialsRepositoryImpl();

  @override
  Future<Either<String, List<TestimonialModel>>> getTestimonials() async {
    try {
      // Quotes with no attribution are dropped rather than rendered. An
      // anonymous testimonial reads as invented even when it is not.
      return Right([
        for (final t in TestimonialsLocalDatasource.testimonials)
          if (t.quote.isNotEmpty && t.name.isNotEmpty) t,
      ]);
    } catch (e) {
      return const Left('Could not load testimonials.');
    }
  }
}
