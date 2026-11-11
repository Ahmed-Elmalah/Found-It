import 'package:found_it/features/auth/domain/auth_repository.dart';

import 'auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthDataSource _dataSource;

  @override
  bool hasActiveSession() => _dataSource.hasActiveSession();
}
