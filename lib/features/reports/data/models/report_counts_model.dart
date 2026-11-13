import 'package:found_it/features/reports/domain/entities/report_counts_entity.dart';

class ReportCountsModel extends ReportCountsEntity {
  const ReportCountsModel({
    required super.total,
    required super.active,
    required super.matching,
    required super.recovered,
  });

  factory ReportCountsModel.fromJson(Map<String, dynamic> json) {
    return ReportCountsModel(
      total: _asInt(json['total']),
      active: _asInt(json['active']),
      matching: _asInt(json['matching']),
      recovered: _asInt(json['recovered']),
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
