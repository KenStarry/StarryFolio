import 'package:fpdart/fpdart.dart';

import '../model/about_profile.dart';

/// Contract for reading the profile behind `/about`.
///
/// `Left` carries a human-readable message ready to render; `Right` carries
/// the whole profile. Presentation depends on this interface only — never on
/// an implementation — so moving this content behind a CMS is a one-line
/// change at the composition root.
abstract class AboutRepository {
  Future<Either<String, AboutProfile>> getProfile();
}
