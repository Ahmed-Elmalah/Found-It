import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/chat/view/cubit/chat_list_cubit.dart';
import 'package:found_it/features/chat/view/cubit/chat_list_state.dart';
import 'package:found_it/features/chat/view/widgets/chat_list_card.dart';
import 'package:found_it/features/chat/view/widgets/chat_list_empty_view.dart';
import 'package:found_it/features/chat/view/widgets/chat_list_shimmer.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    final progress = (offset / 48.h).clamp(0.0, 1.0);
    if ((progress - _scrollProgress).abs() > 0.01) {
      setState(() => _scrollProgress = progress);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int? count,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected
              ? primary
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? primary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04)),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.85)
                        : const Color(0xFF475569)),
              ),
            ),
            if (count != null && count > 0) ...[
              SizedBox(width: 5.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : const Color(0xFF1B4B66),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ChatListCubit>();
    final topPadding = MediaQuery.of(context).padding.top;
    final topBarHeight = topPadding + 52.h;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Scrollable List with RefreshIndicator
          RefreshIndicator(
            onRefresh: () => cubit.refresh(),
            displacement: 70.h,
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surface,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Top clearance for header bar
                SliverToBoxAdapter(
                  child: SizedBox(height: topBarHeight),
                ),

                // Large Title & Search & Filter Pills
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Large Bold Title
                        Text(
                          l10n.messagesTitle,
                          style: TextStyle(
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.8,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Sleek, generous iOS/WhatsApp Search Bar
                        Container(
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E2638)
                                : const Color(0xFFE2E8F0).withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.black.withValues(alpha: 0.04),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 12.w),
                              Icon(
                                Icons.search_rounded,
                                size: 20.sp,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.65),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (query) =>
                                      cubit.onSearchChanged(query),
                                  textAlignVertical: TextAlignVertical.center,
                                  style: TextStyle(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w400,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                    ),
                                    hintText: l10n.messagesSearchPlaceholder,
                                    hintStyle: TextStyle(
                                      fontSize: 14.5.sp,
                                      fontWeight: FontWeight.w400,
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.55),
                                    ),
                                  ),
                                ),
                              ),
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _searchController,
                                builder: (context, value, _) {
                                  if (value.text.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      _searchController.clear();
                                      cubit.clearSearch();
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                      ),
                                      child: Icon(
                                        Icons.cancel_rounded,
                                        size: 19.sp,
                                        color: theme
                                            .colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Category Filter Pills
                        BlocBuilder<ChatListCubit, ChatListState>(
                          buildWhen: (prev, curr) =>
                              prev.activeFilter != curr.activeFilter ||
                              prev.chats != curr.chats,
                          builder: (context, state) {
                            final unreadCount = state.chats
                                .where((c) => c.unreadCount > 0)
                                .length;

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  _buildFilterChip(
                                    context: context,
                                    label: l10n.messagesFilterAll,
                                    isSelected:
                                        state.activeFilter == ChatFilter.all,
                                    onTap: () =>
                                        cubit.setFilter(ChatFilter.all),
                                  ),
                                  SizedBox(width: 8.w),
                                  _buildFilterChip(
                                    context: context,
                                    label: l10n.messagesFilterUnread,
                                    isSelected:
                                        state.activeFilter == ChatFilter.unread,
                                    count: unreadCount,
                                    onTap: () =>
                                        cubit.setFilter(ChatFilter.unread),
                                  ),
                                  SizedBox(width: 8.w),
                                  _buildFilterChip(
                                    context: context,
                                    label: l10n.messagesFilterLost,
                                    isSelected:
                                        state.activeFilter == ChatFilter.lost,
                                    onTap: () =>
                                        cubit.setFilter(ChatFilter.lost),
                                  ),
                                  SizedBox(width: 8.w),
                                  _buildFilterChip(
                                    context: context,
                                    label: l10n.messagesFilterFound,
                                    isSelected:
                                        state.activeFilter == ChatFilter.found,
                                    onTap: () =>
                                        cubit.setFilter(ChatFilter.found),
                                  ),
                                  SizedBox(width: 8.w),
                                  _buildFilterChip(
                                    context: context,
                                    label: l10n.messagesFilterVerified,
                                    isSelected: state.activeFilter ==
                                        ChatFilter.verified,
                                    onTap: () =>
                                        cubit.setFilter(ChatFilter.verified),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Chat Cards / States
                BlocBuilder<ChatListCubit, ChatListState>(
                  builder: (context, state) {
                    // Loading State
                    if (state.status == ChatListStatus.loading) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: const ChatListShimmer(),
                        ),
                      );
                    }

                    // Failure State
                    if (state.status == ChatListStatus.failure) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: ChatListEmptyView(
                          isError: true,
                          onRetry: () => cubit.loadChats(),
                        ),
                      );
                    }

                    // Search or Filter Empty State
                    if (state.isSearchEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: ChatListEmptyView(
                          isSearchEmpty: true,
                          onClearFilters: () {
                            _searchController.clear();
                            cubit.clearSearch();
                            cubit.setFilter(ChatFilter.all);
                          },
                        ),
                      );
                    }

                    // Zero Chats Empty State
                    if (state.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: ChatListEmptyView(
                          onExplore: () => context.push(AppRoutes.explore),
                        ),
                      );
                    }

                    // Success Chat List with Staggered Entrance Animation
                    final chats = state.filteredChats;
                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 110.h),
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
                              )
                                  .animate(
                                    delay: Duration(
                                      milliseconds: (35 * index).clamp(0, 400),
                                    ),
                                  )
                                  .fadeIn(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
                                  )
                                  .slideY(
                                    begin: 0.08,
                                    end: 0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
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

          // 2. Gradual, Seamless Frosted Header Bar (NO hard line, NO icons)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 18 * _scrollProgress,
                  sigmaY: 18 * _scrollProgress,
                ),
                child: Container(
                  height: topBarHeight,
                  padding: EdgeInsets.only(top: topPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        (isDark ? const Color(0xFF0F172A) : Colors.white)
                            .withValues(alpha: 0.88 * _scrollProgress),
                        (isDark ? const Color(0xFF0F172A) : Colors.white)
                            .withValues(alpha: 0.60 * _scrollProgress),
                        (isDark ? const Color(0xFF0F172A) : Colors.white)
                            .withValues(alpha: 0.0 * _scrollProgress),
                      ],
                      stops: const [0.0, 0.72, 1.0],
                    ),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: _scrollProgress,
                      child: Text(
                        l10n.messagesTitle,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
