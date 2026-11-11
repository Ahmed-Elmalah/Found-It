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

  @override
  String get fieldRequired => 'Required';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Log in to continue.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Log in';

  @override
  String get noAccount => 'Don’t have an account?';

  @override
  String get signUpLink => 'Sign up';

  @override
  String get invalidCredentialsTitle => 'Invalid Credentials:';

  @override
  String get invalidCredentialsMessage =>
      'Please check your email and password.';

  @override
  String get connectionErrorTitle => 'Connection error:';

  @override
  String get connectionErrorMessage => 'Check your connection and try again.';

  @override
  String get genericErrorTitle => 'Something went wrong:';

  @override
  String get genericErrorMessage => 'Please try again.';
}
