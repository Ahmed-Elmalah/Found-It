import 'package:flutter_test/flutter_test.dart';

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
import 'package:found_it/features/reports/view/cubit/report_details_state.dart';

class _FakeReportsRepository implements ReportsRepository {
  bool shouldFailReport = false;
  ReportFailureType reportFailureType = ReportFailureType.network;
  bool shouldFailClaim = false;
  ReportFailureType claimFailureType = ReportFailureType.network;

  ReportDetailsEntity testReport = ReportDetailsEntity(
    id: 'rep_123',
    refCode: '#RPT-1234',
    ownerName: 'Ahmed',
    cityId: 'city_cairo',
    cityNameEn: 'Cairo',
    cityNameAr: 'القاهرة',
    areaId: 'area_1',
    areaNameEn: 'Nasr City',
    areaNameAr: 'مدينة نصر',
    categoryId: 'cat_wallet',
    categoryNameEn: 'Wallet',
    categoryNameAr: 'محفظة',
    categoryIcon: 'wallet',
    title: 'Black leather wallet',
    description: 'Found near metro station',
    type: 'found',
    status: 'active',
    itemDate: DateTime(2026, 11, 20),
    createdAt: DateTime(2026, 11, 20),
    updatedAt: DateTime(2026, 11, 20),
    images: const ['https://example.com/wallet.jpg'],
    isMine: false,
    hasPrivateDetails: true,
    privateDetails: null,
    hasQuestions: false,
    questionsCount: 0,
    questions: const [],
    iAmBlocked: false,
    myMatchId: null,
    myMatchStatus: null,
  );

  ManualMatchResultEntity testManualMatch = const ManualMatchResultEntity(
    matchId: 'match_999',
    status: 'pending',
    claimStatus: 'pending',
    isNew: true,
  );

  @override
  Future<ReportDetailsEntity> getReportDetails(String reportId) async {
    if (shouldFailReport) throw ReportFailure(reportFailureType);
    return testReport;
  }

  @override
  Future<ManualMatchResultEntity> createManualMatch(String reportId) async {
    if (shouldFailClaim) throw ReportFailure(claimFailureType);
    return testManualMatch;
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

void main() {
  group('ReportDetailsCubit', () {
    late _FakeReportsRepository repo;
    late ReportDetailsCubit cubit;

    setUp(() {
      repo = _FakeReportsRepository();
      cubit = ReportDetailsCubit(
        GetReportDetailsUseCase(repo),
        CreateManualMatchUseCase(repo),
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is ReportDetailsStatus.initial', () {
      expect(cubit.state.status, equals(ReportDetailsStatus.initial));
      expect(cubit.state.report, isNull);
      expect(cubit.state.isLoading, isFalse);
    });

    test('loadReport emits [loading, success] on successful load', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<ReportDetailsState>((s) => s.status == ReportDetailsStatus.loading),
          predicate<ReportDetailsState>(
            (s) => s.status == ReportDetailsStatus.success && s.report?.id == 'rep_123',
          ),
        ]),
      );

      await cubit.loadReport('rep_123');
      await expectation;

      expect(cubit.state.status, equals(ReportDetailsStatus.success));
      expect(cubit.state.report?.id, equals('rep_123'));
      expect(cubit.state.report?.isMine, isFalse);
      expect(cubit.state.report?.hasPrivateDetails, isTrue);
    });

    test('loadReport emits [loading, failure] on notFound failure', () async {
      repo.shouldFailReport = true;
      repo.reportFailureType = ReportFailureType.notFound;

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<ReportDetailsState>((s) => s.status == ReportDetailsStatus.loading),
          predicate<ReportDetailsState>(
            (s) => s.status == ReportDetailsStatus.failure && s.isNotFound,
          ),
        ]),
      );

      await cubit.loadReport('rep_not_found');
      await expectation;

      expect(cubit.state.status, equals(ReportDetailsStatus.failure));
      expect(cubit.state.failure, equals(ReportFailureType.notFound));
      expect(cubit.state.isNotFound, isTrue);
    });

    test('claimReport emits [loading, success] with match result', () async {
      await cubit.loadReport('rep_123');

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<ReportDetailsState>((s) => s.claimStatus == ClaimStatus.loading),
          predicate<ReportDetailsState>(
            (s) => s.claimStatus == ClaimStatus.success && s.claimResult?.matchId == 'match_999',
          ),
        ]),
      );

      await cubit.claimReport();
      await expectation;

      expect(cubit.state.claimStatus, equals(ClaimStatus.success));
      expect(cubit.state.claimResult?.matchId, equals('match_999'));
      expect(cubit.state.claimResult?.isClaimPending, isTrue);
    });

    test('claimReport emits [loading, failure] when claim fails', () async {
      await cubit.loadReport('rep_123');

      repo.shouldFailClaim = true;
      repo.claimFailureType = ReportFailureType.notAllowed;

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<ReportDetailsState>((s) => s.claimStatus == ClaimStatus.loading),
          predicate<ReportDetailsState>(
            (s) => s.claimStatus == ClaimStatus.failure && s.claimFailure == ReportFailureType.notAllowed,
          ),
        ]),
      );

      await cubit.claimReport();
      await expectation;

      expect(cubit.state.claimStatus, equals(ClaimStatus.failure));
      expect(cubit.state.claimFailure, equals(ReportFailureType.notAllowed));
    });

    test('refresh reloads report details', () async {
      await cubit.loadReport('rep_123');
      expect(cubit.state.status, equals(ReportDetailsStatus.success));

      await cubit.refresh();
      expect(cubit.state.status, equals(ReportDetailsStatus.success));
    });
  });
}
