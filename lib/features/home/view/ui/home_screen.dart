import 'package:flutter/material.dart';

import '../../domain/entities/home_report_item.dart';
import '../../domain/entities/sample_home_data.dart';
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
  late HomeViewState _currentState;
  late String _cityName;
  HomeFilterType _selectedFilter = HomeFilterType.all;
  late List<HomeReportItem> _reports;

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;
    _cityName = widget.initialCityName;
    _reports = List<HomeReportItem>.from(kSampleHomeReports);
  }

  Future<void> _handleRefresh() async {
    // Simulates network latency on pull-to-refresh
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() {
        // Keeps user on current state or refreshes list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Persistent Header with City Switcher and State Preview Chips
            HomeHeader(
              cityName: _cityName,
              currentState: _currentState,
              onStateChanged: (newState) {
                setState(() => _currentState = newState);
              },
            ),

            // Animated State Container
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: switch (_currentState) {
                  HomeViewState.success => HomeSuccessView(
                      key: const ValueKey('home_success'),
                      cityName: _cityName,
                      reports: _reports,
                      selectedFilter: _selectedFilter,
                      onFilterSelected: (filter) {
                        setState(() => _selectedFilter = filter);
                      },
                      onRefresh: _handleRefresh,
                    ),
                  HomeViewState.loading => const HomeShimmerView(
                      key: ValueKey('home_loading'),
                    ),
                  HomeViewState.empty => HomeEmptyView(
                      key: const ValueKey('home_empty'),
                      cityName: _cityName,
                      onRefresh: _handleRefresh,
                    ),
                  HomeViewState.error => HomeErrorView(
                      key: const ValueKey('home_error'),
                      onRetry: _handleRefresh,
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
