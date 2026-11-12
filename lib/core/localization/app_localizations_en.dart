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

  @override
  String get signUpTitle => 'Create account';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameHint => 'Your full name';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get phoneHint => '10 1234 5678';

  @override
  String get addressLabel => 'Address';

  @override
  String get addressHint => 'Optional';

  @override
  String get passwordHelper => 'At least 8 characters';

  @override
  String get createAccountButton => 'Create account';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get logInLink => 'Log in';

  @override
  String get nameTooShort => 'Name must be at least 2 characters';

  @override
  String get invalidPhone => 'Enter a valid Egyptian mobile number';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get registrationFailedTitle => 'Registration Failed:';

  @override
  String get emailInUseMessage =>
      'An account with this email address already exists.';

  @override
  String get weakPasswordTitle => 'Weak password:';

  @override
  String get weakPasswordMessage => 'Choose a stronger password.';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we’ll send you a link to reset it.';

  @override
  String get sendResetLinkButton => 'Send reset link';

  @override
  String get rememberedIt => 'Remembered it?';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get resetComingSoon => 'Password reset will be available soon.';

  @override
  String get verifyEmailTitle => 'Verify your email';

  @override
  String verifyEmailBody(String email) {
    return 'We sent a verification link to $email. Open it to activate your account.';
  }

  @override
  String get verifiedButton => 'I’ve verified my email';

  @override
  String get resendEmail => 'Resend email';

  @override
  String resendEmailIn(String time) {
    return 'Resend email · $time';
  }

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
  String dateFromValue(String date) {
    return 'From $date';
  }

  @override
  String dateUntilValue(String date) {
    return 'Until $date';
  }

  @override
  String get reset => 'Reset';

  @override
  String get showResults => 'Show results';

  @override
  String get emptySearchTitle => 'No matching reports found.';

  @override
  String get emptySearchMessage => 'Try adjusting your search filters.';

  @override
  String get typeLost => 'Lost';

  @override
  String get typeFound => 'Found';

  @override
  String get statusMatching => 'Matching';

  @override
  String get statusRecovered => 'Recovered';
}
