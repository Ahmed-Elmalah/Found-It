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
}
