import 'package:found_it/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call({
    required String fullName,
    String? phone,
    String? address,
  }) {
    return _repository.updateProfile(
      fullName: fullName,
      phone: phone,
      address: address,
    );
  }
}
