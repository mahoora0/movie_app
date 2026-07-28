class ApiConstants {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  // 빌드 시 --dart-define=TMDB_API_KEY=your_key 로 주입
  static const String _apiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: '',
  );

  /// API 키 반환. 빈 값이면 개발 모드에서 에러를 출력.
  static String get apiKey {
    assert(
      _apiKey.isNotEmpty,
      '⚠️ TMDB_API_KEY가 설정되지 않았습니다!\n'
      '실행 시 --dart-define=TMDB_API_KEY=your_key 옵션을 추가해주세요.\n'
      '예: flutter run --dart-define=TMDB_API_KEY=your_key',
    );
    return _apiKey;
  }

  // Image sizes
  static const String posterW342 = '$imageBaseUrl/w342';
  static const String posterW500 = '$imageBaseUrl/w500';
  static const String backdropW780 = '$imageBaseUrl/w780';
  static const String originalSize = '$imageBaseUrl/original';

  // Endpoints
  static const String popularMovies = '/movie/popular';
  static const String nowPlayingMovies = '/movie/now_playing';
  static const String topRatedMovies = '/movie/top_rated';
  static const String upcomingMovies = '/movie/upcoming';
  static const String searchMovies = '/search/movie';
  static String movieDetail(int id) => '/movie/$id';
  static String movieCredits(int id) => '/movie/$id/credits';
  static String similarMovies(int id) => '/movie/$id/similar';

  // Person endpoints
  static String personDetail(int id) => '/person/$id';
  static String personMovieCredits(int id) => '/person/$id/movie_credits';
}
