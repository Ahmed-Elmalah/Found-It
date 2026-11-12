/// Lifecycle status of a report.
///
/// Values match the `reports.status` column in Supabase.
enum ReportStatus {
  active('active'),
  matching('matching'),
  recovered('recovered');

  const ReportStatus(this.dbValue);

  /// Value stored in the database.
  final String dbValue;

  static ReportStatus fromDb(String value) => values.firstWhere(
    (status) => status.dbValue == value,
    orElse: () => active,
  );
}
