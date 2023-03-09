// ignore_for_file: file_names

import 'dart:async';
import 'package:leaders_book/methods/download_methods.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApftsPdf {
  ApftsPdf(
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

  Map<String, int> getAverages() {
    List<int> pu = [];
    List<int> su = [];
    List<int> run = [];
    List<int> total = [];
    for (DocumentSnapshot doc in documents) {
      int events = 0;
      if (doc['puScore'] != 0) {
        pu.add(doc['puScore']);
        events++;
      }
      if (doc['suScore'] != 0) {
        su.add(doc['suScore']);
        events++;
      }
      if (doc['runScore'] != 0) {
        run.add(doc['runScore']);
        events++;
      }
      if (events == 3) {
        total.add(pu.last + su.last + run.last);
      }
    }
    return <String, int>{
      'pu':
          (pu.reduce((value, element) => value + element) / pu.length).floor(),
      'su':
          (su.reduce((value, element) => value + element) / su.length).floor(),
      'run': (run.reduce((value, element) => value + element) / run.length)
          .floor(),
      'total':
          (total.reduce((value, element) => value + element) / total.length)
              .floor(),
    };
  }

  TableRow fullPageTableHeader() {
    return TableRow(
      children: [
        headerField('Name', 2.75),
        headerField('Date', 1.625),
        headerField('PU Raw', 0.625),
        headerField('PU Score', 0.625),
        headerField('SU Raw', 0.625),
        headerField('SU Score', 0.625),
        headerField('Run Raw', 0.75),
        headerField('Run Score', 0.75),
        headerField('Total', 0.625)
      ],
    );
  }

  List<TableRow> fullTableChildren(int startIndex, int endIndex) {
    List<TableRow> children = [];
    for (int i = startIndex; i <= endIndex; i++) {
      bool failed = false;
      if (!documents[i]['pass']) {
        failed = true;
      }
      children.add(
        TableRow(
          children: [
            tableField(
                '${documents[i]['rank']} ${documents[i]['name']}, ${documents[i]['firstName']}',
                2.75,
                failed),
            tableField(documents[i]['date'], 1.625, failed),
            tableField(documents[i]['puRaw'], 0.625, failed),
            tableField(documents[i]['puScore'].toString(), 0.625, failed),
            tableField(documents[i]['suRaw'], 0.625, failed),
            tableField(documents[i]['suScore'].toString(), 0.625, failed),
            tableField(documents[i]['runRaw'], 0.75, failed),
            tableField(documents[i]['runScore'].toString(), 0.75, failed),
            tableField(documents[i]['total'].toString(), 0.625, failed),
          ],
        ),
      );
    }

    return children;
  }

  TableRow fullPageAveRow() {
    return TableRow(
      children: [
        headerField('Average', 2.75),
        headerField('', 1.625),
        headerField('', 0.625),
        headerField(getAverages()['pu'].toString(), 0.625),
        headerField('', 0.625),
        headerField(getAverages()['su'].toString(), 0.625),
        headerField('', 0.75),
        headerField(getAverages()['run'].toString(), 0.625),
        headerField(getAverages()['total'].toString(), 0.75),
      ],
    );
  }

  TableRow halfPageTableHeader() {
    return TableRow(
      children: [
        headerField('Name', 2.5),
        headerField('Date', 1.5),
        headerField('PU', 0.625),
        headerField('SU', 0.625),
        headerField('Run', 0.625),
        headerField('Total', 0.625)
      ],
    );
  }

  List<TableRow> halfTableChildren(int startIndex, int endIndex) {
    List<TableRow> children = [];
    for (int i = startIndex; i <= endIndex; i++) {
      bool failed = false;
      if (!documents[i]['pass']) {
        failed = true;
      }
      children.add(
        TableRow(
          children: [
            tableField(
                '${documents[i]['rank']} ${documents[i]['name']}, ${documents[i]['firstName']}',
                2.5,
                failed),
            tableField(documents[i]['date'], 1.5, failed),
            tableField(documents[i]['puScore'].toString(), 0.625, failed),
            tableField(documents[i]['suScore'].toString(), 0.625, failed),
            tableField(documents[i]['runScore'].toString(), 0.625, failed),
            tableField(documents[i]['total'].toString(), 0.625, failed),
          ],
        ),
      );
    }
    return children;
  }

  TableRow halfPageAveRow() {
    return TableRow(
      children: [
        headerField('Average', 2.5),
        headerField('', 1.5),
        headerField(getAverages()['pu'].toString(), 0.625),
        headerField(getAverages()['su'].toString(), 0.625),
        headerField(getAverages()['run'].toString(), 0.625),
        headerField(getAverages()['total'].toString(), 0.625),
      ],
    );
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
                    fullPageTableHeader(),
                    ...fullTableChildren(startIndex, endIndex),
                    fullPageAveRow(),
                  ]),
            );
          },
        ),
      );
    }

    return pdfDownload(pdf, 'apftStats');
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
                    halfPageTableHeader(),
                    ...halfTableChildren(startIndex, endIndex),
                    halfPageAveRow(),
                  ]),
            );
          },
        ),
      );
    }

    return pdfDownload(pdf, 'apftStats');
  }
}
