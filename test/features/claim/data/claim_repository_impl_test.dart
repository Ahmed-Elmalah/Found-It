import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/claim/data/claim_remote_data_source.dart';
import 'package:found_it/features/claim/data/claim_repository_impl.dart';
import 'package:found_it/features/claim/data/models/claim_question_model.dart';
import 'package:found_it/features/claim/data/models/claim_submission_model.dart';
import 'package:found_it/features/claim/domain/entities/claim_answer_entity.dart';
import 'package:found_it/features/claim/domain/entities/claim_failure.dart';

class _FakeClaimRemoteDataSource implements ClaimRemoteDataSource {
  List<ClaimQuestionModel> questions = const [];
  ClaimSubmissionModel result = const ClaimSubmissionModel(
    passed: true,
    matchId: 'm1',
  );
  Object? error;
  String? lastMatchId;
  List<ClaimAnswerEntity> lastAnswers = const [];

  @override
  Future<List<ClaimQuestionModel>> getClaimQuestions(String matchId) async {
    lastMatchId = matchId;
    if (error != null) throw error!;
    return questions;
  }

  @override
  Future<ClaimSubmissionModel> submitClaimAnswers(
    String matchId,
    List<ClaimAnswerEntity> answers,
  ) async {
    lastMatchId = matchId;
    lastAnswers = answers;
    if (error != null) throw error!;
    return result;
  }
}

Matcher _failsWith(ClaimFailureType type) {
  return throwsA(
    isA<ClaimFailure>().having((failure) => failure.type, 'type', type),
  );
}

void main() {
  late _FakeClaimRemoteDataSource remote;
  late ClaimRepositoryImpl repository;

  setUp(() {
    remote = _FakeClaimRemoteDataSource();
    repository = ClaimRepositoryImpl(remoteDataSource: remote);
  });

  group('ClaimRepositoryImpl failure mapping', () {
    test('P0002 becomes notFound', () async {
      remote.error = const PostgrestException(
        message: 'match not found',
        code: 'P0002',
      );

      await expectLater(
        repository.getClaimQuestions('m1'),
        _failsWith(ClaimFailureType.notFound),
      );
    });

    test('42501 becomes notAllowed (the finder cannot answer)', () async {
      remote.error = const PostgrestException(
        message: 'you are the finder',
        code: '42501',
      );

      await expectLater(
        repository.getClaimQuestions('m1'),
        _failsWith(ClaimFailureType.notAllowed),
      );
    });

    test('55000 becomes invalidState (already answered or closed)', () async {
      remote.error = const PostgrestException(
        message: 'nothing to answer',
        code: '55000',
      );

      await expectLater(
        repository.submitClaimAnswers('m1', const []),
        _failsWith(ClaimFailureType.invalidState),
      );
    });

    test('22023 becomes invalidInput (missing/duplicate answers)', () async {
      remote.error = const PostgrestException(
        message: 'answer missing',
        code: '22023',
      );

      await expectLater(
        repository.submitClaimAnswers('m1', const []),
        _failsWith(ClaimFailureType.invalidInput),
      );
    });

    test('PGRST301 and PGRST302 become unauthorized', () async {
      remote.error = const PostgrestException(
        message: 'JWT expired',
        code: 'PGRST301',
      );

      await expectLater(
        repository.getClaimQuestions('m1'),
        _failsWith(ClaimFailureType.unauthorized),
      );

      remote.error = const PostgrestException(
        message: 'JWT invalid',
        code: 'PGRST302',
      );

      await expectLater(
        repository.submitClaimAnswers('m1', const []),
        _failsWith(ClaimFailureType.unauthorized),
      );
    });

    test('other Postgrest errors become server failures', () async {
      remote.error = const PostgrestException(
        message: 'column does not exist',
        code: '42703',
      );

      await expectLater(
        repository.getClaimQuestions('m1'),
        _failsWith(ClaimFailureType.server),
      );
    });

    test('timeouts become network failures', () async {
      remote.error = TimeoutException('slow');

      await expectLater(
        repository.getClaimQuestions('m1'),
        _failsWith(ClaimFailureType.network),
      );
    });

    test(
      'unexpected errors become unknown (raw message is not exposed)',
      () async {
        remote.error = StateError('database exploded');

        await expectLater(
          repository.getClaimQuestions('m1'),
          throwsA(
            isA<ClaimFailure>()
                .having(
                  (failure) => failure.type,
                  'type',
                  ClaimFailureType.unknown,
                )
                .having((failure) => failure.code, 'code', isNull)
                .having(
                  (failure) => failure.toString(),
                  'toString',
                  isNot(contains('exploded')),
                ),
          ),
        );
      },
    );
  });

  group('ClaimRepositoryImpl calls', () {
    test('forwards the match id and returns the questions', () async {
      remote.questions = [
        const ClaimQuestionModel(
          id: 'q1',
          position: 1,
          question: 'What color is the wallet?',
          options: ['Brown', 'Black'],
        ),
      ];

      final questions = await repository.getClaimQuestions('m1');

      expect(remote.lastMatchId, 'm1');
      expect(questions.single.id, 'q1');
      expect(questions.single.options, ['Brown', 'Black']);
    });

    test('forwards every answer and returns the submission result', () async {
      remote.result = const ClaimSubmissionModel(passed: false, matchId: 'm1');

      final result = await repository.submitClaimAnswers('m1', const [
        ClaimAnswerEntity(questionId: 'q1', choice: 1),
        ClaimAnswerEntity(questionId: 'q2', choice: 0),
      ]);

      expect(remote.lastMatchId, 'm1');
      expect(
        remote.lastAnswers.map(
          (answer) => '${answer.questionId}:${answer.choice}',
        ),
        ['q1:1', 'q2:0'],
      );
      expect(result.passed, isFalse);
    });
  });

  group('claim models', () {
    test(
      'ClaimQuestionModel parses question_id/options and tolerates nulls',
      () {
        final model = ClaimQuestionModel.fromJson(const {
          'question_id': 'q1',
          'position': 2,
          'question': 'What is written inside?',
          'options': ['A.K.', 'M.S.', 'R.T.'],
        });

        expect(model.id, 'q1');
        expect(model.position, 2);
        expect(model.options, ['A.K.', 'M.S.', 'R.T.']);

        final empty = ClaimQuestionModel.fromJson(const {});
        expect(empty.id, '');
        expect(empty.position, 0);
        expect(empty.options, isEmpty);
      },
    );

    test('ClaimSubmissionModel parses passed and match_id', () {
      final model = ClaimSubmissionModel.fromJson(const {
        'passed': true,
        'match_id': 'm1',
      });

      expect(model.passed, isTrue);
      expect(model.matchId, 'm1');

      final failed = ClaimSubmissionModel.fromJson(const {});
      expect(failed.passed, isFalse);
      expect(failed.matchId, '');
    });
  });
}
