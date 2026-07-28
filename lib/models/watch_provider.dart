import 'package:movie_app/core/constants/api_constants.dart';

/// 스트리밍 제공자 정보
class WatchProviders {
  final List<WatchProvider> flatrate; // 구독 스트리밍 (Netflix, Disney+ 등)
  final List<WatchProvider> rent; // 대여
  final List<WatchProvider> buy; // 구매
  final String? link; // TMDB 제공자 페이지 링크

  WatchProviders({
    this.flatrate = const [],
    this.rent = const [],
    this.buy = const [],
    this.link,
  });

  factory WatchProviders.fromJson(Map<String, dynamic> json, String region) {
    final results = json['results'] as Map<String, dynamic>?;
    if (results == null || !results.containsKey(region)) {
      return WatchProviders();
    }

    final regionData = results[region] as Map<String, dynamic>;

    return WatchProviders(
      flatrate: _parseProviders(regionData['flatrate']),
      rent: _parseProviders(regionData['rent']),
      buy: _parseProviders(regionData['buy']),
      link: regionData['link'] as String?,
    );
  }

  static List<WatchProvider> _parseProviders(dynamic data) {
    if (data == null) return [];
    return (data as List<dynamic>)
        .map((e) => WatchProvider.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 스트리밍 가능한 제공자가 있는지
  bool get hasStreamingOptions =>
      flatrate.isNotEmpty || rent.isNotEmpty || buy.isNotEmpty;

  /// 구독 스트리밍이 있는지
  bool get hasSubscription => flatrate.isNotEmpty;
}

/// 개별 스트리밍 제공자
class WatchProvider {
  final int providerId;
  final String providerName;
  final String? logoPath;
  final int displayPriority;

  WatchProvider({
    required this.providerId,
    required this.providerName,
    this.logoPath,
    this.displayPriority = 0,
  });

  factory WatchProvider.fromJson(Map<String, dynamic> json) {
    return WatchProvider(
      providerId: json['provider_id'] as int,
      providerName: json['provider_name'] as String,
      logoPath: json['logo_path'] as String?,
      displayPriority: json['display_priority'] as int? ?? 0,
    );
  }

  String? get logoUrl =>
      logoPath != null ? '${ApiConstants.posterW342}$logoPath' : null;
}
