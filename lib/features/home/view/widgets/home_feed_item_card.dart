import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import '../../domain/entities/home_report_item.dart';

class HomeFeedItemCard extends StatefulWidget {
  const HomeFeedItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final HomeReportItem item;
  final VoidCallback? onTap;

  @override
  State<HomeFeedItemCard> createState() => _HomeFeedItemCardState();
}

class _HomeFeedItemCardState extends State<HomeFeedItemCard> {
  bool _isPressed = false;

  IconData _resolveCategoryIcon(String iconName) {
    return switch (iconName.toLowerCase()) {
      'headphones' => Icons.headphones_rounded,
      'smartphone' || 'phone' => Icons.smartphone_rounded,
      'account_balance_wallet' || 'wallet' || 'wallets' =>
        Icons.account_balance_wallet_rounded,
      'key' || 'keys' => Icons.key_rounded,
      'badge' || 'document' || 'documents' => Icons.badge_outlined,
      'pets' || 'pet' => Icons.pets_rounded,
      'backpack' || 'bag' || 'bags' => Icons.backpack_outlined,
      _ => Icons.category_rounded,
    };
  }

  String _formatTimeAgo(DateTime date, BuildContext context) {
    final diff = DateTime.now().difference(date);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    if (diff.inMinutes < 60) {
      final mins = diff.inMinutes.clamp(1, 59);
      return isAr ? 'منذ $mins د' : '${mins}m ago';
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      return isAr ? 'منذ $hours س' : '${hours}h ago';
    } else {
      final days = diff.inDays;
      return isAr ? 'منذ $days ي' : '${days}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final item = widget.item;

    final isLost = item.isLost;
    final tagBg = isLost
        ? (isDark ? const Color(0xFF3F1717) : const Color(0xFFFEE2E2))
        : (isDark ? const Color(0xFF0D3323) : const Color(0xFFD1FAE5));
    final tagText = isLost
        ? (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626))
        : (isDark ? const Color(0xFF34D399) : const Color(0xFF059669));

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutQuad,
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
                blurRadius: 16.r,
                offset: Offset(0, 4.h),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                blurRadius: 4.r,
                offset: Offset(0, 1.h),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Rounded Thumbnail Image or Category Icon Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  width: 72.r,
                  height: 72.r,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : (isLost
                          ? const Color(0xFFFFF1F2)
                          : const Color(0xFFF0FDF4)),
                  child: item.hasImages
                      ? Image.network(
                          item.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildCategoryIconFallback(
                            item,
                            isDark,
                            tagText,
                          ),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 20.r,
                                height: 20.r,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    tagText.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : _buildCategoryIconFallback(item, isDark, tagText),
                ),
              ),
              SizedBox(width: 14.w),

              // Right: Content Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Row: Tag (Lost/Found) + Time Ago
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: tagBg,
                          ),
                          child: Text(
                            isLost ? l10n.lost : l10n.found,
                            style: TextStyle(
                              color: tagText,
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTimeAgo(item.createdAt, context),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.75),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),

                    // Title
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 4.h),

                    // Location: Area, City
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14.r,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.75),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            '${item.areaName}, ${item.cityName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIconFallback(
    HomeReportItem item,
    bool isDark,
    Color accentColor,
  ) {
    return Center(
      child: Icon(
        _resolveCategoryIcon(item.categoryIcon),
        size: 30.r,
        color: accentColor.withValues(alpha: isDark ? 0.85 : 0.75),
      ),
    );
  }
}
