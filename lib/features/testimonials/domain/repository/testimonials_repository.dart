import 'package:fpdart/fpdart.dart';

import '../model/testimonial_model.dart';

/// Contract for reading testimonials.
///
/// `Left` carries a human-readable message ready to render; `Right` carries the
/// data — and an empty `Right` is a normal, expected result, not an error.
/// Nobody has said anything yet is a different situation from something broke.
abstract class TestimonialsRepository {
  Future<Either<String, List<TestimonialModel>>> getTestimonials();
}
