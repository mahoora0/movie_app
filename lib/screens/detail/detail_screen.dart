import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/theme/theme.dart';
import 'package:movie_app/l10n/app_localizations.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/models/movie_detail.dart';
import 'package:movie_app/models/watch_provider.dart';
import 'package:movie_app/providers/providers.dart';
import 'package:movie_app/widgets/cast_card.dart';
import 'package:movie_app/widgets/movie_card.dart';
import 'package:movie_app/widgets/shimmer_loading.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends ConsumerWidget {
  final int movieId;
  final String heroTag;
  final String? posterPath;

  const DetailScreen({
    super.key,
    required this.movieId,
    required this.heroTag,
    this.posterPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieDetailAsync = ref.watch(movieDetailProvider(movieId));
    final creditsAsync = ref.watch(movieCreditsProvider(movieId));
    final similarMoviesAsync = ref.watch(similarMoviesProvider(movieId));
    final watchProvidersAsync = ref.watch(watchProvidersProvider(movieId));
    final favorites = ref.watch(favoritesProvider);

    final movie = movieDetailAsync.valueOrNull;
    final isLoading = movieDetailAsync.isLoading;
    final hasError = movieDetailAsync.hasError;
    final isFavorite = movie != null && favorites.any((m) => m.id == movieId);

    if (hasError) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: context.textTertiaryColor,
              ),
              SizedBox(height: AppSpacing.md),
              Text(AppLocalizations.of(context)!.error, style: context.caption),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context, ref, movie, isFavorite),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, movie),
                    SizedBox(height: AppSpacing.md),
                    if (isLoading) ...[
                      ShimmerLoading(
                        height: 32,
                        width: 200,
                        borderRadius: BorderRadius.circular(
                          AppComponents.radiusSm,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      ShimmerLoading(
                        height: 100,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(
                          AppComponents.radiusSm,
                        ),
                      ),
                    ] else if (movie != null) ...[
                      _buildInfo(context, movie),
                      SizedBox(height: AppSpacing.md),
                      _buildTrailerButton(context, ref),
                      SizedBox(height: AppSpacing.lg),
                      _buildWatchProviders(context, watchProvidersAsync),
                      if (movie.overview?.isNotEmpty ?? false) ...[
                        SizedBox(height: AppSpacing.lg),
                        _buildOverview(context, movie),
                      ],
                      SizedBox(height: AppSpacing.lg),
                      _buildCast(context, creditsAsync),
                      SizedBox(height: AppSpacing.lg),
                      _buildSimilarMovies(context, similarMoviesAsync),
                    ],
                    SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, String? path) {
    final imagePath = path ?? posterPath;
    return Hero(
      tag: heroTag,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppComponents.radiusLg),
        child: SizedBox(
          width: 130,
          height: 195,
          child: imagePath != null && imagePath.isNotEmpty
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: context.surfaceColor,
                      child: Center(
                        child: Icon(
                          Icons.movie_outlined,
                          size: 40,
                          color: context.textTertiaryColor,
                        ),
                      ),
                    ),
                    Image(
                      image: CachedNetworkImageProvider(
                        '${ApiConstants.posterW342}$imagePath',
                      ),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(),
                    ),
                  ],
                )
              : Container(
                  color: context.surfaceColor,
                  child: Center(
                    child: Icon(
                      Icons.movie_outlined,
                      size: 40,
                      color: context.textTertiaryColor,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    MovieDetail? movie,
    bool isFavorite,
  ) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: context.surfaceColor),
            if (movie?.backdropUrl != null)
              CachedNetworkImage(
                imageUrl: movie!.backdropUrl!,
                fit: BoxFit.cover,
                fadeInDuration: AppComponents.animationNormal,
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, context.backgroundColor],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (movie != null) ...[
          // 공유 버튼
          IconButton(
            icon: Icon(Icons.share_outlined, color: context.textPrimaryColor),
            onPressed: () => _shareMovie(context, movie),
          ),
          // 즐겨찾기 버튼
          IconButton(
            icon: Icon(
              isFavorite ? Icons.bookmark_rounded : Icons.bookmark_outline,
              color: context.textPrimaryColor,
            ),
            onPressed: () {
              final movieForFavorite = Movie(
                id: movie.id,
                title: movie.title,
                overview: movie.overview,
                posterPath: movie.posterPath,
                backdropPath: movie.backdropPath,
                voteAverage: movie.voteAverage,
                voteCount: movie.voteCount,
                releaseDate: movie.releaseDate,
                genreIds: movie.genres.map((g) => g.id).toList(),
                popularity: 0,
              );
              ref
                  .read(favoritesProvider.notifier)
                  .toggleFavorite(movieForFavorite);
            },
          ),
        ],
      ],
    );
  }

  /// 영화 정보 공유
  void _shareMovie(BuildContext context, MovieDetail movie) {
    final year = movie.year;
    final rating = movie.ratingText;

    // 공유할 텍스트 구성
    final shareText = StringBuffer();
    shareText.write('🎬 ${movie.title}');
    if (year.isNotEmpty) {
      shareText.write(' ($year)');
    }
    shareText.write('\n⭐ $rating/10');
    if (movie.overview?.isNotEmpty ?? false) {
      shareText.write('\n\n${movie.overview}');
    }
    shareText.write('\n\nhttps://www.themoviedb.org/movie/${movie.id}');

    Share.share(shareText.toString(), subject: movie.title);
  }

  Widget _buildHeader(BuildContext context, MovieDetail? movie) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroImage(context, movie?.posterPath),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: movie != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title, style: context.headlineMedium),
                    if (movie.tagline?.isNotEmpty ?? false) ...[
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        movie.tagline!,
                        style: context.bodyMedium.copyWith(
                          color: context.textSecondaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    SizedBox(height: AppSpacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          movie.ratingText,
                          style: context.titleLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text('/10', style: context.caption),
                        SizedBox(width: AppSpacing.sm),
                        Text('(${movie.voteCount})', style: context.caption),
                      ],
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(
                      height: 24,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(
                        AppComponents.radiusXs,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    ShimmerLoading(
                      height: 16,
                      width: 150,
                      borderRadius: BorderRadius.circular(
                        AppComponents.radiusXs,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    ShimmerLoading(
                      height: 20,
                      width: 100,
                      borderRadius: BorderRadius.circular(
                        AppComponents.radiusXs,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildTrailerButton(BuildContext context, WidgetRef ref) {
    final trailerAsync = ref.watch(movieTrailerProvider(movieId));

    return trailerAsync.when(
      data: (trailer) {
        if (trailer == null) return const SizedBox.shrink();

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await _openTrailerExternal(trailer.key);
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(AppLocalizations.of(context)!.trailer),
          ),
        ).animate().fadeIn(delay: 50.ms, duration: 300.ms);
      },
      loading: () => ShimmerLoading(
        height: 48,
        width: double.infinity,
        borderRadius: BorderRadius.circular(AppComponents.radiusMd),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Future<void> _openTrailerExternal(String videoKey) async {
    final uri = Uri.parse('https://www.youtube.com/watch?v=$videoKey');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildInfo(BuildContext context, MovieDetail movie) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        if (movie.releaseDate?.isNotEmpty ?? false)
          _InfoChip(label: movie.year),
        if (movie.runtimeText.isNotEmpty) _InfoChip(label: movie.runtimeText),
        if (movie.genresText.isNotEmpty) _InfoChip(label: movie.genresText),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  Widget _buildOverview(BuildContext context, MovieDetail movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.overview, style: context.titleLarge),
        SizedBox(height: AppSpacing.sm),
        Text(
          movie.overview!,
          style: context.bodyMedium.copyWith(
            height: 1.6,
            color: context.textSecondaryColor,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
  }

  Widget _buildCast(BuildContext context, AsyncValue<List<Cast>> creditsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.cast, style: context.titleLarge),
        SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 140,
          child: creditsAsync.when(
            data: (casts) => ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: casts.length,
              itemBuilder: (context, index) =>
                  CastCard(cast: casts[index], movieId: movieId),
            ),
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) => Container(
                width: 80,
                margin: EdgeInsets.only(right: AppSpacing.md),
                child: Column(
                  children: [
                    ShimmerLoading(
                      width: 72,
                      height: 72,
                      borderRadius: BorderRadius.circular(36),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    ShimmerLoading(
                      width: 60,
                      height: 12,
                      borderRadius: BorderRadius.circular(
                        AppComponents.radiusXs,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            error: (error, stack) => const SizedBox(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 300.ms);
  }

  Widget _buildSimilarMovies(
    BuildContext context,
    AsyncValue<List<Movie>> similarMoviesAsync,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.similarMovies, style: context.titleLarge),
        SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 280,
          child: similarMoviesAsync.when(
            data: (movies) => movies.isEmpty
                ? Center(
                    child: Text(l10n.noSimilarMovies, style: context.caption),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: movies.length,
                    itemBuilder: (context, index) => MovieCard(
                      movie: movies[index],
                      heroTagPrefix: 'similar-$movieId',
                    ),
                  ),
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) => const MovieCardShimmer(),
            ),
            error: (error, stack) => const SizedBox(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 300.ms);
  }

  Widget _buildWatchProviders(
    BuildContext context,
    AsyncValue<WatchProviders> watchProvidersAsync,
  ) {
    return watchProvidersAsync.when(
      data: (providers) {
        if (!providers.hasStreamingOptions) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.whereToWatch,
              style: context.titleLarge,
            ),
            SizedBox(height: AppSpacing.md),
            // 구독 스트리밍 (Netflix, Disney+ 등)
            if (providers.flatrate.isNotEmpty) ...[
              _buildProviderRow(
                context,
                AppLocalizations.of(context)!.streaming,
                providers.flatrate,
                providers.link,
              ),
              SizedBox(height: AppSpacing.sm),
            ],
            // 대여
            if (providers.rent.isNotEmpty) ...[
              _buildProviderRow(
                context,
                AppLocalizations.of(context)!.rent,
                providers.rent,
                providers.link,
              ),
              SizedBox(height: AppSpacing.sm),
            ],
            // 구매
            if (providers.buy.isNotEmpty) ...[
              _buildProviderRow(
                context,
                AppLocalizations.of(context)!.buy,
                providers.buy,
                providers.link,
              ),
            ],
          ],
        ).animate().fadeIn(delay: 150.ms, duration: 300.ms);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildProviderRow(
    BuildContext context,
    String label,
    List<WatchProvider> providers,
    String? link,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 50, child: Text(label, style: context.caption)),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: providers.map((provider) {
                return GestureDetector(
                  onTap: () async {
                    if (link != null) {
                      final uri = Uri.parse(link);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: AppSpacing.sm),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppComponents.radiusSm,
                      ),
                      child: provider.logoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: provider.logoUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              color: context.surfaceColor,
                              child: Center(
                                child: Text(
                                  provider.providerName.substring(0, 1),
                                  style: context.titleMedium,
                                ),
                              ),
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: context.dividerColor),
        borderRadius: BorderRadius.circular(AppComponents.radiusSm),
      ),
      child: Text(label, style: context.caption),
    );
  }
}
