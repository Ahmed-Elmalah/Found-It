import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/features/claim/domain/entities/claim_answer_entity.dart';
import 'package:found_it/features/claim/domain/entities/claim_failure.dart';
import 'package:found_it/features/claim/domain/entities/claim_question_entity.dart';
import 'package:found_it/features/claim/domain/entities/claim_submission_result.dart';
import 'package:found_it/features/claim/domain/repositories/claim_repository.dart';
import 'package:found_it/features/claim/domain/use_cases/get_claim_questions_use_case.dart';
import 'package:found_it/features/claim/domain/use_cases/submit_claim_answers_use_case.dart';
import 'package:found_it/features/claim/view/cubit/claim_cubit.dart';
import 'package:found_it/features/claim/view/cubit/claim_state.dart';
import 'package:found_it/features/claim/view/ui/verify_ownership_screen.dart';

import '../../../../helpers/test_app.dart';

class _FakeClaimRepository implements ClaimRepository {
  List<ClaimQuestionEntity> questions = const [];
  ClaimSubmissionResult result = const ClaimSubmissionResult(
    passed: true,
    matchId: 'm1',
  );

  Object? loadError;
  Object? submitError;
  Completer<List<ClaimQuestionEntity>>? loadGate;

  int loadCalls = 0;
  int submitCalls = 0;

  @override
  Future<List<ClaimQuestionEntity>> getClaimQuestions(String matchId) async {
    loadCalls++;
    final gate = loadGate;
    if (gate != null) return gate.future;
    if (loadError != null) throw loadError!;
    return questions;
  }

  @override
  Future<ClaimSubmissionResult> submitClaimAnswers(
    String matchId,
    List<ClaimAnswerEntity> answers,
  ) async {
    submitCalls++;
    if (submitError != null) throw submitError!;
    return result;
  }
}

List<ClaimQuestionEntity> _questions() => const [
  ClaimQuestionEntity(
    id: 'q1',
    position: 1,
    question: 'What color is the wallet?',
    options: ['Brown', 'Black', 'Blue'],
  ),
  ClaimQuestionEntity(
    id: 'q2',
    position: 2,
    question: 'What is written inside?',
    options: ['A.K.', 'M.S.', 'R.T.'],
  ),
];

class _Harness {
  _Harness({Object? loadError}) : repository = _FakeClaimRepository() {
    repository.questions = _questions();
    repository.loadError = loadError;
    cubit = ClaimCubit(
      getClaimQuestions: GetClaimQuestionsUseCase(repository),
      submitClaimAnswers: SubmitClaimAnswersUseCase(repository),
    );
  }

  final _FakeClaimRepository repository;
  late final ClaimCubit cubit;

  Future<void> load() => cubit.loadQuestions('m1');

  Future<void> dispose() => cubit.close();
}

void main() {
  GoRouter buildRouter(ClaimCubit cubit, {String matchId = 'm1'}) {
    return GoRouter(
      initialLocation: AppRoutes.claimVerifyPath(matchId),
      routes: [
        GoRoute(
          path: AppRoutes.claimVerify,
          builder: (context, state) => BlocProvider<ClaimCubit>.value(
            value: cubit,
            child: VerifyOwnershipScreen(
              matchId: state.pathParameters['id'] ?? '',
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.matches,
          builder: (context, state) =>
              const Scaffold(body: Text('MATCHES PAGE')),
        ),
        GoRoute(
          path: AppRoutes.chat,
          builder: (context, state) =>
              Scaffold(body: Text('CHAT ${state.pathParameters['matchId']}')),
        ),
      ],
    );
  }

  Future<void> pumpScreen(
    WidgetTester tester,
    ClaimCubit cubit, {
    bool dark = false,
    bool rtl = false,
    bool settle = true,
  }) async {
    await pumpTestRouterApp(tester, buildRouter(cubit), dark: dark, rtl: rtl);
    if (settle) await tester.pumpAndSettle();
  }

  Future<void> answerAll(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('claim_option_q1_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('claim_option_q2_0')));
    await tester.pumpAndSettle();
  }

  Future<void> confirmSubmit(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('claim_submit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('claim_confirm_dialog')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('claim_confirm_submit')));
    await tester.pumpAndSettle();
  }

  AppButton submitButton(WidgetTester tester) =>
      tester.widget<AppButton>(find.byKey(const ValueKey('claim_submit')));

  testWidgets('shows a loading state while the questions are fetched', (
    tester,
  ) async {
    final harness = _Harness();
    addTearDown(harness.dispose);
    harness.repository.loadGate = Completer<List<ClaimQuestionEntity>>();

    await pumpScreen(tester, harness.cubit, settle: false);
    await tester.pump();

    expect(find.byKey(const ValueKey('claim_loading')), findsOneWidget);

    harness.repository.loadGate!.complete(_questions());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('claim_loading')), findsNothing);
    expect(find.text('What color is the wallet?'), findsOneWidget);
  });

  testWidgets(
    'renders the questions and keeps Submit disabled until complete',
    (tester) async {
      final harness = _Harness();
      addTearDown(harness.dispose);
      await harness.load();

      await pumpScreen(tester, harness.cubit);

      expect(find.text('Verify Ownership'), findsOneWidget);
      expect(
        find.textContaining("Answer the finder's questions"),
        findsOneWidget,
      );
      expect(find.text('Question 1'), findsOneWidget);
      expect(find.text('Question 2'), findsOneWidget);
      expect(find.text('What color is the wallet?'), findsOneWidget);
      expect(find.text('What is written inside?'), findsOneWidget);
      expect(find.text('Black'), findsOneWidget);
      expect(find.text('A.K.'), findsOneWidget);
      expect(find.text('Answer every question to continue.'), findsOneWidget);
      expect(submitButton(tester).onPressed, isNull);

      await tester.tap(find.byKey(const ValueKey('claim_option_q1_1')));
      await tester.pumpAndSettle();

      expect(harness.cubit.state.choiceFor('q1'), 1);
      expect(submitButton(tester).onPressed, isNull);

      await tester.tap(find.byKey(const ValueKey('claim_option_q2_0')));
      await tester.pumpAndSettle();

      expect(harness.cubit.state.choiceFor('q2'), 0);
      expect(submitButton(tester).onPressed, isNotNull);
      expect(find.text('Answer every question to continue.'), findsNothing);
    },
  );

  testWidgets('renders in dark theme', (tester) async {
    final harness = _Harness();
    addTearDown(harness.dispose);
    await harness.load();

    await pumpScreen(tester, harness.cubit, dark: true);

    final context = tester.element(find.byType(VerifyOwnershipScreen));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.text('What color is the wallet?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in Arabic RTL with translated strings', (tester) async {
    final harness = _Harness();
    addTearDown(harness.dispose);
    await harness.load();

    await pumpScreen(tester, harness.cubit, rtl: true);

    final context = tester.element(find.byType(VerifyOwnershipScreen));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(find.text('إثبات الملكية'), findsOneWidget);
    expect(find.text('إرسال الإجابات'), findsOneWidget);
    expect(find.text('What color is the wallet?'), findsOneWidget);
  });

  testWidgets('shows the load error and retries successfully', (tester) async {
    final harness = _Harness(
      loadError: const ClaimFailure(ClaimFailureType.network),
    );
    addTearDown(harness.dispose);
    await harness.load();

    await pumpScreen(tester, harness.cubit);

    expect(find.byKey(const ValueKey('claim_load_error')), findsOneWidget);
    expect(find.text("Couldn't load the questions"), findsOneWidget);
    expect(harness.cubit.state.status, ClaimStatus.loadFailure);

    harness.repository.loadError = null;
    await tester.tap(find.byKey(const ValueKey('claim_retry')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('claim_load_error')), findsNothing);
    expect(find.text('What color is the wallet?'), findsOneWidget);
    expect(harness.repository.loadCalls, 2);
  });

  testWidgets('the confirmation dialog can be cancelled without submitting', (
    tester,
  ) async {
    final harness = _Harness();
    addTearDown(harness.dispose);
    await harness.load();

    await pumpScreen(tester, harness.cubit);
    await answerAll(tester);

    await tester.tap(find.byKey(const ValueKey('claim_submit')));
    await tester.pumpAndSettle();

    expect(find.text('You only have one chance'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('claim_confirm_cancel')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('claim_confirm_dialog')), findsNothing);
    expect(harness.repository.submitCalls, 0);
    expect(harness.cubit.state.status, ClaimStatus.ready);
    expect(harness.cubit.state.choices.length, 2);
  });

  testWidgets('a correct submission opens the chat', (tester) async {
    final harness = _Harness();
    addTearDown(harness.dispose);
    await harness.load();

    await pumpScreen(tester, harness.cubit);
    await answerAll(tester);
    await confirmSubmit(tester);

    expect(harness.repository.submitCalls, 1);
    expect(find.text('CHAT m1'), findsOneWidget);
    expect(find.byType(VerifyOwnershipScreen), findsNothing);
  });

  testWidgets('a wrong submission shows the blocked screen and goes back', (
    tester,
  ) async {
    final harness = _Harness();
    addTearDown(harness.dispose);
    await harness.load();
    harness.repository.result = const ClaimSubmissionResult(
      passed: false,
      matchId: 'm1',
    );

    await pumpScreen(tester, harness.cubit);
    await answerAll(tester);
    await confirmSubmit(tester);

    expect(find.byKey(const ValueKey('claim_failed')), findsOneWidget);
    expect(find.text("You can't claim this item"), findsOneWidget);
    expect(
      find.textContaining("you can no longer claim this report"),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('claim_submit')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('claim_back_to_matches')));
    await tester.pumpAndSettle();

    expect(find.text('MATCHES PAGE'), findsOneWidget);
  });

  testWidgets('a transient submit error keeps the choices and can be retried', (
    tester,
  ) async {
    final harness = _Harness();
    addTearDown(harness.dispose);
    await harness.load();
    harness.repository.submitError = const ClaimFailure(
      ClaimFailureType.network,
    );

    await pumpScreen(tester, harness.cubit);
    await answerAll(tester);
    await confirmSubmit(tester);

    expect(find.byKey(const ValueKey('claim_submit_error')), findsOneWidget);
    expect(harness.cubit.state.status, ClaimStatus.submitFailure);
    expect(harness.cubit.state.choices, {'q1': 1, 'q2': 0});
    expect(submitButton(tester).onPressed, isNotNull);

    harness.repository.submitError = null;
    await confirmSubmit(tester);

    expect(harness.repository.submitCalls, 2);
    expect(find.text('CHAT m1'), findsOneWidget);
  });
}
