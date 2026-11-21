import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/matches/data/matches_remote_data_source.dart';
import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/domain/entities/matches_failure.dart';
import 'package:found_it/features/matches/domain/repositories/matches_repository.dart';

class MatchesRepositoryImpl implements MatchesRepository {
  final MatchesRemoteDataSource remoteDataSource;

  const MatchesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MatchEntity>> getMyMatches({String? reportId}) async {
    try {
      return await remoteDataSource.getMyMatches(reportId: reportId);
    } catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<MatchEntity> getMatchDetails(String matchId) async {
    try {
      return await remoteDataSource.getMatchDetails(matchId);
    } catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<void> rejectMatch(String matchId) async {
    try {
      await remoteDataSource.rejectMatch(matchId);
    } catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<int> getMyMatchesCount() async {
    try {
      return await remoteDataSource.getMyMatchesCount();
    } catch (e) {
      throw _mapFailure(e);
    }
  }

  MatchesFailure _mapFailure(Object error) {
    if (error is MatchesFailure) return error;

    if (error is PostgrestException) {
      return switch (error.code) {
        'P0002' => MatchesFailure(MatchesFailureType.notFound, error.message),
        '42501' => MatchesFailure(MatchesFailureType.notAllowed, error.message),
        '55000' => MatchesFailure(MatchesFailureType.invalidState, error.message),
        _ => MatchesFailure(MatchesFailureType.unknown, error.message),
      };
    }

    if (error is AuthRetryableFetchException || error is TimeoutException) {
      return const MatchesFailure(MatchesFailureType.network);
    }

    final typeName = error.runtimeType.toString();
    if (typeName.contains('Socket') || typeName.contains('ClientException')) {
      return const MatchesFailure(MatchesFailureType.network);
    }

    return const MatchesFailure(MatchesFailureType.unknown);
  }
}
