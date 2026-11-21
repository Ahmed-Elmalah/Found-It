import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/recovery/data/models/handover_contact_model.dart';

abstract class RecoveryRemoteDataSource {
  Future<HandoverContactModel> getMatchContact(String matchId);
  Future<void> markItemRecovered(String matchId);
}

class RecoveryRemoteDataSourceImpl implements RecoveryRemoteDataSource {
  final SupabaseClient _supabase;

  const RecoveryRemoteDataSourceImpl(this._supabase);

  @override
  Future<HandoverContactModel> getMatchContact(String matchId) async {
    final res = await _supabase.rpc(
      'get_match_contact',
      params: {'p_match_id': matchId},
    );

    return HandoverContactModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> markItemRecovered(String matchId) async {
    await _supabase.rpc(
      'mark_item_recovered',
      params: {'p_match_id': matchId},
    );
  }
}
