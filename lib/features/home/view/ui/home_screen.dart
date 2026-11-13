import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/home_report_item.dart';
import '../../domain/entities/sample_home_data.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/city_selection_bottom_sheet.dart';
import '../widgets/home_empty_view.dart';
import '../widgets/home_error_view.dart';
import '../widgets/home_header.dart';
import '../widgets/home_shimmer_view.dart';
import '../widgets/home_success_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.initialCityName = 'Cairo',
    this.initialState = HomeViewState.success,
  });

  final String initialCityName;
  final HomeViewState initialState;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewState _previewState;
  late String _previewCityName;
  late List<HomeReportItem> _previewReports;

  @override
  void initState() {
    super.initState();
    _previewState = widget.initialState;
    _previewCityName = widget.initialCityName;
    _previewReports = List<HomeReportItem>.from(kSampleHomeReports);
  }

  void _openCityPicker(BuildContext context, String currentCity, [HomeCubit? cubit]) {
    final availableCities = (cubit != null && cubit.cachedCities.isNotEmpty)
        ? cubit.cachedCities
        : kEgyptianCities;

    CitySelectionBottomSheet.show(
      context: context,
      currentCity: currentCity,
      availableCities: availableCities,
      onCitySelected: (selectedName) {
        final locale = Localizations.localeOf(context).languageCode;
        if (cubit != null) {
          final match = availableCities.where((c) =>
              c.nameAr == selectedName ||
              c.nameEn == selectedName ||
              c.localizedName(locale) == selectedName).firstOrNull;
          if (match != null) {
            cubit.selectCity(match, locale: locale);
            return;
          }
        }
        setState(() => _previewCityName = selectedName);
      },
    );
  }

  HomeViewState _mapStatusToViewState(HomeStatus status, bool isEmpty) {
    return switch (status) {
      HomeStatus.loading => HomeViewState.loading,
      HomeStatus.failure => HomeViewState.error,
      HomeStatus.success || HomeStatus.initial =>
        isEmpty ? HomeViewState.empty : HomeViewState.success,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.watch<HomeCubit?>();

    // 1. Cubit-driven production & integration mode
    if (cubit != null) {
      final state = cubit.state;
      final cityName = state.selectedCityName.isNotEmpty
          ? state.selectedCityName
          : _previewCityName;

      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              HomeHeader(
                cityName: cityName,
                currentState: _mapStatusToViewState(state.status, state.reports.isEmpty),
                onStateChanged: (newState) {
                  if (newState == HomeViewState.loading) {
                    cubit.setPreviewStatus(HomeStatus.loading);
                  } else if (newState == HomeViewState.error) {
                    cubit.setPreviewStatus(
                      HomeStatus.failure,
                      errorMessage: 'Preview error',
                    );
                  } else if (newState == HomeViewState.empty) {
                    cubit.setPreviewStatus(
                      HomeStatus.success,
                      reports: const [],
                    );
                  } else {
                    cubit.refresh();
                  }
                },
                onCityTap: () => _openCityPicker(context, cityName, cubit),
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
                    HomeStatus.success || HomeStatus.initial => state.reports.isEmpty
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
    }

    // 2. Standalone UI & widget preview mode
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HomeHeader(
              cityName: _previewCityName,
              currentState: _previewState,
              onStateChanged: (newState) {
                setState(() => _previewState = newState);
              },
              onCityTap: () => _openCityPicker(context, _previewCityName),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: switch (_previewState) {
                  HomeViewState.success => HomeSuccessView(
                      key: const ValueKey('home_success'),
                      cityName: _previewCityName,
                      reports: _previewReports,
                      onRefresh: () async {},
                    ),
                  HomeViewState.loading => const HomeShimmerView(
                      key: ValueKey('home_loading'),
                    ),
                  HomeViewState.empty => HomeEmptyView(
                      key: const ValueKey('home_empty'),
                      cityName: _previewCityName,
                      onRefresh: () async {},
                    ),
                  HomeViewState.error => HomeErrorView(
                      key: const ValueKey('home_error'),
                      onRetry: () async {},
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
