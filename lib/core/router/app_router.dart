import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/screens/home/home_screen.dart';
import 'package:movie_app/screens/detail/detail_screen.dart';
import 'package:movie_app/screens/search/search_screen.dart';
import 'package:movie_app/screens/explore/explore_screen.dart';
import 'package:movie_app/screens/favorites/favorites_screen.dart';
import 'package:movie_app/screens/category/category_screen.dart';
import 'package:movie_app/screens/actor/actor_detail_screen.dart';
import 'package:movie_app/screens/settings/settings_screen.dart';
import 'package:movie_app/widgets/main_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/explore',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ExploreScreen(),
          ),
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SearchScreen(),
          ),
        ),
        GoRoute(
          path: '/favorites',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: FavoritesScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/movie/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final heroTag = state.uri.queryParameters['heroTag'] ?? 'movie-$id';
        final posterPath = state.uri.queryParameters['poster'];
        return DetailScreen(
          movieId: id,
          heroTag: heroTag,
          posterPath: posterPath,
        );
      },
    ),
    GoRoute(
      path: '/category/:type',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final type = state.pathParameters['type']!;
        final title = state.uri.queryParameters['title'] ?? '';
        return CategoryScreen(
          categoryType: type,
          title: title,
        );
      },
    ),
    GoRoute(
      path: '/actor/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final heroTag = state.uri.queryParameters['heroTag'] ?? 'actor-$id';
        final profilePath = state.uri.queryParameters['profile'];
        return ActorDetailScreen(
          personId: id,
          heroTag: heroTag,
          profilePath: profilePath,
        );
      },
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
