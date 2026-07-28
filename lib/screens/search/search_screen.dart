import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/theme/theme.dart';
import 'package:movie_app/l10n/app_localizations.dart';
import 'package:movie_app/providers/providers.dart';
import 'package:movie_app/widgets/shimmer_loading.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchResultsProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.search, style: context.headlineLarge),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.screenHorizontal),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: context.bodyMedium,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: Icon(Icons.search, color: context.textTertiaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon:
                            Icon(Icons.clear, color: context.textTertiaryColor),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? _buildEmptyState(context, l10n)
                : state.movies.isEmpty && state.isLoading
                    ? _buildLoadingList(context)
                    : state.movies.isEmpty
                        ? _buildNoResults(context, l10n)
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.screenHorizontal),
                            itemCount:
                                state.movies.length + (state.hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= state.movies.length) {
                                return _buildLoadingItem(context);
                              }
                              final movie = state.movies[index];
                              final heroTag = 'search-${movie.id}';
                              return GestureDetector(
                                onTap: () {
                                  final posterPath = movie.posterPath ?? '';
                                  context.push(
                                      '/movie/${movie.id}?heroTag=$heroTag&poster=$posterPath');
                                },
                                child: Container(
                                  margin:
                                      EdgeInsets.only(bottom: AppSpacing.md),
                                  child: Row(
                                    children: [
                                      Hero(
                                        tag: heroTag,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              AppComponents.radiusSm),
                                          child: movie.posterUrl != null
                                              ? CachedNetworkImage(
                                                  imageUrl: movie.posterUrl!,
                                                  width: 80,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  width: 80,
                                                  height: 120,
                                                  color: context.surfaceColor,
                                                  child: Icon(
                                                    Icons.movie_outlined,
                                                    color: context
                                                        .textTertiaryColor,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              movie.title,
                                              style: context.titleMedium,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: AppSpacing.xs),
                                            Text(
                                              _buildSubtitle(movie),
                                              style: context.caption,
                                            ),
                                            if (movie.overview?.isNotEmpty ??
                                                false) ...[
                                              SizedBox(height: AppSpacing.sm),
                                              Text(
                                                movie.overview!,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: context.captionSmall,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
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

  Widget _buildLoadingList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      itemCount: 5,
      itemBuilder: (context, index) => _buildLoadingItem(context),
    );
  }

  Widget _buildLoadingItem(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          ShimmerLoading(
            width: 80,
            height: 120,
            borderRadius: BorderRadius.circular(AppComponents.radiusSm),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  height: 20,
                  borderRadius: BorderRadius.circular(AppComponents.radiusXs),
                ),
                SizedBox(height: AppSpacing.sm),
                ShimmerLoading(
                  width: 100,
                  height: 16,
                  borderRadius: BorderRadius.circular(AppComponents.radiusXs),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: context.textTertiaryColor),
          SizedBox(height: AppSpacing.md),
          Text(
            l10n.searchMovies,
            style: context.bodyMedium.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_filter_outlined,
              size: 64, color: context.textTertiaryColor),
          SizedBox(height: AppSpacing.md),
          Text(
            l10n.noSearchResults,
            style: context.bodyMedium.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
