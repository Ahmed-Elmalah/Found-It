import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/chat/data/models/chat_item_model.dart';
import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';

void main() {
  group('ChatItemModel & ChatItemEntity Tests (User Story #6)', () {
    test('fromJson parses claim_status and i_must_answer correctly', () {
      final json = {
        'match_id': 'match-123',
        'status': 'chatting',
        'other_user_name': 'Ahmed',
        'claim_status': 'pending',
        'i_must_answer': true,
      };

      final model = ChatItemModel.fromJson(json);

      expect(model.matchId, 'match-123');
      expect(model.claimStatus, 'pending');
      expect(model.iMustAnswer, true);
      expect(model.isClaimPending, true);
    });

    test('fromJson defaults claim_status to not_required and i_must_answer to false', () {
      final json = {
        'match_id': 'match-123',
        'status': 'potential',
        'other_user_name': 'Sara',
      };

      final model = ChatItemModel.fromJson(json);

      expect(model.claimStatus, 'not_required');
      expect(model.iMustAnswer, false);
      expect(model.isClaimPending, false);
    });

    test('toJson serializes claim_status and i_must_answer', () {
      const model = ChatItemModel(
        matchId: 'match-123',
        status: 'chatting',
        otherUserName: 'Omar',
        claimStatus: 'passed',
        iMustAnswer: false,
      );

      final json = model.toJson();

      expect(json['claim_status'], 'passed');
      expect(json['i_must_answer'], false);
    });

    test('copyWith updates claimStatus and iMustAnswer', () {
      const entity = ChatItemEntity(
        matchId: 'match-1',
        status: 'potential',
        otherUserName: 'Ziad',
        claimStatus: 'not_required',
        iMustAnswer: false,
      );

      final updated = entity.copyWith(
        claimStatus: 'pending',
        iMustAnswer: true,
      );

      expect(updated.claimStatus, 'pending');
      expect(updated.iMustAnswer, true);
      expect(updated.isClaimPending, true);
    });
  });
}
