import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/exceptions/app_exception.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/models/movie_detail.dart';
import 'package:movie_app/models/person.dart';
import 'package:movie_app/models/watch_provider.dart';

export 'package:movie_app/models/movie_detail.dart' show Genre;

class TmdbService {
  late final Dio _dio;
  late final String _regionCode; // 스트리밍 제공자용 지역 코드

  TmdbService() {
    final locale = PlatformDispatcher.instance.locale;
    final languageCode =
        '${locale.languageCode}-${locale.countryCode ?? locale.languageCode.toUpperCase()}';

    // 지역 코드 설정 (countryCode가 없으면 languageCode 대문자 사용)
    _regionCode = locale.countryCode ?? locale.languageCode.toUpperCase();

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        queryParameters: {
          'api_key': ApiConstants.apiKey,
          'language': languageCode,
        },
      ),
    );
  }

  /// 모든 API 요청을 감싸는 에러 핸들링 래퍼
  Future<T> _safeRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ParseException('데이터 처리 중 오류가 발생했습니다: $e');
    }
  }

  /// DioException을 AppException으로 변환
  AppException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 500) {
            return ServerException(
              message: '서버에 문제가 발생했습니다 ($statusCode)',
              statusCode: statusCode,
            );
          } else if (statusCode == 401) {
            return const ApiException(message: 'API 인증에 실패했습니다');
          } else if (statusCode == 404) {
            return const ApiException(message: '요청한 데이터를 찾을 수 없습니다');
          } else if (statusCode >= 400) {
            return ApiException(
              message: '요청을 처리할 수 없습니다 ($statusCode)',
              statusCode: statusCode,
            );
          }
        }
        return const ApiException();
      case DioExceptionType.cancel:
        return const ApiException(message: '요청이 취소되었습니다');
      default:
        return NetworkException(e.message ?? '알 수 없는 네트워크 오류');
    }
  }

  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    return _safeRequest(() async {
      final response = await _dio.get(
        ApiConstants.popularMovies,
        queryParameters: {'page': page},
      );
      return _parseMovieList(response.data);
    });
  }

  Future<List<Movie>> getNowPlayingMovies({int page = 1}) async {
    return _safeRequest(() async {
      final response = await _dio.get(
        ApiConstants.nowPlayingMovies,
        queryParameters: {'page': page},
      );
      return _parseMovieList(response.data);
    });
  }

  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    return _safeRequest(() async {
      final response = await _dio.get(
        ApiConstants.topRatedMovies,
        queryParameters: {'page': page},
      );
      return _parseMovieList(response.data);
    });
  }

  Future<List<Movie>> getUpcomingMovies({int page = 1}) async {
    return _safeRequest(() async {
      final response = await _dio.get(
        ApiConstants.upcomingMovies,
        queryParameters: {'page': page},
      );
      return _parseMovieList(response.data);
    });
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.isEmpty) return [];
    return _safeRequest(() async {
      final response = await _dio.get(
        ApiConstants.searchMovies,
        queryParameters: {'query': query, 'page': page},
      );
      return _parseMovieList(response.data);
    });
  }

  Future<MovieDetail> getMovieDetail(int movieId) async {
    return _safeRequest(() async {
      final response = await _dio.get(ApiConstants.movieDetail(movieId));
      return MovieDetail.fromJson(response.data);
    });
  }

  Future<List<Cast>> getMovieCredits(int movieId) async {
    return _safeRequest(() async {
      final response = await _dio.get(ApiConstants.movieCredits(movieId));
      final castList = response.data['cast'] as List<dynamic>;
      return castList
          .take(10)
          .map((e) => Cast.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<Movie>> getSimilarMovies(int movieId, {int page = 1}) async {
    return _safeRequest(() async {
      final response = await _dio.get(
        ApiConstants.similarMovies(movieId),
        queryParameters: {'page': page},
      );
      return _parseMovieList(response.data);
    });
  }

  Future<List<Genre>> getGenres() async {
    return _safeRequest(() async {
      final response = await _dio.get('/genre/movie/list');
      final genres = response.data['genres'] as List<dynamic>;
      return genres
          .map((e) => Genre.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    return _safeRequest(() async {
      final response = await _dio.get(
        '/discover/movie',
        queryParameters: {
          'with_genres': genreId,
          'page': page,
          'sort_by': 'popularity.desc',
        },
      );
      return _parseMovieList(response.data);
    });
  }

  Future<List<MovieVideo>> getMovieVideos(int movieId) async {
    return _safeRequest(() async {
      final response = await _dio.get('/movie/$movieId/videos');
      final results = response.data['results'] as List<dynamic>;
      return results
          .map((e) => MovieVideo.fromJson(e as Map<String, dynamic>))
          .where((v) => v.site == 'YouTube')
          .toList();
    });
  }

  Future<MovieVideo?> getMovieTrailer(int movieId) async {
    final videos = await getMovieVideos(movieId);
    // 공식 트레일러 우선, 없으면 첫 번째 영상
    return videos.isEmpty
        ? null
        : videos.firstWhere(
            (v) => v.type == 'Trailer' && v.official,
            orElse: () => videos.firstWhere(
              (v) => v.type == 'Trailer',
              orElse: () => videos.first,
            ),
          );
  }

  List<Movie> _parseMovieList(Map<String, dynamic> data) {
    final results = data['results'] as List<dynamic>;
    return results
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Person (Actor) endpoints
  Future<Person> getPersonDetail(int personId) async {
    return _safeRequest(() async {
      final response = await _dio.get(ApiConstants.personDetail(personId));
      return Person.fromJson(response.data);
    });
  }

  Future<List<PersonCredit>> getPersonMovieCredits(int personId) async {
    return _safeRequest(() async {
      final response = await _dio.get(
        ApiConstants.personMovieCredits(personId),
      );
      final castList = response.data['cast'] as List<dynamic>;
      final credits = castList
          .map((e) => PersonCredit.fromJson(e as Map<String, dynamic>))
          .toList();
      // Sort by release date (newest first), filter out items without poster
      credits.sort((a, b) {
        if (a.releaseDate == null && b.releaseDate == null) return 0;
        if (a.releaseDate == null) return 1;
        if (b.releaseDate == null) return -1;
        return b.releaseDate!.compareTo(a.releaseDate!);
      });
      return credits;
    });
  }

  /// 스트리밍 제공자 정보 가져오기 (사용자 지역 기준)
  Future<WatchProviders> getWatchProviders(int movieId) async {
    return _safeRequest(() async {
      final response = await _dio.get('/movie/$movieId/watch/providers');
      return WatchProviders.fromJson(response.data, _regionCode);
    });
  }
}
