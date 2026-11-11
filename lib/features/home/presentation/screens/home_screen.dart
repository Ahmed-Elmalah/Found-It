import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/theme/app_colors.dart';
import 'package:found_it/core/theme/app_theme.dart';
import 'package:found_it/core/widgets/empty_state.dart';

/// Home feed screen (Figma P17, light mode) - empty state version.
///
/// Pure UI with mock data: the selected city is a mock, the feed is empty by
/// design in this screen, and the action buttons are visual only until their
/// features land.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Mock selected city until the city feature lands.
  static const String _mockCity = 'Cairo';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _mockCity,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: 22.r,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding.w),
            child: _buildSearchField(l10n, colors),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding.w),
            child: _buildActionCards(l10n, colors),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding.w),
            child: _buildSectionHeader(l10n, colors),
          ),
          Expanded(
            child: EmptyState(
              icon: Icons.inventory_2_outlined,
              title: l10n.noReportsInCity(_mockCity),
              message: l10n.beFirstToReport,
              action: FilledButton(
                // The create report flow is a separate user story.
                onPressed: () {},
                child: Text(l10n.createReport),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n, ColorScheme colors) {
    return IgnorePointer(
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          hintText: l10n.homeSearchHint,
          prefixIcon: const Icon(Icons.search),
          prefixIconColor: colors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildActionCards(AppLocalizations l10n, ColorScheme colors) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(label: l10n.actionLost, color: colors.error),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _ActionCard(
            label: l10n.actionFound,
            color: AppColors.successLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(AppLocalizations l10n, ColorScheme colors) {
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.latestInCity(_mockCity),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          // The full city feed screen arrives with the reports feature.
          onPressed: () {},
          child: Text(l10n.seeAll),
        ),
      ],
    );
  }
}

/// Tinted status action card ("I lost something" / "I found something").
/// The background is a soft tint of [color] and the text uses it at full
/// opacity, mirroring the StatusChip style.
class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radius.r),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
