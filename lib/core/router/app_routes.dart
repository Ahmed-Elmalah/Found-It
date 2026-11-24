abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signUp = '/sign-up';
  static const forgotPassword = '/forgot-password';
  static const verifyEmail = '/verify-email';
  static const city = '/city';
  static const home = '/home';
  static const explore = '/explore';
  static const messages = '/messages';
  static const createReport = '/create-report';
  static const reportCreated = '/report-created';
  static const myReports = '/my-reports';
  static const editReport = '/edit-report';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';

  // ---------------------------------------------------------------------------
  // Sprint 2 Routes
  // ---------------------------------------------------------------------------
  /// Report Details (Adham, story #1) — opens from any report card.
  static const reportDetails = '/reports/:id';
  static String reportDetailsPath(String id) => '/reports/$id';

  /// Potential Matches list (Ziad, story #2) — P28.
  static const matches = '/matches';

  /// Match Compare screen (Ziad, story #2) — P29.
  static const matchCompare = '/matches/:id';
  static String matchComparePath(String id) => '/matches/$id';

  /// Live Chat screen (Youssef, story #3) — P32.
  static const chat = '/chat/:matchId';
  static String chatPath(String matchId) => '/chat/$matchId';

  /// Handover Instructions screen (Ziad, story #4) — after ownership verified.
  static const handover = '/chat/:matchId/handover';
  static String handoverPath(String matchId) => '/chat/$matchId/handover';

  /// Notifications screen (Mohamed, story #5) — P30.
  static const notifications = '/notifications';

  /// Verify Ownership Questions (Mohamed, story #6) — /matches/:id/verify
  static const claimVerify = '/matches/:id/verify';
  static String claimVerifyPath(String id) => '/matches/$id/verify';
}
