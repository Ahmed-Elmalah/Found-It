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
  String get fieldRequired => 'Required';

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
}
