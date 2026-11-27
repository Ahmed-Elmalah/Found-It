import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/claim/data/claim_remote_data_source.dart';
import 'package:found_it/features/claim/domain/entities/claim_answer_entity.dart';
import 'package:found_it/features/claim/domain/entities/claim_failure.dart';
import 'package:found_it/features/claim/domain/entities/claim_question_entity.dart';
import 'package:found_it/features/claim/domain/entities/claim_submission_result.dart';
import 'package:found_it/features/claim/domain/repositories/claim_repository.dart';

class ClaimRepositoryImpl implements ClaimRepository {
  const ClaimRepositoryImpl({required this.remoteDataSource});

  final ClaimRemoteDataSource remoteDataSource;

  @override
  Future<List<ClaimQuestionEntity>> getClaimQuestions(String matchId) async {
    try {
      return await remoteDataSource.getClaimQuestions(matchId);
    } catch (error) {
      throw _mapFailure(error);
    }
  }

  @override
  Future<ClaimSubmissionResult> submitClaimAnswers(
    String matchId,
    List<ClaimAnswerEntity> answers,
  ) async {
    try {
      return await remoteDataSource.submitClaimAnswers(matchId, answers);
    } catch (error) {
      throw _mapFailure(error);
    }
  }

  /// Typed mapping; the raw server message is never exposed to the UI.
  ClaimFailure _mapFailure(Object error) {
    if (error is ClaimFailure) return error;

    if (error is PostgrestException) {
      return switch (error.code) {
        'P0002' => ClaimFailure(ClaimFailureType.notFound, error.code),
        '42501' => ClaimFailure(ClaimFailureType.notAllowed, error.code),
        '55000' => ClaimFailure(ClaimFailureType.invalidState, error.code),
        '22023' => ClaimFailure(ClaimFailureType.invalidInput, error.code),
        'PGRST301' ||
        'PGRST302' => ClaimFailure(ClaimFailureType.unauthorized, error.code),
        _ => ClaimFailure(ClaimFailureType.server, error.code),
      };
    }

    if (error is AuthRetryableFetchException || error is TimeoutException) {
      return const ClaimFailure(ClaimFailureType.network);
    }

    final typeName = error.runtimeType.toString();
    if (typeName.contains('Socket') || typeName.contains('ClientException')) {
      return const ClaimFailure(ClaimFailureType.network);
    }

    return const ClaimFailure(ClaimFailureType.unknown);
  }
}
