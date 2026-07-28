import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/theme/theme.dart';
import 'package:movie_app/l10n/app_localizations.dart';
import 'package:movie_app/models/person.dart';
import 'package:movie_app/providers/providers.dart';
import 'package:movie_app/widgets/shimmer_loading.dart';

class ActorDetailScreen extends ConsumerStatefulWidget {
  final int personId;
  final String heroTag;
  final String? profilePath;

  const ActorDetailScreen({
    super.key,
    required this.personId,
    required this.heroTag,
    this.profilePath,
  });

  @override
  ConsumerState<ActorDetailScreen> createState() => _ActorDetailScreenState();
}

class _ActorDetailScreenState extends ConsumerState<ActorDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final personAsync = ref.watch(personDetailProvider(widget.personId));
    final creditsAsync = ref.watch(personCreditsProvider(widget.personId));
    final l10n = AppLocalizations.of(context)!;

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
            _buildAppBar(context, personAsync),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, personAsync),
                    SizedBox(height: AppSpacing.lg),
                    _buildBiography(context, personAsync, l10n),
                    SizedBox(height: AppSpacing.lg),
                    _buildFilmography(context, creditsAsync, l10n),
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

  Widget _buildAppBar(BuildContext context, AsyncValue<Person> personAsync) {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: context.surfaceColor),
            Hero(tag: widget.heroTag, child: _buildProfileImage(context)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    context.backgroundColor.withValues(alpha: 0.5),
                    context.backgroundColor,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 프로필 이미지 빌드 - 꽉 찬 사각형 이미지 (CastCard의 flightShuttleBuilder가 애니메이션 처리)
  Widget _buildProfileImage(BuildContext context) {
    final imagePath = widget.profilePath;
    final imageUrl = imagePath != null && imagePath.isNotEmpty
        ? '${ApiConstants.posterW342}$imagePath'
        : null;

    if (imageUrl == null) {
      return Container(
        color: context.surfaceColor,
        child: Center(
          child: Icon(Icons.person, size: 80, color: context.textTertiaryColor),
        ),
      );
    }

    return Image(
      image: CachedNetworkImageProvider(imageUrl),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: context.surfaceColor,
        child: Center(
          child: Icon(Icons.person, size: 80, color: context.textTertiaryColor),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue<Person> personAsync) {
    return personAsync.when(
      data: (person) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            person.name,
            style: context.headlineLarge,
          ).animate().fadeIn(duration: 300.ms),
          SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            context,
            person,
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
        ],
      ),
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(
            height: 32,
            width: 200,
            borderRadius: BorderRadius.circular(AppComponents.radiusSm),
          ),
          SizedBox(height: AppSpacing.sm),
          ShimmerLoading(
            height: 20,
            width: 150,
            borderRadius: BorderRadius.circular(AppComponents.radiusXs),
          ),
        ],
      ),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildInfoRow(BuildContext context, Person person) {
    final infoParts = <String>[];

    if (person.knownForDepartment != null) {
      infoParts.add(person.knownForDepartment!);
    }

    if (person.age != null) {
      infoParts.add('${person.age}');
    }

    if (person.placeOfBirth != null && person.placeOfBirth!.isNotEmpty) {
      final birthPlace = person.placeOfBirth!.split(',').last.trim();
      infoParts.add(birthPlace);
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: infoParts.map((info) => _InfoChip(label: info)).toList(),
    );
  }

  Widget _buildBiography(
    BuildContext context,
    AsyncValue<Person> personAsync,
    AppLocalizations l10n,
  ) {
    return personAsync.when(
      data: (person) {
        if (person.biography == null || person.biography!.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.biography, style: context.titleLarge),
            SizedBox(height: AppSpacing.sm),
            Text(
              person.biography!,
              style: context.bodyMedium.copyWith(
                height: 1.6,
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(
            height: 24,
            width: 100,
            borderRadius: BorderRadius.circular(AppComponents.radiusSm),
          ),
          SizedBox(height: AppSpacing.sm),
          ShimmerLoading(
            height: 100,
            width: double.infinity,
            borderRadius: BorderRadius.circular(AppComponents.radiusSm),
          ),
        ],
      ),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildFilmography(
    BuildContext context,
    AsyncValue<List<PersonCredit>> creditsAsync,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.filmography, style: context.titleLarge),
        SizedBox(height: AppSpacing.md),
        creditsAsync.when(
          data: (credits) {
            if (credits.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Text(l10n.noFilmography, style: context.caption),
                ),
              );
            }
            // Only show movies with poster
            final moviesWithPoster = credits
                .where((c) => c.posterPath != null && c.mediaType == 'movie')
                .toList();
            return SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: moviesWithPoster.length,
                itemBuilder: (context, index) {
                  final credit = moviesWithPoster[index];
                  return _FilmographyCard(
                    credit: credit,
                    onTap: () {
                      final heroTag = 'filmography-${credit.id}';
                      context.push(
                        '/movie/${credit.id}?heroTag=$heroTag&poster=${credit.posterPath}',
                      );
                    },
                  );
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) => Container(
                width: 140,
                margin: EdgeInsets.only(right: AppSpacing.cardGap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(
                      height: 200,
                      width: 140,
                      borderRadius: BorderRadius.circular(
                        AppComponents.radiusLg,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    ShimmerLoading(
                      height: 16,
                      width: 100,
                      borderRadius: BorderRadius.circular(
                        AppComponents.radiusXs,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          error: (_, __) => const SizedBox(),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 300.ms);
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

class _FilmographyCard extends StatelessWidget {
  final PersonCredit credit;
  final VoidCallback onTap;

  const _FilmographyCard({required this.credit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: EdgeInsets.only(right: AppSpacing.cardGap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppComponents.radiusLg),
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    width: 140,
                    color: context.surfaceColor,
                    child: Center(
                      child: Icon(
                        Icons.movie_outlined,
                        size: 40,
                        color: context.textTertiaryColor,
                      ),
                    ),
                  ),
                  if (credit.posterUrl != null)
                    CachedNetworkImage(
                      imageUrl: credit.posterUrl!,
                      height: 200,
                      width: 140,
                      fit: BoxFit.cover,
                      fadeInDuration: AppComponents.animationNormal,
                    ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              credit.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.titleMedium,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              _buildSubtitle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.caption,
            ),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (credit.year.isNotEmpty) {
      parts.add(credit.year);
    }
    if (credit.character != null && credit.character!.isNotEmpty) {
      parts.add(credit.character!);
    }
    return parts.join(' · ');
  }
}
