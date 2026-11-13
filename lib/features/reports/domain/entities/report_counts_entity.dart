import 'package:equatable/equatable.dart';

class ReportCountsEntity extends Equatable {
  const ReportCountsEntity({
    required this.total,
    required this.active,
    required this.matching,
    required this.recovered,
  });

  const ReportCountsEntity.empty()
      : total = 0,
        active = 0,
        matching = 0,
        recovered = 0;

  final int total;
  final int active;
  final int matching;
  final int recovered;

  @override
  List<Object?> get props => [total, active, matching, recovered];
}
