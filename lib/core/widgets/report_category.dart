import 'package:found_it/core/localization/app_localizations.dart';

/// Category of a report, used by the search filters and the report form.
///
/// TEMPORARY home (User Story #2 - pure UI with mock data): once the
/// `reports` feature lands, move this enum next to its entity in
/// `features/reports/domain/` and keep only the presentation mapping here.
enum ReportCategory { electronics, valuables, keys, bags, documents, pets }

extension ReportCategoryX on ReportCategory {
  /// Localized label, also shown on filter chips.
  String label(AppLocalizations l10n) => switch (this) {
    ReportCategory.electronics => l10n.categoryElectronics,
    ReportCategory.valuables => l10n.categoryValuables,
    ReportCategory.keys => l10n.categoryKeys,
    ReportCategory.bags => l10n.categoryBags,
    ReportCategory.documents => l10n.categoryDocuments,
    ReportCategory.pets => l10n.categoryPets,
  };
}
