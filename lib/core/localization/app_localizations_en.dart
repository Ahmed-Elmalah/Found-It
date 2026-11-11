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
  String get appName => 'FOUND IT';

  @override
  String get appTagline => 'Lost something? Let’s bring it back.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingFindTitle => 'Find what you lost';

  @override
  String get onboardingFindBody =>
      'Search reports in your city and filter by category and date.';

  @override
  String get onboardingReportTitle => 'Report what you found';

  @override
  String get onboardingReportBody =>
      'Publish a report with photos and details so the owner can reach you.';

  @override
  String get onboardingChatTitle => 'Chat and get it back';

  @override
  String get onboardingChatBody =>
      'Message the other side inside the app and arrange a safe handover.';
}
