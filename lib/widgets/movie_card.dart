import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/theme/theme.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/providers/providers.dart';

class MovieCard extends ConsumerStatefulWidget {
  final Movie movie;
  final double? width;
  final double? height;
  final String? heroTagPrefix;
  final bool showMargin;

  const MovieCard({
    super.key,
    required this.movie,
    this.width,
    this.height,
    this.heroTagPrefix,
    this.showMargin = true,
  });

  @override
  ConsumerState<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends ConsumerState<MovieCard>
    with SingleTickerProviderStateMixin {
  bool _isPrecached = false;
  Future<void>? _precacheFuture;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AppComponents.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: AppComponents.scaleNormal,
      end: AppComponents.scalePressed,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheFuture = _precacheImage();
    _prefetchMovieDetail();
  }

  Future<void> _precacheImage() async {
    if (_isPrecached || widget.movie.posterUrl == null) return;

    try {
      await precacheImage(
        CachedNetworkImageProvider(widget.movie.posterUrl!),
        context,
      );
      if (mounted) {
        setState(() => _isPrecached = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isPrecached = true);
      }
    }
  }

  void _prefetchMovieDetail() {
    ref.read(movieDetailProvider(widget.movie.id));
  }

  Future<void> _onTap() async {
    final heroTag = widget.heroTagPrefix != null
        ? '${widget.heroTagPrefix}-${widget.movie.id}'
        : 'movie-${widget.movie.id}';

    if (!_isPrecached && _precacheFuture != null) {
      await _precacheFuture!.timeout(
        const Duration(milliseconds: 500),
        onTimeout: () {},
      );
    }

    if (mounted) {
      final posterPath = widget.movie.posterPath ?? '';
      context.push(
          '/movie/${widget.movie.id}?heroTag=$heroTag&poster=$posterPath');
    }
  }

  @override
  Widget build(BuildContext context) {
    final heroTag = widget.heroTagPrefix != null
        ? '${widget.heroTagPrefix}-${widget.movie.id}'
        : 'movie-${widget.movie.id}';

    return GestureDetector(
      onTap: _onTap,
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: widget.width ?? AppComponents.movieCardWidth,
          margin: widget.showMargin ? EdgeInsets.only(right: AppSpacing.cardGap) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Hero(
                  tag: heroTag,
                  child: _buildPosterImage(context),
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                widget.movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.titleMedium,
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                _buildSubtitle(),
                style: context.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (widget.movie.ratingText.isNotEmpty) {
      parts.add(widget.movie.ratingText);
    }
    if (widget.movie.year.isNotEmpty) {
      parts.add(widget.movie.year);
    }
    return parts.join(' · ');
  }

  Widget _buildPosterImage(BuildContext context) {
    if (widget.movie.posterUrl == null) {
      return _buildPlaceholder(context);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppComponents.radiusXl),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildPlaceholder(context),
          Image(
            image: CachedNetworkImageProvider(widget.movie.posterUrl!),
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedOpacity(
                opacity: frame != null ? 1.0 : 0.0,
                duration: AppComponents.animationNormal,
                child: child,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppComponents.radiusXl),
      child: Container(
        color: context.surfaceColor,
        child: Center(
          child: Icon(
            Icons.movie_outlined,
            size: 40,
            color: context.textTertiaryColor,
          ),
        ),
      ),
    );
  }
}
