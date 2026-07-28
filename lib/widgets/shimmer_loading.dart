import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:movie_app/core/theme/theme.dart';

class ShimmerLoading extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.surfaceColor,
      highlightColor: context.surfaceVariantColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppComponents.radiusXl),
        ),
      ),
    );
  }
}

class MovieCardShimmer extends StatelessWidget {
  final double? width;
  final bool showMargin;

  const MovieCardShimmer({super.key, this.width, this.showMargin = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? AppComponents.movieCardWidth,
      margin: showMargin ? EdgeInsets.only(right: AppSpacing.cardGap) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ShimmerLoading(
              width: double.infinity,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          ShimmerLoading(
            width: 120,
            height: 14,
            borderRadius: BorderRadius.circular(AppComponents.radiusXs),
          ),
          SizedBox(height: AppSpacing.xs),
          ShimmerLoading(
            width: 80,
            height: 12,
            borderRadius: BorderRadius.circular(AppComponents.radiusXs),
          ),
        ],
      ),
    );
  }
}
