import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/services/notification_payload.dart';

void main() {
  group('NotificationType.fromRaw', () {
    test('parses every type from Section 8', () {
      expect(
        NotificationType.fromRaw('potential_match'),
        NotificationType.potentialMatch,
      );
      expect(
        NotificationType.fromRaw('new_message'),
        NotificationType.newMessage,
      );
      expect(
        NotificationType.fromRaw('ownership_verified'),
        NotificationType.ownershipVerified,
      );
      expect(
        NotificationType.fromRaw('match_rejected'),
        NotificationType.matchRejected,
      );
      expect(
        NotificationType.fromRaw('item_recovered'),
        NotificationType.itemRecovered,
      );
      expect(
        NotificationType.fromRaw('claim_passed'),
        NotificationType.claimPassed,
      );
    });

    test('accepts the short aliases match / message / recovered', () {
      expect(
        NotificationType.fromRaw('match'),
        NotificationType.potentialMatch,
      );
      expect(NotificationType.fromRaw('message'), NotificationType.newMessage);
      expect(
        NotificationType.fromRaw('recovered'),
        NotificationType.itemRecovered,
      );
    });

    test('is case-insensitive and trims whitespace', () {
      expect(
        NotificationType.fromRaw(' Potential_Match '),
        NotificationType.potentialMatch,
      );
    });

    test('returns null for unknown or missing types', () {
      expect(NotificationType.fromRaw('something_else'), isNull);
      expect(NotificationType.fromRaw(''), isNull);
      expect(NotificationType.fromRaw(null), isNull);
    });
  });

  group('NotificationPayload parsing', () {
    test('reads every id from the data map', () {
      final payload = NotificationPayload.fromData({
        'type': 'potential_match',
        'notification_id': 'n-1',
        'match_id': 'm-1',
        'report_id': 'r-1',
      });

      expect(payload.type, NotificationType.potentialMatch);
      expect(payload.notificationId, 'n-1');
      expect(payload.matchId, 'm-1');
      expect(payload.reportId, 'r-1');
    });

    test('trims ids and treats blank ids as missing', () {
      final payload = NotificationPayload.fromData({
        'type': 'new_message',
        'notification_id': '  n-1  ',
        'match_id': '   ',
      });

      expect(payload.notificationId, 'n-1');
      expect(payload.matchId, isNull);
      expect(payload.reportId, isNull);
    });

    test('fromData throws on a missing or unknown type', () {
      expect(
        () => NotificationPayload.fromData(const {}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => NotificationPayload.fromData(const {'type': 'nope'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('tryParse returns null instead of throwing', () {
      expect(NotificationPayload.tryParse(null), isNull);
      expect(NotificationPayload.tryParse(const {}), isNull);
      expect(NotificationPayload.tryParse(const {'type': 'nope'}), isNull);
    });

    test('toData / toJsonString round-trip through tryParseJson', () {
      const original = NotificationPayload(
        type: NotificationType.matchRejected,
        notificationId: 'n-1',
        matchId: 'm-1',
      );

      final restored = NotificationPayload.tryParseJson(
        original.toJsonString(),
      );

      expect(restored, isNotNull);
      expect(restored!.type, NotificationType.matchRejected);
      expect(restored.notificationId, 'n-1');
      expect(restored.matchId, 'm-1');
      expect(restored.reportId, isNull);
    });

    test('tryParseJson ignores invalid or non-object JSON', () {
      expect(NotificationPayload.tryParseJson(null), isNull);
      expect(NotificationPayload.tryParseJson(''), isNull);
      expect(NotificationPayload.tryParseJson('not json'), isNull);
      expect(NotificationPayload.tryParseJson(jsonEncode([1, 2])), isNull);
      expect(
        NotificationPayload.tryParseJson(jsonEncode({'type': 'nope'})),
        isNull,
      );
    });
  });

  group('NotificationPayload.route (deep links)', () {
    test('potential_match opens the match compare screen', () {
      const payload = NotificationPayload(
        type: NotificationType.potentialMatch,
        matchId: 'match-456',
      );

      expect(payload.route, '/matches/match-456');
      expect(payload.route, AppRoutes.matchComparePath('match-456'));
    });

    test('new_message opens the chat', () {
      const payload = NotificationPayload(
        type: NotificationType.newMessage,
        matchId: 'match-456',
      );

      expect(payload.route, '/chat/match-456');
      expect(payload.route, AppRoutes.chatPath('match-456'));
    });

    test(
      'ownership_verified / match_rejected / claim_passed open the chat',
      () {
        const types = [
          NotificationType.ownershipVerified,
          NotificationType.matchRejected,
          NotificationType.claimPassed,
        ];

        for (final type in types) {
          final payload = NotificationPayload(type: type, matchId: 'm-9');
          expect(payload.route, AppRoutes.chatPath('m-9'), reason: '$type');
        }
      },
    );

    test('item_recovered opens the report details', () {
      const payload = NotificationPayload(
        type: NotificationType.itemRecovered,
        reportId: 'rep-123',
      );

      expect(payload.route, '/reports/rep-123');
      expect(payload.route, AppRoutes.reportDetailsPath('rep-123'));
    });

    test('returns null when the id required by the type is missing', () {
      const noMatch = NotificationPayload(type: NotificationType.newMessage);
      const noReport = NotificationPayload(
        type: NotificationType.itemRecovered,
        matchId: 'm-1',
      );

      expect(noMatch.route, isNull);
      expect(noReport.route, isNull);
    });
  });
}
