import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/matches/data/models/match_model.dart';

void main() {
  group('MatchModel', () {
    test('parses Story #6 claim verification fields from JSON', () {
      final model = MatchModel.fromJson({
        'match_id': 'match-1',
        'status': 'potential',
        'similarity': 86,
        'source': 'auto',
        'ownership_verified': false,
        'i_am_finder': false,
        'created_at': '2026-11-20T10:12:00Z',
        'other_user_name': 'Mona K.',
        'claim_status': 'pending',
        'i_must_answer': true,
        'questions_count': 2,
      });

      expect(model.matchId, 'match-1');
      expect(model.claimStatus, 'pending');
      expect(model.iMustAnswer, isTrue);
      expect(model.questionsCount, 2);
      expect(model.isClaimPending, isTrue);
    });

    test('defaults Story #6 fields when omitted from JSON', () {
      final model = MatchModel.fromJson({
        'match_id': 'match-2',
        'status': 'potential',
        'similarity': 90,
        'source': 'auto',
        'ownership_verified': false,
        'i_am_finder': true,
        'created_at': '2026-11-20T10:12:00Z',
        'other_user_name': 'Omar S.',
      });

      expect(model.claimStatus, 'not_required');
      expect(model.iMustAnswer, isFalse);
      expect(model.questionsCount, 0);
      expect(model.isClaimPending, isFalse);
    });
  });
}
