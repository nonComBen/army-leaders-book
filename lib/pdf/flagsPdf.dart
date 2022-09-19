// ignore_for_file: file_names

import 'dart:async';
import 'package:leaders_book/methods/download_methods.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FlagsPdf {
  FlagsPdf(
    this.documents,
  );

  final List<DocumentSnapshot> documents;

  Widget tableField(String text, double width) {
    return SizedBox(
        width: width * 72,
        height: 24.0,
        child: Padding(padding: const EdgeInsets.all(5.0), child: Text(text)));
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

  List<TableRow> fullTableChildren() {
    List<TableRow> children = [
      TableRow(children: [
        headerField('Name', 2.75),
        headerField('Type', 2.75),
        headerField('Issued Date', 1.75),
        headerField('Exp Date', 1.75),
      ])
    ];
    for (DocumentSnapshot document in documents) {
      children.add(TableRow(children: [
        tableField(
            '${document['rank']} ${document['name']}, ${document['firstName']}',
            2.75),
        tableField(document['type'], 2.75),
        tableField(document['date'], 1.75),
        tableField(document['exp'], 1.75)
      ]));
    }
    return children;
  }

  List<TableRow> halfTableChildren() {
    List<TableRow> children = [
      TableRow(children: [
        headerField('Name', 2.75),
        headerField('Type', 2.75),
        headerField('Issued Date', 1.5),
      ])
    ];
    for (DocumentSnapshot document in documents) {
      children.add(TableRow(children: [
        tableField(
            '${document['rank']} ${document['name']}, ${document['firstName']}',
            2.75),
        tableField(document['type'], 2.75),
        tableField(document['date'], 1.5),
      ]));
    }
    return children;
  }

  Future<String> createFullPage() async {
    final Document pdf = Document();

    pdf.addPage(Page(
        pageFormat: PdfPageFormat.letter,
        orientation: PageOrientation.landscape,
        margin: const EdgeInsets.all(72.0),
        build: (Context context) {
          return Center(
              child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: const TableBorder(
                      left: BorderSide(),
                      top: BorderSide(),
                      right: BorderSide(),
                      bottom: BorderSide(),
                      horizontalInside: BorderSide(),
                      verticalInside: BorderSide()),
                  children: fullTableChildren()));
        }));

    return pdfDownload(pdf, 'flags');
  }

  Future<String> createHalfPage() async {
    final Document pdf = Document();

    pdf.addPage(Page(
        pageFormat: PdfPageFormat.letter,
        orientation: PageOrientation.portrait,
        margin: const EdgeInsets.all(0.75 * 72.0),
        build: (Context context) {
          return Container(
              child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: const TableBorder(
                      left: BorderSide(),
                      top: BorderSide(),
                      right: BorderSide(),
                      bottom: BorderSide(),
                      horizontalInside: BorderSide(),
                      verticalInside: BorderSide()),
                  children: halfTableChildren()));
        }));

    return pdfDownload(pdf, 'flags');
  }
}
