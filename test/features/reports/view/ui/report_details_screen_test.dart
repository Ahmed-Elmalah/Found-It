import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/core/di/injection.dart';
import 'package:found_it/core/events/reports_changed_notifier.dart';
import 'package:found_it/core/widgets/status_chip.dart';
import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/domain/repositories/matches_repository.dart';
import 'package:found_it/features/matches/domain/use_cases/get_match_details_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/get_my_matches_count_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/get_my_matches_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/reject_match_use_case.dart';
import 'package:found_it/features/matches/view/cubit/matches_cubit.dart';
import 'package:found_it/features/recovery/domain/entities/handover_contact_entity.dart';
import 'package:found_it/features/recovery/domain/repositories/recovery_repository.dart';
import 'package:found_it/features/recovery/domain/use_cases/get_match_contact_use_case.dart';
import 'package:found_it/features/recovery/domain/use_cases/mark_item_recovered_use_case.dart';
import 'package:found_it/features/recovery/view/cubit/recovery_cubit.dart';
import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/entities/create_report_params.dart';
import 'package:found_it/features/reports/domain/entities/manual_match_result_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_counts_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_details_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_failure.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';
import 'package:found_it/features/reports/domain/use_cases/create_manual_match_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_report_details_use_case.dart';
import 'package:found_it/features/reports/view/cubit/report_details_cubit.dart';
import 'package:found_it/features/reports/view/ui/report_details_screen.dart';

import '../../../../helpers/test_app.dart';

class _FakeReportsRepo implements ReportsRepository {
  bool notFound = false;
  bool isOwner = false;

  ReportDetailsEntity get report => ReportDetailsEntity(
        id: 'rep_1',
        refCode: '#RPT-1001',
        ownerName: 'Test User',
        cityId: 'city_cairo',
        cityNameEn: 'Cairo',
        cityNameAr: 'القاهرة',
        areaId: 'area_1',
        areaNameEn: 'Nasr City',
        areaNameAr: 'مدينة نصر',
        categoryId: 'cat_1',
        categoryNameEn: 'Wallet',
        categoryNameAr: 'محفظة',
        categoryIcon: 'wallet',
        title: 'Lost Leather Wallet',
        description: 'Black leather wallet with cards',
        type: 'lost',
        status: 'active',
        itemDate: DateTime(2026, 11, 15),
        createdAt: DateTime(2026, 11, 15),
        updatedAt: DateTime(2026, 11, 15),
        images: const ['https://example.com/wallet.jpg'],
        isMine: isOwner,
        hasPrivateDetails: false,
        privateDetails: isOwner ? 'Secret serial: 9988' : null,
      );

  @override
  Future<ReportDetailsEntity> getReportDetails(String reportId) async {
    if (notFound) {
      throw const ReportFailure(ReportFailureType.notFound);
    }
    return report;
  }

  @override
  Future<ManualMatchResultEntity> createManualMatch(String reportId) async {
    return const ManualMatchResultEntity(
      matchId: 'match_123',
      status: 'pending',
      claimStatus: 'pending',
      isNew: true,
    );
  }

  @override
  Future<String> createReport(CreateReportParams params) => throw UnimplementedError();
  @override
  Future<List<CategoryEntity>> getCategories() => throw UnimplementedError();
  @override
  Future<List<AreaEntity>> getCityAreas({required String cityId, required String lang}) =>
      throw UnimplementedError();
  @override
  Future<List<ReportEntity>> getMyReports({String? status}) => throw UnimplementedError();
  @override
  Future<ReportCountsEntity> getMyReportsCounts() => throw UnimplementedError();
  @override
  Future<String> getSelectedCityId() => throw UnimplementedError();
  @override
  Future<void> softDeleteReport(String reportId) => throw UnimplementedError();
  @override
  Future<ReportEntity> updateReport({
    required String reportId,
    String? title,
    String? description,
    String? type,
    String? categoryId,
    String? areaId,
    DateTime? itemDate,
    String? privateDetails,
  }) =>
      throw UnimplementedError();
}

class _FakeMatchesRepo implements MatchesRepository {
  @override
  Future<List<MatchEntity>> getMyMatches({String? reportId}) async => const [];
  @override
  Future<int> getMyMatchesCount() async => 0;
  @override
  Future<MatchEntity> getMatchDetails(String matchId) => throw UnimplementedError();
  @override
  Future<void> rejectMatch(String matchId) => throw UnimplementedError();
}

class _FakeRecoveryRepo implements RecoveryRepository {
  @override
  Future<HandoverContactEntity> getMatchContact(String matchId) =>
      throw UnimplementedError();
  @override
  Future<void> markItemRecovered(String matchId) => throw UnimplementedError();
}

void main() {
  group('ReportDetailsScreen Widget Test', () {
    late _FakeReportsRepo fakeReportsRepo;
    late _FakeMatchesRepo fakeMatchesRepo;
    late _FakeRecoveryRepo fakeRecoveryRepo;

    setUp(() {
      fakeReportsRepo = _FakeReportsRepo();
      fakeMatchesRepo = _FakeMatchesRepo();
      fakeRecoveryRepo = _FakeRecoveryRepo();

      sl.reset();
      sl.registerFactory<ReportDetailsCubit>(
        () => ReportDetailsCubit(
          GetReportDetailsUseCase(fakeReportsRepo),
          CreateManualMatchUseCase(fakeReportsRepo),
        ),
      );
      sl.registerFactory<MatchesCubit>(
        () => MatchesCubit(
          getMyMatches: GetMyMatchesUseCase(fakeMatchesRepo),
          getMatchDetails: GetMatchDetailsUseCase(fakeMatchesRepo),
          rejectMatchUseCase: RejectMatchUseCase(fakeMatchesRepo),
          getMyMatchesCount: GetMyMatchesCountUseCase(fakeMatchesRepo),
        ),
      );
      sl.registerFactory<RecoveryCubit>(
        () => RecoveryCubit(
          getMatchContact: GetMatchContactUseCase(fakeRecoveryRepo),
          markItemRecovered: MarkItemRecoveredUseCase(fakeRecoveryRepo),
          reportsChangedNotifier: ReportsChangedNotifier(),
        ),
      );
    });

    tearDown(() {
      sl.reset();
    });

    testWidgets('renders report details, gallery, chips, title and claim button for non-owner',
        (tester) async {
      fakeReportsRepo.isOwner = false;

      await pumpTestApp(
        tester,
        const ReportDetailsScreen(reportId: 'rep_1'),
        padded: false,
      );
      await tester.pumpAndSettle();

      expect(find.text('Lost Leather Wallet'), findsOneWidget);
      expect(find.text('#RPT-1001'), findsOneWidget);
      expect(find.byType(StatusChip), findsNWidgets(2));
      expect(find.text('Black leather wallet with cards'), findsOneWidget);
      expect(find.text('I Found This'), findsOneWidget);
    });

    testWidgets('renders edit icon in AppBar when user is owner', (tester) async {
      fakeReportsRepo.isOwner = true;

      await pumpTestApp(
        tester,
        const ReportDetailsScreen(reportId: 'rep_1'),
        padded: false,
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.text('I Found This'), findsNothing);
    });

    testWidgets('renders not found state when report does not exist', (tester) async {
      fakeReportsRepo.notFound = true;

      await pumpTestApp(
        tester,
        const ReportDetailsScreen(reportId: 'rep_missing'),
        padded: false,
      );
      await tester.pumpAndSettle();

      expect(find.text('Report not found'), findsOneWidget);
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
    });
  });
}
