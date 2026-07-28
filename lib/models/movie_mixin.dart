import 'package:movie_app/core/constants/api_constants.dart';

/// Movie와 MovieDetail에서 공통으로 사용하는 속성과 메서드를 정의하는 mixin
mixin MovieMixin {
  String? get posterPath;
  String? get backdropPath;
  String? get releaseDate;
  double get voteAverage;

  /// 포스터 이미지 URL (w342 사이즈)
  String? get posterUrl =>
      posterPath != null ? '${ApiConstants.posterW342}$posterPath' : null;

  /// 포스터 이미지 URL (w500 고해상도)
  String? get posterUrlHigh =>
      posterPath != null ? '${ApiConstants.posterW500}$posterPath' : null;

  /// 배경 이미지 URL (w780 사이즈)
  String? get backdropUrl =>
      backdropPath != null ? '${ApiConstants.backdropW780}$backdropPath' : null;

  /// 개봉 연도 추출
  String get year {
    if (releaseDate == null || releaseDate!.isEmpty) return '';
    return releaseDate!.split('-').first;
  }

  /// 평점 텍스트 (소수점 1자리)
  String get ratingText => voteAverage.toStringAsFixed(1);
}
