import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/recovery/data/recovery_remote_data_source.dart';
import 'package:found_it/features/recovery/domain/entities/handover_contact_entity.dart';
import 'package:found_it/features/recovery/domain/entities/recovery_failure.dart';
import 'package:found_it/features/recovery/domain/repositories/recovery_repository.dart';

class RecoveryRepositoryImpl implements RecoveryRepository {
  final RecoveryRemoteDataSource remoteDataSource;

  const RecoveryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<HandoverContactEntity> getMatchContact(String matchId) async {
    try {
      return await remoteDataSource.getMatchContact(matchId);
    } catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<void> markItemRecovered(String matchId) async {
    try {
      await remoteDataSource.markItemRecovered(matchId);
    } catch (e) {
      throw _mapFailure(e);
    }
  }

  RecoveryFailure _mapFailure(Object error) {
    if (error is RecoveryFailure) return error;

    if (error is PostgrestException) {
      return switch (error.code) {
        'P0002' => RecoveryFailure(RecoveryFailureType.notFound, error.message),
        '42501' => RecoveryFailure(RecoveryFailureType.notAllowed, error.message),
        '55000' => RecoveryFailure(RecoveryFailureType.notVerified, error.message),
        _ => RecoveryFailure(RecoveryFailureType.unknown, error.message),
      };
    }

    if (error is AuthRetryableFetchException || error is TimeoutException) {
      return const RecoveryFailure(RecoveryFailureType.network);
    }

    final typeName = error.runtimeType.toString();
    if (typeName.contains('Socket') || typeName.contains('ClientException')) {
      return const RecoveryFailure(RecoveryFailureType.network);
    }

    return const RecoveryFailure(RecoveryFailureType.unknown);
  }
}
