// ignore_for_file: file_names

import 'dart:async';
import 'package:leaders_book/methods/download_methods.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HrActionsPdf {
  HrActionsPdf(
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
        headerField('Name', 3.0),
        headerField('DD93', 2.0),
        headerField('SGLV', 2.0),
        headerField('Records Review', 2.0),
      ])
    ];
    for (DocumentSnapshot document in documents) {
      children.add(TableRow(children: [
        tableField(
            '${document['rank']} ${document['name']}, ${document['firstName']}',
            3.0),
        tableField(document['dd93'], 2.0),
        tableField(document['sglv'], 2.0),
        tableField(document['prr'], 2.0),
      ]));
    }
    return children;
  }

  List<TableRow> halfTableChildren() {
    List<TableRow> children = [
      TableRow(children: [
        headerField('Name', 2.5),
        headerField('DD93', 1.5),
        headerField('SGLV', 1.5),
        headerField('RR', 1.5),
      ])
    ];
    for (DocumentSnapshot document in documents) {
      children.add(TableRow(children: [
        tableField(
            '${document['rank']} ${document['name']}, ${document['firstName']}',
            2.5),
        tableField(document['dd93'], 1.5),
        tableField(document['sglv'], 1.5),
        tableField(document['prr'], 1.5),
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

    return pdfDownload(pdf, 'hrActions');
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

    return pdfDownload(pdf, 'hrActions');
  }
}
