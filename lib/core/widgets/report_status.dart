import 'package:flutter/material.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/theme/app_colors.dart';

/// Status of a report, displayed as a [StatusChip] in cards and lists.
///
/// TEMPORARY home (Task #1 of User Story #2 - pure UI with mock data):
/// once the `reports` feature lands, move this enum next to its entity in
/// `features/reports/domain/` and keep only the presentation mapping here.
enum ReportStatus { lost, found, active, resolved }

extension ReportStatusX on ReportStatus {
  /// Localized label for the status chip.
  String label(AppLocalizations l10n) => switch (this) {
    ReportStatus.lost => l10n.statusLost,
    ReportStatus.found => l10n.statusFound,
    ReportStatus.active => l10n.statusActive,
    ReportStatus.resolved => l10n.statusResolved,
  };

  /// Chip color for the active theme (light / dark aware):
  ///  - lost     -> error (red)
  ///  - found    -> success (green, from the central palette)
  ///  - active   -> primary (brand blue)
  ///  - resolved -> neutral (muted)
  Color color(BuildContext context) {
    final theme = Theme.of(context);
    return switch (this) {
      ReportStatus.lost => theme.colorScheme.error,
      ReportStatus.found =>
        theme.brightness == Brightness.light
            ? AppColors.successLight
            : AppColors.successDark,
      ReportStatus.active => theme.colorScheme.primary,
      ReportStatus.resolved => theme.colorScheme.onSurfaceVariant,
    };
  }
}
