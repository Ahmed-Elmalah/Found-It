import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/core/di/injection.dart';
import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/entities/chat_message_entity.dart';
import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';
import 'package:found_it/features/chat/domain/use_cases/confirm_ownership_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/get_chat_match_details_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/get_signed_image_url_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/mark_messages_read_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/send_message_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/upload_chat_image_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/watch_messages_use_case.dart';
import 'package:found_it/features/chat/view/cubit/chat_cubit.dart';
import 'package:found_it/features/chat/view/ui/chat_screen.dart';
import 'package:found_it/features/chat/view/widgets/chat_app_bar.dart';
import 'package:found_it/features/chat/view/widgets/chat_confirm_ownership_bar.dart';
import 'package:found_it/features/chat/view/widgets/chat_input_bar.dart';
import 'package:found_it/features/chat/view/widgets/chat_message_bubble.dart';
import '../../../../helpers/test_app.dart';

class _FakeChatRepository implements ChatRepository {
  StreamController<List<ChatMessageEntity>> messagesController =
      StreamController<List<ChatMessageEntity>>.broadcast();

  ChatItemEntity matchDetails = const ChatItemEntity(
    matchId: 'match-1',
    status: 'chatting',
    otherUserName: 'Omar Khaled',
    iAmFinder: true,
  );

  @override
  Future<ChatItemEntity> getMatchDetails(String matchId) async => matchDetails;

  @override
  Stream<List<ChatMessageEntity>> getMessages(String matchId) =>
      messagesController.stream;

  @override
  Future<void> sendMessage(String matchId, {String? body, String? imagePath}) async {}

  @override
  Future<void> markMessagesRead(String matchId) async {}

  @override
  Future<void> confirmOwnership(String matchId) async {}

  @override
  Future<String> uploadChatImage(
      String matchId, List<int> bytes, String extension) async =>
      'path/img.jpg';

  @override
  Future<String> getSignedImageUrl(String path) async => 'https://signed.url';

  @override
  Future<List<ChatItemEntity>> getMyChats() async => [matchDetails];

  @override
  Future<int> getUnreadMessagesCount() async => 0;
}

void main() {
  group('ChatScreen Widget Tests', () {
    late _FakeChatRepository repository;
    late ChatCubit cubit;

    setUp(() {
      repository = _FakeChatRepository();
      cubit = ChatCubit(
        getChatMatchDetailsUseCase: GetChatMatchDetailsUseCase(repository),
        watchMessagesUseCase: WatchMessagesUseCase(repository),
        sendMessageUseCase: SendMessageUseCase(repository),
        uploadChatImageUseCase: UploadChatImageUseCase(repository),
        getSignedImageUrlUseCase: GetSignedImageUrlUseCase(repository),
        markMessagesReadUseCase: MarkMessagesReadUseCase(repository),
        confirmOwnershipUseCase: ConfirmOwnershipUseCase(repository),
      );

      if (sl.isRegistered<ChatCubit>()) {
        sl.unregister<ChatCubit>();
      }
      sl.registerFactory<ChatCubit>(() => cubit);
    });

    tearDown(() {
      if (sl.isRegistered<ChatCubit>()) {
        sl.unregister<ChatCubit>();
      }
      cubit.close();
    });

    testWidgets('renders ChatAppBar and ChatInputBar', (tester) async {
      await pumpTestApp(
        tester,
        const ChatScreen(matchId: 'match-1'),
        padded: false,
      );
      await tester.pump();

      expect(find.byType(ChatAppBar), findsOneWidget);
      expect(find.byType(ChatInputBar), findsOneWidget);
      expect(find.text('Omar Khaled'), findsOneWidget);
    });

    testWidgets('displays message bubbles when messages arrive from stream', (tester) async {
      await pumpTestApp(
        tester,
        const ChatScreen(matchId: 'match-1'),
        padded: false,
      );
      await tester.pump();

      final testMessage = ChatMessageEntity(
        id: 'msg-1',
        matchId: 'match-1',
        senderId: 'other-user',
        body: 'Hello, I found your phone!',
        createdAt: DateTime.now(),
        isMine: false,
      );

      repository.messagesController.add([testMessage]);
      await tester.pumpAndSettle();

      expect(find.byType(ChatMessageBubble), findsOneWidget);
      expect(find.text('Hello, I found your phone!'), findsOneWidget);
    });

    testWidgets('shows Confirm Ownership button when iAmFinder is true and status is chatting', (tester) async {
      repository.matchDetails = const ChatItemEntity(
        matchId: 'match-1',
        status: 'chatting',
        otherUserName: 'Omar Khaled',
        iAmFinder: true,
      );

      await pumpTestApp(
        tester,
        const ChatScreen(matchId: 'match-1'),
        padded: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ChatConfirmOwnershipBar), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('hides Confirm Ownership button when iAmFinder is false', (tester) async {
      repository.matchDetails = const ChatItemEntity(
        matchId: 'match-1',
        status: 'chatting',
        otherUserName: 'Omar Khaled',
        iAmFinder: false,
      );

      await pumpTestApp(
        tester,
        const ChatScreen(matchId: 'match-1'),
        padded: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Confirm'), findsNothing);
    });
  });
}
