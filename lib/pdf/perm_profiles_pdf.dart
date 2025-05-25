import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:leaders_book/methods/download_methods.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PermProfilesPdf {
  PermProfilesPdf({
    required this.documents,
  });

  final List<DocumentSnapshot> documents;

  Widget tableField(String text, double width) {
    return SizedBox(
      width: width * 72,
      height: 24.0,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(text),
      ),
    );
  }

  Widget headerField(String text, double width) {
    return SizedBox(
      width: width * 72,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  TableRow tableHeader(bool fullPage) {
    return TableRow(children: [
      headerField('Name', fullPage ? 2.75 : 2.5),
      headerField('Shave', 0.85),
      headerField('Run', 0.85),
      if (fullPage) headerField('Alt Event', 1.25),
      headerField('MDL', 0.75),
      headerField('HRP', 0.75),
      headerField('SDC', 0.75),
      headerField('PLK', 0.75),
    ]);
  }

  List<TableRow> tableChildren(bool fullPage, int startIndex, int endIndex) {
    List<TableRow> children = [];
    for (int i = startIndex; i <= endIndex; i++) {
      String mdl = 'TRUE', hrp = 'TRUE', sdc = 'TRUE', plk = 'TRUE';
      try {
        mdl = documents[i]['mdl'].toString().toUpperCase();
        hrp = documents[i]['hrp'].toString().toUpperCase();
        sdc = documents[i]['sdc'].toString().toUpperCase();
        plk = documents[i]['plk'].toString().toUpperCase();
      } catch (e) {
        debugPrint('new events are null');
      }
      children.add(
        TableRow(
          children: [
            tableField(
                '${documents[i]['rank']} ${documents[i]['name']}, ${documents[i]['firstName']}',
                fullPage ? 2.75 : 2.5),
            tableField(documents[i]['shaving'].toString().toUpperCase(), 0.85),
            tableField(documents[i]['run'].toString().toUpperCase(), 0.85),
            if (fullPage) tableField(documents[i]['altEvent'], 1.25),
            tableField(mdl, 0.75),
            tableField(hrp, 0.75),
            tableField(sdc, 0.75),
            tableField(plk, 0.75),
          ],
        ),
      );
    }
    return children;
  }

  Future<String> createFullPage() async {
    final Document pdf = Document();
    int pages = (documents.length / 18).ceil();

    for (int i = 1; i <= pages; i++) {
      int startIndex = i == 1 ? 0 : (i - 1) * 18;
      int endIndex = documents.length - 1;
      if (documents.length > i * 18) {
        endIndex = (i * 18) - 1;
      }
      pdf.addPage(
        Page(
          pageFormat: PdfPageFormat.letter,
          orientation: PageOrientation.landscape,
          margin: const EdgeInsets.all(72.0),
          build: (Context context) {
            return Center(
              heightFactor: 1,
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.all(),
                children: [
                  tableHeader(true),
                  ...tableChildren(true, startIndex, endIndex),
                ],
              ),
            );
          },
        ),
      );
    }

    return pdfDownload(pdf, 'permProfiles');
  }

  Future<String> createHalfPage() async {
    final Document pdf = Document();
    int pages = (documents.length / 11).ceil();

    for (int i = 1; i <= pages; i++) {
      int startIndex = i == 1 ? 0 : (i - 1) * 11;
      int endIndex = documents.length - 1;
      if (documents.length > i * 11) {
        endIndex = (i * 11) - 1;
      }
      pdf.addPage(
        Page(
          pageFormat: PdfPageFormat.letter,
          orientation: PageOrientation.portrait,
          margin: const EdgeInsets.all(0.75 * 72.0),
          build: (Context context) {
            return Container(
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.all(),
                children: [
                  tableHeader(false),
                  ...tableChildren(false, startIndex, endIndex),
                ],
              ),
            );
          },
        ),
      );
    }

    return pdfDownload(pdf, 'permProfiles');
  }
}
