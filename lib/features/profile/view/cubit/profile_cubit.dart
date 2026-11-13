import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/profile/domain/entities/city_entity.dart';
import 'package:found_it/features/profile/domain/entities/profile_failure.dart';
import 'package:found_it/features/profile/domain/entities/user_profile_entity.dart';
import 'package:found_it/features/profile/domain/use_cases/get_active_cities_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/set_my_city_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/update_profile_use_case.dart';
import 'package:found_it/features/profile/view/cubit/profile_state.dart';
import 'package:found_it/features/reports/domain/entities/report_counts_entity.dart';
import 'package:found_it/features/reports/domain/use_cases/get_my_reports_counts_use_case.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._getProfileUseCase,
    this._updateProfileUseCase,
    this._setMyCityUseCase,
    this._getActiveCitiesUseCase,
    this._getMyReportsCountsUseCase,
  ) : super(const ProfileState());

  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final SetMyCityUseCase _setMyCityUseCase;
  final GetActiveCitiesUseCase _getActiveCitiesUseCase;
  final GetMyReportsCountsUseCase _getMyReportsCountsUseCase;

  Future<void> loadProfile() async {
    emit(state.copyWith(
      status: ProfileStatus.loading,
      failure: () => null,
    ));

    try {
      final results = await Future.wait([
        _getProfileUseCase(),
        _getActiveCitiesUseCase(),
        _getMyReportsCountsUseCase(),
      ]);

      final profile = results[0] as UserProfileEntity;
      final cities = results[1] as List<CityEntity>;
      final counts = results[2] as ReportCountsEntity;

      emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        activeCities: cities,
        reportsCount: counts.total,
        isUpdating: false,
      ));
    } on ProfileFailure catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        failure: () => e.type,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        failure: () => ProfileFailureType.unknown,
      ));
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    String? phone,
    String? address,
  }) async {
    emit(state.copyWith(isUpdating: true, failure: () => null));
    try {
      await _updateProfileUseCase(
        fullName: fullName,
        phone: phone,
        address: address,
      );
      await loadProfile();
      return true;
    } on ProfileFailure catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        failure: () => e.type,
      ));
      return false;
    } catch (_) {
      emit(state.copyWith(
        isUpdating: false,
        failure: () => ProfileFailureType.unknown,
      ));
      return false;
    }
  }

  Future<bool> changeCity(String cityId) async {
    emit(state.copyWith(isUpdating: true, failure: () => null));
    try {
      await _setMyCityUseCase(cityId);
      await loadProfile();
      return true;
    } on ProfileFailure catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        failure: () => e.type,
      ));
      return false;
    } catch (_) {
      emit(state.copyWith(
        isUpdating: false,
        failure: () => ProfileFailureType.unknown,
      ));
      return false;
    }
  }
}
