import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/theme/app_theme.dart';
import 'package:found_it/core/widgets/report_card.dart';
import 'package:found_it/features/explore/data/mock/explore_mock_data.dart';
import 'package:found_it/features/explore/domain/report_entity.dart';
import 'package:found_it/features/explore/view/ui/widgets/active_filter_chip.dart';
import 'package:found_it/features/explore/view/ui/widgets/filters_bottom_sheet.dart';

/// Explore screen (Figma P19 / P52).
///
/// Phase 1: renders [ExploreMockData] and filters it locally. The follow-up
/// data layer will replace the mock calls; the UI stays the same.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();

  String _query = '';
  String? _categoryId;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _showCityChip = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ReportEntity> get _results => ExploreMockData.search(
    query: _query,
    categoryId: _categoryId,
    dateFrom: _dateFrom,
    dateTo: _dateTo,
  );

  Future<void> _openFilters() async {
    final l10n = AppLocalizations.of(context);
    final result = await showModalBottomSheet<ExploreFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FiltersBottomSheet(
        categories: ExploreMockData.categories,
        cityName: ExploreMockData.city.name(l10n.localeName),
        initialCategoryId: _categoryId,
        initialDateFrom: _dateFrom,
        initialDateTo: _dateTo,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _categoryId = result.categoryId;
      _dateFrom = result.dateFrom;
      _dateTo = result.dateTo;
    });
  }

  void _clearDateRange() {
    setState(() {
      _dateFrom = null;
      _dateTo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final results = _results;
    final chips = _buildChips(l10n);

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
      body: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          AppSizes.pagePadding.w,
          8.h,
          AppSizes.pagePadding.w,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
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
                  onPressed: _openFilters,
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
            if (results.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Text(
                '${l10n.activeReportsCount(results.length)}'
                '  ·  ${l10n.mostRecentFirst}',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(child: _buildList(l10n, results)),
            ] else ...[
              SizedBox(height: 16.h),
              Expanded(child: _EmptyView(l10n: l10n)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildList(AppLocalizations l10n, List<ReportEntity> results) {
    return ListView.separated(
      padding: EdgeInsetsDirectional.only(bottom: 16.h),
      itemCount: results.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final report = results[index];
        return ReportCard(
          title: report.title,
          type: report.type,
          status: report.status,
          location: report.location(l10n.localeName),
          date: report.itemDate,
          imageUrl: report.primaryImageUrl,
        );
      },
    );
  }

  List<Widget> _buildChips(AppLocalizations l10n) {
    final chips = <Widget>[];

    final categoryId = _categoryId;
    if (categoryId != null) {
      for (final category in ExploreMockData.categories) {
        if (category.id == categoryId) {
          chips.add(
            ActiveFilterChip(
              label: category.name(l10n.localeName),
              isPrimary: true,
            ),
          );
          break;
        }
      }
    }

    if (_dateFrom != null || _dateTo != null) {
      final format = intl.DateFormat.MMMd(l10n.localeName);
      final parts = <String>[];
      if (_dateFrom != null) {
        parts.add(l10n.dateFromValue(format.format(_dateFrom!)));
      }
      if (_dateTo != null) {
        parts.add(l10n.dateUntilValue(format.format(_dateTo!)));
      }
      chips.add(
        ActiveFilterChip(label: parts.join(' · '), onRemove: _clearDateRange),
      );
    }

    if (_showCityChip) {
      chips.add(
        ActiveFilterChip(
          label: ExploreMockData.city.name(l10n.localeName),
          onRemove: () => setState(() => _showCityChip = false),
        ),
      );
    }

    return chips;
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.l10n});

  final AppLocalizations l10n;

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
          ],
        ),
      ),
    );
  }
}
