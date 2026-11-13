import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/profile/domain/use_cases/get_active_cities_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/logout_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/set_my_city_use_case.dart';
import 'package:found_it/features/profile/domain/use_cases/update_profile_use_case.dart';
import 'package:found_it/features/profile/view/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._getProfileUseCase,
    this._updateProfileUseCase,
    this._setMyCityUseCase,
    this._getActiveCitiesUseCase,
    this._logoutUseCase,
  ) : super(const ProfileState());

  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final SetMyCityUseCase _setMyCityUseCase;
  final GetActiveCitiesUseCase _getActiveCitiesUseCase;
  final LogoutUseCase _logoutUseCase;

  Future<void> loadProfile() async {
    emit(state.copyWith(
      status: ProfileStatus.loading,
      errorMessage: null,
    ));

    try {
      final results = await Future.wait([
        _getProfileUseCase(),
        _getActiveCitiesUseCase(),
      ]);

      final profile = results[0] as dynamic;
      final cities = results[1] as dynamic;

      emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        activeCities: cities,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    String? phone,
    String? address,
  }) async {
    emit(state.copyWith(isUpdating: true, errorMessage: null));
    try {
      await _updateProfileUseCase(
        fullName: fullName,
        phone: phone,
        address: address,
      );
      await loadProfile();
      return true;
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  Future<bool> changeCity(String cityId) async {
    emit(state.copyWith(isUpdating: true, errorMessage: null));
    try {
      await _setMyCityUseCase(cityId);
      await loadProfile();
      return true;
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  Future<bool> logout() async {
    emit(state.copyWith(isLoggingOut: true, errorMessage: null));
    try {
      await _logoutUseCase();
      return true;
    } catch (e) {
      emit(state.copyWith(
        isLoggingOut: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }
}
