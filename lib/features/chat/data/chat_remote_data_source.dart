import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/chat/data/models/chat_item_model.dart';
import 'package:found_it/features/chat/domain/entities/chat_failure.dart';

abstract interface class ChatRemoteDataSource {
  Future<List<ChatItemModel>> getMyChats();
  Future<int> getUnreadMessagesCount();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  const ChatRemoteDataSourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<ChatItemModel>> getMyChats() async {
    try {
      final response = await _supabase.rpc('get_my_chats');
      if (response is List) {
        return response
            .whereType<Map<String, dynamic>>()
            .map(ChatItemModel.fromJson)
            .toList();
      }
      return const [];
    } on PostgrestException catch (e) {
      throw switch (e.code) {
        'P0002' => const ChatFailure(ChatFailureType.notFound),
        '42501' => const ChatFailure(ChatFailureType.notAllowed),
        '55000' => const ChatFailure(ChatFailureType.invalidState),
        _ => ChatFailure(ChatFailureType.unknown, e.message),
      };
    } on SocketException catch (e) {
      throw ChatFailure(ChatFailureType.network, e.message);
    } catch (e) {
      if (e is ChatFailure) rethrow;
      throw ChatFailure(ChatFailureType.unknown, e.toString());
    }
  }

  @override
  Future<int> getUnreadMessagesCount() async {
    try {
      final response = await _supabase.rpc('get_unread_messages_count');
      if (response is int) return response;
      if (response != null) {
        return int.tryParse(response.toString()) ?? 0;
      }
      return 0;
    } on PostgrestException catch (e) {
      throw switch (e.code) {
        'P0002' => const ChatFailure(ChatFailureType.notFound),
        '42501' => const ChatFailure(ChatFailureType.notAllowed),
        '55000' => const ChatFailure(ChatFailureType.invalidState),
        _ => ChatFailure(ChatFailureType.unknown, e.message),
      };
    } on SocketException catch (e) {
      throw ChatFailure(ChatFailureType.network, e.message);
    } catch (e) {
      if (e is ChatFailure) rethrow;
      throw ChatFailure(ChatFailureType.unknown, e.toString());
    }
  }
}
