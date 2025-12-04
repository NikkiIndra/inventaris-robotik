import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:path_provider/path_provider.dart';

/// Untuk Web
import 'dart:html' as html;

class ExportService {
  // ============================================================
  //                       EXPORT EXCEL
  // ============================================================
  Future<void> exportToXlsx({
    required String title,
    required List<Map<String, dynamic>> data,
    required List<String> headers,
    required List<String> fields,
  }) async {
    final workbook = xls.Workbook();
    final sheet = workbook.worksheets[0];

    int row = 1;

    // ==== Header Style ====
    final headerStyle = workbook.styles.add('HeaderStyle');
    headerStyle.bold = true;

    // ==== Write Header ====
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.getRangeByIndex(row, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle = headerStyle;
    }

    row++;

    // ==== Write Data ====
    for (var item in data) {
      for (int i = 0; i < fields.length; i++) {
        final value = getNestedValue(item, fields[i]);
        final cell = sheet.getRangeByIndex(row, i + 1);

        if (value == null) {
          cell.setText('');
        } else if (value is num) {
          cell.number = value.toDouble();
        } else {
          cell.setText(value.toString());
        }
      }
      row++;
    }

    // Auto fit columns
    for (int i = 1; i <= headers.length; i++) {
      sheet.autoFitColumn(i);
    }

    final bytes = Uint8List.fromList(workbook.saveAsStream());
    workbook.dispose();

    // WEB SAVE
    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..style.display = 'none'
        ..download = "$title.xlsx";

      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);

      html.Url.revokeObjectUrl(url);
      print("Download Excel Web → $title.xlsx");
      return;
    }

    // ANDROID / DESKTOP
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/$title.xlsx");
    await file.writeAsBytes(bytes, flush: true);

    print("Excel saved: ${file.path}");
  }

  // ============================================================
  //                       EXPORT PDF
  // ============================================================
  Future<void> exportToPdf({
    required String title,
    required List<Map<String, dynamic>> data,
    required List<String> headers,
    required List<String> fields,
  }) async {
    final pdf = pw.Document();

    // ==== BUILD TABLE DATA (WITH NESTED VALUE FIX) ====
    final tableData = data.map((row) {
      return fields.map((f) {
        final value = getNestedValue(row, f);
        return value?.toString() ?? "";
      }).toList();
    }).toList();

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ===== TITLE =====
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),

              // ===== TABLE =====
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  for (int i = 0; i < headers.length; i++)
                    i: pw.FixedColumnWidth(100), // agar rapi & tidak mepet
                },
                children: [
                  // === HEADER ROW ===
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: headers
                        .map(
                          (h) => pw.Padding(
                            padding: pw.EdgeInsets.all(6),
                            child: pw.Text(
                              h,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  // === DATA ROWS ===
                  ...tableData.map(
                    (row) => pw.TableRow(
                      children: row
                          .map(
                            (cell) => pw.Padding(
                              padding: pw.EdgeInsets.all(6),
                              child: pw.Text(
                                cell,
                                style: pw.TextStyle(fontSize: 9),
                                maxLines: 5,
                                softWrap: true,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();

    // ==== WEB SAVE ====
    if (kIsWeb) {
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..download = "$title.pdf"
        ..click();

      html.Url.revokeObjectUrl(url);
      return;
    }

    // ==== ANDROID / DESKTOP SAVE ====
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$title.pdf");
    await file.writeAsBytes(bytes, flush: true);

    print("PDF saved: ${file.path}");
  }

  // ============================================================
  //                SUPPORT NESTED FIELD
  // ============================================================
  dynamic getNestedValue(Map<String, dynamic> data, String field) {
    if (!field.contains('.')) return data[field];

    final keys = field.split('.');
    dynamic current = data;

    for (var key in keys) {
      if (current == null || current[key] == null) return null;
      current = current[key];
    }
    return current;
  }
}
