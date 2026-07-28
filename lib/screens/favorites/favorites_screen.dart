import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/theme/theme.dart';
import 'package:movie_app/l10n/app_localizations.dart';
import 'package:movie_app/providers/providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.library, style: context.headlineLarge),
      ),
      body: favorites.isEmpty
          ? _buildEmptyState(context, l10n)
          : GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(AppSpacing.screenHorizontal),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getGridCrossAxisCount(context),
                childAspectRatio: 0.6,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final movie = favorites[index];
                final heroTag = 'favorites-${movie.id}';
                final posterPath = movie.posterPath ?? '';
                return GestureDetector(
                  onTap: () => context.push(
                      '/movie/${movie.id}?heroTag=$heroTag&poster=$posterPath'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Hero(
                              tag: heroTag,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    AppComponents.radiusXl),
                                child: Stack(
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
                                    if (movie.posterUrl != null)
                                      Image(
                                        image: CachedNetworkImageProvider(
                                            movie.posterUrl!),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const SizedBox(),
                                        frameBuilder: (context, child, frame,
                                            wasSynchronouslyLoaded) {
                                          if (wasSynchronouslyLoaded) {
                                            return child;
                                          }
                                          return AnimatedOpacity(
                                            opacity: frame != null ? 1.0 : 0.0,
                                            duration:
                                                AppComponents.animationNormal,
                                            child: child,
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: AppSpacing.sm,
                              right: AppSpacing.sm,
                              child: GestureDetector(
                                onTap: () {
                                  ref
                                      .read(favoritesProvider.notifier)
                                      .toggleFavorite(movie);
                                },
                                child: Icon(
                                  Icons.bookmark_rounded,
                                  color: Colors.white,
                                  size: 24,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.titleMedium,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        _buildSubtitle(movie),
                        style: context.caption,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _buildSubtitle(dynamic movie) {
    final parts = <String>[];
    if (movie.ratingText.isNotEmpty) {
      parts.add(movie.ratingText);
    }
    if (movie.year.isNotEmpty) {
      parts.add(movie.year);
    }
    return parts.join(' · ');
  }

  int _getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 5;
    if (width >= 600) return 4;
    if (width >= 400) return 3;
    return 2;
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_outline,
              size: 64, color: context.textTertiaryColor),
          SizedBox(height: AppSpacing.md),
          Text(
            l10n.emptyLibrary,
            style: context.bodyMedium.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            l10n.emptyLibraryHint,
            style: context.caption,
          ),
        ],
      ),
    );
  }
}
