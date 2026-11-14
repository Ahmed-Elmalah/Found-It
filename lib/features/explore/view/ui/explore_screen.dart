import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/core/theme/app_theme.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/core/widgets/report_card.dart';
import 'package:found_it/features/explore/domain/report_entity.dart';
import 'package:found_it/features/explore/view/cubit/search_cubit.dart';
import 'package:found_it/features/explore/view/cubit/search_state.dart';
import 'package:found_it/features/explore/view/ui/widgets/active_filter_chip.dart';
import 'package:found_it/features/explore/view/ui/widgets/filters_bottom_sheet.dart';

/// Explore screen (Figma P19 / P52).
///
/// Everything comes from `SearchCubit`: the city, the filter data and the
/// results of `search_reports`.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilters(SearchState state) async {
    final l10n = AppLocalizations.of(context);
    final result = await showModalBottomSheet<ExploreFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FiltersBottomSheet(
        categories: state.categories,
        areas: state.areas,
        cityName: state.cityName(l10n.localeName),
        initialType: state.type,
        initialCategoryIds: state.categoryIds,
        initialAreaIds: state.areaIds,
        initialDateFrom: _parseDate(state.dateFrom),
        initialDateTo: _parseDate(state.dateTo),
      ),
    );
    if (result == null || !mounted) return;

    await context.read<SearchCubit>().applyFilters(
      type: result.type,
      categoryIds: result.categoryIds,
      areaIds: result.areaIds,
      dateFrom: _formatDate(result.dateFrom),
      dateTo: _formatDate(result.dateTo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, size: 24.r),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        titleSpacing: 4.w,
        title: Text(
          l10n.exploreTitle,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocListener<SearchCubit, SearchState>(
        listenWhen: (previous, current) => previous.query != current.query,
        listener: (context, state) {
          if (_searchController.text == state.query) return;
          _searchController.value = TextEditingValue(
            text: state.query,
            selection: TextSelection.collapsed(offset: state.query.length),
          );
        },
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            AppSizes.pagePadding.w,
            8.h,
            AppSizes.pagePadding.w,
            0,
          ),
          child: BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              final chips = _buildChips(context, state, l10n);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: context.read<SearchCubit>().onQueryChanged,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(fontSize: 16.sp, color: colors.onSurface),
                    decoration: InputDecoration(
                      hintText: l10n.searchHint,
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20.r,
                        color: colors.onSurfaceVariant,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () => _openFilters(state),
                        icon: Icon(
                          Icons.tune_rounded,
                          size: 20.r,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ),
                  if (chips.isNotEmpty) ...[
                    SizedBox(height: 14.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var i = 0; i < chips.length; i++) ...[
                            if (i > 0) SizedBox(width: 8.w),
                            chips[i],
                          ],
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  Expanded(child: _buildBody(context, state, l10n)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SearchState state,
    AppLocalizations l10n,
  ) {
    switch (state.status) {
      case SearchStatus.initial:
      case SearchStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case SearchStatus.failure:
        return _FailureView(
          l10n: l10n,
          onRetry: context.read<SearchCubit>().search,
        );
      case SearchStatus.empty:
        return _EmptyView(
          l10n: l10n,
          onClearFilters: context.read<SearchCubit>().resetFilters,
        );
      case SearchStatus.success:
        return _buildResults(context, state, l10n);
    }
  }

  Widget _buildResults(
    BuildContext context,
    SearchState state,
    AppLocalizations l10n,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.activeReportsCount(state.results.length)}'
          '  ·  ${l10n.mostRecentFirst}',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12.h),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsetsDirectional.only(bottom: 16.h),
            itemCount: state.results.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) =>
                _buildCard(state.results[index], l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(ReportEntity report, AppLocalizations l10n) {
    return ReportCard(
      title: report.title,
      type: report.type,
      status: report.status,
      areaName: report.areaName(l10n.localeName),
      cityName: report.cityName(l10n.localeName),
      date: report.itemDate,
      imageUrl: report.primaryImageUrl,
    );
  }

  List<Widget> _buildChips(
    BuildContext context,
    SearchState state,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<SearchCubit>();
    final chips = <Widget>[];

    final type = state.type;
    if (type != null) {
      chips.add(
        ActiveFilterChip(
          label: type == ReportType.lost ? l10n.typeLost : l10n.typeFound,
          isPrimary: true,
          onRemove: cubit.clearTypeFilter,
        ),
      );
    }

    for (final categoryId in state.categoryIds) {
      final category = _categoryOption(state, categoryId);
      if (category == null) continue;
      chips.add(
        ActiveFilterChip(
          label: category.name(l10n.localeName),
          isPrimary: true,
          onRemove: () => cubit.removeCategoryFilter(categoryId),
        ),
      );
    }

    for (final areaId in state.areaIds) {
      final area = _areaOption(state, areaId);
      if (area == null) continue;
      chips.add(
        ActiveFilterChip(
          label: area.name(l10n.localeName),
          onRemove: () => cubit.removeAreaFilter(areaId),
        ),
      );
    }

    if (state.dateFrom != null || state.dateTo != null) {
      final format = intl.DateFormat.MMMd(l10n.localeName);
      final parts = <String>[];
      final from = _parseDate(state.dateFrom);
      final to = _parseDate(state.dateTo);
      if (from != null) parts.add(l10n.dateFromValue(format.format(from)));
      if (to != null) parts.add(l10n.dateUntilValue(format.format(to)));
      chips.add(
        ActiveFilterChip(
          label: parts.join(' · '),
          onRemove: cubit.clearDateFilter,
        ),
      );
    }

    final cityName = state.cityName(l10n.localeName);
    if (cityName.isNotEmpty) {
      chips.add(ActiveFilterChip(label: cityName));
    }

    return chips;
  }

  CategoryOption? _categoryOption(SearchState state, String id) {
    for (final category in state.categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  AreaOption? _areaOption(SearchState state, String id) {
    for (final area in state.areas) {
      if (area.id == id) return area;
    }
    return null;
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static String? _formatDate(DateTime? value) {
    if (value == null) return null;
    return value.toIso8601String().split('T').first;
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.l10n, required this.onRetry});

  final AppLocalizations l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56.r,
              color: colors.onSurfaceVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.searchFailedTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              l10n.searchFailedMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14.sp),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: 180.w,
              child: AppButton(label: l10n.retry, onPressed: onRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.l10n, required this.onClearFilters});

  final AppLocalizations l10n;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56.r,
              color: colors.onSurfaceVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.emptySearchTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              l10n.emptySearchMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14.sp),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: 180.w,
              child: AppButton(
                label: l10n.clearFilters,
                variant: AppButtonVariant.outlined,
                onPressed: onClearFilters,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
