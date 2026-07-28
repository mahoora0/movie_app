import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/core/theme/theme.dart';
import 'package:movie_app/providers/providers.dart';
import 'package:movie_app/widgets/movie_card.dart';
import 'package:movie_app/widgets/shimmer_loading.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  final String categoryType;
  final String title;

  const CategoryScreen({
    super.key,
    required this.categoryType,
    required this.title,
  });

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
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

  StateNotifierProvider<PaginatedMoviesNotifier, PaginatedMoviesState>
      get _provider {
    switch (widget.categoryType) {
      case 'now_playing':
        return nowPlayingMoviesProvider;
      case 'popular':
        return popularMoviesProvider;
      case 'top_rated':
        return topRatedMoviesProvider;
      case 'upcoming':
        return upcomingMoviesProvider;
      default:
        return popularMoviesProvider;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(_provider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: context.headlineMedium),
      ),
      body: state.movies.isEmpty && state.isLoading
          ? _buildLoadingGrid()
          : GridView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(AppSpacing.screenHorizontal),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemCount: state.movies.length + (state.hasMore ? 2 : 0),
              itemBuilder: (context, index) {
                if (index >= state.movies.length) {
                  return const MovieCardShimmer(
                      width: double.infinity, showMargin: false);
                }
                return MovieCard(
                  movie: state.movies[index],
                  heroTagPrefix: 'category-${widget.categoryType}',
                  width: double.infinity,
                  showMargin: false,
                );
              },
            ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(AppSpacing.screenHorizontal),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: 6,
      itemBuilder: (context, index) =>
          const MovieCardShimmer(width: double.infinity, showMargin: false),
    );
  }
}
