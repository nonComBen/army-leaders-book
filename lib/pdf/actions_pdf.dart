import 'dart:async';
import 'package:leaders_book/methods/download_methods.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActionsPdf {
  ActionsPdf({
    required this.documents,
  });

  final List<DocumentSnapshot> documents;

  Widget tableField(String text, double width, TextAlign textAlign) {
    return SizedBox(
        width: width * 72,
        height: 24.0,
        child: Container(
            padding: const EdgeInsets.all(5.0),
            child: Text(text, textAlign: textAlign)));
  }

  Widget headerField(String text, double width) {
    return SizedBox(
        width: width * 72,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ));
  }

  TableRow tableHeader(bool fullPage) {
    return TableRow(
      children: [
        headerField('Name', fullPage ? 2.75 : 2.5),
        headerField('Action', fullPage ? 1.75 : 1.375),
        if (fullPage) headerField('Date Submitted', 1.50),
        headerField('Current Status', fullPage ? 1.50 : 1.25),
        headerField('Status Date', fullPage ? 1.50 : 1.375),
      ],
    );
  }

  List<TableRow> tableChildren(bool fullPage, int startIndex, int endIndex) {
    List<TableRow> children = [];
    for (int i = startIndex; i <= endIndex; i++) {
      children.add(TableRow(children: [
        tableField(
            '${documents[i]['rank']} ${documents[i]['name']}, ${documents[i]['firstName']}',
            fullPage ? 2.75 : 2.5,
            TextAlign.left),
        tableField(
            documents[i]['action'], fullPage ? 1.75 : 1.375, TextAlign.center),
        if (fullPage)
          tableField(documents[i]['dateSubmitted'], 1.50, TextAlign.center),
        tableField(documents[i]['currentStatus'], fullPage ? 1.50 : 1.25,
            TextAlign.center),
        tableField(documents[i]['statusDate'], fullPage ? 1.50 : 1.375,
            TextAlign.center),
      ]));
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

    return pdfDownload(pdf, 'actionsTracker');
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

    return pdfDownload(pdf, 'actionsTracker');
  }
}
