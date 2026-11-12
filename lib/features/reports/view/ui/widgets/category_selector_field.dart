import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';

/// A tappable field that opens a bottom-sheet list for picking a [category].
class CategorySelectorField extends StatelessWidget {
  final List<CategoryEntity> categories;
  final String? selectedId;
  final String? errorText;
  final ValueChanged<String> onSelected;
  final bool isLoading;

  const CategorySelectorField({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    this.errorText,
    this.isLoading = false,
  });

  static IconData mapCategoryIcon(String icon) {
    switch (icon.toLowerCase().trim()) {
      case 'devices':
      case 'electronics':
      case 'phone_iphone':
        return Icons.devices_rounded;
      case 'account_balance_wallet':
      case 'wallet':
      case 'wallets':
        return Icons.account_balance_wallet_rounded;
      case 'vpn_key':
      case 'key':
      case 'keys':
        return Icons.vpn_key_rounded;
      case 'backpack':
      case 'bag':
      case 'bags':
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;
      case 'description':
      case 'document':
      case 'documents':
      case 'folder':
        return Icons.description_rounded;
      case 'pets':
      case 'pet':
        return Icons.pets_rounded;
      case 'watch':
        return Icons.watch_rounded;
      case 'glasses':
        return Icons.visibility_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final hasError = errorText != null;

    final selectedCategory = categories
        .where((c) => c.id == selectedId)
        .firstOrNull;
    final displayText = selectedCategory?.localizedName(locale) ?? l10n.selectCategory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: l10n.category,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: hasError ? colors.error : colors.onSurface,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: colors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: isLoading ? null : () => _showSheet(context),
          child: Container(
            height: 56.h,
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: hasError ? colors.error : colors.outline,
                width: hasError ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selectedCategory != null
                      ? mapCategoryIcon(selectedCategory.icon)
                      : Icons.grid_view_rounded,
                  size: 20.r,
                  color: hasError
                      ? colors.error
                      : (selectedCategory != null
                          ? colors.primary
                          : colors.onSurfaceVariant),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: selectedCategory != null
                          ? colors.onSurface
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22.r,
                    color: colors.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 14.r,
                color: colors.error,
              ),
              SizedBox(width: 4.w),
              Text(
                errorText!,
                style: TextStyle(fontSize: 12.sp, color: colors.error),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _showSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.w, 4.h, 20.w, 12.h),
                child: Text(
                  l10n.category,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (ctx, index) {
                    final cat = categories[index];
                    final isSelected = selectedId == cat.id;
                    return ListTile(
                      leading: Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary.withValues(alpha: 0.12)
                              : colors.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          mapCategoryIcon(cat.icon),
                          color: isSelected ? colors.primary : colors.onSurfaceVariant,
                          size: 20.r,
                        ),
                      ),
                      title: Text(
                        cat.localizedName(locale),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? colors.primary : colors.onSurface,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              color: colors.primary,
                              size: 20.r,
                            )
                          : null,
                      onTap: () {
                        onSelected(cat.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
