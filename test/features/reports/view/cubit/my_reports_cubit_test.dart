import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/entities/create_report_params.dart';
import 'package:found_it/features/reports/domain/entities/report_counts_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_failure.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';
import 'package:found_it/features/reports/domain/use_cases/get_my_reports_counts_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_my_reports_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/soft_delete_report_use_case.dart';
import 'package:found_it/features/reports/view/cubit/my_reports_cubit.dart';
import 'package:found_it/features/reports/view/cubit/my_reports_state.dart';

class _FakeReportsRepo implements ReportsRepository {
  bool shouldFailReports = false;
  bool shouldFailCounts = false;
  bool shouldFailDelete = false;

  String? deletedReportId;
  String? queriedStatus;

  final testReports = [
    ReportEntity(
      id: 'rep_1',
      refCode: '#RPT-1001',
      userId: 'user_1',
      cityId: 'city_cairo',
      areaId: 'area_1',
      categoryId: 'cat_1',
      title: 'Lost Keys',
      description: 'Keychain with BMW logo',
      type: 'lost',
      status: 'active',
      itemDate: DateTime(2026, 11, 10),
      createdAt: DateTime(2026, 11, 10),
      updatedAt: DateTime(2026, 11, 10),
      images: const ['https://example.com/image.jpg'],
    ),
  ];

  final testCounts = const ReportCountsEntity(
    total: 5,
    active: 2,
    matching: 2,
    recovered: 1,
  );

  @override
  Future<List<ReportEntity>> getMyReports({String? status}) async {
    if (shouldFailReports) throw const ReportFailure(ReportFailureType.network);
    queriedStatus = status;
    if (status == null) return testReports;
    return testReports.where((r) => r.status == status).toList();
  }

  @override
  Future<ReportCountsEntity> getMyReportsCounts() async {
    if (shouldFailCounts) throw const ReportFailure(ReportFailureType.network);
    return testCounts;
  }

  @override
  Future<void> softDeleteReport(String reportId) async {
    if (shouldFailDelete) throw const ReportFailure(ReportFailureType.invalidData);
    deletedReportId = reportId;
  }

  @override
  Future<String> createReport(CreateReportParams params) => throw UnimplementedError();

  @override
  Future<List<CategoryEntity>> getCategories() => throw UnimplementedError();

  @override
  Future<List<AreaEntity>> getCityAreas({required String cityId, required String lang}) =>
      throw UnimplementedError();

  @override
  Future<String> getSelectedCityId() async => 'city_cairo';

  @override
  Future<ReportEntity> updateReport({
    required String reportId,
    String? title,
    String? description,
    String? type,
    String? categoryId,
    String? areaId,
    DateTime? itemDate,
  }) =>
      throw UnimplementedError();
}

void main() {
  group('MyReportsCubit', () {
    late _FakeReportsRepo repo;
    late MyReportsCubit cubit;

    setUp(() {
      repo = _FakeReportsRepo();
      cubit = MyReportsCubit(
        GetMyReportsUseCase(repo),
        GetMyReportsCountsUseCase(repo),
        SoftDeleteReportUseCase(repo),
      );
    });

    tearDown(() => cubit.close());

    test('initial state has initial status and all filter', () {
      expect(cubit.state.status, MyReportsStatus.initial);
      expect(cubit.state.selectedFilter, MyReportsFilter.all);
      expect(cubit.state.reports, isEmpty);
      expect(cubit.state.counts, const ReportCountsEntity.empty());
      expect(cubit.state.failure, isNull);
    });

    test('loadReports loads reports and counts successfully', () async {
      await cubit.loadReports();

      expect(cubit.state.status, MyReportsStatus.success);
      expect(cubit.state.reports.length, 1);
      expect(cubit.state.counts.total, 5);
      expect(cubit.state.counts.active, 2);
      expect(repo.queriedStatus, isNull);
    });

    test('loadReports emits failure state with typed failure when repo fails', () async {
      repo.shouldFailReports = true;

      await cubit.loadReports();

      expect(cubit.state.status, MyReportsStatus.failure);
      expect(cubit.state.failure, ReportFailureType.network);
    });

    test('setFilter updates filter and passes status to repo', () async {
      cubit.setFilter(MyReportsFilter.active);
      await pumpEventQueue();

      expect(cubit.state.selectedFilter, MyReportsFilter.active);
      expect(repo.queriedStatus, 'active');

      cubit.setFilter(MyReportsFilter.matching);
      await pumpEventQueue();
      expect(cubit.state.selectedFilter, MyReportsFilter.matching);
      expect(repo.queriedStatus, 'matching');

      cubit.setFilter(MyReportsFilter.recovered);
      await pumpEventQueue();
      expect(cubit.state.selectedFilter, MyReportsFilter.recovered);
      expect(repo.queriedStatus, 'recovered');
    });

    test('deleteReport calls softDelete and reloads reports on success', () async {
      await cubit.loadReports();
      expect(cubit.state.reports.length, 1);

      final success = await cubit.deleteReport('rep_1');

      expect(success, isTrue);
      expect(repo.deletedReportId, 'rep_1');
      expect(cubit.state.isDeleting, isFalse);
      expect(cubit.state.status, MyReportsStatus.success);
    });

    test('deleteReport returns false and sets typed failure on failure', () async {
      repo.shouldFailDelete = true;

      final success = await cubit.deleteReport('rep_1');

      expect(success, isFalse);
      expect(cubit.state.isDeleting, isFalse);
      expect(cubit.state.failure, ReportFailureType.invalidData);
    });
  });
}
