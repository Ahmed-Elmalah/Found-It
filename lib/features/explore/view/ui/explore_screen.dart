import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/theme/app_theme.dart';
import 'package:found_it/core/widgets/empty_state.dart';
import 'package:found_it/core/widgets/report_card.dart';
import 'package:found_it/core/widgets/report_category.dart';
import 'package:found_it/core/widgets/report_status.dart';
import 'package:found_it/features/explore/view/ui/widgets/active_filter_chip.dart';
import 'package:found_it/features/explore/view/ui/widgets/filter_bottom_sheet.dart';

/// Explore / Smart Search screen (Figma P19, light mode).
///
/// Pure UI with mock data: the query text and the category filter are
/// matched against the local mock list only - the real query engine and the
/// data source arrive in later tasks of this user story.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static final List<_MockReport> _mockReports = [
    _MockReport(
      title: 'Black wireless earbuds',
      status: ReportStatus.lost,
      category: ReportCategory.electronics,
      location: 'Nasr City, Cairo',
      date: DateTime(2026, 11, 6),
      imageUrl: 'https://picsum.photos/seed/found-it-earbuds/200',
    ),
    _MockReport(
      title: 'Silver laptop charger',
      status: ReportStatus.found,
      category: ReportCategory.electronics,
      location: 'Dokki, Giza',
      date: DateTime(2026, 11, 4),
      imageUrl: 'https://picsum.photos/seed/found-it-charger/200',
    ),
    _MockReport(
      title: 'Smartphone with a blue case',
      status: ReportStatus.lost,
      category: ReportCategory.electronics,
      location: 'Maadi, Cairo',
      date: DateTime(2026, 11, 2),
      imageUrl: 'https://picsum.photos/seed/found-it-phone/200',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();

  /// Mock filters matching the P19/P20 example: Electronics, Nov 1-7, Cairo.
  ExploreFilters _filters = ExploreFilters(
    category: ReportCategory.electronics,
    startDate: DateTime(2026, 11, 1),
    endDate: DateTime(2026, 11, 7),
    city: 'Cairo',
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<ExploreFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FilterBottomSheet(initialFilters: _filters),
    );
    if (result == null || !mounted) return;
    setState(() => _filters = result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final results = _matchingReports;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exploreTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding.w),
            child: _buildSearchField(l10n, colors),
          ),
          if (_filters.hasAny) ...[
            SizedBox(height: 12.h),
            _buildActiveChips(l10n),
          ],
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding.w),
            child: Text(
              '${l10n.activeReportsCount(results.length)} · ${l10n.mostRecentFirst}',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: results.isEmpty
                ? EmptyState(
                    title: l10n.emptySearchTitle,
                    message: l10n.emptySearchMessage,
                  )
                : _buildResultsList(results),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n, ColorScheme colors) {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: l10n.searchHint,
        prefixIcon: const Icon(Icons.search),
        prefixIconColor: colors.onSurfaceVariant,
        suffixIcon: IconButton(
          icon: const Icon(Icons.tune),
          color: colors.primary,
          onPressed: _openFilters,
        ),
      ),
    );
  }

  Widget _buildActiveChips(AppLocalizations l10n) {
    final chips = <Widget>[
      if (_filters.category != null)
        ActiveFilterChip(
          label: _filters.category!.label(l10n),
          filled: true,
          onRemove: () => setState(() => _filters.category = null),
        ),
      if (_filters.startDate != null && _filters.endDate != null)
        ActiveFilterChip(
          label: _dateRangeLabel(l10n),
          onRemove: () => setState(() {
            _filters.startDate = null;
            _filters.endDate = null;
          }),
        ),
      if ((_filters.city ?? '').trim().isNotEmpty)
        ActiveFilterChip(
          label: _filters.city!.trim(),
          onRemove: () => setState(() => _filters.city = null),
        ),
    ];

    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding.w),
        itemCount: chips.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (_, index) => chips[index],
      ),
    );
  }

  Widget _buildResultsList(List<_MockReport> results) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePadding.w,
        0,
        AppSizes.pagePadding.w,
        AppSizes.pagePadding.w,
      ),
      itemCount: results.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final report = results[index];
        return ReportCard(
          title: report.title,
          status: report.status,
          location: report.location,
          date: report.date,
          imageUrl: report.imageUrl,
        );
      },
    );
  }

  /// Mock matching: query text + category only (local, no backend).
  List<_MockReport> get _matchingReports {
    final query = _searchController.text.trim().toLowerCase();

    return _mockReports.where((report) {
      final matchesQuery =
          query.isEmpty || report.title.toLowerCase().contains(query);
      final matchesCategory =
          _filters.category == null || report.category == _filters.category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  String _dateRangeLabel(AppLocalizations l10n) {
    final format = intl.DateFormat.MMMd(l10n.localeName);
    return '${format.format(_filters.startDate!)} – ${format.format(_filters.endDate!)}';
  }
}

/// Mock data only - replaced by the real report model in later tasks.
class _MockReport {
  const _MockReport({
    required this.title,
    required this.status,
    required this.category,
    required this.location,
    required this.date,
    required this.imageUrl,
  });

  final String title;
  final ReportStatus status;
  final ReportCategory category;
  final String location;
  final DateTime date;
  final String? imageUrl;
}
