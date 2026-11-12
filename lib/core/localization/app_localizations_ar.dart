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

  @override
  String get fieldRequired => 'مطلوب';

  @override
  String get invalidEmail => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get loginTitle => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول للمتابعة.';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get signUpLink => 'إنشاء حساب';

  @override
  String get invalidCredentialsTitle => 'بيانات غير صحيحة:';

  @override
  String get invalidCredentialsMessage =>
      'تأكد من البريد الإلكتروني وكلمة المرور.';

  @override
  String get connectionErrorTitle => 'خطأ في الاتصال:';

  @override
  String get connectionErrorMessage => 'تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get genericErrorTitle => 'حدث خطأ:';

  @override
  String get genericErrorMessage => 'حاول مرة أخرى.';

  @override
  String get exploreTitle => 'استكشاف';

  @override
  String get searchHint => 'ابحث';

  @override
  String activeReportsCount(int count) {
    return '$count تقارير نشطة';
  }

  @override
  String get mostRecentFirst => 'الأحدث أولاً';

  @override
  String get filtersTitle => 'الفلاتر';

  @override
  String get categoryLabel => 'التصنيف';

  @override
  String get dateRangeLabel => 'نطاق التاريخ';

  @override
  String get cityLabel => 'المدينة';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String dateFromValue(String date) {
    return 'من $date';
  }

  @override
  String dateUntilValue(String date) {
    return 'حتى $date';
  }

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get showResults => 'عرض النتائج';

  @override
  String get emptySearchTitle => 'لا توجد تقارير مطابقة.';

  @override
  String get emptySearchMessage => 'جرّب تعديل فلاتر البحث.';

  @override
  String get typeLost => 'مفقود';

  @override
  String get typeFound => 'تم العثور عليه';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusMatching => 'قيد المطابقة';

  @override
  String get statusRecovered => 'تم استرجاعه';

  @override
  String get retry => 'حاول مرة أخرى';
}
