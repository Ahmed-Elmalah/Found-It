import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/widgets/error_banner.dart';
import 'package:found_it/features/reports/data/services/photo_picker_service.dart';
import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/entities/create_report_params.dart';
import 'package:found_it/features/reports/domain/entities/report_counts_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_failure.dart';
import 'package:found_it/features/reports/domain/entities/report_image.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';
import 'package:found_it/features/reports/domain/use_cases/create_report_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_categories_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_city_areas_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_selected_city_id_use_case.dart';
import 'package:found_it/features/reports/view/cubit/create_report_cubit.dart';
import 'package:found_it/features/reports/view/ui/create_report_screen.dart';
import 'package:found_it/features/reports/view/ui/report_created_screen.dart';

import '../../../../helpers/test_app.dart';

class _FakeReportsRepository implements ReportsRepository {
  final List<CategoryEntity> categories = const [
    CategoryEntity(id: 'cat_1', nameEn: 'Wallet', nameAr: 'محفظة', icon: 'wallet'),
  ];
  final List<AreaEntity> areas = const [
    AreaEntity(id: 'area_1', cityId: 'city_cairo', nameEn: 'Zamalek', nameAr: 'الزمالك'),
  ];
  final String cityId = 'city_cairo';
  final String returnedRefCode = '#RPT-1001';
  final bool shouldFail;

  _FakeReportsRepository({this.shouldFail = false});

  @override
  Future<List<CategoryEntity>> getCategories() async {
    if (shouldFail) throw const ReportFailure(ReportFailureType.network);
    return categories;
  }

  @override
  Future<List<AreaEntity>> getCityAreas({required String cityId, required String lang}) async {
    if (shouldFail) throw const ReportFailure(ReportFailureType.network);
    return areas;
  }

  @override
  Future<String> getSelectedCityId() async {
    if (shouldFail) throw const ReportFailure(ReportFailureType.network);
    return cityId;
  }

  @override
  Future<String> createReport(CreateReportParams params) async {
    if (shouldFail) throw const ReportFailure(ReportFailureType.invalidData);
    return returnedRefCode;
  }

  @override
  Future<List<ReportEntity>> getMyReports({String? status}) async => const [];

  @override
  Future<ReportCountsEntity> getMyReportsCounts() async =>
      const ReportCountsEntity.empty();

  @override
  Future<void> softDeleteReport(String reportId) async {}

  @override
  Future<ReportEntity> updateReport({
    required String reportId,
    String? title,
    String? description,
    String? type,
    String? categoryId,
    String? areaId,
    DateTime? itemDate,
  }) async =>
      throw UnimplementedError();
}

class _FakePhotoPickerService implements PhotoPickerService {
  ReportImage? photoToReturn;

  @override
  Future<ReportImage?> pickImage({required ImageSource source}) async => photoToReturn;
}

Future<CreateReportCubit> _pump(
  WidgetTester tester, {
  _FakePhotoPickerService? photoPicker,
  _FakeReportsRepository? repository,
  String initialLocation = AppRoutes.createReport,
  bool dark = false,
  bool rtl = false,
}) async {
  final repo = repository ?? _FakeReportsRepository();
  final picker = photoPicker ?? _FakePhotoPickerService();
  final cubit = CreateReportCubit(
    getCategories: GetCategoriesUseCase(repo),
    getCityAreas: GetCityAreasUseCase(repo),
    getSelectedCityId: GetSelectedCityIdUseCase(repo),
    createReport: CreateReportUseCase(repo),
    photoPicker: picker,
  );
  addTearDown(cubit.close);

  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.createReport,
        builder: (_, _) => BlocProvider.value(
          value: cubit,
          child: const CreateReportScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.reportCreated,
        redirect: (context, state) {
          final extra = state.extra;
          if (extra is! String || extra.isEmpty) {
            return AppRoutes.home;
          }
          return null;
        },
        builder: (_, state) {
          final id = state.extra! as String;
          return ReportCreatedScreen(referenceId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, _) => const Scaffold(body: Text('HOME PAGE')),
      ),
    ],
  );

  await pumpTestRouterApp(tester, router, dark: dark, rtl: rtl);
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  testWidgets('initial render (P23) displays all fields and labels', (tester) async {
    await _pump(tester);

    expect(find.text('Create report'), findsOneWidget);
    expect(find.text('Lost'), findsOneWidget);
    expect(find.text('Found'), findsOneWidget);
    expect(find.textContaining('Item title'), findsOneWidget);
    expect(find.textContaining('Category'), findsOneWidget);
    expect(find.textContaining('Location (district)'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.textContaining('Photos'), findsOneWidget);
    expect(find.text('Submit report'), findsOneWidget);
    expect(find.byType(ErrorBanner), findsNothing);
  });

  testWidgets('submitting empty form displays Required Fields banner (P25)', (tester) async {
    await _pump(tester);

    // Tap submit button
    await tester.tap(find.text('Submit report'));
    await tester.pumpAndSettle();

    // Banner is visible
    expect(find.byType(ErrorBanner), findsOneWidget);
    expect(find.textContaining('Required Fields:'), findsOneWidget);
    expect(find.textContaining('Title, category, and location are required.'), findsOneWidget);
  });

  testWidgets('picking invalid photo shows Invalid File banner (P26)', (tester) async {
    final picker = _FakePhotoPickerService();
    picker.photoToReturn = ReportImage(
      name: 'bad_image.webp',
      bytes: Uint8List.fromList([1, 2, 3]),
    );

    final cubit = await _pump(tester, photoPicker: picker);

    // Pick photo
    await cubit.pickPhoto(ImageSource.gallery);
    await tester.pumpAndSettle();

    // Banner should be Invalid File
    expect(find.byType(ErrorBanner), findsOneWidget);
    expect(find.textContaining('Invalid File:'), findsOneWidget);
    expect(find.text('Rejected'), findsOneWidget);
  });

  testWidgets('successful submission navigates to ReportCreatedScreen (P27)', (tester) async {
    final picker = _FakePhotoPickerService();
    final cubit = await _pump(tester, photoPicker: picker);

    await cubit.loadInitialData();
    cubit.updateTitle('MacBook Air M2');
    cubit.selectCategory('cat_1');
    cubit.selectDistrict('area_1');

    picker.photoToReturn = ReportImage(
      name: 'photo.jpg',
      bytes: Uint8List.fromList([1, 2, 3]),
    );
    await cubit.pickPhoto(ImageSource.gallery);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit report'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Report Created Successfully!'), findsOneWidget);
    expect(find.textContaining('#RPT-1001'), findsOneWidget);
    expect(find.text('View my report'), findsOneWidget);
    expect(find.text('Back to home'), findsOneWidget);
  });

  testWidgets('initialDataFailure shows translated ErrorBanner and retry button', (tester) async {
    final failingRepo = _FakeReportsRepository(shouldFail: true);
    await _pump(tester, repository: failingRepo);

    expect(find.byType(ErrorBanner), findsOneWidget);
    expect(find.textContaining('Connection error:'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('reportCreated route redirects to home if extra is missing', (tester) async {
    await _pump(tester, initialLocation: AppRoutes.reportCreated);

    expect(find.text('HOME PAGE'), findsOneWidget);
  });
}
