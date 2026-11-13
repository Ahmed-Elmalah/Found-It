import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/widgets/app_button.dart';

class ReportCreatedScreen extends StatelessWidget {
  /// The reference ID returned from the backend, e.g. "#RPT-8092".
  final String referenceId;

  const ReportCreatedScreen({super.key, required this.referenceId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 70.h),

                  // ── Success icon ──────────────────────────────────────────
                  // NOTE: Needs AppColors.success from Youssef (light ≈ #DDF5E7 bg, dark ≈ #113020 bg).
                  // Using theme colorScheme to avoid hardcoded Color values per review.
                  Container(
                    width: 88.r,
                    height: 88.r,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: colors.onPrimaryContainer,
                      size: 48.r,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // ── Title ─────────────────────────────────────────────────
                  Text(
                    l10n.reportCreatedTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // ── Reference ID ──────────────────────────────────────────
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: colors.onSurfaceVariant,
                      ),
                      children: [
                        TextSpan(
                          text: l10n
                              .reportCreatedId(referenceId)
                              .split(referenceId)
                              .first,
                        ),
                        TextSpan(
                          text: referenceId,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),

                  // ── Active message ────────────────────────────────────────
                  Text(
                    l10n.reportActiveMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const Spacer(),

                  // ── View my report button ─────────────────────────────────
                  AppButton(
                    label: l10n.viewMyReport,
                    onPressed: () => context.go(AppRoutes.myReports),
                  ),
                  SizedBox(height: 12.h),

                  // ── Back to home button ───────────────────────────────────
                  AppButton(
                    label: l10n.backToHome,
                    variant: AppButtonVariant.outlined,
                    onPressed: () => context.go(AppRoutes.home),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
