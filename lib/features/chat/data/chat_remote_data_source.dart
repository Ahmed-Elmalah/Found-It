import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/chat/data/models/chat_item_model.dart';
import 'package:found_it/features/chat/data/models/chat_message_model.dart';
import 'package:found_it/features/chat/domain/entities/chat_failure.dart';

abstract interface class ChatRemoteDataSource {
  Future<List<ChatItemModel>> getMyChats();
  Future<int> getUnreadMessagesCount();
  Stream<List<ChatMessageModel>> getMessages(String matchId);
  Future<void> sendMessage(String matchId, {String? body, String? imagePath});
  Future<void> markMessagesRead(String matchId);
  Future<void> confirmOwnership(String matchId);
  Future<String> uploadChatImage(
    String matchId,
    List<int> bytes,
    String extension,
  );
  Future<String> getSignedImageUrl(String path);
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
      throw _mapPostgrestException(e);
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
      throw _mapPostgrestException(e);
    } on SocketException catch (e) {
      throw ChatFailure(ChatFailureType.network, e.message);
    } catch (e) {
      if (e is ChatFailure) rethrow;
      throw ChatFailure(ChatFailureType.unknown, e.toString());
    }
  }

  @override
  Stream<List<ChatMessageModel>> getMessages(String matchId) {
    final currentUserId = _supabase.auth.currentUser?.id;
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('match_id', matchId)
        .order('created_at', ascending: true)
        .map((rows) => rows
            .map((r) => ChatMessageModel.fromJson(
                  r,
                  currentUserId: currentUserId,
                ))
            .toList());
  }

  @override
  Future<void> sendMessage(
    String matchId, {
    String? body,
    String? imagePath,
  }) async {
    try {
      final payload = <String, dynamic>{'match_id': matchId};
      if (body != null) payload['body'] = body;
      if (imagePath != null) payload['image_path'] = imagePath;
      await _supabase.from('messages').insert(payload);
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
    } on SocketException catch (e) {
      throw ChatFailure(ChatFailureType.network, e.message);
    } catch (e) {
      if (e is ChatFailure) rethrow;
      throw ChatFailure(ChatFailureType.unknown, e.toString());
    }
  }

  @override
  Future<void> markMessagesRead(String matchId) async {
    try {
      await _supabase.rpc('mark_messages_read', params: {
        'p_match_id': matchId,
      });
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
    } catch (_) {
      // Background read marking should not crash the flow
    }
  }

  @override
  Future<void> confirmOwnership(String matchId) async {
    try {
      await _supabase.rpc('confirm_ownership', params: {
        'p_match_id': matchId,
      });
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(e);
    } on SocketException catch (e) {
      throw ChatFailure(ChatFailureType.network, e.message);
    } catch (e) {
      if (e is ChatFailure) rethrow;
      throw ChatFailure(ChatFailureType.unknown, e.toString());
    }
  }

  @override
  Future<String> uploadChatImage(
    String matchId,
    List<int> bytes,
    String extension,
  ) async {
    try {
      final ext = extension.replaceAll('.', '').toLowerCase();
      final path = '$matchId/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _supabase.storage.from('chat-images').uploadBinary(
            path,
            Uint8List.fromList(bytes),
          );
      return path;
    } on StorageException catch (e) {
      throw ChatFailure(ChatFailureType.unknown, e.message);
    } on SocketException catch (e) {
      throw ChatFailure(ChatFailureType.network, e.message);
    } catch (e) {
      if (e is ChatFailure) rethrow;
      throw ChatFailure(ChatFailureType.unknown, e.toString());
    }
  }

  @override
  Future<String> getSignedImageUrl(String path) async {
    try {
      return await _supabase.storage
          .from('chat-images')
          .createSignedUrl(path, 3600);
    } catch (_) {
      return '';
    }
  }

  ChatFailure _mapPostgrestException(PostgrestException e) {
    return switch (e.code) {
      'P0002' => const ChatFailure(ChatFailureType.notFound),
      '42501' => const ChatFailure(ChatFailureType.notAllowed),
      '55000' => const ChatFailure(ChatFailureType.invalidState),
      _ => ChatFailure(ChatFailureType.unknown, e.message),
    };
  }
}
