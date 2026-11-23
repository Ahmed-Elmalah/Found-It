import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/models/notification_type.dart';
import 'package:found_it/features/notifications/domain/entities/notification_entity.dart';

/// Title + body shown on a notification card.
///
/// The database stores the facts, not the text (Section 8), so every string is
/// built here from the current language's `.arb`.
class NotificationText {
  const NotificationText({required this.title, required this.body});

  final String title;
  final String body;
}

NotificationText notificationText(
  AppLocalizations l10n,
  NotificationEntity notification,
) {
  final reportTitle =
      notification.reportTitle ?? l10n.notificationsUntitledReport;
  final actorName = notification.actorName ?? l10n.notificationsSomeone;

  switch (notification.type) {
    case NotificationType.potentialMatch:
      final reportType = _reportTypeLabel(l10n, notification.reportType);
      return NotificationText(
        title: l10n.notificationsPotentialMatchTitle,
        body: l10n.notificationsPotentialMatchBody(
          _otherReportTypeLabel(l10n, notification.reportType),
          reportType,
          reportTitle,
        ),
      );

    case NotificationType.newMessage:
      return NotificationText(
        title: l10n.notificationsNewMessageTitle(actorName),
        body: notification.messagePreview ?? l10n.messagesPhotoLabel,
      );

    case NotificationType.ownershipVerified:
      return NotificationText(
        title: l10n.notificationsOwnershipVerifiedTitle,
        body: l10n.notificationsOwnershipVerifiedBody(actorName),
      );

    case NotificationType.matchRejected:
      return NotificationText(
        title: l10n.notificationsMatchRejectedTitle,
        body: l10n.notificationsMatchRejectedBody(actorName, reportTitle),
      );

    case NotificationType.itemRecovered:
      return NotificationText(
        title: l10n.notificationsItemRecoveredTitle,
        body: l10n.notificationsItemRecoveredBody(reportTitle),
      );

    case NotificationType.claimPassed:
      return NotificationText(
        title: l10n.notificationsClaimPassedTitle,
        body: l10n.notificationsClaimPassedBody(actorName, reportTitle),
      );

    case null:
      return NotificationText(
        title: l10n.notificationsGenericTitle,
        body: l10n.notificationsGenericBody,
      );
  }
}

/// `reports.type` is `lost` / `found`; anything else degrades to "item".
String _reportTypeLabel(AppLocalizations l10n, String? reportType) {
  switch (reportType) {
    case 'lost':
      return l10n.typeLost;
    case 'found':
      return l10n.typeFound;
    default:
      return l10n.notificationsItemLabel;
  }
}

/// The other side of the match: a found report matching a lost one.
String _otherReportTypeLabel(AppLocalizations l10n, String? reportType) {
  switch (reportType) {
    case 'lost':
      return l10n.typeFound;
    case 'found':
      return l10n.typeLost;
    default:
      return l10n.notificationsItemLabel;
  }
}
