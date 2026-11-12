abstract final class AppLimits {
  static const int passwordMinLength = 8;
  static const int fullNameMinLength = 2;

  static const int reportTitleMinLength = 3;
  static const int reportTitleMaxLength = 50;
  static const int reportMinImages = 1;
  static const int reportMaxImages = 4;

  static const int maxImageSizeMb = 10;
  static const int maxImageSizeBytes = maxImageSizeMb * 1024 * 1024;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];
}
