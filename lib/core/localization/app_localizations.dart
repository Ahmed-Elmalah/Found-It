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

  /// No description provided for @chooseCitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your city to see lost and found reports near you.'**
  String get chooseCitySubtitle;

  /// No description provided for @locationRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Required:'**
  String get locationRequiredTitle;

  /// No description provided for @locationRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select a city to continue.'**
  String get locationRequiredMessage;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

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

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmail;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account?'**
  String get noAccount;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpLink;

  /// No description provided for @invalidCredentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid Credentials:'**
  String get invalidCredentialsTitle;

  /// No description provided for @invalidCredentialsMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your email and password.'**
  String get invalidCredentialsMessage;

  /// No description provided for @connectionErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection error:'**
  String get connectionErrorTitle;

  /// No description provided for @connectionErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get connectionErrorMessage;

  /// No description provided for @genericErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong:'**
  String get genericErrorTitle;

  /// No description provided for @genericErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get genericErrorMessage;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get fullNameHint;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'10 1234 5678'**
  String get phoneHint;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get addressHint;

  /// No description provided for @passwordHelper.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordHelper;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountButton;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @logInLink.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logInLink;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameTooShort;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Egyptian mobile number'**
  String get invalidPhone;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @registrationFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration Failed:'**
  String get registrationFailedTitle;

  /// No description provided for @emailInUseMessage.
  ///
  /// In en, this message translates to:
  /// **'An account with this email address already exists.'**
  String get emailInUseMessage;

  /// No description provided for @weakPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Weak password:'**
  String get weakPasswordTitle;

  /// No description provided for @weakPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password.'**
  String get weakPasswordMessage;

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

  /// No description provided for @notLoggedInTitle.
  ///
  /// In en, this message translates to:
  /// **'Login Required:'**
  String get notLoggedInTitle;

  /// No description provided for @notLoggedInMessage.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to create a report.'**
  String get notLoggedInMessage;

  /// No description provided for @invalidDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid Data:'**
  String get invalidDataTitle;

  /// No description provided for @invalidDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check the entered report details.'**
  String get invalidDataMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we’ll send you a link to reset it.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLinkButton;

  /// No description provided for @rememberedIt.
  ///
  /// In en, this message translates to:
  /// **'Remembered it?'**
  String get rememberedIt;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @resetComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Password reset will be available soon.'**
  String get resetComingSoon;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to {email}. Open it to activate your account.'**
  String verifyEmailBody(String email);

  /// No description provided for @verifiedButton.
  ///
  /// In en, this message translates to:
  /// **'I’ve verified my email'**
  String get verifiedButton;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get resendEmail;

  /// No description provided for @resendEmailIn.
  ///
  /// In en, this message translates to:
  /// **'Resend email · {time}'**
  String resendEmailIn(String time);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get navReport;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity in {city}'**
  String homeRecentActivity(String city);

  /// No description provided for @homeFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get homeFilterAll;

  /// No description provided for @homeFilterLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get homeFilterLost;

  /// No description provided for @homeFilterFound.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get homeFilterFound;

  /// No description provided for @homeHeroTag.
  ///
  /// In en, this message translates to:
  /// **'✨ Quick Action'**
  String get homeHeroTag;

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Lost something? Let’s bring it back.'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroButton.
  ///
  /// In en, this message translates to:
  /// **'Report now'**
  String get homeHeroButton;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reports yet in {city}'**
  String homeEmptyTitle(String city);

  /// No description provided for @homeEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'The city is calm with no registered reports. If you lost or found something, help others and create the first report!'**
  String get homeEmptySubtitle;

  /// No description provided for @homeEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Create first report'**
  String get homeEmptyAction;

  /// No description provided for @homeErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load reports'**
  String get homeErrorTitle;

  /// No description provided for @homeErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and pull to refresh or tap retry.'**
  String get homeErrorSubtitle;

  /// No description provided for @homeRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get homeRetryButton;

  /// No description provided for @homeNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get homeNotifications;

  /// No description provided for @homeChangeCity.
  ///
  /// In en, this message translates to:
  /// **'Change City'**
  String get homeChangeCity;

  /// No description provided for @homeSelectCityTitle.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get homeSelectCityTitle;

  /// No description provided for @homeSelectCitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse found items in your governorate'**
  String get homeSelectCitySubtitle;

  /// No description provided for @homeSearchCityHint.
  ///
  /// In en, this message translates to:
  /// **'Search city or governorate...'**
  String get homeSearchCityHint;

  /// No description provided for @homeNoCitiesFound.
  ///
  /// In en, this message translates to:
  /// **'No cities found matching your search'**
  String get homeNoCitiesFound;
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
