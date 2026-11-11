import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/widgets/line_icon.dart';

/// The FOUND IT logo: a rounded square tile with the search-check icon.
///
///   const AppLogo(size: 96)
///   AppLogo(size: 48, tileColor: colors.primary, iconColor: colors.onPrimary)
///
/// Light theme: white tile, primary icon. Dark theme: primary tile, onPrimary icon.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96, this.tileColor, this.iconColor});

  final double size;
  final Color? tileColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final tile = tileColor ?? (isDark ? colors.primary : colors.surface);
    final icon = iconColor ?? (isDark ? colors.onPrimary : colors.primary);

    return Semantics(
      image: true,
      label: AppLocalizations.of(context).appName,
      child: Container(
        width: size.r,
        height: size.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tile,
          borderRadius: BorderRadius.circular(size.r * 0.25),
        ),
        child: LineIcon(
          LineIconType.searchCheck,
          size: size.r * 0.6,
          color: icon,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
