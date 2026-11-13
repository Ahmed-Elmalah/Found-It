import 'package:flutter_test/flutter_test.dart';

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
import 'package:found_it/features/reports/view/cubit/edit_report_state.dart';

class _FakeEditReportsRepo implements ReportsRepository {
  bool shouldFailInit = false;
  bool shouldFailUpdate = false;

  final categories = const [
    CategoryEntity(id: 'cat_1', nameEn: 'Wallets', nameAr: 'محافظ', icon: 'wallet'),
    CategoryEntity(id: 'cat_2', nameEn: 'Keys', nameAr: 'مفاتيح', icon: 'key'),
  ];

  final areas = const [
    AreaEntity(id: 'area_1', cityId: 'city_cairo', nameEn: 'Maadi', nameAr: 'المعادي'),
    AreaEntity(id: 'area_2', cityId: 'city_cairo', nameEn: 'Zamalek', nameAr: 'الزمالك'),
  ];

  String? lastUpdatedTitle;

  @override
  Future<List<CategoryEntity>> getCategories() async {
    if (shouldFailInit) throw Exception('Failed to load categories');
    return categories;
  }

  @override
  Future<List<AreaEntity>> getCityAreas({required String cityId, required String lang}) async {
    if (shouldFailInit) throw Exception('Failed to load areas');
    return areas;
  }

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
    if (shouldFailUpdate) throw Exception('Update failed');
    lastUpdatedTitle = title;
    return ReportEntity(
      id: reportId,
      refCode: '#RPT-1001',
      userId: 'user_1',
      cityId: 'city_cairo',
      areaId: areaId ?? 'area_1',
      categoryId: categoryId ?? 'cat_1',
      title: title ?? 'Updated Title',
      description: description,
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
  group('EditReportCubit', () {
    late _FakeEditReportsRepo repo;
    late ReportEntity initialReport;
    late EditReportCubit cubit;

    setUp(() {
      repo = _FakeEditReportsRepo();
      initialReport = ReportEntity(
        id: 'rep_1',
        refCode: '#RPT-1001',
        userId: 'user_1',
        cityId: 'city_cairo',
        areaId: 'area_1',
        categoryId: 'cat_1',
        title: 'Original Title',
        description: 'Original Description',
        type: 'lost',
        status: 'active',
        itemDate: DateTime(2026, 11, 1),
        createdAt: DateTime(2026, 11, 1),
        updatedAt: DateTime(2026, 11, 1),
        images: const [],
      );

      cubit = EditReportCubit(
        initialReport,
        UpdateReportUseCase(repo),
        GetCategoriesUseCase(repo),
        GetCityAreasUseCase(repo),
      );
    });

    tearDown(() => cubit.close());

    test('initial state takes values from report', () {
      expect(cubit.state.report, initialReport);
      expect(cubit.state.selectedType, 'lost');
      expect(cubit.state.selectedCategoryId, 'cat_1');
      expect(cubit.state.selectedAreaId, 'area_1');
      expect(cubit.state.selectedDate, initialReport.itemDate);
      expect(cubit.state.status, EditReportStatus.initial);
    });

    test('init loads categories and areas successfully', () async {
      await cubit.init();

      expect(cubit.state.status, EditReportStatus.ready);
      expect(cubit.state.categories.length, 2);
      expect(cubit.state.areas.length, 2);
    });

    test('init sets failure status on error', () async {
      repo.shouldFailInit = true;

      await cubit.init();

      expect(cubit.state.status, EditReportStatus.failure);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('field change methods update selected values in state', () {
      cubit.typeChanged('found');
      expect(cubit.state.selectedType, 'found');

      cubit.categoryChanged('cat_2');
      expect(cubit.state.selectedCategoryId, 'cat_2');

      cubit.areaChanged('area_2');
      expect(cubit.state.selectedAreaId, 'area_2');

      final newDate = DateTime(2026, 11, 5);
      cubit.dateChanged(newDate);
      expect(cubit.state.selectedDate, newDate);
    });

    test('submit updates report successfully', () async {
      final success = await cubit.submit(
        title: 'New Wallet Title',
        description: 'Brown leather',
      );

      expect(success, isTrue);
      expect(repo.lastUpdatedTitle, 'New Wallet Title');
      expect(cubit.state.status, EditReportStatus.success);
      expect(cubit.state.report.title, 'New Wallet Title');
    });

    test('submit emits failure state when repo throws', () async {
      repo.shouldFailUpdate = true;

      final success = await cubit.submit(title: 'Failing Title');

      expect(success, isFalse);
      expect(cubit.state.status, EditReportStatus.failure);
      expect(cubit.state.errorMessage, contains('Update failed'));
    });
  });
}
