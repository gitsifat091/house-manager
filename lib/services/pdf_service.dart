import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/payment_model.dart';
import '../models/tenant_model.dart';

class PdfService {
  static const List<String> _months = [
    '', 'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
    'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর',
    'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
  ];

  static Future<Uint8List> generateRentReceipt({
    required PaymentModel payment,
    required String landlordName,
    required String landlordPhone,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('1D9E75'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('RENT RECEIPT',
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        )),
                    pw.SizedBox(height: 4),
                    pw.Text('House Management System',
                        style: const pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.white,
                        )),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Receipt info row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('RECEIPT NO.',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      pw.Text('#${payment.id.substring(0, 8).toUpperCase()}',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('DATE',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      pw.Text(
                        payment.paidAt != null
                            ? '${payment.paidAt!.day}/${payment.paidAt!.month}/${payment.paidAt!.year}'
                            : 'N/A',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 20),

              // From / To
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('FROM (বাড়ীওয়ালা)',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                        pw.SizedBox(height: 4),
                        pw.Text(landlordName,
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text(landlordPhone,
                            style: const pw.TextStyle(fontSize: 12)),
                        pw.Text(payment.propertyName,
                            style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('TO (ভাড়াটিয়া)',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                        pw.SizedBox(height: 4),
                        pw.Text(payment.tenantName,
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Room: ${payment.roomNumber}',
                            style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Payment details table
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    // Table header
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('F5F5F5'),
                        borderRadius: const pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(8),
                          topRight: pw.Radius.circular(8),
                        ),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(flex: 3,
                              child: pw.Text('DESCRIPTION',
                                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold))),
                          pw.Expanded(child: pw.Text('PERIOD',
                              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold))),
                          pw.Expanded(child: pw.Text('AMOUNT',
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold))),
                        ],
                      ),
                    ),
                    // Table row
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: pw.Row(
                        children: [
                          pw.Expanded(flex: 3,
                              child: pw.Text('Monthly Rent - Room ${payment.roomNumber}',
                                  style: const pw.TextStyle(fontSize: 12))),
                          pw.Expanded(
                              child: pw.Text('${_months[payment.month]} ${payment.year}',
                                  style: const pw.TextStyle(fontSize: 12))),
                          pw.Expanded(
                              child: pw.Text(
                                'BDT ${payment.amount.toStringAsFixed(0)}',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                              )),
                        ],
                      ),
                    ),
                    pw.Divider(color: PdfColors.grey300, indent: 16, endIndent: 16),
                    // Total
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('TOTAL PAID',
                              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('1D9E75'),
                              borderRadius: pw.BorderRadius.circular(6),
                            ),
                            child: pw.Text(
                              'BDT ${payment.amount.toStringAsFixed(0)}',
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Status badge
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('E8F5E9'),
                    borderRadius: pw.BorderRadius.circular(20),
                    border: pw.Border.all(color: PdfColor.fromHex('4CAF50')),
                  ),
                  child: pw.Text(
                    '✓ PAYMENT RECEIVED',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('2E7D32'),
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 24),

              // Note
              if (payment.note != null && payment.note!.isNotEmpty) ...[
                pw.Text('Note: ${payment.note}',
                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
                pw.SizedBox(height: 16),
              ],

              pw.Spacer(),

              // Footer
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Generated by House Manager App • ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Print or preview PDF
  static Future<void> printReceipt(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
    );
  }

  // Share PDF
  static Future<void> sharePdf(Uint8List pdfBytes, String filename) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }
}