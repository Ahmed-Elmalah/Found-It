import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/core/widgets/line_icon.dart';
import 'package:found_it/features/onboarding/view/cubit/onboarding_cubit.dart';
import 'package:found_it/features/onboarding/view/widgets/onboarding_page.dart';
import 'package:found_it/features/onboarding/view/widgets/page_indicator.dart';

/// Three-page onboarding. The [OnboardingCubit] is provided from outside.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<OnboardingCubit>();

    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (p, c) => !p.completed && c.completed,
      listener: (context, state) => context.go(AppRoutes.login),
      builder: (context, state) {
        final isLast = state.isLastPage;
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(top: 8.h, end: 16.w),
                    child: Visibility(
                      visible: !isLast,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: TextButton(
                        onPressed: cubit.complete,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 8.h,
                          ),
                          foregroundColor: colors.onSurfaceVariant,
                        ),
                        child: Text(
                          l10n.onboardingSkip,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: cubit.pageChanged,
                    children: [
                      OnboardingPage(
                        icon: LineIconType.search,
                        title: l10n.onboardingFindTitle,
                        body: l10n.onboardingFindBody,
                      ),
                      OnboardingPage(
                        icon: LineIconType.plus,
                        title: l10n.onboardingReportTitle,
                        body: l10n.onboardingReportBody,
                      ),
                      OnboardingPage(
                        icon: LineIconType.messageCircle,
                        title: l10n.onboardingChatTitle,
                        body: l10n.onboardingChatBody,
                      ),
                    ],
                  ),
                ),
                PageIndicator(
                  count: OnboardingCubit.pageCount,
                  current: state.page,
                ),
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                  child: AppButton(
                    label: isLast
                        ? l10n.onboardingGetStarted
                        : l10n.onboardingNext,
                    onPressed: isLast
                        ? cubit.complete
                        : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          ),
                  ),
                ),
                SizedBox(height: 33.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
