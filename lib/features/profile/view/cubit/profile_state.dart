import 'package:equatable/equatable.dart';

import 'package:found_it/features/profile/domain/entities/city_entity.dart';
import 'package:found_it/features/profile/domain/entities/profile_failure.dart';
import 'package:found_it/features/profile/domain/entities/user_profile_entity.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.activeCities = const [],
    this.reportsCount = 0,
    this.isUpdating = false,
    this.failure,
  });

  final ProfileStatus status;
  final UserProfileEntity? profile;
  final List<CityEntity> activeCities;
  final int reportsCount;
  final bool isUpdating;
  final ProfileFailureType? failure;

  bool get isLoading => status == ProfileStatus.loading;
  bool get isSuccess => status == ProfileStatus.success;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfileEntity? profile,
    List<CityEntity>? activeCities,
    int? reportsCount,
    bool? isUpdating,
    ProfileFailureType? Function()? failure,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      activeCities: activeCities ?? this.activeCities,
      reportsCount: reportsCount ?? this.reportsCount,
      isUpdating: isUpdating ?? this.isUpdating,
      failure: failure != null ? failure() : this.failure,
    );
  }

  @override
  List<Object?> get props => [
        status,
        profile,
        activeCities,
        reportsCount,
        isUpdating,
        failure,
      ];
}
