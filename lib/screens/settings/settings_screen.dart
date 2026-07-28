import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movie_app/core/theme/theme.dart';
import 'package:movie_app/l10n/app_localizations.dart';
import 'package:movie_app/providers/providers.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings, style: context.headlineLarge)),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.screenHorizontal),
        children: [
          // Theme Section
          _SectionHeader(title: l10n.appearance),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: l10n.theme,
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              underline: const SizedBox(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(l10n.systemTheme, style: context.bodyMedium),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n.lightTheme, style: context.bodyMedium),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(l10n.darkTheme, style: context.bodyMedium),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.xl),

          // About Section
          _SectionHeader(title: l10n.about),
          _SettingsTile(
            icon: Icons.info_outline,
            title: l10n.appVersion,
            trailing: Text('1.0.0', style: context.caption),
          ),

          SizedBox(height: AppSpacing.xl),

          // TMDB Attribution
          _buildTmdbAttribution(context, l10n),
        ],
      ),
    );
  }

  Widget _buildTmdbAttribution(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppComponents.radiusMd),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _launchUrl('https://www.themoviedb.org'),
            child: SvgPicture.asset('assets/images/tmdb_logo.svg', height: 20),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            l10n.tmdbAttribution,
            style: context.caption.copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () => _launchUrl('https://www.themoviedb.org'),
            child: Text(
              'www.themoviedb.org',
              style: context.caption.copyWith(
                color: const Color(0xFF01b4e4),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: context.titleMedium.copyWith(color: context.textSecondaryColor),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const _SettingsTile({required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: context.textSecondaryColor),
      title: Text(title, style: context.bodyMedium),
      trailing: trailing,
    );
  }
}
