import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/view/cubit/matches_cubit.dart';
import 'package:found_it/features/matches/view/cubit/matches_state.dart';
import 'package:found_it/features/matches/view/widgets/match_card.dart';

/// Screen listing potential matches for the user's reports (Figma P28 / P62).
class PotentialMatchesScreen extends StatelessWidget {
  final List<MatchEntity>? initialMatches;
  final String? reportId;

  const PotentialMatchesScreen({
    super.key,
    this.initialMatches,
    this.reportId,
  });

  @override
  Widget build(BuildContext context) {
    if (initialMatches != null) {
      return _PotentialMatchesStaticView(initialMatches: initialMatches!);
    }

    return _PotentialMatchesCubitView(reportId: reportId);
  }
}

class _PotentialMatchesCubitView extends StatelessWidget {
  final String? reportId;

  const _PotentialMatchesCubitView({this.reportId});

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
          l10n.potentialMatches,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: colors.onSurface,
          ),
        ),
      ),
      body: BlocConsumer<MatchesCubit, MatchesState>(
        listener: (context, state) {
          if (state is MatchesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? l10n.matchesLoadError),
                backgroundColor: colors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MatchesLoading || state is MatchesInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MatchesError) {
            return Center(
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
                      l10n.matchesLoadError,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    FilledButton.tonal(
                      onPressed: () => context
                          .read<MatchesCubit>()
                          .loadMatches(reportId: reportId),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is MatchesLoaded) {
            final matches = state.matches;
            if (matches.isEmpty) {
              return _buildEmptyState(context, l10n, colors);
            }

            return RefreshIndicator(
              onRefresh: () => context
                  .read<MatchesCubit>()
                  .loadMatches(reportId: reportId),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 16.w, 24.h),
                itemCount: matches.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return MatchCard(
                    match: match,
                    onViewMatch: () async {
                      await context.push(
                        AppRoutes.matchComparePath(match.matchId),
                        extra: match,
                      );
                      if (context.mounted) {
                        context
                            .read<MatchesCubit>()
                            .loadMatches(reportId: reportId);
                      }
                    },
                    onDismiss: () async {
                      final success = await context
                          .read<MatchesCubit>()
                          .dismissMatch(match.matchId);
                      if (!context.mounted) return;
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.matchDismissedMessage),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.matchDismissError),
                            backgroundColor: colors.error,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _PotentialMatchesStaticView extends StatefulWidget {
  final List<MatchEntity> initialMatches;

  const _PotentialMatchesStaticView({required this.initialMatches});

  @override
  State<_PotentialMatchesStaticView> createState() =>
      _PotentialMatchesStaticViewState();
}

class _PotentialMatchesStaticViewState
    extends State<_PotentialMatchesStaticView> {
  late List<MatchEntity> _matches;

  @override
  void initState() {
    super.initState();
    _matches = List<MatchEntity>.from(widget.initialMatches);
  }

  void _onDismiss(MatchEntity match) {
    setState(() {
      _matches.removeWhere((m) => m.matchId == match.matchId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).matchDismissedMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onViewMatch(MatchEntity match) {
    context.push(AppRoutes.matchComparePath(match.matchId), extra: match);
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
          l10n.potentialMatches,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: colors.onSurface,
          ),
        ),
      ),
      body: _matches.isEmpty
          ? _buildEmptyState(context, l10n, colors)
          : ListView.separated(
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 16.w, 24.h),
              itemCount: _matches.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final match = _matches[index];
                return MatchCard(
                  match: match,
                  onViewMatch: () => _onViewMatch(match),
                  onDismiss: () => _onDismiss(match),
                );
              },
            ),
    );
  }
}

Widget _buildEmptyState(
  BuildContext context,
  AppLocalizations l10n,
  ColorScheme colors,
) {
  return Center(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_outlined,
              size: 38.r,
              color: colors.primary,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            l10n.noMatchesTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.noMatchesSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  );
}
