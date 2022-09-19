// ignore_for_file: file_names

import 'dart:async';
import 'package:leaders_book/methods/download_methods.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BodyfatsPdf {
  BodyfatsPdf(
    this.documents,
  );

  final List<DocumentSnapshot> documents;

  Widget tableField(String text, double width, failed) {
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
        headerField('Age', 0.75),
        headerField('Ht', 0.75),
        headerField('Wt', 0.75),
        headerField('Neck', 0.75),
        headerField('Waist', 0.75),
        headerField('Hip', 0.75),
        headerField('BF%', 0.75)
      ])
    ];
    for (DocumentSnapshot bf in documents) {
      bool failed = false;
      if (!bf['passBmi'] && !bf['passBf']) {
        failed = true;
      }
      children.add(TableRow(children: [
        tableField(
            '${bf['rank']} ${bf['name']}, ${bf['firstName']}', 2.75, failed),
        tableField(bf['date'], 1.5, failed),
        tableField(bf['age'].toString(), 0.75, failed),
        tableField(bf['height'], 0.75, failed),
        tableField(bf['weight'], 0.75, failed),
        tableField(bf['neck'], 0.75, failed),
        tableField(bf['waist'], 0.75, failed),
        tableField(bf['hip'], 0.75, failed),
        tableField(
            bf['percent'] != '' ? '${bf['percent']}%' : '', 0.75, failed),
      ]));
    }
    return children;
  }

  List<TableRow> halfTableChildren() {
    List<TableRow> children = [
      TableRow(children: [
        headerField('Name', 2.5),
        headerField('Date', 1.5),
        headerField('Age', 0.75),
        headerField('Ht', 0.75),
        headerField('Wt', 0.75),
        headerField('BF%', 0.75)
      ])
    ];
    for (DocumentSnapshot bf in documents) {
      bool failed = false;
      if (!bf['passBmi'] && !bf['passBf']) {
        failed = true;
      }
      children.add(TableRow(children: [
        tableField(
            '${bf['rank']} ${bf['name']}, ${bf['firstName']}', 2.5, failed),
        tableField(bf['date'], 1.5, failed),
        tableField(bf['age'].toString(), 0.75, failed),
        tableField(bf['height'], 0.75, failed),
        tableField(bf['weight'], 0.75, failed),
        tableField(
            bf['percent'] != '' ? '${bf['percent']}%' : '', 0.75, failed),
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

    return pdfDownload(pdf, 'bodyCompStats');
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

    return pdfDownload(pdf, 'bodyCompStats');
  }
}
