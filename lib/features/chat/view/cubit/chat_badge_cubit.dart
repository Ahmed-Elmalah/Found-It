import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/chat/domain/use_cases/get_unread_messages_count_use_case.dart';

class ChatBadgeCubit extends Cubit<int> {
  ChatBadgeCubit(this._getUnreadMessagesCountUseCase) : super(0);

  final GetUnreadMessagesCountUseCase _getUnreadMessagesCountUseCase;

  Future<void> loadUnreadCount() async {
    try {
      final count = await _getUnreadMessagesCountUseCase();
      if (!isClosed) {
        emit(count < 0 ? 0 : count);
      }
    } catch (_) {
      // Keep existing count on error
    }
  }

  void updateCount(int count) {
    if (!isClosed) {
      emit(count < 0 ? 0 : count);
    }
  }

  void decrement([int amount = 1]) {
    if (!isClosed) {
      final newCount = (state - amount).clamp(0, 9999);
      emit(newCount);
    }
  }
}
