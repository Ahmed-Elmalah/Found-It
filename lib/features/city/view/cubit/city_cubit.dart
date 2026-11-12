import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/city/domain/city_entity.dart';
import 'package:found_it/features/city/domain/get_cities_use_case.dart';
import 'package:found_it/features/city/domain/select_city_use_case.dart';

part 'city_state.dart';

class CityCubit extends Cubit<CityState> {
  final GetCitiesUseCase getCitiesUseCase;
  final SelectCityUseCase selectCityUseCase;

  CityCubit({
    required this.getCitiesUseCase,
    required this.selectCityUseCase,
  }) : super(const CityState());

  Future<void> loadCities() async {
    if (state.isLoading) return;
    emit(state.copyWith(status: CityStatus.loading, errorMessage: null));
    try {
      final cities = await getCitiesUseCase();
      if (isClosed) return;
      emit(state.copyWith(
        status: CityStatus.loaded,
        cities: cities,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: CityStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void selectCity(String cityId) {
    emit(state.copyWith(
      selectedCityId: cityId,
      hasLocationRequiredError: false,
    ));
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;

    final cityId = state.selectedCityId;
    if (cityId == null || cityId.isEmpty) {
      emit(state.copyWith(hasLocationRequiredError: true));
      return;
    }

    emit(state.copyWith(
      status: CityStatus.submitting,
      hasLocationRequiredError: false,
      errorMessage: null,
    ));

    try {
      await selectCityUseCase(cityId);
      if (isClosed) return;
      emit(state.copyWith(status: CityStatus.success));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: CityStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
