import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/theme/theme.dart';
import 'package:movie_app/l10n/app_localizations.dart';
import 'package:movie_app/providers/providers.dart';
import 'package:movie_app/widgets/movie_card.dart';
import 'package:movie_app/widgets/shimmer_loading.dart';

class MovieSection extends ConsumerWidget {
  final String title;
  final StateNotifierProvider<PaginatedMoviesNotifier, PaginatedMoviesState>
      moviesProvider;
  final double cardHeight;
  final String heroTagPrefix;
  final String? categoryType;

  const MovieSection({
    super.key,
    required this.title,
    required this.moviesProvider,
    required this.heroTagPrefix,
    this.cardHeight = 300,
    this.categoryType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moviesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: context.headlineMedium,
              ),
              if (categoryType != null)
                GestureDetector(
                  onTap: () => context.push('/category/$categoryType?title=$title'),
                  child: Text(
                    AppLocalizations.of(context)!.seeAll,
                    style: context.bodyMedium.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        SizedBox(
          height: cardHeight,
          child: state.movies.isEmpty && state.isLoading
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal),
                  physics: const BouncingScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) => const MovieCardShimmer(),
                )
              : state.error != null && state.movies.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          AppLocalizations.of(context)!.error,
                          style: context.caption,
                        ),
                      ),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollEndNotification) {
                          final metrics = notification.metrics;
                          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                            ref.read(moviesProvider.notifier).loadMore();
                          }
                        }
                        return false;
                      },
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal),
                        physics: const BouncingScrollPhysics(),
                        itemCount:
                            state.movies.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.movies.length) {
                            return Padding(
                              padding: EdgeInsets.only(right: AppSpacing.cardGap),
                              child: const MovieCardShimmer(),
                            );
                          }
                          return MovieCard(
                            movie: state.movies[index],
                            heroTagPrefix: heroTagPrefix,
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
