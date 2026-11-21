import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/matches/data/models/match_model.dart';

abstract class MatchesRemoteDataSource {
  Future<List<MatchModel>> getMyMatches({String? reportId});
  Future<MatchModel> getMatchDetails(String matchId);
  Future<void> rejectMatch(String matchId);
  Future<int> getMyMatchesCount();
}

class MatchesRemoteDataSourceImpl implements MatchesRemoteDataSource {
  final SupabaseClient _supabase;

  const MatchesRemoteDataSourceImpl(this._supabase);

  @override
  Future<List<MatchModel>> getMyMatches({String? reportId}) async {
    final res = await _supabase.rpc(
      'get_my_matches',
      params: {
        'p_report_id': ?reportId,
      },
    );

    if (res == null) return const [];
    return (res as List)
        .map((e) => MatchModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MatchModel> getMatchDetails(String matchId) async {
    final res = await _supabase.rpc(
      'get_match_details',
      params: {'p_match_id': matchId},
    );

    return MatchModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> rejectMatch(String matchId) async {
    await _supabase.rpc(
      'reject_match',
      params: {'p_match_id': matchId},
    );
  }

  @override
  Future<int> getMyMatchesCount() async {
    final res = await _supabase.rpc('get_my_matches_count');
    if (res is num) return res.toInt();
    return 0;
  }
}
