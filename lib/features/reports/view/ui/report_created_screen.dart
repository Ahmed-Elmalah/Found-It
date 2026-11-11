import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';

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
                  Container(
                    width: 88.r,
                    height: 88.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981), // emerald green — fixed in both light/dark
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
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
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                          fontSize: 15.sp, color: colors.onSurfaceVariant),
                      children: [
                        TextSpan(
                          text: l10n.reportCreatedId(referenceId).split(referenceId).first,
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
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: FilledButton(
                      onPressed: () {
                        // Navigates or pops back
                        Navigator.of(context).maybePop();
                      },
                      child: Text(
                        l10n.viewMyReport,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // ── Back to home button ───────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                      child: Text(
                        l10n.backToHome,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
