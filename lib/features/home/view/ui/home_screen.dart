import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/auth/view/cubit/auth_cubit.dart';
import 'package:found_it/features/city/domain/city_entity.dart';
import 'package:found_it/features/home/view/cubit/home_cubit.dart';
import 'package:found_it/features/home/view/cubit/home_state.dart';
import 'package:found_it/features/home/view/widgets/city_selection_bottom_sheet.dart';
import 'package:found_it/features/home/view/widgets/home_empty_view.dart';
import 'package:found_it/features/home/view/widgets/home_error_view.dart';
import 'package:found_it/features/home/view/widgets/home_header.dart';
import 'package:found_it/features/home/view/widgets/home_shimmer_view.dart';
import 'package:found_it/features/home/view/widgets/home_success_view.dart';
import 'package:found_it/features/notifications/view/cubit/notifications_cubit.dart';
import 'package:found_it/features/notifications/view/cubit/notifications_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  void _openCityPicker(BuildContext context, HomeCubit cubit, String currentCityId) {
    if (cubit.cachedCities.isEmpty) return;

    CitySelectionBottomSheet.show(
      context: context,
      currentCityId: currentCityId,
      cities: cubit.cachedCities,
      onCitySelected: (CityEntity selectedCity) {
        cubit.selectCity(
          selectedCity,
          onCitySyncedToAuth: (cityId) {
            if (context.mounted) {
              context.read<AuthCubit>().cityChanged(cityId);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, curr) => prev.user?.cityId != curr.user?.cityId,
      listener: (context, authState) {
        final newCityId = authState.user?.cityId;
        if (newCityId != null && newCityId.isNotEmpty) {
          context.read<HomeCubit>().onCityChangedFromAuth(newCityId);
        }
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final cubit = context.read<HomeCubit>();
          final cityName = state.selectedCity?.localizedName(locale) ??
              cubit.cachedCities
                  .where((c) => c.id == state.selectedCityId)
                  .firstOrNull
                  ?.localizedName(locale) ??
              '';
          final cityId = state.selectedCityId;

          // Optional: the bell dot must not break isolated Home tests that
          // pump HomeScreen without the app-wide NotificationsCubit.
          final notificationsCubit = context.read<NotificationsCubit?>();

          Widget buildHeader(NotificationsState? notificationsState) {
            return HomeHeader(
              cityName: cityName,
              showUnreadDot: notificationsState?.hasUnread ?? false,
              onCityTap: () => _openCityPicker(context, cubit, cityId),
              onNotificationTap: () => context.push(AppRoutes.notifications),
            );
          }

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  if (notificationsCubit == null)
                    buildHeader(null)
                  else
                    BlocBuilder<NotificationsCubit, NotificationsState>(
                      bloc: notificationsCubit,
                      buildWhen: (previous, current) =>
                          previous.unreadCount != current.unreadCount,
                      builder: (context, notificationsState) =>
                          buildHeader(notificationsState),
                    ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: switch (state.status) {
                        HomeStatus.loading => const HomeShimmerView(
                            key: ValueKey('home_loading'),
                          ),
                        HomeStatus.failure => HomeErrorView(
                            key: const ValueKey('home_error'),
                            onRetry: () => cubit.refresh(),
                          ),
                        HomeStatus.success || HomeStatus.initial =>
                          state.reports.isEmpty
                              ? HomeEmptyView(
                                  key: const ValueKey('home_empty'),
                                  cityName: cityName,
                                  onRefresh: () => cubit.refresh(),
                                )
                              : HomeSuccessView(
                                  key: const ValueKey('home_success'),
                                  cityName: cityName,
                                  reports: state.reports,
                                  onRefresh: () => cubit.refresh(),
                                ),
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
