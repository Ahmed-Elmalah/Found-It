import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/di/injection.dart';
import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/recovery/domain/entities/handover_contact_entity.dart';
import 'package:found_it/features/recovery/domain/entities/recovery_failure.dart';
import 'package:found_it/features/recovery/view/cubit/recovery_cubit.dart';
import 'package:found_it/features/recovery/view/cubit/recovery_state.dart';
import 'package:found_it/features/recovery/view/widgets/mark_recovered_button.dart';
import 'package:found_it/features/recovery/view/widgets/safety_guideline_tile.dart';
import 'package:found_it/features/recovery/view/widgets/verified_contact_card.dart';

/// Screen displayed after ownership is verified, guiding both parties through
/// safe handover instructions and providing verified contact info.
class HandoverInstructionsScreen extends StatelessWidget {
  final String? matchId;
  final HandoverContactEntity? contact;
  final VoidCallback? onRecovered;

  const HandoverInstructionsScreen({
    super.key,
    this.matchId,
    this.contact,
    this.onRecovered,
  });

  @override
  Widget build(BuildContext context) {
    if (contact != null) {
      return _HandoverContent(
        contact: contact!,
        matchId: matchId,
        onRecovered: onRecovered,
      );
    }

    try {
      context.read<RecoveryCubit>();
      return _HandoverCubitView(
        matchId: matchId,
        onRecovered: onRecovered,
      );
    } catch (_) {
      return BlocProvider(
        create: (_) {
          final cubit = sl<RecoveryCubit>();
          if (matchId != null) {
            cubit.loadContact(matchId!);
          }
          return cubit;
        },
        child: _HandoverCubitView(
          matchId: matchId,
          onRecovered: onRecovered,
        ),
      );
    }
  }
}

class _HandoverCubitView extends StatelessWidget {
  final String? matchId;
  final VoidCallback? onRecovered;

  const _HandoverCubitView({
    this.matchId,
    this.onRecovered,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return BlocConsumer<RecoveryCubit, RecoveryState>(
      listener: (context, state) {
        if (state is RecoverySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.itemRecoveredSuccess),
              duration: const Duration(seconds: 3),
            ),
          );
          context.go(AppRoutes.myReports);
        } else if (state is RecoveryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_mapErrorMessage(state.failureType, l10n)),
              backgroundColor: colors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is RecoveryLoading || state is RecoveryInitial) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: Text(
                l10n.handoverTitle,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: colors.onSurface,
                ),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is RecoveryError && state is! HandoverContactLoaded) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: Text(
                l10n.handoverTitle,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: colors.onSurface,
                ),
              ),
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48.r,
                      color: colors.error,
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      _mapErrorMessage(state.failureType, l10n),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    if (matchId != null)
                      FilledButton.tonal(
                        onPressed: () =>
                            context.read<RecoveryCubit>().loadContact(matchId!),
                        child: Text(l10n.retry),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        final contact = state is HandoverContactLoaded ? state.contact : null;
        if (contact == null) {
          return Scaffold(
            body: Center(child: Text(l10n.recoveryErrorGeneric)),
          );
        }

        return _HandoverContent(
          contact: contact,
          matchId: matchId,
          onRecovered: onRecovered,
          isSubmitting: state is RecoverySubmitting,
        );
      },
    );
  }
}

class _HandoverContent extends StatelessWidget {
  final HandoverContactEntity contact;
  final String? matchId;
  final VoidCallback? onRecovered;
  final bool isSubmitting;

  const _HandoverContent({
    required this.contact,
    this.matchId,
    this.onRecovered,
    this.isSubmitting = false,
  });

  void _onConfirmRecovery(BuildContext context) {
    if (onRecovered != null) {
      onRecovered!();
      return;
    }

    if (matchId != null) {
      context.read<RecoveryCubit>().confirmRecovery(matchId!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).itemRecoveredSuccess),
          duration: const Duration(seconds: 3),
        ),
      );
      context.go(AppRoutes.myReports);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.handoverTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: colors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header Box ──
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.handshake_outlined,
                              size: 28.r,
                              color: colors.primary,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.handoverTitle,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: colors.onSurface,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  l10n.handoverSubtitle,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: colors.onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // ── Safety Tips Section ──
                    Text(
                      l10n.safetyTipsTitle,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        children: [
                          SafetyGuidelineTile(
                            icon: Icons.storefront_outlined,
                            text: l10n.safetyTipPublic,
                          ),
                          const Divider(height: 1),
                          SafetyGuidelineTile(
                            icon: Icons.wb_sunny_outlined,
                            text: l10n.safetyTipDaylight,
                          ),
                          const Divider(height: 1),
                          SafetyGuidelineTile(
                            icon: Icons.find_in_page_outlined,
                            text: l10n.safetyTipInspect,
                          ),
                          const Divider(height: 1),
                          SafetyGuidelineTile(
                            icon: Icons.money_off_outlined,
                            text: l10n.safetyTipCash,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // ── Verified Contact Card ──
                    VerifiedContactCard(contact: contact),
                  ],
                ),
              ),
            ),

            // ── Bottom Action ──
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 12.h, 16.w, 12.h),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: colors.outline)),
              ),
              child: MarkRecoveredButton(
                isLoading: isSubmitting,
                onConfirmed: () => _onConfirmRecovery(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _mapErrorMessage(RecoveryFailureType type, AppLocalizations l10n) {
  return switch (type) {
    RecoveryFailureType.notVerified => l10n.recoveryErrorNotVerified,
    RecoveryFailureType.invalidState => l10n.recoveryErrorInvalidState,
    RecoveryFailureType.notAllowed => l10n.recoveryErrorNotAllowed,
    _ => l10n.recoveryErrorGeneric,
  };
}
