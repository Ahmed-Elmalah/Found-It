import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/entities/create_report_params.dart';
import 'package:found_it/features/reports/domain/entities/report_counts_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';
import 'package:found_it/features/reports/domain/use_cases/get_categories_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_city_areas_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/update_report_use_case.dart';
import 'package:found_it/features/reports/view/cubit/edit_report_cubit.dart';
import 'package:found_it/features/reports/view/ui/edit_report_screen.dart';

import '../../../../helpers/test_app.dart';

class _FakeEditRepo implements ReportsRepository {
  String? updatedTitle;

  final categories = const [
    CategoryEntity(id: 'cat_1', nameEn: 'Wallet', nameAr: 'محفظة', icon: 'wallet'),
  ];

  final areas = const [
    AreaEntity(id: 'area_1', cityId: 'city_cairo', nameEn: 'Maadi', nameAr: 'المعادي'),
  ];

  @override
  Future<List<CategoryEntity>> getCategories() async => categories;

  @override
  Future<List<AreaEntity>> getCityAreas({required String cityId, required String lang}) async =>
      areas;

  @override
  Future<ReportEntity> updateReport({
    required String reportId,
    String? title,
    String? description,
    String? type,
    String? categoryId,
    String? areaId,
    DateTime? itemDate,
  }) async {
    updatedTitle = title;
    return ReportEntity(
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
  }

  @override
  Future<String> createReport(CreateReportParams params) => throw UnimplementedError();
  @override
  Future<List<ReportEntity>> getMyReports({String? status}) => throw UnimplementedError();
  @override
  Future<ReportCountsEntity> getMyReportsCounts() => throw UnimplementedError();
  @override
  Future<String> getSelectedCityId() async => 'city_cairo';
  @override
  Future<void> softDeleteReport(String reportId) => throw UnimplementedError();
}

void main() {
  group('EditReportScreen Widget Test', () {
    late ReportEntity report;
    late _FakeEditRepo repo;
    late EditReportCubit cubit;

    setUp(() {
      report = ReportEntity(
        id: 'rep_1',
        refCode: '#RPT-1001',
        userId: 'user_1',
        cityId: 'city_cairo',
        areaId: 'area_1',
        categoryId: 'cat_1',
        title: 'Black Leather Wallet',
        description: 'Lost near subway',
        type: 'lost',
        status: 'active',
        itemDate: DateTime(2026, 11, 10),
        createdAt: DateTime(2026, 11, 10),
        updatedAt: DateTime(2026, 11, 10),
        images: const [],
      );

      repo = _FakeEditRepo();
      cubit = EditReportCubit(
        report,
        UpdateReportUseCase(repo),
        GetCategoriesUseCase(repo),
        GetCityAreasUseCase(repo),
      );
    });

    tearDown(() => cubit.close());

    testWidgets('renders initial report data and labels', (tester) async {
      await pumpTestApp(
        tester,
        BlocProvider<EditReportCubit>.value(
          value: cubit,
          child: EditReportScreen(report: report),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Report'), findsOneWidget);
      expect(find.text('Black Leather Wallet'), findsOneWidget);
      expect(find.text('Lost near subway'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('validates title length: < 3 shows too short, > 50 shows too long', (tester) async {
      await pumpTestApp(
        tester,
        BlocProvider<EditReportCubit>.value(
          value: cubit,
          child: EditReportScreen(report: report),
        ),
      );
      await tester.pumpAndSettle();

      final titleFinder = find.byType(TextField).first;

      // Test title too short (< 3)
      await tester.enterText(titleFinder, 'ab');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(find.text('Title must be at least 3 characters'), findsOneWidget);

      // Test title too long (> 50)
      final tooLongText = 'A' * 51;
      await tester.enterText(titleFinder, tooLongText);
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(find.text('Title must be at most 50 characters'), findsOneWidget);
    });

    testWidgets('submitting valid changes updates report', (tester) async {
      final router = GoRouter(
        initialLocation: '/reports/edit',
        routes: [
          GoRoute(
            path: '/reports',
            builder: (_, _) => const Scaffold(body: Text('Reports Page')),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (_, _) => BlocProvider<EditReportCubit>.value(
                  value: cubit,
                  child: EditReportScreen(report: report),
                ),
              ),
            ],
          ),
        ],
      );
      await pumpTestRouterApp(tester, router);
      await tester.pumpAndSettle();

      final titleFinder = find.byType(TextField).first;
      await tester.enterText(titleFinder, 'Updated Brown Wallet');

      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(repo.updatedTitle, 'Updated Brown Wallet');
    });
  });
}
