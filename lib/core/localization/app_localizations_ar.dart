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
  String get tabHome => 'الرئيسية';

  @override
  String get tabExplore => 'استكشاف';

  @override
  String get tabReport => 'بلاغ';

  @override
  String get tabMessages => 'الرسائل';

  @override
  String get tabProfile => 'حسابي';

  @override
  String get homeSearchHint => 'ابحث عن عنصر مفقود أو تم العثور عليه';

  @override
  String get actionLost => 'فقدت شيئًا';

  @override
  String get actionFound => 'وجدت شيئًا';

  @override
  String latestInCity(String city) {
    return 'أحدث التقارير في $city';
  }

  @override
  String get seeAll => 'عرض الكل';

  @override
  String noReportsInCity(String city) {
    return 'لا توجد تقارير في $city بعد';
  }

  @override
  String get beFirstToReport =>
      'كن أول من يبلّغ عن عنصر مفقود أو تم العثور عليه في مدينتك.';

  @override
  String get createReport => 'إنشاء بلاغ';

  @override
  String get statusLost => 'مفقود';

  @override
  String get statusFound => 'تم العثور عليه';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusResolved => 'تم الحل';

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
  String get reset => 'إعادة تعيين';

  @override
  String get showResults => 'عرض النتائج';

  @override
  String get emptySearchTitle => 'لا توجد تقارير مطابقة.';

  @override
  String get emptySearchMessage => 'جرّب تعديل فلاتر البحث.';

  @override
  String get categoryElectronics => 'إلكترونيات';

  @override
  String get categoryValuables => 'أشياء ثمينة';

  @override
  String get categoryKeys => 'مفاتيح';

  @override
  String get categoryBags => 'حقائب';

  @override
  String get categoryDocuments => 'مستندات';

  @override
  String get categoryPets => 'حيوانات أليفة';
}
