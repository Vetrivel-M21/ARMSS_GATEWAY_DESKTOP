import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/report_line.dart';

class PdfReportExporter {
  Future<Uint8List> build({
    required String departmentName,
    required DateTime from,
    required DateTime to,
    required List<ReportLine> lines,
  }) async {
    final letterheadBytes = await rootBundle.load('assets/images/pdf_letterhead.png');
    final letterhead = pw.MemoryImage(letterheadBytes.buffer.asUint8List());

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          pw.Image(letterhead, height: 36, alignment: pw.Alignment.centerLeft),
          pw.SizedBox(height: 8),
          pw.Header(level: 0, text: 'Balance Report — $departmentName'),
          pw.Text('${AppDateUtils.format(from)} to ${AppDateUtils.format(to)}'),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: ['Category', 'Title', 'Sub-Title', 'Opening', 'Debit', 'Credit', 'Closing'],
            data: [
              for (final l in lines)
                [
                  l.mainTitleName,
                  l.titleName,
                  l.subTitleName,
                  l.openingCarry.toStringAsFixed(2),
                  l.periodDebit.toStringAsFixed(2),
                  l.periodCredit.toStringAsFixed(2),
                  l.closing.toStringAsFixed(2),
                ],
            ],
          ),
        ],
      ),
    );

    return doc.save();
  }
}
