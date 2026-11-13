/// Type of a report: something lost, or something found.
///
/// Values match the `reports.type` column in Supabase (`lost` / `found`).
enum ReportType {
  lost('lost'),
  found('found');

  const ReportType(this.dbValue);

  /// Value stored in the database.
  final String dbValue;

  static ReportType fromDb(String value) =>
      values.firstWhere((type) => type.dbValue == value, orElse: () => lost);
}
