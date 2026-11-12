// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FOUND IT';

  @override
  String get appTagline => 'Lost something? Let’s bring it back.';

  @override
  String get chooseCityTitle => 'Choose your city';

  @override
  String get chooseCitySubtitle =>
      'Select your city to see lost and found reports near you.';

  @override
  String get locationRequiredTitle => 'Location Required:';

  @override
  String get locationRequiredMessage => 'Please select a city to continue.';

  @override
  String get continueButton => 'Continue';

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
  String get createReport => 'Create report';

  @override
  String get reportType => 'Report type';

  @override
  String get lost => 'Lost';

  @override
  String get found => 'Found';

  @override
  String get itemTitle => 'Item title';

  @override
  String get itemTitleHint => 'e.g., Black leather wallet';

  @override
  String itemTitleCounter(int count) {
    return '$count/50';
  }

  @override
  String get category => 'Category';

  @override
  String get selectCategory => 'Select category';

  @override
  String get locationDistrict => 'Location (district)';

  @override
  String get selectDistrict => 'Select district';

  @override
  String get date => 'Date';

  @override
  String get photos => 'Photos';

  @override
  String photoCounter(int count) {
    return '$count/4';
  }

  @override
  String get addPhoto => 'Add';

  @override
  String get photoHint => 'JPG or PNG, up to 10 MB each. Add 1 to 4 photos.';

  @override
  String get submitReport => 'Submit report';

  @override
  String get titleTooShort => 'Title must be at least 3 characters';

  @override
  String get titleTooLong => 'Title must be at most 50 characters';

  @override
  String get categoryRequired => 'Please select a category';

  @override
  String get districtRequired => 'Please select a district';

  @override
  String get photosRequired => 'Please add at least 1 photo';

  @override
  String get invalidFileType => 'Only JPG and PNG files are allowed';

  @override
  String get invalidFileSize => 'File size must be under 10 MB';

  @override
  String get requiredFieldsBannerTitle => 'Required Fields:';

  @override
  String get requiredFieldsBannerMessage =>
      'Title, category, and location are required.';

  @override
  String get invalidFileBannerTitle => 'Invalid File:';

  @override
  String get invalidFileBannerMessage =>
      'Please upload image files (JPG/PNG) under 10 MB.';

  @override
  String get photoRejected => 'Rejected';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get reportCreatedTitle => 'Report Created Successfully!';

  @override
  String reportCreatedId(String id) {
    return 'Your report ID is $id';
  }

  @override
  String get reportActiveMessage =>
      'Your report is Active and listed for matching.';

  @override
  String get viewMyReport => 'View my report';

  @override
  String get backToHome => 'Back to home';

  @override
  String get notLoggedInTitle => 'Login Required:';

  @override
  String get notLoggedInMessage => 'You must be logged in to create a report.';

  @override
  String get invalidDataTitle => 'Invalid Data:';

  @override
  String get invalidDataMessage => 'Please check the entered report details.';

  @override
  String get retry => 'Retry';

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
  String get navHome => 'Home';

  @override
  String get navExplore => 'Explore';

  @override
  String get navReport => 'Report';

  @override
  String get navNotifications => 'Alerts';

  @override
  String get navProfile => 'Profile';
}
