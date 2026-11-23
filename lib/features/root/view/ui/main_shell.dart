import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/di/injection.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/chat/view/cubit/chat_badge_cubit.dart';
import 'package:found_it/features/root/view/widgets/liquid_glass_bottom_nav_bar.dart';

/// The persistent application shell containing the [LiquidGlassBottomNavBar]
/// and hosting the root branches (Home, Explore, Messages, Profile).
class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
    this.chatBadgeCubit,
  });

  final StatefulNavigationShell navigationShell;
  final ChatBadgeCubit? chatBadgeCubit;

  @override
  Widget build(BuildContext context) {
    final cubit = chatBadgeCubit ?? sl<ChatBadgeCubit>();

    return BlocProvider.value(
      value: cubit..loadUnreadCount(),
      child: Scaffold(
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: BlocBuilder<ChatBadgeCubit, int>(
          builder: (context, unreadCount) {
            return LiquidGlassBottomNavBar(
              currentIndex: navigationShell.currentIndex,
              unreadMessagesCount: unreadCount,
              onTap: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              onReportTap: () {
                context.push(AppRoutes.createReport);
              },
            );
          },
        ),
      ),
    );
  }
}
