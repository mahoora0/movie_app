import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/models/movie_detail.dart';
import 'package:movie_app/models/person.dart';
import 'package:movie_app/models/watch_provider.dart';
import 'package:movie_app/services/tmdb_service.dart';
import 'package:movie_app/services/favorites_service.dart';
import 'package:movie_app/services/settings_service.dart';

// Services
final tmdbServiceProvider = Provider((ref) => TmdbService());
final favoritesServiceProvider = Provider((ref) => FavoritesService());
final settingsServiceProvider = Provider((ref) => SettingsService());

// Theme (영구 저장)
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // 초기값은 system, 실제 저장된 값은 main.dart에서 초기화 시 설정
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    // 설정 저장
    ref.read(settingsServiceProvider).setThemeMode(mode);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

// Paginated Movies State
class PaginatedMoviesState {
  final List<Movie> movies;
  final int currentPage;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const PaginatedMoviesState({
    this.movies = const [],
    this.currentPage = 0,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  PaginatedMoviesState copyWith({
    List<Movie>? movies,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return PaginatedMoviesState(
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

// Paginated Movies Notifier
class PaginatedMoviesNotifier extends StateNotifier<PaginatedMoviesState> {
  final TmdbService _service;
  final Future<List<Movie>> Function(TmdbService service, int page) _fetcher;

  PaginatedMoviesNotifier(this._service, this._fetcher)
    : super(const PaginatedMoviesState()) {
    loadMore();
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final nextPage = state.currentPage + 1;
      final newMovies = await _fetcher(_service, nextPage);

      state = state.copyWith(
        movies: [...state.movies, ...newMovies],
        currentPage: nextPage,
        isLoading: false,
        hasMore: newMovies.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = const PaginatedMoviesState();
    await loadMore();
  }
}

// Paginated Movie Providers
final popularMoviesProvider =
    StateNotifierProvider<PaginatedMoviesNotifier, PaginatedMoviesState>((ref) {
      final service = ref.watch(tmdbServiceProvider);
      return PaginatedMoviesNotifier(
        service,
        (s, page) => s.getPopularMovies(page: page),
      );
    });

final nowPlayingMoviesProvider =
    StateNotifierProvider<PaginatedMoviesNotifier, PaginatedMoviesState>((ref) {
      final service = ref.watch(tmdbServiceProvider);
      return PaginatedMoviesNotifier(
        service,
        (s, page) => s.getNowPlayingMovies(page: page),
      );
    });

final topRatedMoviesProvider =
    StateNotifierProvider<PaginatedMoviesNotifier, PaginatedMoviesState>((ref) {
      final service = ref.watch(tmdbServiceProvider);
      return PaginatedMoviesNotifier(
        service,
        (s, page) => s.getTopRatedMovies(page: page),
      );
    });

final upcomingMoviesProvider =
    StateNotifierProvider<PaginatedMoviesNotifier, PaginatedMoviesState>((ref) {
      final service = ref.watch(tmdbServiceProvider);
      return PaginatedMoviesNotifier(
        service,
        (s, page) => s.getUpcomingMovies(page: page),
      );
    });

// Movie Detail
final movieDetailProvider = FutureProvider.family<MovieDetail, int>((
  ref,
  movieId,
) async {
  final service = ref.watch(tmdbServiceProvider);
  return service.getMovieDetail(movieId);
});

final movieCreditsProvider = FutureProvider.family<List<Cast>, int>((
  ref,
  movieId,
) async {
  final service = ref.watch(tmdbServiceProvider);
  return service.getMovieCredits(movieId);
});

final similarMoviesProvider = FutureProvider.family<List<Movie>, int>((
  ref,
  movieId,
) async {
  final service = ref.watch(tmdbServiceProvider);
  return service.getSimilarMovies(movieId);
});

final movieTrailerProvider = FutureProvider.family<MovieVideo?, int>((
  ref,
  movieId,
) async {
  final service = ref.watch(tmdbServiceProvider);
  return service.getMovieTrailer(movieId);
});

// Watch Providers (스트리밍 정보)
final watchProvidersProvider = FutureProvider.family<WatchProviders, int>((
  ref,
  movieId,
) async {
  final service = ref.watch(tmdbServiceProvider);
  return service.getWatchProviders(movieId);
});

// Person (Actor)
final personDetailProvider = FutureProvider.family<Person, int>((
  ref,
  personId,
) async {
  final service = ref.watch(tmdbServiceProvider);
  return service.getPersonDetail(personId);
});

final personCreditsProvider = FutureProvider.family<List<PersonCredit>, int>((
  ref,
  personId,
) async {
  final service = ref.watch(tmdbServiceProvider);
  return service.getPersonMovieCredits(personId);
});

// Genres
final genresProvider = FutureProvider<List<Genre>>((ref) async {
  final service = ref.watch(tmdbServiceProvider);
  return service.getGenres();
});

final selectedGenreProvider = StateProvider<int?>((ref) => null);

final moviesByGenreProvider =
    StateNotifierProvider<PaginatedMoviesNotifier, PaginatedMoviesState>((ref) {
      final service = ref.watch(tmdbServiceProvider);
      final genreId = ref.watch(selectedGenreProvider);

      // genreId가 null이면 빈 상태 반환 (장르 미선택 시 크래시 방지)
      if (genreId == null) {
        return PaginatedMoviesNotifier(service, (s, page) async => []);
      }

      return PaginatedMoviesNotifier(
        service,
        (s, page) => s.getMoviesByGenre(genreId, page: page),
      );
    });

// Search
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider =
    StateNotifierProvider<PaginatedMoviesNotifier, PaginatedMoviesState>((ref) {
      final service = ref.watch(tmdbServiceProvider);
      final query = ref.watch(searchQueryProvider);

      if (query.isEmpty) {
        return PaginatedMoviesNotifier(service, (s, page) async => []);
      }

      return PaginatedMoviesNotifier(
        service,
        (s, page) => s.searchMovies(query, page: page),
      );
    });

// Favorites
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Movie>>(
  (ref) {
    final service = ref.watch(favoritesServiceProvider);
    return FavoritesNotifier(service);
  },
);

class FavoritesNotifier extends StateNotifier<List<Movie>> {
  final FavoritesService _service;

  FavoritesNotifier(this._service) : super([]) {
    _loadFavorites();
  }

  void _loadFavorites() {
    state = _service.getFavorites();
  }

  bool isFavorite(int movieId) {
    return state.any((movie) => movie.id == movieId);
  }

  Future<void> toggleFavorite(Movie movie) async {
    await _service.toggleFavorite(movie);
    _loadFavorites();
  }
}
