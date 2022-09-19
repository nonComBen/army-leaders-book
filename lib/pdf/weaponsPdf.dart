// ignore_for_file: file_names

import 'dart:async';
import 'package:leaders_book/methods/download_methods.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeaponsPdf {
  WeaponsPdf(
    this.documents,
  );

  final List<DocumentSnapshot> documents;

  Widget tableField(String text, double width, bool failed) {
    return SizedBox(
        width: width * 72,
        height: 24.0,
        child: Container(
            padding: const EdgeInsets.all(5.0),
            decoration:
                failed ? const BoxDecoration(color: PdfColor(1, 0, 0)) : null,
            child: Text(text)));
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
        headerField('Date', 1.5),
        headerField('Weapon', 1.0),
        headerField('Hits', 1.0),
        headerField('Max', 1.0),
        headerField('Badge', 1.75),
      ])
    ];
    for (DocumentSnapshot document in documents) {
      bool failed = false;
      if (!document['pass']) {
        failed = true;
      }
      children.add(TableRow(children: [
        tableField(
            '${document['rank']} ${document['name']}, ${document['firstName']}',
            2.75,
            failed),
        tableField(document['date'], 1.5, failed),
        tableField(document['type'], 1.0, failed),
        tableField(document['score'], 1.0, failed),
        tableField(document['max'], 1.0, failed),
        tableField(document['badge'], 1.75, failed),
      ]));
    }
    return children;
  }

  List<TableRow> halfTableChildren() {
    List<TableRow> children = [
      TableRow(children: [
        headerField('Name', 2.5),
        headerField('Date', 1.5),
        headerField('Weapon', 1.0),
        headerField('Hits', 1.0),
        headerField('Max', 1.0),
      ])
    ];
    for (DocumentSnapshot document in documents) {
      bool failed = false;
      if (!document['pass']) {
        failed = true;
      }
      children.add(TableRow(children: [
        tableField(
            '${document['rank']} ${document['name']}, ${document['firstName']}',
            2.5,
            failed),
        tableField(document['date'], 1.5, failed),
        tableField(document['type'], 1.0, failed),
        tableField(document['score'], 1.0, failed),
        tableField(document['max'], 1.0, failed),
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

    return pdfDownload(pdf, 'weaponStats');
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

    return pdfDownload(pdf, 'weaponStats');
  }
}
