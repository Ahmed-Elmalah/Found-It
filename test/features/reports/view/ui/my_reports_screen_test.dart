import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/widgets/status_chip.dart';
import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/entities/create_report_params.dart';
import 'package:found_it/features/reports/domain/entities/manual_match_result_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_counts_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_details_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_question_entity.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';
import 'package:found_it/features/reports/domain/use_cases/get_categories_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_city_areas_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_my_reports_counts_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_my_reports_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_report_details_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/soft_delete_report_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/update_report_use_case.dart';
import 'package:found_it/features/reports/view/cubit/edit_report_cubit.dart';
import 'package:found_it/features/reports/view/cubit/my_reports_cubit.dart';
import 'package:found_it/features/reports/view/ui/edit_report_screen.dart';
import 'package:found_it/features/reports/view/ui/my_reports_screen.dart';
import 'package:found_it/features/reports/view/widgets/filter_tabs.dart';
import 'package:found_it/features/reports/view/widgets/my_report_card.dart';

import '../../../../helpers/test_app.dart';

class _FakeReportsRepo implements ReportsRepository {
  _FakeReportsRepo({List<ReportEntity>? reports})
      : reports = reports ?? [];

  final List<ReportEntity> reports;
  ReportDetailsEntity? detailsToReturn;

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
  Future<List<CategoryEntity>> getCategories() async => const [
        CategoryEntity(id: 'cat_1', nameEn: 'Wallet', nameAr: 'محفظة', icon: 'wallet'),
      ];

  @override
  Future<List<AreaEntity>> getCityAreas({required String cityId, required String lang}) async =>
      const [
        AreaEntity(id: 'area_1', cityId: 'city_cairo', nameEn: 'Maadi', nameAr: 'المعادي'),
      ];

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
    String? privateDetails,
    List<Map<String, dynamic>>? questions,
  }) async =>
      ReportEntity(
        id: reportId,
        refCode: '#RPT-1001',
        userId: 'user_1',
        cityId: 'city_cairo',
        areaId: areaId ?? 'area_1',
        categoryId: categoryId ?? 'cat_1',
        title: title ?? 'Title',
        type: type ?? 'lost',
        status: 'active',
        itemDate: itemDate ?? DateTime(2026, 11, 10),
        createdAt: DateTime(2026, 11, 10),
        updatedAt: DateTime(2026, 11, 10),
        images: const [],
      );

  @override
  Future<ReportDetailsEntity> getReportDetails(String reportId) async {
    if (detailsToReturn != null) return detailsToReturn!;
    throw UnimplementedError();
  }

  @override
  Future<ManualMatchResultEntity> createManualMatch(String reportId) =>
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

      expect(find.byType(MyReportCard), findsOneWidget);
      expect(find.byType(StatusChip), findsNWidgets(2));
      expect(find.text('Lost'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MyReportCard),
          matching: find.text('Active'),
        ),
        findsOneWidget,
      );
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

      expect(find.byType(StatusChip), findsNWidgets(2));
      expect(
        find.descendant(
          of: find.byType(MyReportCard),
          matching: find.text('Recovered'),
        ),
        findsOneWidget,
      );
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete Report'), findsNothing);

      await cubit.close();
    });

    testWidgets('editing a Found report with questions from My Reports loads full questions in edit form', (tester) async {
      final report = ReportEntity(
        id: 'rep_1',
        refCode: '#RPT-1001',
        userId: 'user_1',
        type: 'found',
        title: 'Found Keys with Red Lanyard',
        categoryId: 'cat_1',
        cityId: 'city_cairo',
        areaId: 'area_1',
        itemDate: DateTime(2026, 11, 20),
        images: const [],
        status: 'active',
        createdAt: DateTime(2026, 11, 20),
        updatedAt: DateTime(2026, 11, 20),
        isMine: true,
      );

      final repo = _FakeReportsRepo(reports: [report]);
      repo.detailsToReturn = ReportDetailsEntity(
        id: 'rep_1',
        refCode: '#RPT-1001',
        type: 'found',
        title: 'Found Keys with Red Lanyard',
        categoryId: 'cat_1',
        cityId: 'city_cairo',
        areaId: 'area_1',
        itemDate: DateTime(2026, 11, 20),
        images: const [],
        status: 'active',
        isMine: true,
        ownerName: 'Me',
        hasPrivateDetails: true,
        privateDetails: 'Small scratch near ring',
        hasQuestions: true,
        questionsCount: 1,
        questions: const [
          ReportQuestionEntity(
            id: 'q_1',
            position: 1,
            question: 'What color is the lanyard?',
            correct: 'Red',
            wrong: ['Blue', 'Black'],
          ),
        ],
        createdAt: DateTime(2026, 11, 20),
        updatedAt: DateTime(2026, 11, 20),
      );

      final cubit = MyReportsCubit(
        GetMyReportsUseCase(repo),
        GetMyReportsCountsUseCase(repo),
        SoftDeleteReportUseCase(repo),
        GetReportDetailsUseCase(repo),
      );
      addTearDown(cubit.close);

      final router = GoRouter(
        initialLocation: AppRoutes.myReports,
        routes: [
          GoRoute(
            path: AppRoutes.myReports,
            builder: (_, _) => BlocProvider<MyReportsCubit>.value(
              value: cubit,
              child: const MyReportsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.editReport,
            builder: (_, state) {
              final rep = state.extra! as ReportEntity;
              final editCubit = EditReportCubit(
                rep,
                UpdateReportUseCase(repo),
                GetCategoriesUseCase(repo),
                GetCityAreasUseCase(repo),
              );
              return BlocProvider.value(
                value: editCubit,
                child: EditReportScreen(report: rep),
              );
            },
          ),
        ],
      );

      await pumpTestRouterApp(tester, router);
      await tester.pumpAndSettle();

      final editButton = find.widgetWithText(OutlinedButton, 'Edit');
      expect(editButton, findsOneWidget);
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      expect(find.byType(EditReportScreen), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('What color is the lanyard?'), findsOneWidget);
      expect(find.text('Red'), findsOneWidget);
      expect(find.text('Blue'), findsOneWidget);
      expect(find.text('Black'), findsOneWidget);
    });
  });
}
