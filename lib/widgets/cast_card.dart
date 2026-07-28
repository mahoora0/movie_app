import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/theme/theme.dart';
import 'package:movie_app/models/movie_detail.dart';

/// 출연진 카드 - Hero 애니메이션을 위해 이미지를 미리 로딩
class CastCard extends StatefulWidget {
  final Cast cast;
  final int movieId;

  const CastCard({super.key, required this.cast, required this.movieId});

  @override
  State<CastCard> createState() => _CastCardState();
}

class _CastCardState extends State<CastCard> {
  bool _isPrecached = false;
  Future<void>? _precacheFuture;

  String? get _imageUrl {
    if (widget.cast.profilePath == null) return null;
    return '${ApiConstants.posterW342}${widget.cast.profilePath}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheFuture = _precacheImage();
  }

  Future<void> _precacheImage() async {
    final url = _imageUrl;
    if (_isPrecached || url == null) return;

    try {
      await precacheImage(CachedNetworkImageProvider(url), context);
      if (mounted) {
        setState(() => _isPrecached = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isPrecached = true);
      }
    }
  }

  Future<void> _onTap() async {
    final castHeroTag = 'cast-${widget.movieId}-${widget.cast.id}';

    // 이미지 로딩 완료까지 잠시 대기 (최대 500ms)
    if (!_isPrecached && _precacheFuture != null) {
      await _precacheFuture!.timeout(
        const Duration(milliseconds: 500),
        onTimeout: () {},
      );
    }

    if (mounted) {
      context.push(
        '/actor/${widget.cast.id}?heroTag=$castHeroTag&profile=${widget.cast.profilePath ?? ''}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final castHeroTag = 'cast-${widget.movieId}-${widget.cast.id}';
    final url = _imageUrl;

    return GestureDetector(
      onTap: _onTap,
      child: Container(
        width: 80,
        margin: EdgeInsets.only(right: AppSpacing.md),
        child: Column(
          children: [
            Hero(
              tag: castHeroTag,
              // push(상세로 이동)할 때만 원형 → 사각형 애니메이션, pop(돌아올 때)은 기본
              flightShuttleBuilder:
                  (
                    flightContext,
                    animation,
                    flightDirection,
                    fromHeroContext,
                    toHeroContext,
                  ) {
                    // pop일 때는 기본 Hero 애니메이션 사용 (toHero의 child 반환)
                    if (flightDirection == HeroFlightDirection.pop) {
                      return toHeroContext.widget;
                    }

                    // push일 때만 커스텀 애니메이션 (원형 → 사각형)
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        final radius = 36.0 * (1 - animation.value); // 36 → 0

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(radius),
                          child: url != null
                              ? Image(
                                  image: CachedNetworkImageProvider(url),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Theme.of(context).colorScheme.surface,
                                  child: const Icon(Icons.person),
                                ),
                        );
                      },
                    );
                  },
              child: _buildProfileImage(context),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              widget.cast.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.captionSmall.copyWith(
                color: context.textPrimaryColor,
              ),
            ),
            Text(
              widget.cast.character ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.captionSmall,
            ),
          ],
        ),
      ),
    );
  }

  /// 원형 프로필 이미지
  Widget _buildProfileImage(BuildContext context) {
    final url = _imageUrl;

    return ClipOval(
      child: Container(
        width: 72,
        height: 72,
        color: context.surfaceColor,
        child: url != null
            ? Image(
                image: CachedNetworkImageProvider(url),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, color: context.textTertiaryColor),
              )
            : Icon(Icons.person, color: context.textTertiaryColor),
      ),
    );
  }
}
