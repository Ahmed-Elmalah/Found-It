import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'FOUND IT'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Lost something? Let’s bring it back.'**
  String get appTagline;

  /// No description provided for @chooseCityTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your city'**
  String get chooseCityTitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingFindTitle.
  ///
  /// In en, this message translates to:
  /// **'Find what you lost'**
  String get onboardingFindTitle;

  /// No description provided for @onboardingFindBody.
  ///
  /// In en, this message translates to:
  /// **'Search reports in your city and filter by category and date.'**
  String get onboardingFindBody;

  /// No description provided for @onboardingReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report what you found'**
  String get onboardingReportTitle;

  /// No description provided for @onboardingReportBody.
  ///
  /// In en, this message translates to:
  /// **'Publish a report with photos and details so the owner can reach you.'**
  String get onboardingReportBody;

  /// No description provided for @onboardingChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat and get it back'**
  String get onboardingChatTitle;

  /// No description provided for @onboardingChatBody.
  ///
  /// In en, this message translates to:
  /// **'Message the other side inside the app and arrange a safe handover.'**
  String get onboardingChatBody;

  /// No description provided for @createReport.
  ///
  /// In en, this message translates to:
  /// **'Create report'**
  String get createReport;

  /// No description provided for @reportType.
  ///
  /// In en, this message translates to:
  /// **'Report type'**
  String get reportType;

  /// No description provided for @lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get lost;

  /// No description provided for @found.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get found;

  /// No description provided for @itemTitle.
  ///
  /// In en, this message translates to:
  /// **'Item title'**
  String get itemTitle;

  /// No description provided for @itemTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Black leather wallet'**
  String get itemTitleHint;

  /// No description provided for @itemTitleCounter.
  ///
  /// In en, this message translates to:
  /// **'{count}/50'**
  String itemTitleCounter(int count);

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @locationDistrict.
  ///
  /// In en, this message translates to:
  /// **'Location (district)'**
  String get locationDistrict;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select district'**
  String get selectDistrict;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @photoCounter.
  ///
  /// In en, this message translates to:
  /// **'{count}/4'**
  String photoCounter(int count);

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addPhoto;

  /// No description provided for @photoHint.
  ///
  /// In en, this message translates to:
  /// **'JPG or PNG, up to 10 MB each. Add 1 to 4 photos.'**
  String get photoHint;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get submitReport;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @titleTooShort.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 3 characters'**
  String get titleTooShort;

  /// No description provided for @titleTooLong.
  ///
  /// In en, this message translates to:
  /// **'Title must be at most 50 characters'**
  String get titleTooLong;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get categoryRequired;

  /// No description provided for @districtRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a district'**
  String get districtRequired;

  /// No description provided for @photosRequired.
  ///
  /// In en, this message translates to:
  /// **'Please add at least 1 photo'**
  String get photosRequired;

  /// No description provided for @invalidFileType.
  ///
  /// In en, this message translates to:
  /// **'Only JPG and PNG files are allowed'**
  String get invalidFileType;

  /// No description provided for @invalidFileSize.
  ///
  /// In en, this message translates to:
  /// **'File size must be under 10 MB'**
  String get invalidFileSize;

  /// No description provided for @requiredFieldsBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Required Fields:'**
  String get requiredFieldsBannerTitle;

  /// No description provided for @requiredFieldsBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'Title, category, and location are required.'**
  String get requiredFieldsBannerMessage;

  /// No description provided for @invalidFileBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid File:'**
  String get invalidFileBannerTitle;

  /// No description provided for @invalidFileBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'Please upload image files (JPG/PNG) under 10 MB.'**
  String get invalidFileBannerMessage;

  /// No description provided for @photoRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get photoRejected;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @reportCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Created Successfully!'**
  String get reportCreatedTitle;

  /// No description provided for @reportCreatedId.
  ///
  /// In en, this message translates to:
  /// **'Your report ID is {id}'**
  String reportCreatedId(String id);

  /// No description provided for @reportActiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Your report is Active and listed for matching.'**
  String get reportActiveMessage;

  /// No description provided for @viewMyReport.
  ///
  /// In en, this message translates to:
  /// **'View my report'**
  String get viewMyReport;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
