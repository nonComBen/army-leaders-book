// ignore_for_file: file_names

import 'dart:async';
import 'package:leaders_book/methods/download_methods.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MilLicPdf {
  MilLicPdf(
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

  List<TableRow> tableChildren(bool fullPage) {
    List<TableRow> children = [
      TableRow(children: [
        headerField('Name', fullPage ? 3.5 : 2.5),
        headerField('License #', fullPage ? 2.0 : 1.75),
        headerField('Issued Date', fullPage ? 1.75 : 1.375),
        headerField('Exp Date', fullPage ? 1.75 : 1.375),
      ])
    ];
    for (DocumentSnapshot document in documents) {
      children.add(TableRow(children: [
        tableField(
            '${document['rank']} ${document['name']}, ${document['firstName']}',
            fullPage ? 3.5 : 2.5),
        tableField(document['license'], fullPage ? 2.0 : 1.75),
        tableField(document['date'], fullPage ? 1.75 : 1.375),
        tableField(document['exp'], fullPage ? 1.75 : 1.375)
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
                  children: tableChildren(true)));
        }));

    return pdfDownload(pdf, 'milLicenses');
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
                  children: tableChildren(false)));
        }));

    return pdfDownload(pdf, 'milLicenses');
  }
}
