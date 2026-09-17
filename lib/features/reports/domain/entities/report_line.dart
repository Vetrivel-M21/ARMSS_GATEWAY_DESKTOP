/// One sub-title's computed row for a report period. Unlike the persisted
/// tables, this is derived data (opening/closing depend on the selected date
/// range), so it's a real domain entity rather than a pass-through DB row.
class ReportLine {
  final int subTitleId;
  final String subTitleName;
  final int titleId;
  final String titleName;
  final String? vfNo;
  final String mainTitleName;
  final double openingCarry;
  final double periodDebit;
  final double periodCredit;

  const ReportLine({
    required this.subTitleId,
    required this.subTitleName,
    required this.titleId,
    required this.titleName,
    required this.vfNo,
    required this.mainTitleName,
    required this.openingCarry,
    required this.periodDebit,
    required this.periodCredit,
  });

  /// Closing = Opening + Debit - Credit — matches `balancereport.php`'s own
  /// formula exactly (confirmed at every occurrence: group/title/sub-title/
  /// running-entry closing all compute it this way). This is the OPPOSITE
  /// of Transaction Entry's Opening+Credit-Debit convention — a real
  /// inconsistency in the old app between its two screens, reproduced here
  /// deliberately (per explicit decision) rather than "fixed," since this
  /// screen's fidelity target is balancereport.php specifically.
  double get closing => openingCarry + periodDebit - periodCredit;
}
