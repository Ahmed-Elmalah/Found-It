import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/entities/create_report_params.dart';
import 'package:found_it/features/reports/domain/entities/report_counts_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';
import 'package:found_it/features/reports/domain/use_cases/get_my_reports_counts_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_my_reports_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/soft_delete_report_use_case.dart';
import 'package:found_it/features/reports/view/cubit/my_reports_cubit.dart';
import 'package:found_it/features/reports/view/ui/my_reports_screen.dart';
import 'package:found_it/features/reports/view/widgets/filter_tabs.dart';
import 'package:found_it/features/reports/view/widgets/report_card.dart';

import '../../../../helpers/test_app.dart';

class _FakeReportsRepo implements ReportsRepository {
  _FakeReportsRepo({List<ReportEntity>? reports})
      : reports = reports ?? [];

  final List<ReportEntity> reports;

  @override
  Future<List<ReportEntity>> getMyReports({String? status}) async => reports;

  @override
  Future<ReportCountsEntity> getMyReportsCounts() async => ReportCountsEntity(
        total: reports.length,
        active: reports.where((r) => r.status == 'active').length,
        matching: reports.where((r) => r.status == 'matching').length,
        recovered: reports.where((r) => r.status == 'recovered').length,
      );

  @override
  Future<void> softDeleteReport(String reportId) async {
    reports.removeWhere((r) => r.id == reportId);
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
  group('MyReportsScreen Widget Test', () {
    testWidgets('displays title, filter tabs and empty state when no reports', (tester) async {
      final repo = _FakeReportsRepo(reports: []);
      final cubit = MyReportsCubit(
        GetMyReportsUseCase(repo),
        GetMyReportsCountsUseCase(repo),
        SoftDeleteReportUseCase(repo),
      );

      await pumpTestApp(
        tester,
        BlocProvider<MyReportsCubit>.value(
          value: cubit,
          child: const MyReportsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Reports'), findsOneWidget);
      expect(find.byType(FilterTabs), findsOneWidget);
      expect(find.text('No reports yet'), findsOneWidget);
      expect(find.text('Reports you publish will appear here.'), findsOneWidget);

      await cubit.close();
    });

    testWidgets('displays report cards when reports are available', (tester) async {
      final reports = [
        ReportEntity(
          id: 'rep_1',
          refCode: '#RPT-1001',
          userId: 'user_1',
          cityId: 'city_cairo',
          areaId: 'area_1',
          categoryId: 'cat_1',
          title: 'Black Leather Wallet',
          description: 'Contains national ID',
          type: 'lost',
          status: 'active',
          itemDate: DateTime(2026, 11, 10),
          createdAt: DateTime(2026, 11, 10),
          updatedAt: DateTime(2026, 11, 10),
          images: const [],
        ),
      ];

      final repo = _FakeReportsRepo(reports: reports);
      final cubit = MyReportsCubit(
        GetMyReportsUseCase(repo),
        GetMyReportsCountsUseCase(repo),
        SoftDeleteReportUseCase(repo),
      );

      await pumpTestApp(
        tester,
        BlocProvider<MyReportsCubit>.value(
          value: cubit,
          child: const MyReportsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ReportCard), findsOneWidget);
      expect(find.text('Black Leather Wallet'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete Report'), findsOneWidget);

      await cubit.close();
    });

    testWidgets('delete flow opens dialog, deletes report, and refreshes list', (tester) async {
      final reports = [
        ReportEntity(
          id: 'rep_1',
          refCode: '#RPT-1001',
          userId: 'user_1',
          cityId: 'city_cairo',
          areaId: 'area_1',
          categoryId: 'cat_1',
          title: 'Black Leather Wallet',
          type: 'lost',
          status: 'active',
          itemDate: DateTime(2026, 11, 10),
          createdAt: DateTime(2026, 11, 10),
          updatedAt: DateTime(2026, 11, 10),
          images: const [],
        ),
      ];

      final repo = _FakeReportsRepo(reports: reports);
      final cubit = MyReportsCubit(
        GetMyReportsUseCase(repo),
        GetMyReportsCountsUseCase(repo),
        SoftDeleteReportUseCase(repo),
      );

      await pumpTestApp(
        tester,
        BlocProvider<MyReportsCubit>.value(
          value: cubit,
          child: const MyReportsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Black Leather Wallet'), findsOneWidget);
      expect(find.text('Delete Report'), findsOneWidget);

      // Tap Delete Report button
      await tester.tap(find.text('Delete Report'));
      await tester.pumpAndSettle();

      // Delete dialog should be open with P22 texts
      expect(find.text('Delete this report?'), findsOneWidget);
      expect(find.text('Your report will be removed from public search results.'), findsOneWidget);

      // Confirm delete in dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // List refreshed and item removed from repo
      expect(repo.reports.isEmpty, isTrue);
      expect(find.text('No reports yet'), findsOneWidget);

      await cubit.close();
    });

    testWidgets('recovered report does not show delete button', (tester) async {
      final reports = [
        ReportEntity(
          id: 'rep_2',
          refCode: '#RPT-1002',
          userId: 'user_1',
          cityId: 'city_cairo',
          areaId: 'area_1',
          categoryId: 'cat_1',
          title: 'Recovered Keys',
          type: 'lost',
          status: 'recovered',
          itemDate: DateTime(2026, 11, 10),
          createdAt: DateTime(2026, 11, 10),
          updatedAt: DateTime(2026, 11, 10),
          images: const [],
        ),
      ];

      final repo = _FakeReportsRepo(reports: reports);
      final cubit = MyReportsCubit(
        GetMyReportsUseCase(repo),
        GetMyReportsCountsUseCase(repo),
        SoftDeleteReportUseCase(repo),
      );

      await pumpTestApp(
        tester,
        BlocProvider<MyReportsCubit>.value(
          value: cubit,
          child: const MyReportsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete Report'), findsNothing);

      await cubit.close();
    });
  });
}
