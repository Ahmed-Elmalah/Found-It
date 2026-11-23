/// Notification types stored in `notifications.type` and sent in the push
/// `data.type` field.
///
/// Source of truth: `docs/api_sprint2.md` Section 8.
enum NotificationType {
  potentialMatch('potential_match'),
  newMessage('new_message'),
  ownershipVerified('ownership_verified'),
  matchRejected('match_rejected'),
  itemRecovered('item_recovered'),
  claimPassed('claim_passed');

  const NotificationType(this.raw);

  /// The value used by the backend / Edge Function.
  final String raw;

  /// Maps a raw `type` to a [NotificationType], or null when unknown.
  ///
  /// The short aliases (`match`, `message`, `recovered`) are accepted too so a
  /// typo on the backend side degrades gracefully instead of dropping the tap.
  static NotificationType? fromRaw(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'potential_match':
      case 'match':
        return NotificationType.potentialMatch;
      case 'new_message':
      case 'message':
        return NotificationType.newMessage;
      case 'ownership_verified':
        return NotificationType.ownershipVerified;
      case 'match_rejected':
        return NotificationType.matchRejected;
      case 'item_recovered':
      case 'recovered':
        return NotificationType.itemRecovered;
      case 'claim_passed':
        return NotificationType.claimPassed;
      default:
        return null;
    }
  }
}
