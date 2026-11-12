import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:found_it/features/reports/data/services/photo_picker_service.dart';
import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/entities/create_report_params.dart';
import 'package:found_it/features/reports/domain/entities/report_failure.dart';
import 'package:found_it/features/reports/domain/entities/report_field_error.dart';
import 'package:found_it/features/reports/domain/entities/report_image.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';
import 'package:found_it/features/reports/domain/use_cases/create_report_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_categories_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_city_areas_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_selected_city_id_use_case.dart';
import 'package:found_it/features/reports/view/cubit/create_report_cubit.dart';
import 'package:found_it/features/reports/view/cubit/create_report_state.dart';

class _FakeReportsRepository implements ReportsRepository {
  final List<CategoryEntity> categories = const [
    CategoryEntity(id: 'cat_1', nameEn: 'Wallet', nameAr: 'محفظة', icon: 'wallet'),
  ];
  final List<AreaEntity> areas = const [
    AreaEntity(id: 'area_1', cityId: 'city_cairo', nameEn: 'Zamalek', nameAr: 'الزمالك'),
  ];
  final String cityId = 'city_cairo';
  final String returnedRefCode = 'RPT-1001';
  final bool shouldFail;
  final bool failOnCreate;

  CreateReportParams? lastCreatedParams;

  _FakeReportsRepository({
    this.shouldFail = false,
    this.failOnCreate = false,
  });

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
    if (shouldFail || failOnCreate) throw const ReportFailure(ReportFailureType.invalidData);
    lastCreatedParams = params;
    return returnedRefCode;
  }
}

class _FakePhotoPickerService implements PhotoPickerService {
  ReportImage? photoToReturn;

  @override
  Future<ReportImage?> pickImage({required ImageSource source}) async => photoToReturn;
}

void main() {
  late _FakeReportsRepository repo;
  late _FakePhotoPickerService picker;
  late CreateReportCubit cubit;

  setUp(() {
    repo = _FakeReportsRepository();
    picker = _FakePhotoPickerService();
    cubit = CreateReportCubit(
      getCategories: GetCategoriesUseCase(repo),
      getCityAreas: GetCityAreasUseCase(repo),
      getSelectedCityId: GetSelectedCityIdUseCase(repo),
      createReport: CreateReportUseCase(repo),
      photoPicker: picker,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('loadInitialData populates categories, areas, and cityId', () async {
    await cubit.loadInitialData();

    expect(cubit.state, isA<CreateReportFormState>());
    final form = cubit.state as CreateReportFormState;
    expect(form.categories.length, 1);
    expect(form.areas.length, 1);
    expect(form.cityId, 'city_cairo');
    expect(form.isLoadingData, false);
    expect(form.initialDataFailure, isNull);
  });

  test('loadInitialData handles failure', () async {
    final failingRepo = _FakeReportsRepository(shouldFail: true);
    final failCubit = CreateReportCubit(
      getCategories: GetCategoriesUseCase(failingRepo),
      getCityAreas: GetCityAreasUseCase(failingRepo),
      getSelectedCityId: GetSelectedCityIdUseCase(failingRepo),
      createReport: CreateReportUseCase(failingRepo),
      photoPicker: picker,
    );

    await failCubit.loadInitialData();

    final form = failCubit.state as CreateReportFormState;
    expect(form.isLoadingData, false);
    expect(form.initialDataFailure, ReportFailureType.network);

    await failCubit.close();
  });

  test('toggleReportType switches between lost and found', () {
    cubit.toggleReportType(false);
    expect((cubit.state as CreateReportFormState).isLost, false);

    cubit.toggleReportType(true);
    expect((cubit.state as CreateReportFormState).isLost, true);
  });

  test('validation emits errors when required fields are missing', () async {
    await cubit.submit();

    final form = cubit.state as CreateReportFormState;
    expect(form.errors['title'], ReportFieldError.required);
    expect(form.errors['category'], ReportFieldError.required);
    expect(form.errors['district'], ReportFieldError.required);
    expect(form.errors['photos'], ReportFieldError.required);
  });

  test('validates title length constraints', () async {
    // Too short (< 3 chars)
    cubit.updateTitle('ab');
    await cubit.submit();
    expect((cubit.state as CreateReportFormState).errors['title'], ReportFieldError.tooShort);

    // Too long (> 50 chars)
    cubit.updateTitle('a' * 51);
    await cubit.submit();
    expect((cubit.state as CreateReportFormState).errors['title'], ReportFieldError.tooLong);

    // Valid title
    cubit.updateTitle('Black Leather Wallet');
    expect((cubit.state as CreateReportFormState).errors.containsKey('title'), false);
  });

  test('photo picking accepts valid JPG and PNG', () async {
    picker.photoToReturn = ReportImage(
      name: 'photo.jpg',
      bytes: Uint8List.fromList([1, 2, 3]),
    );

    await cubit.pickPhoto(ImageSource.gallery);

    final form = cubit.state as CreateReportFormState;
    expect(form.photos.length, 1);
    expect(form.rejectedPhotoIndices.isEmpty, true);
    expect(form.hasInvalidFile, false);
  });

  test('photo picking marks invalid extension as rejected', () async {
    picker.photoToReturn = ReportImage(
      name: 'photo.webp',
      bytes: Uint8List.fromList([1, 2, 3]),
    );

    await cubit.pickPhoto(ImageSource.gallery);

    final form = cubit.state as CreateReportFormState;
    expect(form.photos.length, 1);
    expect(form.rejectedPhotoIndices.contains(0), true);
    expect(form.hasInvalidFile, true);
  });

  test('removing photo updates photo list and rejected indices', () async {
    picker.photoToReturn = ReportImage(
      name: 'photo.webp',
      bytes: Uint8List.fromList([1, 2, 3]),
    );
    await cubit.pickPhoto(ImageSource.gallery);

    cubit.removePhoto(0);

    final form = cubit.state as CreateReportFormState;
    expect(form.photos.isEmpty, true);
    expect(form.rejectedPhotoIndices.isEmpty, true);
    expect(form.hasInvalidFile, false);
  });

  test('submit with valid form creates report and emits CreateReportSuccess', () async {
    await cubit.loadInitialData();

    cubit.updateTitle('Brown Leather Wallet');
    cubit.selectCategory('cat_1');
    cubit.selectDistrict('area_1');

    picker.photoToReturn = ReportImage(
      name: 'wallet.png',
      bytes: Uint8List.fromList([1, 2, 3]),
    );
    await cubit.pickPhoto(ImageSource.gallery);

    await cubit.submit();

    expect(cubit.state, isA<CreateReportSuccess>());
    final success = cubit.state as CreateReportSuccess;
    expect(success.referenceId, 'RPT-1001');
    expect(repo.lastCreatedParams?.title, 'Brown Leather Wallet');
  });

  test('submit failure emits submitFailure in form state', () async {
    final failingRepo = _FakeReportsRepository(failOnCreate: true);
    final failCubit = CreateReportCubit(
      getCategories: GetCategoriesUseCase(failingRepo),
      getCityAreas: GetCityAreasUseCase(failingRepo),
      getSelectedCityId: GetSelectedCityIdUseCase(failingRepo),
      createReport: CreateReportUseCase(failingRepo),
      photoPicker: picker,
    );

    failCubit.updateTitle('Valid Title');
    failCubit.selectCategory('cat_1');
    failCubit.selectDistrict('area_1');

    picker.photoToReturn = ReportImage(
      name: 'test.jpg',
      bytes: Uint8List.fromList([1, 2, 3]),
    );
    await failCubit.pickPhoto(ImageSource.gallery);

    await failCubit.submit();

    final form = failCubit.state as CreateReportFormState;
    expect(form.submitFailure, ReportFailureType.invalidData);
    expect(form.isSubmitting, false);

    await failCubit.close();
  });
}
