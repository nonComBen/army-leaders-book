// ignore_for_file: file_names

import 'dart:async';
import 'package:leaders_book/methods/download_methods.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActionsPdf {
  ActionsPdf(
    this.documents,
  );

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

  List<TableRow> fullTableChildren() {
    List<TableRow> children = [
      TableRow(children: [
        headerField('Name', 2.75),
        headerField('Action', 1.75),
        headerField('Date Submitted', 1.50),
        headerField('Current Status', 1.50),
        headerField('Status Date', 1.50),
      ])
    ];
    for (DocumentSnapshot doc in documents) {
      children.add(TableRow(children: [
        tableField('${doc['rank']} ${doc['name']}, ${doc['firstName']}', 2.75,
            TextAlign.left),
        tableField(doc['action'], 1.75, TextAlign.center),
        tableField(doc['dateSubmitted'], 1.50, TextAlign.center),
        tableField(doc['currentStatus'], 1.50, TextAlign.center),
        tableField(doc['statusDate'], 1.50, TextAlign.center),
      ]));
    }

    return children;
  }

  List<TableRow> halfTableChildren() {
    List<TableRow> children = [
      TableRow(children: [
        headerField('Name', 2.5),
        headerField('Action', 1.375),
        headerField('Current Status', 1.25),
        headerField('Status Date', 1.375),
      ])
    ];
    for (DocumentSnapshot doc in documents) {
      children.add(TableRow(children: [
        tableField('${doc['rank']} ${doc['name']}, ${doc['firstName']}', 2.5,
            TextAlign.left),
        tableField(doc['action'].toString(), 1.25, TextAlign.center),
        tableField(doc['currentStatus'].toString(), 1.375, TextAlign.center),
        tableField(doc['statusDate'].toString(), 1.375, TextAlign.center)
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

    return pdfDownload(pdf, 'actionsTracker');
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

    return pdfDownload(pdf, 'actionsTracker');
  }
}
