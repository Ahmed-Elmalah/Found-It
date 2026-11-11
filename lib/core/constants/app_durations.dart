abstract final class AppDurations {
  static const Duration splash = Duration(seconds: 2);
  static const Duration snackBar = Duration(seconds: 3);

  static const Duration searchDebounce = Duration(milliseconds: 400);

  /// Wait before "Resend email" can be tapped again (Verify email, P10).
  static const Duration resendCooldown = Duration(seconds: 45);
}
