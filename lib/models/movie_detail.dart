import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/models/movie_mixin.dart';

class MovieDetail with MovieMixin {
  final int id;
  final String title;
  final String? overview;
  @override
  final String? posterPath;
  @override
  final String? backdropPath;
  @override
  final double voteAverage;
  final int voteCount;
  @override
  final String? releaseDate;
  final List<Genre> genres;
  final int? runtime;
  final String? tagline;
  final int? budget;
  final int? revenue;
  final String? status;

  MovieDetail({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    this.releaseDate,
    required this.genres,
    this.runtime,
    this.tagline,
    this.budget,
    this.revenue,
    this.status,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num).toDouble(),
      voteCount: json['vote_count'] as int,
      releaseDate: json['release_date'] as String?,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      runtime: json['runtime'] as int?,
      tagline: json['tagline'] as String?,
      budget: json['budget'] as int?,
      revenue: json['revenue'] as int?,
      status: json['status'] as String?,
    );
  }

  /// 러닝타임 텍스트 (예: "2h 30m")
  String get runtimeText {
    if (runtime == null) return '';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// 장르 텍스트 (쉼표로 구분)
  String get genresText => genres.map((g) => g.name).join(', ');
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'] as int, name: json['name'] as String);
  }
}

class Cast {
  final int id;
  final String name;
  final String? character;
  final String? profilePath;

  Cast({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'] as int,
      name: json['name'] as String,
      character: json['character'] as String?,
      profilePath: json['profile_path'] as String?,
    );
  }

  String? get profileUrl =>
      profilePath != null ? '${ApiConstants.posterW342}$profilePath' : null;
}

class MovieVideo {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final bool official;

  MovieVideo({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.official,
  });

  factory MovieVideo.fromJson(Map<String, dynamic> json) {
    return MovieVideo(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      site: json['site'] as String,
      type: json['type'] as String,
      official: json['official'] as bool? ?? false,
    );
  }

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';
  String get thumbnailUrl => 'https://img.youtube.com/vi/$key/hqdefault.jpg';
}
