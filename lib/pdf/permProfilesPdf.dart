// ignore_for_file: file_names

import 'dart:async';
import 'package:leaders_book/methods/download_methods.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PermProfilesPdf {
  PermProfilesPdf(
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
        headerField('Date', 1.75),
        headerField('Shaving', 1.0),
        headerField('PU', 0.75),
        headerField('PU', 0.75),
        headerField('PU', 0.75),
        headerField('Alt Event', 1.25),
      ])
    ];
    for (DocumentSnapshot document in documents) {
      children.add(TableRow(children: [
        tableField(
            '${document['rank']} ${document['name']}, ${document['firstName']}',
            2.75),
        tableField(document['date'], 1.75),
        tableField(document['shaving'].toString().toUpperCase(), 1.0),
        tableField(document['pu'].toString().toUpperCase(), 0.75),
        tableField(document['su'].toString().toUpperCase(), 0.75),
        tableField(document['run'].toString().toUpperCase(), 0.75),
        tableField(document['altEvent'], 1.25),
      ]));
    }
    return children;
  }

  List<TableRow> halfTableChildren() {
    List<TableRow> children = [
      TableRow(children: [
        headerField('Name', 2.5),
        headerField('Shaving', 1.0),
        headerField('PU', 0.75),
        headerField('SU', 0.75),
        headerField('Run', 0.75),
        headerField('Alt Event', 1.25),
      ])
    ];
    for (DocumentSnapshot document in documents) {
      children.add(TableRow(children: [
        tableField(
            '${document['rank']} ${document['name']}, ${document['firstName']}',
            2.5),
        tableField(document['shaving'].toString().toUpperCase(), 1.0),
        tableField(document['pu'].toString().toUpperCase(), 0.75),
        tableField(document['su'].toString().toUpperCase(), 0.75),
        tableField(document['run'].toString().toUpperCase(), 0.75),
        tableField(document['altEvent'], 1.25),
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

    return pdfDownload(pdf, 'permProfiles');
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

    return pdfDownload(pdf, 'permProfiles');
  }
}
