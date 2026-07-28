import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/core/theme/theme.dart';
import 'package:movie_app/l10n/app_localizations.dart';
import 'package:movie_app/providers/providers.dart';
import 'package:movie_app/services/tmdb_service.dart';
import 'package:movie_app/widgets/movie_card.dart';
import 'package:movie_app/widgets/shimmer_loading.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final selectedGenre = ref.read(selectedGenreProvider);
      if (selectedGenre != null) {
        ref.read(moviesByGenreProvider.notifier).loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final genresAsync = ref.watch(genresProvider);
    final selectedGenre = ref.watch(selectedGenreProvider);
    final moviesState = ref.watch(moviesByGenreProvider);

    // 장르 목록이 로드되면 첫 번째 장르를 자동 선택
    ref.listen<AsyncValue<List<Genre>>>(genresProvider, (previous, next) {
      final currentSelection = ref.read(selectedGenreProvider);
      if (next.hasValue && next.value!.isNotEmpty && currentSelection == null) {
        // 첫 번째 장르(액션)를 기본 선택
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(selectedGenreProvider.notifier).state = next.value!.first.id;
        });
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.explore, style: context.headlineLarge)),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: genresAsync.when(
              data: (genres) => ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                itemCount: genres.length,
                itemBuilder: (context, index) {
                  final genre = genres[index];
                  final isSelected = selectedGenre == genre.id;
                  return Padding(
                    padding: EdgeInsets.only(right: AppSpacing.md),
                    child: TextButton(
                      onPressed: () {
                        if (isSelected) {
                          ref.read(selectedGenreProvider.notifier).state = null;
                        } else {
                          ref.read(selectedGenreProvider.notifier).state =
                              genre.id;
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                      ),
                      child: Text(
                        genre.name,
                        style: isSelected
                            ? context.titleMedium
                            : context.titleMedium.copyWith(
                                color: context.textTertiaryColor,
                              ),
                      ),
                    ),
                  );
                },
              ),
              loading: () => ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                itemCount: 5,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(right: AppSpacing.sm),
                  child: ShimmerLoading(
                    width: 80,
                    height: 36,
                    borderRadius: BorderRadius.circular(AppComponents.radiusSm),
                  ),
                ),
              ),
              error: (e, s) => const SizedBox(),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Expanded(
            child: selectedGenre == null
                ? _buildSelectGenreHint(context, l10n)
                : moviesState.movies.isEmpty && moviesState.isLoading
                ? _buildLoadingGrid(context)
                : moviesState.movies.isEmpty
                ? _buildNoMovies(context, l10n)
                : GridView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(AppSpacing.screenHorizontal),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getGridCrossAxisCount(context),
                      childAspectRatio: 0.6,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                    ),
                    itemCount:
                        moviesState.movies.length +
                        (moviesState.hasMore ? 2 : 0),
                    itemBuilder: (context, index) {
                      if (index >= moviesState.movies.length) {
                        return const MovieCardShimmer(
                          width: double.infinity,
                          showMargin: false,
                        );
                      }
                      return MovieCard(
                        movie: moviesState.movies[index],
                        heroTagPrefix: 'explore-$selectedGenre',
                        width: double.infinity,
                        showMargin: false,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectGenreHint(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: context.textTertiaryColor,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            l10n.selectGenre,
            style: context.bodyMedium.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  int _getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 5;
    if (width >= 600) return 4;
    if (width >= 400) return 3;
    return 2;
  }

  Widget _buildLoadingGrid(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(AppSpacing.screenHorizontal),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getGridCrossAxisCount(context),
        childAspectRatio: 0.6,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: 6,
      itemBuilder: (context, index) =>
          const MovieCardShimmer(width: double.infinity, showMargin: false),
    );
  }

  Widget _buildNoMovies(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter_outlined,
            size: 64,
            color: context.textTertiaryColor,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            l10n.noMovies,
            style: context.bodyMedium.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
