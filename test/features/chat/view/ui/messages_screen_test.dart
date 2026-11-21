import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mock/fake_chat_data.dart';
import 'package:found_it/features/chat/domain/entities/chat_failure.dart';
import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';
import 'package:found_it/features/chat/domain/use_cases/get_my_chats_use_case.dart';
import 'package:found_it/features/chat/view/cubit/chat_list_cubit.dart';
import 'package:found_it/features/chat/view/ui/messages_screen.dart';
import 'package:found_it/features/chat/view/widgets/chat_list_card.dart';
import 'package:found_it/features/chat/view/widgets/chat_list_empty_view.dart';
import 'package:found_it/features/chat/view/widgets/chat_list_shimmer.dart';
import '../../../../helpers/test_app.dart';

class _FakeChatRepository implements ChatRepository {
  List<ChatItemEntity> chatsToReturn = const [];
  Object? errorToThrow;
  Completer<List<ChatItemEntity>>? pendingCompleter;

  @override
  Future<List<ChatItemEntity>> getMyChats() async {
    if (pendingCompleter != null) return pendingCompleter!.future;
    final err = errorToThrow;
    if (err != null) throw err;
    return chatsToReturn;
  }

  @override
  Future<int> getUnreadMessagesCount() async => 0;
}

void main() {
  group('MessagesScreen', () {
    late _FakeChatRepository repository;
    late GetMyChatsUseCase getMyChatsUseCase;
    late ChatListCubit cubit;

    setUp(() {
      repository = _FakeChatRepository();
      getMyChatsUseCase = GetMyChatsUseCase(repository);
      cubit = ChatListCubit(getMyChatsUseCase);
    });

    tearDown(() {
      cubit.close();
    });

    Widget buildSubject() {
      return BlocProvider.value(
        value: cubit,
        child: const MessagesScreen(),
      );
    }

    testWidgets('displays shimmer while loading', (tester) async {
      final completer = Completer<List<ChatItemEntity>>();
      repository.pendingCompleter = completer;

      final loadFuture = cubit.loadChats();

      await pumpTestApp(tester, buildSubject(), padded: false);
      await tester.pump();

      expect(find.byType(ChatListShimmer), findsOneWidget);

      completer.complete(FakeChatData.sampleChats);
      await loadFuture;
      await tester.pumpAndSettle();
    });

    testWidgets('displays empty view when no conversations exist', (tester) async {
      repository.chatsToReturn = const [];
      await cubit.loadChats();

      await pumpTestApp(tester, buildSubject(), padded: false);
      await tester.pumpAndSettle();

      expect(find.byType(ChatListEmptyView), findsOneWidget);
      expect(find.text('No conversations yet'), findsOneWidget);
    });

    testWidgets('displays chat cards when conversations exist', (tester) async {
      repository.chatsToReturn = FakeChatData.sampleChats;
      await cubit.loadChats();

      await pumpTestApp(tester, buildSubject(), padded: false);
      await tester.pumpAndSettle();

      expect(find.byType(ChatListCard), findsWidgets);
      expect(find.text('Mona K.'), findsOneWidget);
      expect(find.text('Sarah Hassan'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Unread'), findsOneWidget);
    });

    testWidgets('filters chat cards when searching in the header', (tester) async {
      repository.chatsToReturn = FakeChatData.sampleChats;
      await cubit.loadChats();

      await pumpTestApp(tester, buildSubject(), padded: false);
      await tester.pumpAndSettle();

      expect(find.byType(ChatListCard), findsWidgets);

      // Enter search query
      final searchInput = find.byType(TextField);
      expect(searchInput, findsOneWidget);
      await tester.enterText(searchInput, 'Mona');
      await tester.pumpAndSettle();

      // Only Mona's card should be visible
      expect(find.byType(ChatListCard), findsOneWidget);
      expect(find.text('Mona K.'), findsOneWidget);
      expect(find.text('Sarah Hassan'), findsNothing);
    });

    testWidgets('displays error view with retry when loading fails', (tester) async {
      repository.errorToThrow = const ChatFailure(ChatFailureType.network);
      await cubit.loadChats();

      await pumpTestApp(tester, buildSubject(), padded: false);
      await tester.pumpAndSettle();

      expect(find.byType(ChatListEmptyView), findsOneWidget);
      expect(find.text("Couldn't load messages"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
