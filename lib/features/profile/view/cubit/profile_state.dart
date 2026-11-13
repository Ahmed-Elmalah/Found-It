import 'package:equatable/equatable.dart';

import 'package:found_it/features/profile/domain/entities/city_entity.dart';
import 'package:found_it/features/profile/domain/entities/user_profile_entity.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.activeCities = const [],
    this.isUpdating = false,
    this.errorMessage,
  });

  final ProfileStatus status;
  final UserProfileEntity? profile;
  final List<CityEntity> activeCities;
  final bool isUpdating;
  final String? errorMessage;

  bool get isLoading => status == ProfileStatus.loading;
  bool get isSuccess => status == ProfileStatus.success;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfileEntity? profile,
    List<CityEntity>? activeCities,
    bool? isUpdating,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      activeCities: activeCities ?? this.activeCities,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        profile,
        activeCities,
        isUpdating,
        errorMessage,
      ];
}
