// import 'dart:typed_data';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import '../models/payment_model.dart';
// import '../models/tenant_model.dart';

// class PdfService {
//   static const List<String> _months = [
//     '', 'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
//     'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর',
//     'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
//   ];

//   static Future<Uint8List> generateRentReceipt({
//     required PaymentModel payment,
//     required String landlordName,
//     required String landlordPhone,
//   }) async {
//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(40),
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               // Header
//               pw.Container(
//                 width: double.infinity,
//                 padding: const pw.EdgeInsets.all(20),
//                 decoration: pw.BoxDecoration(
//                   color: PdfColor.fromHex('1D9E75'),
//                   borderRadius: pw.BorderRadius.circular(8),
//                 ),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.center,
//                   children: [
//                     pw.Text('RENT RECEIPT',
//                         style: pw.TextStyle(
//                           fontSize: 28,
//                           fontWeight: pw.FontWeight.bold,
//                           color: PdfColors.white,
//                         )),
//                     pw.SizedBox(height: 4),
//                     pw.Text('House Management System',
//                         style: const pw.TextStyle(
//                           fontSize: 14,
//                           color: PdfColors.white,
//                         )),
//                   ],
//                 ),
//               ),
//               pw.SizedBox(height: 24),

//               // Receipt info row
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text('RECEIPT NO.',
//                           style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
//                       pw.Text('#${payment.id.substring(0, 8).toUpperCase()}',
//                           style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//                     ],
//                   ),
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.end,
//                     children: [
//                       pw.Text('DATE',
//                           style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
//                       pw.Text(
//                         payment.paidAt != null
//                             ? '${payment.paidAt!.day}/${payment.paidAt!.month}/${payment.paidAt!.year}'
//                             : 'N/A',
//                         style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               pw.SizedBox(height: 20),
//               pw.Divider(color: PdfColors.grey300),
//               pw.SizedBox(height: 20),

//               // From / To
//               pw.Row(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Expanded(
//                     child: pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text('FROM (বাড়ীওয়ালা)',
//                             style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
//                         pw.SizedBox(height: 4),
//                         pw.Text(landlordName,
//                             style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//                         pw.Text(landlordPhone,
//                             style: const pw.TextStyle(fontSize: 12)),
//                         pw.Text(payment.propertyName,
//                             style: const pw.TextStyle(fontSize: 12)),
//                       ],
//                     ),
//                   ),
//                   pw.Expanded(
//                     child: pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text('TO (ভাড়াটিয়া)',
//                             style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
//                         pw.SizedBox(height: 4),
//                         pw.Text(payment.tenantName,
//                             style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//                         pw.Text('Room: ${payment.roomNumber}',
//                             style: const pw.TextStyle(fontSize: 12)),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               pw.SizedBox(height: 24),

//               // Payment details table
//               pw.Container(
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.grey300),
//                   borderRadius: pw.BorderRadius.circular(8),
//                 ),
//                 child: pw.Column(
//                   children: [
//                     // Table header
//                     pw.Container(
//                       padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                       decoration: pw.BoxDecoration(
//                         color: PdfColor.fromHex('F5F5F5'),
//                         borderRadius: const pw.BorderRadius.only(
//                           topLeft: pw.Radius.circular(8),
//                           topRight: pw.Radius.circular(8),
//                         ),
//                       ),
//                       child: pw.Row(
//                         children: [
//                           pw.Expanded(flex: 3,
//                               child: pw.Text('DESCRIPTION',
//                                   style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold))),
//                           pw.Expanded(child: pw.Text('PERIOD',
//                               style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold))),
//                           pw.Expanded(child: pw.Text('AMOUNT',
//                               textAlign: pw.TextAlign.right,
//                               style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold))),
//                         ],
//                       ),
//                     ),
//                     // Table row
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                       child: pw.Row(
//                         children: [
//                           pw.Expanded(flex: 3,
//                               child: pw.Text('Monthly Rent - Room ${payment.roomNumber}',
//                                   style: const pw.TextStyle(fontSize: 12))),
//                           pw.Expanded(
//                               child: pw.Text('${_months[payment.month]} ${payment.year}',
//                                   style: const pw.TextStyle(fontSize: 12))),
//                           pw.Expanded(
//                               child: pw.Text(
//                                 'BDT ${payment.amount.toStringAsFixed(0)}',
//                                 textAlign: pw.TextAlign.right,
//                                 style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
//                               )),
//                         ],
//                       ),
//                     ),
//                     pw.Divider(color: PdfColors.grey300, indent: 16, endIndent: 16),
//                     // Total
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.all(16),
//                       child: pw.Row(
//                         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pw.Text('TOTAL PAID',
//                               style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//                           pw.Container(
//                             padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                             decoration: pw.BoxDecoration(
//                               color: PdfColor.fromHex('1D9E75'),
//                               borderRadius: pw.BorderRadius.circular(6),
//                             ),
//                             child: pw.Text(
//                               'BDT ${payment.amount.toStringAsFixed(0)}',
//                               style: pw.TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: pw.FontWeight.bold,
//                                 color: PdfColors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               pw.SizedBox(height: 24),

//               // Status badge
//               pw.Center(
//                 child: pw.Container(
//                   padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//                   decoration: pw.BoxDecoration(
//                     color: PdfColor.fromHex('E8F5E9'),
//                     borderRadius: pw.BorderRadius.circular(20),
//                     border: pw.Border.all(color: PdfColor.fromHex('4CAF50')),
//                   ),
//                   child: pw.Text(
//                     '✓ PAYMENT RECEIVED',
//                     style: pw.TextStyle(
//                       fontSize: 14,
//                       fontWeight: pw.FontWeight.bold,
//                       color: PdfColor.fromHex('2E7D32'),
//                     ),
//                   ),
//                 ),
//               ),
//               pw.SizedBox(height: 24),

//               // Note
//               if (payment.note != null && payment.note!.isNotEmpty) ...[
//                 pw.Text('Note: ${payment.note}',
//                     style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
//                 pw.SizedBox(height: 16),
//               ],

//               pw.Spacer(),

//               // Footer
//               pw.Divider(color: PdfColors.grey300),
//               pw.SizedBox(height: 8),
//               pw.Center(
//                 child: pw.Text(
//                   'Generated by House Manager App • ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
//                   style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     return pdf.save();
//   }

//   // Print or preview PDF
//   static Future<void> printReceipt(Uint8List pdfBytes) async {
//     await Printing.layoutPdf(
//       onLayout: (_) async => pdfBytes,
//     );
//   }

//   // Share PDF
//   static Future<void> sharePdf(Uint8List pdfBytes, String filename) async {
//     await Printing.sharePdf(bytes: pdfBytes, filename: filename);
//   }
// }






import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/payment_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PdfService {
  static const List<String> _months = [
    '', 'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
    'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর',
    'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
  ];

  /// Load Bengali-capable font from Google Fonts (requires internet)
  /// Falls back gracefully if unavailable.
  static Future<pw.Font> _loadBengaliFont() async {
    try {
      // NotoSansBengali supports full Bengali Unicode range
      final font = await PdfGoogleFonts.notoSansBengaliRegular();
      return font;
    } catch (_) {
      // Fallback: try loading from assets if bundled
      try {
        final fontData = await rootBundle.load('assets/fonts/NotoSansBengali-Regular.ttf');
        return pw.Font.ttf(fontData);
      } catch (_) {
        // Last resort: default font (Bengali will show boxes, but app won't crash)
        return pw.Font.helvetica();
      }
    }
  }

  static Future<pw.Font> _loadBengaliFontBold() async {
    try {
      final font = await PdfGoogleFonts.notoSansBengaliBold();
      return font;
    } catch (_) {
      try {
        final fontData = await rootBundle.load('assets/fonts/NotoSansBengali-Bold.ttf');
        return pw.Font.ttf(fontData);
      } catch (_) {
        return pw.Font.helveticaBold();
      }
    }
  }

  static Future<Uint8List> generateRentReceipt({
    required PaymentModel payment,
    required String landlordName,
    required String landlordPhone,
  }) async {
    final pdf = pw.Document();

    // Load Bengali-supporting fonts
    final bengaliFont = await _loadBengaliFont();
    final bengaliFontBold = await _loadBengaliFontBold();

    // Helper TextStyle builders using Bengali font
    pw.TextStyle style({
      double fontSize = 12,
      bool bold = false,
      PdfColor color = PdfColors.black,
    }) {
      return pw.TextStyle(
        font: bold ? bengaliFontBold : bengaliFont,
        fontBold: bengaliFontBold,
        fontSize: fontSize,
        color: color,
      );
    }

    final String monthYear =
        '${_months[payment.month]} ${payment.year}';

    final String paidDate = payment.paidAt != null
        ? '${payment.paidAt!.day}/${payment.paidAt!.month}/${payment.paidAt!.year}'
        : 'N/A';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
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
                        style: style(fontSize: 28, bold: true, color: PdfColors.white)),
                    pw.SizedBox(height: 4),
                    pw.Text('House Management System',
                        style: style(fontSize: 14, color: PdfColors.white)),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // ── Receipt No. & Date ───────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('RECEIPT NO.',
                          style: style(fontSize: 10, color: PdfColors.grey600)),
                      pw.Text('#${payment.id.substring(0, 8).toUpperCase()}',
                          style: style(fontSize: 14, bold: true)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('DATE',
                          style: style(fontSize: 10, color: PdfColors.grey600)),
                      pw.Text(paidDate, style: style(fontSize: 14, bold: true)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 20),

              // ── FROM / TO ────────────────────────────────────────────
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('FROM (বাড়িওয়ালা)',
                            style: style(fontSize: 10, color: PdfColors.grey600)),
                        pw.SizedBox(height: 4),
                        pw.Text(landlordName, style: style(fontSize: 14, bold: true)),
                        pw.Text(landlordPhone, style: style(fontSize: 12)),
                        pw.Text(payment.propertyName, style: style(fontSize: 12)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('TO (ভাড়াটিয়া)',
                            style: style(fontSize: 10, color: PdfColors.grey600)),
                        pw.SizedBox(height: 4),
                        pw.Text(payment.tenantName,
                            style: style(fontSize: 14, bold: true)),
                        pw.Text('Room: ${payment.roomNumber}',
                            style: style(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // ── Payment Details Table ─────────────────────────────────
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    // Table header
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('F5F5F5'),
                        borderRadius: const pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(8),
                          topRight: pw.Radius.circular(8),
                        ),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                              flex: 3,
                              child: pw.Text('DESCRIPTION',
                                  style: style(fontSize: 11, bold: true))),
                          pw.Expanded(
                              child: pw.Text('PERIOD',
                                  style: style(fontSize: 11, bold: true))),
                          pw.Expanded(
                              child: pw.Text('AMOUNT',
                                  textAlign: pw.TextAlign.right,
                                  style: style(fontSize: 11, bold: true))),
                        ],
                      ),
                    ),

                    // Table row
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                              flex: 3,
                              child: pw.Text(
                                  'Monthly Rent - Room ${payment.roomNumber}',
                                  style: style(fontSize: 12))),
                          // PERIOD — Bengali month now renders correctly
                          pw.Expanded(
                              child: pw.Text(monthYear,
                                  style: style(fontSize: 12))),
                          pw.Expanded(
                              child: pw.Text(
                                'BDT ${payment.amount.toStringAsFixed(0)}',
                                textAlign: pw.TextAlign.right,
                                style: style(fontSize: 12, bold: true),
                              )),
                        ],
                      ),
                    ),

                    pw.Divider(
                        color: PdfColors.grey300, indent: 16, endIndent: 16),

                    // Total
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('TOTAL PAID',
                              style: style(fontSize: 14, bold: true)),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('1D9E75'),
                              borderRadius: pw.BorderRadius.circular(6),
                            ),
                            child: pw.Text(
                              'BDT ${payment.amount.toStringAsFixed(0)}',
                              style: style(
                                  fontSize: 16,
                                  bold: true,
                                  color: PdfColors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // ── Status Badge ─────────────────────────────────────────
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('E8F5E9'),
                    borderRadius: pw.BorderRadius.circular(20),
                    border:
                        pw.Border.all(color: PdfColor.fromHex('4CAF50')),
                  ),
                  child: pw.Text(
                    'PAYMENT RECEIVED',
                    style: style(
                        fontSize: 14,
                        bold: true,
                        color: PdfColor.fromHex('2E7D32')),
                  ),
                ),
              ),
              pw.SizedBox(height: 24),

              // ── Note ─────────────────────────────────────────────────
              if (payment.note != null && payment.note!.isNotEmpty) ...[
                pw.Text('Note: ${payment.note}',
                    style: style(fontSize: 11, color: PdfColors.grey600)),
                pw.SizedBox(height: 16),
              ],

              pw.Spacer(),

              // ── Footer ────────────────────────────────────────────────
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Generated by House Manager App • '
                  '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: style(fontSize: 10, color: PdfColors.grey500),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ── Print or preview PDF ──────────────────────────────────────────────
  static Future<void> printReceipt(Uint8List pdfBytes) async {
    await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  }

  // ── Share PDF ─────────────────────────────────────────────────────────
  static Future<void> sharePdf(Uint8List pdfBytes, String filename) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }

  // ── Download PDF ─────────────────────────────────────────────────────────
  static Future<String?> downloadPdf(
      Uint8List pdfBytes, String filename) async {
    try {
      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          dir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
      } else {
        await sharePdf(pdfBytes, filename);
        return null;
      }
      final file = File('${dir!.path}/$filename');
      await file.writeAsBytes(pdfBytes);
      return file.path;
    } catch (_) {
      await sharePdf(pdfBytes, filename);
      return null;
    }
  }

}