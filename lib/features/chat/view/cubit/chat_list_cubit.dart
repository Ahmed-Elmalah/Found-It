import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/chat/domain/entities/chat_failure.dart';
import 'package:found_it/features/chat/domain/use_cases/get_my_chats_use_case.dart';
import 'package:found_it/features/chat/view/cubit/chat_list_state.dart';

class ChatListCubit extends Cubit<ChatListState> {
  ChatListCubit(this._getMyChatsUseCase) : super(const ChatListState());

  final GetMyChatsUseCase _getMyChatsUseCase;

  Future<void> loadChats() async {
    emit(state.copyWith(
      status: ChatListStatus.loading,
      failure: () => null,
    ));

    try {
      final chats = await _getMyChatsUseCase();
      emit(state.copyWith(
        status: ChatListStatus.success,
        chats: chats,
      ));
    } on ChatFailure catch (e) {
      emit(state.copyWith(
        status: ChatListStatus.failure,
        failure: () => e.type,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ChatListStatus.failure,
        failure: () => ChatFailureType.unknown,
      ));
    }
  }

  Future<void> refresh() async {
    try {
      final chats = await _getMyChatsUseCase();
      emit(state.copyWith(
        status: ChatListStatus.success,
        chats: chats,
        failure: () => null,
      ));
    } catch (_) {
      // Keep existing chats on background refresh failure
    }
  }

  void onSearchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void clearSearch() {
    emit(state.copyWith(searchQuery: ''));
  }
}
