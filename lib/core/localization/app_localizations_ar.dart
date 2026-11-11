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
  String get statusLost => 'مفقود';

  @override
  String get statusFound => 'تم العثور عليه';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusResolved => 'تم الحل';
}
