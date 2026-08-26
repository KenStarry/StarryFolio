import '../../domain/model/post_model.dart';

/// The written pieces, as compile-time constants.
///
/// **These are sample entries** so the writing section has something to render —
/// replace them with real posts before launch.
///
/// Deliberately `const` and synchronous for the same reason as the projects
/// source: the static build has to resolve this during pre-render, and the
/// repository on top exists so the page never learns where the data came from.
abstract final class WritingLocalDatasource {
  static const List<PostModel> posts = [
    PostModel(
      slug: 'riverpod-cannot-prerender',
      title: 'Why Riverpod cannot live in a pre-rendered page',
      excerpt: 'A provider read is only legal inside a synchronous build. Once '
          'you await, you are somewhere else entirely — and the crawler gets a '
          'spinner.',
      date: 'Mar 2026',
      readMinutes: 6,
      topic: 'Architecture',
    ),
    PostModel(
      slug: 'last-ten-percent',
      title: 'The last 10% is the whole product',
      excerpt: 'Empty states, error copy, the easing curve on a sheet. Nobody '
          'scopes them and everybody notices them.',
      date: 'Jan 2026',
      readMinutes: 4,
      topic: 'Craft',
    ),
    PostModel(
      slug: 'offline-first-kenya',
      title: 'Offline-first is not a feature here',
      excerpt: 'Building for mid-range phones on unreliable networks changes '
          'what "done" means. The write queue is the architecture.',
      date: 'Nov 2025',
      readMinutes: 8,
      topic: 'Flutter',
    ),
  ];
}
