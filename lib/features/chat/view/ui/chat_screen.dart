import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/di/injection.dart';
import 'package:found_it/core/localization/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final topBarHeight = topPadding + 56.h;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state.messages.isNotEmpty) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          final cubit = context.read<ChatCubit>();
          final messages = state.messages;

          return Stack(
            children: [
              // 1. Messages Stream with Safety Banner & Bottom Action Controls
              Positioned.fill(
                child: Column(
                  children: [
                    // Clearance for Custom App Bar
                    SizedBox(height: topBarHeight),

                    // P32 Safety Banner (pinned at the top of messages)
                    if (!state.isVerified) const ChatSafetyBanner(),

                    // Scrollable Messages List
                    Expanded(
                      child: GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.fromLTRB(0, 8.h, 0, 12.h),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index];
                            final showDate = index == 0 ||
                                !_isSameDay(
                                  messages[index - 1].createdAt,
                                  msg.createdAt,
                                );
                            final dateLabel = showDate
                                ? _formatDateHeader(msg.createdAt, context)
                                : null;

                            return ChatMessageBubble(
                              message: msg,
                              showDateHeader: showDate,
                              dateHeaderLabel: dateLabel,
                            );
                          },
                        ),
                      ),
                    ),

                    // Confirm Ownership Button at the bottom (User requested: وضيف زرار الكونفيرم تحت)
                    ChatConfirmOwnershipBar(
                      matchId: widget.matchId,
                      isVerified: state.isVerified,
                      isConfirming: state.isConfirming,
                      onConfirm: () => cubit.confirmOwnership(),
                    ),

                    // Floating Input Bar
                    ChatInputBar(
                      isClosed: state.isClosed,
                      isSending: state.isSending,
                      onSendMessage: (text) => cubit.sendMessage(text),
                      onSendImage: (bytes, ext) => cubit.sendImage(bytes, ext),
                    ),
                  ],
                ),
              ),

              // 2. Custom Floating App Bar (with Top Darkening Gradient)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ChatAppBar(
                  chatInfo: state.chatInfo,
                  isVerified: state.isVerified,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
