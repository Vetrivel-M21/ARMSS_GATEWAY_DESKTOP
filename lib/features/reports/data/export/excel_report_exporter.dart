import 'package:excel/excel.dart';

import '../../domain/entities/report_line.dart';

class ExcelReportExporter {
  List<int> build({
    required String departmentName,
    required DateTime from,
    required DateTime to,
    required List<ReportLine> lines,
  }) {
    final workbook = Excel.createExcel();
    final sheet = workbook['Report'];
    workbook.setDefaultSheet('Report');

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        TextCellValue('ARMSS Gateway — Financial Ledger System');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = CellStyle(bold: true);
    sheet.appendRow(<CellValue?>[]);

    sheet.appendRow(['Category', 'Title', 'Sub-Title', 'Opening', 'Debit', 'Credit', 'Closing']
        .map((h) => TextCellValue(h))
        .toList());

    for (final l in lines) {
      sheet.appendRow([
        TextCellValue(l.mainTitleName),
        TextCellValue(l.titleName),
        TextCellValue(l.subTitleName),
        DoubleCellValue(l.openingCarry),
        DoubleCellValue(l.periodDebit),
        DoubleCellValue(l.periodCredit),
        DoubleCellValue(l.closing),
      ]);
    }

    return workbook.encode()!;
  }
}
