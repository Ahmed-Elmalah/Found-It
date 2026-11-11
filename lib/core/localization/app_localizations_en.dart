// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get chooseCityTitle => 'Choose your city';

  @override
  String get statusLost => 'Lost';

  @override
  String get statusFound => 'Found';

  @override
  String get statusActive => 'Active';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get searchHint => 'Search';

  @override
  String activeReportsCount(int count) {
    return '$count active reports';
  }

  @override
  String get mostRecentFirst => 'Most recent first';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get categoryLabel => 'Category';

  @override
  String get dateRangeLabel => 'Date range';

  @override
  String get cityLabel => 'City';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get reset => 'Reset';

  @override
  String get showResults => 'Show results';

  @override
  String get emptySearchTitle => 'No matching reports found.';

  @override
  String get emptySearchMessage => 'Try adjusting your search filters.';

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categoryValuables => 'Valuables';

  @override
  String get categoryKeys => 'Keys';

  @override
  String get categoryBags => 'Bags';

  @override
  String get categoryDocuments => 'Documents';

  @override
  String get categoryPets => 'Pets';
}
