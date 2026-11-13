import 'package:equatable/equatable.dart';

enum HomeFailureType {
  network,
  server,
  unknown,
}

class HomeFailure extends Equatable {
  const HomeFailure(this.type, [this.message]);

  final HomeFailureType type;
  final String? message;

  @override
  List<Object?> get props => [type, message];
}
