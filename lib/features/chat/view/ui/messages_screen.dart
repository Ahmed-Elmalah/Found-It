import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/features/chat/view/cubit/chat_list_cubit.dart';
import 'package:found_it/features/chat/view/cubit/chat_list_state.dart';
import 'package:found_it/features/chat/view/widgets/chat_list_card.dart';
import 'package:found_it/features/chat/view/widgets/chat_list_empty_view.dart';
import 'package:found_it/features/chat/view/widgets/chat_list_shimmer.dart';
import 'package:found_it/features/chat/view/widgets/messages_collapsing_header.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final cubit = context.read<ChatListCubit>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () => cubit.refresh(),
        displacement: topPadding + 60.h,
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // Pinned Frosted Glass Collapsing Header (Large Title + Search)
            SliverPersistentHeader(
              pinned: true,
              delegate: MessagesCollapsingHeaderDelegate(
                topPadding: topPadding,
                searchController: _searchController,
                onSearchChanged: (query) => cubit.onSearchChanged(query),
                onClearSearch: () => cubit.clearSearch(),
              ),
            ),

            // Content body
            BlocBuilder<ChatListCubit, ChatListState>(
              builder: (context, state) {
                // 1. Loading State
                if (state.status == ChatListStatus.loading) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 14.h),
                      child: const ChatListShimmer(),
                    ),
                  );
                }

                // 2. Error State
                if (state.status == ChatListStatus.failure) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: ChatListEmptyView(
                      isError: true,
                      onRetry: () => cubit.loadChats(),
                    ),
                  );
                }

                // 3. Search Empty State
                if (state.isSearchEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: ChatListEmptyView(isSearchEmpty: true),
                  );
                }

                // 4. Zero Chats Empty State
                if (state.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: ChatListEmptyView(),
                  );
                }

                // 5. Success Chat List
                final chats = state.filteredChats;
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 110.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final chat = chats[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: ChatListCard(
                            chat: chat,
                            onTap: () {
                              context
                                  .push('/chat/${chat.matchId}')
                                  .then((_) => cubit.refresh());
                            },
                          ),
                        );
                      },
                      childCount: chats.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
