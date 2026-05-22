import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

class ExportService {
  static Future<void> exportToCsv(String fileName, List<List<dynamic>> data) async {
    final csvData = const CsvEncoder().convert(data);
    final bytes = Uint8List.fromList(csvData.codeUnits);
    
    if (kIsWeb) {
      final blob = html.Blob([bytes], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '$fileName.csv')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.csv');
      await file.writeAsBytes(bytes);
    }
  }

  static Future<void> exportToPdf(String fileName, List<String> headers, List<List<dynamic>> rows) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(level: 0, child: pw.Text(fileName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: rows.map((row) => row.map((cell) => cell.toString()).toList()).toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                for (var i = 0; i < headers.length; i++) i: pw.Alignment.centerLeft,
              },
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '$fileName.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.pdf');
      await file.writeAsBytes(bytes);
    }
  }

  static Future<void> printTable(String fileName, List<String> headers, List<List<dynamic>> rows) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(level: 0, child: pw.Text(fileName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: rows.map((row) => row.map((cell) => cell.toString()).toList()).toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                for (var i = 0; i < headers.length; i++) i: pw.Alignment.centerLeft,
              },
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName,
    );
  }

  /// Print a sale invoice as a nicely formatted PDF
  static Future<void> printInvoice({
    required String invoiceNo,
    required String customerName,
    required String saleDate,
    required String location,
    required String paymentMethod,
    required double subtotal,
    required double discount,
    required double netTotal,
    required double paidAmount,
    required double pendingAmount,
    required List<Map<String, dynamic>> items,
    bool isThermal = false,
  }) async {
    final pdf = pw.Document();
    final totalQty = items.fold<int>(0, (s, i) => s + (i['qty'] as int));

    // 80mm thermal paper is approximately 3.15 inches wide -> ~226 points wide
    final pageFormat = isThermal 
      ? const PdfPageFormat(226, double.infinity, marginAll: 12)
      : PdfPageFormat.a4;

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: isThermal ? const pw.EdgeInsets.all(12) : const pw.EdgeInsets.all(40),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Center(
              child: pw.Column(children: [
                pw.Text('Nayia Swaria', style: pw.TextStyle(fontSize: isThermal ? 16 : 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),
                pw.Text('Invoice', style: pw.TextStyle(fontSize: isThermal ? 11 : 16, color: PdfColors.grey700)),
              ]),
            ),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 4),

            // Invoice meta
            _metaRow('Invoice No:', '#$invoiceNo', isThermal),
            _metaRow('Date:', saleDate.split('T')[0], isThermal),
            _metaRow('Customer:', customerName, isThermal),
            _metaRow('Payment:', paymentMethod, isThermal),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 0.5),

            // Items table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2.5),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Product', style: pw.TextStyle(fontSize: isThermal ? 8 : 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Qty', style: pw.TextStyle(fontSize: isThermal ? 8 : 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Price', style: pw.TextStyle(fontSize: isThermal ? 8 : 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Total', style: pw.TextStyle(fontSize: isThermal ? 8 : 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                  ],
                ),
                // Data rows
                ...items.asMap().entries.map((e) => pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(e.value['name'] as String, style: pw.TextStyle(fontSize: isThermal ? 8 : 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${e.value['qty']}', style: pw.TextStyle(fontSize: isThermal ? 8 : 10), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Rs ${(e.value['price'] as double).toStringAsFixed(0)}', style: pw.TextStyle(fontSize: isThermal ? 8 : 10), textAlign: pw.TextAlign.right)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Rs ${(e.value['total'] as double).toStringAsFixed(0)}', style: pw.TextStyle(fontSize: isThermal ? 8 : 10), textAlign: pw.TextAlign.right)),
                  ],
                )),
              ],
            ),
            pw.SizedBox(height: 8),

            // Totals
            _pdfRow('Items:', '$totalQty pcs', isThermal: isThermal),
            _pdfRow('Subtotal:', 'Rs ${subtotal.toStringAsFixed(0)}', isThermal: isThermal),
            if (discount > 0) _pdfRow('Discount:', '- Rs ${discount.toStringAsFixed(0)}', isThermal: isThermal),
            _pdfRow('Net Total:', 'Rs ${netTotal.toStringAsFixed(0)}', bold: true, isThermal: isThermal),
            _pdfRow('Paid:', 'Rs ${paidAmount.toStringAsFixed(0)}', isThermal: isThermal),
            if (pendingAmount > 0) _pdfRow('Balance Due:', 'Rs ${pendingAmount.toStringAsFixed(0)}', color: PdfColors.red, isThermal: isThermal),
            if (pendingAmount < 0) _pdfRow('Change:', 'Rs ${(-pendingAmount).toStringAsFixed(0)}', color: PdfColors.green700, isThermal: isThermal),

            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 8),

            pw.Center(
              child: pw.Column(children: [
                pw.Text('Thank you for your business!', style: pw.TextStyle(fontSize: isThermal ? 9 : 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('Software by Boson Studio', style: pw.TextStyle(fontSize: isThermal ? 7 : 9, color: PdfColors.grey600)),
              ]),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_$invoiceNo',
    );
  }

  static pw.Widget _metaRow(String label, String value, bool isThermal) {
    return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Text(label, style: pw.TextStyle(fontSize: isThermal ? 9 : 12, fontWeight: pw.FontWeight.bold)),
      pw.Text(value, style: pw.TextStyle(fontSize: isThermal ? 9 : 12)),
    ]);
  }

  static pw.Widget _pdfRow(String label, String value, {bool bold = false, PdfColor? color, bool isThermal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: isThermal ? 9 : 12, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontSize: isThermal ? 9 : 12, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color)),
        ],
      ),
    );
  }

  /// Print a stock movement slip PDF
  static Future<void> printStockSlip({
    required String invoiceNo,
    required String customerName,
    required String saleDate,
    required List<Map<String, dynamic>> rows, // {name, sku, qty, before, after}
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(child: pw.Text('Stock Movement Slip', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 4),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Invoice: #$invoiceNo', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('Date: ${saleDate.split('T')[0]}', style: const pw.TextStyle(fontSize: 9)),
            ]),
            pw.Text('Customer: $customerName', style: const pw.TextStyle(fontSize: 9)),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 4),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Product', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Sold', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Before', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.orange), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('After', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.green700), textAlign: pw.TextAlign.center)),
                  ],
                ),
                ...rows.map((r) {
                  final after = r['after'];
                  final isLow = after != null && (after as double) <= 5;
                  return pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(r['name'] as String, style: const pw.TextStyle(fontSize: 8)),
                        if (r['sku'] != null) pw.Text('SKU: ${r['sku']}', style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey)),
                      ],
                    )),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${r['qty']}', style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r['before'] != null ? '${(r['before'] as double).toStringAsFixed(0)}' : '—', style: const pw.TextStyle(fontSize: 8, color: PdfColors.orange800), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(after != null ? '${after.toStringAsFixed(0)}${isLow ? ' ⚠' : ''}' : '—', style: pw.TextStyle(fontSize: 8, color: isLow ? PdfColors.red : PdfColors.green700, fontWeight: isLow ? pw.FontWeight.bold : null), textAlign: pw.TextAlign.center)),
                  ]);
                }),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 0.5),
            pw.Center(child: pw.Text('Nayia Swaria | Developed by Boson Studio', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey))),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'StockSlip-$invoiceNo',
    );
  }

  /// Print a purchase invoice as a nicely formatted PDF
  static Future<void> printPurchaseInvoice({
    required String invoiceNo,
    required String supplierName,
    required String purchaseDate,
    required String location,
    required String paymentMethod,
    required double subtotal,
    required double discount,
    required double netTotal,
    required double paidAmount,
    required double pendingAmount,
    required List<Map<String, dynamic>> items,
    bool isThermal = false,
  }) async {
    final pdf = pw.Document();
    final totalQty = items.fold<int>(0, (s, i) => s + (i['qty'] as int));

    final pageFormat = isThermal 
      ? const PdfPageFormat(226, double.infinity, marginAll: 12)
      : PdfPageFormat.a4;

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: isThermal ? const pw.EdgeInsets.all(12) : const pw.EdgeInsets.all(40),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Center(
              child: pw.Column(children: [
                pw.Text('Nayia Swaria', style: pw.TextStyle(fontSize: isThermal ? 16 : 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),
                pw.Text('Purchase Invoice', style: pw.TextStyle(fontSize: isThermal ? 11 : 16, color: PdfColors.grey700)),
              ]),
            ),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 4),

            // Invoice meta
            _metaRow('Invoice No:', '#$invoiceNo', isThermal),
            _metaRow('Date:', purchaseDate.split('T')[0], isThermal),
            _metaRow('Supplier:', supplierName, isThermal),
            _metaRow('Payment:', paymentMethod, isThermal),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 0.5),

            // Items table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2.5),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Product', style: pw.TextStyle(fontSize: isThermal ? 8 : 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Qty', style: pw.TextStyle(fontSize: isThermal ? 8 : 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Cost', style: pw.TextStyle(fontSize: isThermal ? 8 : 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Total', style: pw.TextStyle(fontSize: isThermal ? 8 : 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                  ],
                ),
                // Data rows
                ...items.asMap().entries.map((e) => pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(e.value['name'] as String, style: pw.TextStyle(fontSize: isThermal ? 8 : 10))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${e.value['qty']}', style: pw.TextStyle(fontSize: isThermal ? 8 : 10), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Rs ${(e.value['price'] as double).toStringAsFixed(0)}', style: pw.TextStyle(fontSize: isThermal ? 8 : 10), textAlign: pw.TextAlign.right)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Rs ${(e.value['total'] as double).toStringAsFixed(0)}', style: pw.TextStyle(fontSize: isThermal ? 8 : 10), textAlign: pw.TextAlign.right)),
                  ],
                )),
              ],
            ),
            pw.SizedBox(height: 8),

            // Totals
            _pdfRow('Items:', '$totalQty pcs', isThermal: isThermal),
            _pdfRow('Subtotal:', 'Rs ${subtotal.toStringAsFixed(0)}', isThermal: isThermal),
            if (discount > 0) _pdfRow('Discount:', '- Rs ${discount.toStringAsFixed(0)}', isThermal: isThermal),
            _pdfRow('Net Total:', 'Rs ${netTotal.toStringAsFixed(0)}', bold: true, isThermal: isThermal),
            _pdfRow('Paid:', 'Rs ${paidAmount.toStringAsFixed(0)}', isThermal: isThermal),
            if (pendingAmount > 0) _pdfRow('Balance Due:', 'Rs ${pendingAmount.toStringAsFixed(0)}', color: PdfColors.red, isThermal: isThermal),
            if (pendingAmount < 0) _pdfRow('Change:', 'Rs ${(-pendingAmount).toStringAsFixed(0)}', color: PdfColors.green700, isThermal: isThermal),

            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 8),

            pw.Center(
              child: pw.Column(children: [
                pw.Text('Purchase Record Receipt', style: pw.TextStyle(fontSize: isThermal ? 9 : 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('Software by Boson Studio', style: pw.TextStyle(fontSize: isThermal ? 7 : 9, color: PdfColors.grey600)),
              ]),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'PurchaseInvoice_$invoiceNo',
    );
  }
}

