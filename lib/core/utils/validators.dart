import 'package:found_it/core/constants/app_limits.dart';

/// Pure checks for form fields. They return true / false only: the screen
/// picks the (translated) error message, see README "Validation".
///
///   validator: (v) => !Validators.isNotEmpty(v)
///       ? l10n.fieldRequired
///       : !Validators.isValidEmail(v) ? l10n.invalidEmail : null,
abstract final class Validators {
  // something@something.tld — no spaces, one @, a dot in the domain part.
  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  /// Not null and not only spaces.
  static bool isNotEmpty(String? value) =>
      value != null && value.trim().isNotEmpty;

  /// A reasonable email format (spaces around it are ignored).
  static bool isValidEmail(String? value) =>
      value != null && _email.hasMatch(value.trim());

  /// At least [AppLimits.passwordMinLength] characters (used on sign up).
  static bool isValidPassword(String? value) =>
      value != null && value.length >= AppLimits.passwordMinLength;

  /// At least [AppLimits.fullNameMinLength] characters (spaces ignored).
  static bool isValidFullName(String? value) =>
      value != null && value.trim().length >= AppLimits.fullNameMinLength;

  // Egyptian mobile after the country code: 10, 11, 12 or 15 + 8 digits.
  static final RegExp _egyptMobile = RegExp(r'^1[0125]\d{8}$');

  /// Egyptian mobile number typed in the field after the fixed "+20":
  /// "10 1234 5678", "01012345678", "+201012345678" are all valid.
  static bool isValidEgyptianPhone(String? value) =>
      normalizeEgyptianPhone(value) != null;

  /// The number in one fixed format, `+201012345678`, or null if invalid.
  /// This is the value saved in the database.
  static String? normalizeEgyptianPhone(String? value) {
    if (value == null) return null;
    var digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('20')) {
      digits = digits.substring(2);
    } else if (digits.length == 11 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return _egyptMobile.hasMatch(digits) ? '+20$digits' : null;
  }
}
