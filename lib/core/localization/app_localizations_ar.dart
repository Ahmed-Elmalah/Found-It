// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get chooseCityTitle => 'اختر مدينتك';

  @override
  String get appName => 'FOUND IT';

  @override
  String get appTagline => 'فقدت شيئًا؟ دعنا نُعيده إليك.';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get onboardingFindTitle => 'ابحث عمّا فقدته';

  @override
  String get onboardingFindBody =>
      'ابحث في البلاغات داخل مدينتك وصفِّها حسب الفئة والتاريخ.';

  @override
  String get onboardingReportTitle => 'أبلِغ عمّا وجدته';

  @override
  String get onboardingReportBody =>
      'انشر بلاغًا بالصور والتفاصيل ليتمكن صاحبه من الوصول إليك.';

  @override
  String get onboardingChatTitle => 'تواصَل واستعِده';

  @override
  String get onboardingChatBody =>
      'راسل الطرف الآخر داخل التطبيق ورتّب لتسليم آمن.';
}
