import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/preferences/app_preferences_cubit.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/auth/domain/auth_failure.dart';
import 'package:found_it/features/auth/view/cubit/auth_cubit.dart';
import 'package:found_it/features/profile/domain/entities/profile_failure.dart';
import 'package:found_it/features/profile/domain/entities/user_profile_entity.dart';
import 'package:found_it/features/profile/view/cubit/profile_cubit.dart';
import 'package:found_it/features/profile/view/cubit/profile_state.dart';
import 'package:found_it/features/profile/view/widgets/city_dialog.dart';
import 'package:found_it/features/profile/view/widgets/language_dialog.dart';
import 'package:found_it/features/profile/view/widgets/logout_dialog.dart';
import 'package:found_it/features/profile/view/widgets/profile_header.dart';
import 'package:found_it/features/profile/view/widgets/settings_section_title.dart';
import 'package:found_it/features/profile/view/widgets/settings_tile.dart';
import 'package:found_it/features/profile/view/widgets/theme_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  void _onEditProfile(UserProfileEntity profile) async {
    final result = await context.push<bool>(
      AppRoutes.editProfile,
      extra: profile,
    );
    if (result == true && mounted) {
      context.read<ProfileCubit>().loadProfile();
    }
  }

  void _onLogout() {
    LogoutDialog.show(
      context,
      onConfirm: () async {
        Navigator.of(context).pop();
        try {
          await context.read<AuthCubit>().logout();
          // The router redirects to Login automatically via authRedirect.
        } on AuthFailure {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).genericErrorMessage),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      },
    );
  }

  static String _mapProfileFailureMessage(
    ProfileFailureType type,
    AppLocalizations l10n,
  ) {
    switch (type) {
      case ProfileFailureType.network:
        return l10n.connectionErrorMessage;
      case ProfileFailureType.unknown:
        return l10n.genericErrorMessage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final prefsState = context.watch<AppPreferencesCubit>().state;

    final currentThemeText = switch (prefsState.themeMode) {
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
      ThemeMode.system => l10n.themeSystem,
    };

    final currentLanguageText = prefsState.locale == null
        ? l10n.languageSystem
        : (prefsState.locale!.languageCode == 'ar'
            ? l10n.languageArabic
            : l10n.languageEnglish);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.profileTitle,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_mapProfileFailureMessage(state.failure!, l10n)),
                backgroundColor: colors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = state.profile;
          if (profile == null) {
            return Center(
              child: FilledButton.tonal(
                onPressed: () => context.read<ProfileCubit>().loadProfile(),
                child: Text(l10n.retry),
              ),
            );
          }

          final currentCityName = profile.localizedCity(locale);

          return ListView(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            children: [
              // Header Card
              ProfileHeader(
                profile: profile,
                onEdit: () => _onEditProfile(profile),
              ),

              // Activity Section (Figma P33)
              SettingsSectionTitle(title: l10n.activitySection),
              SettingsTile(
                icon: Icons.assignment_outlined,
                title: l10n.viewMyReports,
                value: '${state.reportsCount}',
                onTap: () => context.push(AppRoutes.myReports),
              ),
              SettingsTile(
                icon: Icons.bookmark_outline_rounded,
                title: l10n.savedReports,
                value: l10n.comingSoon,
              ),
              SettingsTile(
                icon: Icons.compare_arrows_rounded,
                title: l10n.potentialMatches,
                value: l10n.comingSoon,
              ),

              // Account Section
              SettingsSectionTitle(title: l10n.accountSection),
              SettingsTile(
                icon: Icons.person_outline_rounded,
                title: l10n.editProfile,
                onTap: () => _onEditProfile(profile),
              ),

              // Preferences Section
              SettingsSectionTitle(title: l10n.preferencesSection),
              SettingsTile(
                icon: Icons.location_city_rounded,
                title: l10n.cityLabel,
                value: currentCityName.isNotEmpty
                    ? currentCityName
                    : l10n.selectCity,
                onTap: () {
                  CityDialog.show(
                    context,
                    cities: state.activeCities,
                    selectedCityId: profile.cityId,
                    onCitySelected: (cityId) async {
                      final success =
                          await context.read<ProfileCubit>().changeCity(cityId);
                      if (success && context.mounted) {
                        context.read<AuthCubit>().cityChanged(cityId);
                      }
                    },
                  );
                },
              ),
              SettingsTile(
                icon: Icons.language_rounded,
                title: l10n.languageLabel,
                value: currentLanguageText,
                onTap: () => LanguageDialog.show(context),
              ),
              SettingsTile(
                icon: Icons.brightness_6_rounded,
                title: l10n.themeLabel,
                value: currentThemeText,
                onTap: () => ThemeDialog.show(context),
              ),

              // Logout Tile
              SizedBox(height: 16.h),
              SettingsTile(
                icon: Icons.logout_rounded,
                title: l10n.logoutButton,
                isDestructive: true,
                onTap: _onLogout,
              ),

              // App Version
              SizedBox(height: 24.h),
              Center(
                child: Text(
                  l10n.appVersion,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          );
        },
      ),
    );
  }
}
