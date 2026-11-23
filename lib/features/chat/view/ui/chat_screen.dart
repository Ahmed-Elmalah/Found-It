import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/di/injection.dart';
import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/features/chat/domain/entities/chat_failure.dart';
import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/view/cubit/chat_cubit.dart';
import 'package:found_it/features/chat/view/cubit/chat_state.dart';
import 'package:found_it/features/chat/view/widgets/chat_app_bar.dart';
import 'package:found_it/features/chat/view/widgets/chat_confirm_ownership_bar.dart';
import 'package:found_it/features/chat/view/widgets/chat_input_bar.dart';
import 'package:found_it/features/chat/view/widgets/chat_message_bubble.dart';
import 'package:found_it/features/chat/view/widgets/chat_safety_banner.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    required this.matchId,
    this.initialChatInfo,
  });

  final String matchId;
  final ChatItemEntity? initialChatInfo;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatCubit>()..init(matchId, initialChatInfo: initialChatInfo),
      child: _ChatView(matchId: matchId),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({required this.matchId});

  final String matchId;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _formatDateHeader(DateTime date, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      return l10n.chatToday;
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(date, yesterday)) {
      return l10n.chatYesterday;
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  String _mapFailureToMessage(ChatFailure failure, AppLocalizations l10n) {
    return switch (failure.type) {
      ChatFailureType.notFound => l10n.chatErrorNotFound,
      ChatFailureType.notAllowed => l10n.chatErrorNotAllowed,
      ChatFailureType.invalidState => l10n.chatErrorInvalidState,
      ChatFailureType.network => l10n.chatErrorNetwork,
      ChatFailureType.unknown => l10n.chatErrorUnknown,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final topBarHeight = topPadding + 58.h;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state.messages.isNotEmpty) {
            _scrollToBottom();
          }
          if (state.failure != null) {
            final l10n = AppLocalizations.of(context);
            final msg = _mapFailureToMessage(state.failure!, l10n);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
            context.read<ChatCubit>().clearFailure();
          }
        },
        builder: (context, state) {
          final cubit = context.read<ChatCubit>();
          final messages = state.messages;
          final hasSafetyBanner = !state.isVerified;
          final totalItemCount = messages.length + (hasSafetyBanner ? 1 : 0);

          // Bottom clearance so messages can scroll completely above the floating controls
          final bottomClearance = bottomInset + (state.isVerified ? 135.h : 185.h);

          return Stack(
            children: [
              // 1. Full-Bleed Scrollable Messages Stream (Messages scroll smoothly behind floating controls)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      0,
                      topBarHeight + 8.h,
                      0,
                      bottomClearance,
                    ),
                    itemCount: totalItemCount,
                    itemBuilder: (context, index) {
                      if (hasSafetyBanner && index == 0) {
                        return const ChatSafetyBanner();
                      }

                      final msgIndex = hasSafetyBanner ? index - 1 : index;
                      final msg = messages[msgIndex];
                      final showDate = msgIndex == 0 ||
                          !_isSameDay(
                            messages[msgIndex - 1].createdAt,
                            msg.createdAt,
                          );
                      final dateLabel = showDate
                          ? _formatDateHeader(msg.createdAt, context)
                          : null;

                      return ChatMessageBubble(
                        message: msg,
                        showDateHeader: showDate,
                        dateHeaderLabel: dateLabel,
                        onRetry: (id) => cubit.retryMessage(id),
                      );
                    },
                  ),
                ),
              ),

              // 2. Floating Bottom Controls (Confirm Ownership Capsule + Textfield Input Capsule)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Floating Confirm Ownership Action Pill (visible only when verified or finder with status 'chatting')
                      ChatConfirmOwnershipBar(
                        matchId: widget.matchId,
                        isVerified: state.isVerified,
                        isConfirming: state.isConfirming,
                        canConfirm: state.canConfirmOwnership,
                        onConfirm: () => cubit.confirmOwnership(),
                      ),

                      // Floating Capsule Input Bar
                      ChatInputBar(
                        isClosed: state.isClosed,
                        isSending: state.isSending,
                        onSendMessage: (text) => cubit.sendMessage(text),
                        onSendImage: (bytes, ext) => cubit.sendImage(bytes, ext),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Floating Frosted Glass Custom App Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ChatAppBar(
                  chatInfo: state.chatInfo,
                  isVerified: state.isVerified,
                  onRejectMatch: () => cubit.rejectMatch(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
