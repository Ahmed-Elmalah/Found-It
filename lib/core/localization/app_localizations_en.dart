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
  String get tabHome => 'Home';

  @override
  String get tabExplore => 'Explore';

  @override
  String get tabReport => 'Report';

  @override
  String get tabMessages => 'Messages';

  @override
  String get tabProfile => 'Profile';

  @override
  String get homeSearchHint => 'Search lost or found items';

  @override
  String get actionLost => 'I lost something';

  @override
  String get actionFound => 'I found something';

  @override
  String latestInCity(String city) {
    return 'Latest in $city';
  }

  @override
  String get seeAll => 'See all';

  @override
  String noReportsInCity(String city) {
    return 'No reports in $city yet';
  }

  @override
  String get beFirstToReport =>
      'Be the first to report a lost or found item in your city.';

  @override
  String get createReport => 'Create report';

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
