import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/theme/theme.dart';
import 'package:movie_app/l10n/app_localizations.dart';
import 'package:movie_app/providers/providers.dart';
import 'package:movie_app/widgets/movie_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: context.headlineLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(nowPlayingMoviesProvider.notifier).refresh(),
            ref.read(popularMoviesProvider.notifier).refresh(),
            ref.read(topRatedMoviesProvider.notifier).refresh(),
            ref.read(upcomingMoviesProvider.notifier).refresh(),
          ]);
        },
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          children: [
            SizedBox(height: AppSpacing.lg),
            MovieSection(
              title: l10n.nowPlaying,
              moviesProvider: nowPlayingMoviesProvider,
              heroTagPrefix: 'now-playing',
              categoryType: 'now_playing',
            ),
            SizedBox(height: AppSpacing.sectionGap),
            MovieSection(
              title: l10n.popular,
              moviesProvider: popularMoviesProvider,
              heroTagPrefix: 'popular',
              categoryType: 'popular',
            ),
            SizedBox(height: AppSpacing.sectionGap),
            MovieSection(
              title: l10n.topRated,
              moviesProvider: topRatedMoviesProvider,
              heroTagPrefix: 'top-rated',
              categoryType: 'top_rated',
            ),
            SizedBox(height: AppSpacing.sectionGap),
            MovieSection(
              title: l10n.upcoming,
              moviesProvider: upcomingMoviesProvider,
              heroTagPrefix: 'upcoming',
              categoryType: 'upcoming',
            ),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
