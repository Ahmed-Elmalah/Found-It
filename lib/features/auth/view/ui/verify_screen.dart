import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/core/widgets/line_icon.dart';
import 'package:found_it/features/auth/view/cubit/resend_timer_cubit.dart';
import 'package:found_it/features/auth/view/widgets/auth_back_button.dart';

/// Verify your email screen (Figma P10). The [ResendTimerCubit] is provided
/// by the router.
class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8.h),
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AuthBackButton(),
                    ),
                    SizedBox(height: 52.h),
                    Center(
                      child: Container(
                        width: 96.r,
                        height: 96.r,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: LineIcon(
                          LineIconType.mail,
                          size: 44.r,
                          color: colors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      l10n.verifyEmailTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 24.w,
                      ),
                      child: Text(
                        // The email is wrapped in Unicode isolates (LRI \u2066 ... PDI \u2069)
                        // so it stays one left-to-right piece inside the Arabic sentence
                        // and the period stays at the end.
                        l10n.verifyEmailBody('\u2066$email\u2069'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          height: 1.5,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // TODO(stage 8): re-try login with the saved credentials
                    // instead of just going to the login screen.
                    AppButton(
                      label: l10n.verifiedButton,
                      onPressed: () => context.go(AppRoutes.login),
                    ),
                    SizedBox(height: 12.h),
                    BlocBuilder<ResendTimerCubit, int>(
                      builder: (context, seconds) => AppButton(
                        variant: AppButtonVariant.outlined,
                        label: seconds > 0
                            ? l10n.resendEmailIn(
                                ResendTimerCubit.format(seconds),
                              )
                            : l10n.resendEmail,
                        // Stays non-null so it keeps its look while counting;
                        // the cubit ignores taps until the countdown hits 0.
                        onPressed: () =>
                            context.read<ResendTimerCubit>().resend(),
                      ),
                    ),
                    SizedBox(height: 33.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
