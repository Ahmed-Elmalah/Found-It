import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/claim/domain/entities/claim_answer_entity.dart';
import 'package:found_it/features/claim/domain/entities/claim_failure.dart';
import 'package:found_it/features/claim/domain/entities/claim_question_entity.dart';
import 'package:found_it/features/claim/domain/entities/claim_submission_result.dart';
import 'package:found_it/features/claim/domain/repositories/claim_repository.dart';
import 'package:found_it/features/claim/domain/use_cases/get_claim_questions_use_case.dart';
import 'package:found_it/features/claim/domain/use_cases/submit_claim_answers_use_case.dart';
import 'package:found_it/features/claim/view/cubit/claim_cubit.dart';
import 'package:found_it/features/claim/view/cubit/claim_state.dart';

class _FakeClaimRepository implements ClaimRepository {
  List<ClaimQuestionEntity> questions = const [];
  ClaimSubmissionResult result = const ClaimSubmissionResult(
    passed: true,
    matchId: 'm1',
  );

  Object? loadError;
  Object? submitError;
  Completer<ClaimSubmissionResult>? submitGate;

  int loadCalls = 0;
  int submitCalls = 0;
  String? lastMatchId;
  List<ClaimAnswerEntity> lastAnswers = const [];

  @override
  Future<List<ClaimQuestionEntity>> getClaimQuestions(String matchId) async {
    loadCalls++;
    lastMatchId = matchId;
    if (loadError != null) throw loadError!;
    return questions;
  }

  @override
  Future<ClaimSubmissionResult> submitClaimAnswers(
    String matchId,
    List<ClaimAnswerEntity> answers,
  ) async {
    submitCalls++;
    lastMatchId = matchId;
    lastAnswers = answers;

    final gate = submitGate;
    if (gate != null) return gate.future;

    if (submitError != null) throw submitError!;
    return result;
  }
}

ClaimQuestionEntity _question({
  required String id,
  int position = 1,
  List<String> options = const ['Brown', 'Black', 'Blue'],
}) {
  return ClaimQuestionEntity(
    id: id,
    position: position,
    question: 'Question $id',
    options: options,
  );
}

void main() {
  late _FakeClaimRepository repository;
  late ClaimCubit cubit;

  setUp(() {
    repository = _FakeClaimRepository();
    cubit = ClaimCubit(
      getClaimQuestions: GetClaimQuestionsUseCase(repository),
      submitClaimAnswers: SubmitClaimAnswersUseCase(repository),
    );
  });

  tearDown(() => cubit.close());

  Future<void> loadTwoQuestions() async {
    repository.questions = [
      _question(id: 'q1', position: 1),
      _question(id: 'q2', position: 2),
    ];
    await cubit.loadQuestions('m1');
  }

  void answerAll() {
    cubit.selectAnswer('q1', 1);
    cubit.selectAnswer('q2', 0);
  }

  test('starts with an empty initial state', () {
    expect(cubit.state.status, ClaimStatus.initial);
    expect(cubit.state.questions, isEmpty);
    expect(cubit.state.allAnswered, isFalse);
    expect(cubit.state.canSubmit, isFalse);
  });

  group('loadQuestions', () {
    test('emits loading then ready, ordered by position', () async {
      repository.questions = [
        _question(id: 'q2', position: 2),
        _question(id: 'q1', position: 1),
      ];

      final statuses = cubit.stream
          .map((state) => state.status)
          .take(2)
          .toList();

      await cubit.loadQuestions('m1');

      expect(await statuses, [ClaimStatus.loading, ClaimStatus.ready]);
      expect(cubit.state.matchId, 'm1');
      expect(cubit.state.questions.map((q) => q.id), ['q1', 'q2']);
      expect(cubit.state.choices, isEmpty);
      expect(repository.loadCalls, 1);
    });

    test('maps a load failure to loadFailure', () async {
      repository.loadError = const ClaimFailure(ClaimFailureType.network);

      await cubit.loadQuestions('m1');

      expect(cubit.state.status, ClaimStatus.loadFailure);
      expect(cubit.state.failure?.type, ClaimFailureType.network);
    });

    test('wraps unexpected errors without leaking them', () async {
      repository.loadError = StateError('raw database error');

      await cubit.loadQuestions('m1');

      expect(cubit.state.status, ClaimStatus.loadFailure);
      expect(cubit.state.failure?.type, ClaimFailureType.unknown);
    });

    test('reloading starts a clean selection', () async {
      await loadTwoQuestions();
      answerAll();
      expect(cubit.state.allAnswered, isTrue);

      await cubit.loadQuestions('m1');

      expect(cubit.state.choices, isEmpty);
      expect(cubit.state.allAnswered, isFalse);
    });
  });

  group('selectAnswer', () {
    test('tracks one choice per question and completes allAnswered', () async {
      await loadTwoQuestions();

      cubit.selectAnswer('q1', 2);

      expect(cubit.state.choiceFor('q1'), 2);
      expect(cubit.state.answeredCount, 1);
      expect(cubit.state.allAnswered, isFalse);
      expect(cubit.state.canSubmit, isFalse);

      cubit.selectAnswer('q2', 0);

      expect(cubit.state.answeredCount, 2);
      expect(cubit.state.allAnswered, isTrue);
      expect(cubit.state.canSubmit, isTrue);
    });

    test('changing a choice keeps a single value per question', () async {
      await loadTwoQuestions();

      cubit.selectAnswer('q1', 0);
      cubit.selectAnswer('q1', 2);

      expect(cubit.state.choiceFor('q1'), 2);
      expect(cubit.state.choices.length, 1);
    });

    test('ignores unknown ids and out-of-range choices', () async {
      await loadTwoQuestions();

      cubit.selectAnswer('missing', 0);
      cubit.selectAnswer('q1', -1);
      cubit.selectAnswer('q1', 99);

      expect(cubit.state.choices, isEmpty);
    });
  });

  group('submitAnswers', () {
    test('does nothing until every question is answered', () async {
      await loadTwoQuestions();
      cubit.selectAnswer('q1', 1);

      await cubit.submitAnswers();

      expect(repository.submitCalls, 0);
      expect(cubit.state.status, ClaimStatus.ready);
    });

    test(
      'passes: sends every answer in order and exposes the chat match',
      () async {
        await loadTwoQuestions();
        answerAll();
        repository.result = const ClaimSubmissionResult(
          passed: true,
          matchId: 'm1',
        );

        final statuses = cubit.stream
            .map((state) => state.status)
            .take(2)
            .toList();

        await cubit.submitAnswers();

        expect(await statuses, [ClaimStatus.submitting, ClaimStatus.passed]);
        expect(cubit.state.passedMatchId, 'm1');
        expect(repository.lastMatchId, 'm1');
        expect(
          repository.lastAnswers.map((a) => '${a.questionId}:${a.choice}'),
          ['q1:1', 'q2:0'],
        );
      },
    );

    test('falls back to the loaded match id when the RPC omits it', () async {
      await loadTwoQuestions();
      answerAll();
      repository.result = const ClaimSubmissionResult(
        passed: true,
        matchId: '',
      );

      await cubit.submitAnswers();

      expect(cubit.state.status, ClaimStatus.passed);
      expect(cubit.state.passedMatchId, 'm1');
    });

    test('failed: surfaces the blocked state and never says why', () async {
      await loadTwoQuestions();
      answerAll();
      repository.result = const ClaimSubmissionResult(
        passed: false,
        matchId: 'm1',
      );

      await cubit.submitAnswers();

      expect(cubit.state.status, ClaimStatus.failed);
      expect(cubit.state.passedMatchId, isNull);
    });

    test('transient failure keeps the choices and can be retried', () async {
      await loadTwoQuestions();
      answerAll();
      repository.submitError = const ClaimFailure(ClaimFailureType.network);

      await cubit.submitAnswers();

      expect(cubit.state.status, ClaimStatus.submitFailure);
      expect(cubit.state.failure?.type, ClaimFailureType.network);
      expect(cubit.state.choices, {'q1': 1, 'q2': 0});
      expect(cubit.state.canSubmit, isTrue);

      repository.submitError = null;
      await cubit.submitAnswers();

      expect(repository.submitCalls, 2);
      expect(cubit.state.status, ClaimStatus.passed);
    });

    test('does not double-submit while a request is in flight', () async {
      await loadTwoQuestions();
      answerAll();
      repository.submitGate = Completer<ClaimSubmissionResult>();

      final first = cubit.submitAnswers();
      await cubit.submitAnswers();

      expect(repository.submitCalls, 1);

      repository.submitGate!.complete(
        const ClaimSubmissionResult(passed: true, matchId: 'm1'),
      );
      await first;

      expect(cubit.state.status, ClaimStatus.passed);
    });
  });
}
