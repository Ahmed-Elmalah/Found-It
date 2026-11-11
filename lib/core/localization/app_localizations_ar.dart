// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'FOUND IT';

  @override
  String get appTagline => 'فقدت شيئًا؟ دعنا نُعيده إليك.';

  @override
  String get chooseCityTitle => 'اختر مدينتك';

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
  String get createReport => 'إنشاء بلاغ';

  @override
  String get reportType => 'نوع البلاغ';

  @override
  String get lost => 'مفقود';

  @override
  String get found => 'عُثر عليه';

  @override
  String get itemTitle => 'اسم الغرض';

  @override
  String get itemTitleHint => 'مثال: محفظة جلدية سوداء';

  @override
  String itemTitleCounter(int count) {
    return '$count/50';
  }

  @override
  String get category => 'الفئة';

  @override
  String get selectCategory => 'اختر فئة';

  @override
  String get locationDistrict => 'الموقع (المنطقة)';

  @override
  String get selectDistrict => 'اختر المنطقة';

  @override
  String get date => 'التاريخ';

  @override
  String get photos => 'الصور';

  @override
  String photoCounter(int count) {
    return '$count/4';
  }

  @override
  String get addPhoto => 'إضافة';

  @override
  String get photoHint => 'JPG أو PNG، حجم أقل من 10 ميجا. أضف من 1 إلى 4 صور.';

  @override
  String get submitReport => 'رفع البلاغ';

  @override
  String get fieldRequired => 'مطلوب';

  @override
  String get titleTooShort => 'يجب أن يكون العنوان 3 أحرف على الأقل';

  @override
  String get titleTooLong => 'يجب أن يكون العنوان 50 حرفاً كحد أقصى';

  @override
  String get categoryRequired => 'يرجى اختيار فئة';

  @override
  String get districtRequired => 'يرجى اختيار المنطقة';

  @override
  String get photosRequired => 'يرجى إضافة صورة واحدة على الأقل';

  @override
  String get invalidFileType => 'يُسمح فقط بملفات JPG و PNG';

  @override
  String get invalidFileSize => 'يجب أن يكون حجم الملف أقل من 10 ميجا';

  @override
  String get requiredFieldsBannerTitle => 'حقول مطلوبة:';

  @override
  String get requiredFieldsBannerMessage => 'العنوان والفئة والموقع مطلوبة.';

  @override
  String get invalidFileBannerTitle => 'ملف غير صالح:';

  @override
  String get invalidFileBannerMessage =>
      'يرجى رفع صور بصيغة JPG أو PNG وحجم أقل من 10 ميجا.';

  @override
  String get photoRejected => 'مرفوض';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFromGallery => 'اختيار من المعرض';

  @override
  String get reportCreatedTitle => 'تم إنشاء البلاغ بنجاح!';

  @override
  String reportCreatedId(String id) {
    return 'رقم البلاغ: $id';
  }

  @override
  String get reportActiveMessage => 'بلاغك نشط ومُدرج للمطابقة.';

  @override
  String get viewMyReport => 'عرض بلاغي';

  @override
  String get backToHome => 'العودة للرئيسية';
}
