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
  String get signUpTitle => 'إنشاء حساب';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get fullNameHint => 'اسمك الكامل';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get phoneHint => '10 1234 5678';

  @override
  String get addressLabel => 'العنوان';

  @override
  String get addressHint => 'اختياري';

  @override
  String get passwordHelper => '8 أحرف على الأقل';

  @override
  String get createAccountButton => 'إنشاء حساب';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟';

  @override
  String get logInLink => 'تسجيل الدخول';

  @override
  String get nameTooShort => 'يجب أن يكون الاسم حرفين على الأقل';

  @override
  String get invalidPhone => 'أدخل رقم موبايل مصري صحيح';

  @override
  String get passwordTooShort => 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get registrationFailedTitle => 'فشل التسجيل:';

  @override
  String get emailInUseMessage =>
      'يوجد حساب مسجّل بهذا البريد الإلكتروني بالفعل.';

  @override
  String get weakPasswordTitle => 'كلمة مرور ضعيفة:';

  @override
  String get weakPasswordMessage => 'اختر كلمة مرور أقوى.';

  @override
  String get myReportsTitle => 'بلاغاتي';

  @override
  String get tabAll => 'الكل';

  @override
  String get tabActive => 'نشط';

  @override
  String get tabMatching => 'مطابق';

  @override
  String get tabRecovered => 'مسترد';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusMatching => 'مطابق';

  @override
  String get statusRecovered => 'مسترد';

  @override
  String get typeLost => 'مفقود';

  @override
  String get typeFound => 'معثور عليه';

  @override
  String get noReportsTitle => 'لا توجد بلاغات بعد';

  @override
  String get noReportsSubtitle => 'البلاغات التي تنشرها ستظهر هنا.';

  @override
  String get createReport => 'إنشاء بلاغ';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get reportDeletedSuccess => 'تم حذف البلاغ بنجاح';

  @override
  String get reportUpdatedSuccess => 'تم تحديث البلاغ بنجاح';

  @override
  String get deleteReportDialogTitle => 'حذف البلاغ؟';

  @override
  String get deleteReportDialogMessage =>
      'هل أنت متأكد من حذف هذا البلاغ؟ لن يظهر هذا البلاغ في البحث بعد الآن.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirmDelete => 'حذف';

  @override
  String get editReportTitle => 'تعديل البلاغ';

  @override
  String get reportTitleLabel => 'عنوان البلاغ';

  @override
  String get reportTitleHint => 'مثال: محفظة جلد سوداء';

  @override
  String get reportTypeLabel => 'نوع البلاغ';

  @override
  String get categoryLabel => 'الفئة';

  @override
  String get selectCategory => 'اختر الفئة';

  @override
  String get areaLabel => 'المنطقة / الحي';

  @override
  String get selectArea => 'اختر المنطقة';

  @override
  String get itemDateLabel => 'التاريخ';

  @override
  String get descriptionLabel => 'الوصف';

  @override
  String get descriptionHint => 'أضف تفاصيل تساعد في التعرف على الشيء...';

  @override
  String get saveChanges => 'حفظ التعديلات';

  @override
  String get saving => 'جاري الحفظ...';

  @override
  String get titleTooShort => 'يجب أن يكون العنوان 3 أحرف على الأقل';

  @override
  String get titleTooLong => 'يجب أن يكون العنوان 50 حرفاً كحد أقصى';

  @override
  String get profileTitle => 'الملف الشخصي والإعدادات';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get saveProfile => 'حفظ البيانات';

  @override
  String get accountSection => 'الحساب';

  @override
  String get preferencesSection => 'التفضيلات';

  @override
  String get cityLabel => 'المدينة';

  @override
  String get selectCity => 'اختر المدينة';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get themeLabel => 'المظهر';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'تلقائي (حسب النظام)';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSystem => 'تلقائي (حسب النظام)';

  @override
  String get logoutButton => 'تسجيل الخروج';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get logoutConfirmMessage => 'هل أنت متأكد من رغبتك في تسجيل الخروج؟';

  @override
  String get profileUpdatedSuccess => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get cityUpdatedSuccess => 'تم تغيير المدينة بنجاح';

  @override
  String get appVersion => 'الإصدار 1.0.0';

  @override
  String get viewMyReports => 'بلاغاتي';

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

  @override
  String get notLoggedInTitle => 'تسجيل الدخول مطلوب:';

  @override
  String get notLoggedInMessage => 'يجب تسجيل الدخول لإنشاء بلاغ.';

  @override
  String get invalidDataTitle => 'بيانات غير صالحة:';

  @override
  String get invalidDataMessage => 'يرجى التحقق من صحة تفاصيل البلاغ المدخلة.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيينها.';

  @override
  String get sendResetLinkButton => 'إرسال رابط إعادة التعيين';

  @override
  String get rememberedIt => 'تذكرتها؟';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get resetComingSoon => 'ستتوفر إعادة تعيين كلمة المرور قريبًا.';

  @override
  String get verifyEmailTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String verifyEmailBody(String email) {
    return 'أرسلنا رابط التحقق إلى $email. افتحه لتفعيل حسابك.';
  }

  @override
  String get verifiedButton => 'لقد فعّلت بريدي';

  @override
  String get resendEmail => 'إعادة الإرسال';

  @override
  String resendEmailIn(String time) {
    return 'إعادة الإرسال · $time';
  }

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
  String get dateRangeLabel => 'نطاق التاريخ';

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
}
