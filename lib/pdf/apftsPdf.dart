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
    int pu = 0,
        puNumber = 0,
        su = 0,
        suNumber = 0,
        run = 0,
        runNumber = 0,
        total = 0,
        totalNumber = 0;
    List<TableRow> children = [
      TableRow(children: [
        headerField('Name', 2.75),
        headerField('Date', 1.625),
        headerField('PU Raw', 0.625),
        headerField('PU Score', 0.625),
        headerField('SU Raw', 0.625),
        headerField('SU Score', 0.625),
        headerField('Run Raw', 0.75),
        headerField('Run Score', 0.75),
        headerField('Total', 0.625)
      ])
    ];
    for (DocumentSnapshot apft in documents) {
      if (apft['puScore'] != 0) {
        pu = pu + apft['puScore'];
        puNumber++;
      }
      if (apft['suScore'] != 0) {
        su = su + apft['suScore'];
        suNumber++;
      }
      if (apft['runScore'] != 0) {
        run = run + apft['runScore'];
        runNumber++;
      }
      if (apft['puScore'] != 0 &&
          apft['suScore'] != 0 &&
          apft['runScore'] != 0) {
        total = total + apft['puScore'] + apft['suScore'] + apft['runScore'];
        totalNumber++;
      }
      bool failed = false;
      if (!apft['pass']) {
        failed = true;
      }
      children.add(TableRow(children: [
        tableField('${apft['rank']} ${apft['name']}, ${apft['firstName']}',
            2.75, failed),
        tableField(apft['date'], 1.625, failed),
        tableField(apft['puRaw'], 0.625, failed),
        tableField(apft['puScore'].toString(), 0.625, failed),
        tableField(apft['suRaw'], 0.625, failed),
        tableField(apft['suScore'].toString(), 0.625, failed),
        tableField(apft['runRaw'], 0.75, failed),
        tableField(apft['runScore'].toString(), 0.75, failed),
        tableField(apft['total'].toString(), 0.625, failed),
      ]));
    }
    pu = pu ~/ puNumber;
    su = su ~/ suNumber;
    run = run ~/ runNumber;
    total = total ~/ totalNumber;

    children.add(TableRow(children: [
      headerField('Average', 2.75),
      headerField('', 1.625),
      headerField('', 0.625),
      headerField(pu.toString(), 0.625),
      headerField('', 0.625),
      headerField(su.toString(), 0.625),
      headerField('', 0.75),
      headerField(run.toString(), 0.625),
      headerField(total.toString(), 0.75),
    ]));

    return children;
  }

  List<TableRow> halfTableChildren() {
    int pu = 0,
        puNumber = 0,
        su = 0,
        suNumber = 0,
        run = 0,
        runNumber = 0,
        total = 0,
        totalNumber = 0;
    List<TableRow> children = [
      TableRow(children: [
        headerField('Name', 2.5),
        headerField('Date', 1.5),
        headerField('PU', 0.625),
        headerField('SU', 0.625),
        headerField('Run', 0.625),
        headerField('Total', 0.625)
      ])
    ];
    for (DocumentSnapshot apft in documents) {
      if (apft['puScore'] != 0) {
        pu = pu + apft['puScore'];
        puNumber++;
      }
      if (apft['suScore'] != 0) {
        su = su + apft['suScore'];
        suNumber++;
      }
      if (apft['runScore'] != 0) {
        run = run + apft['runScore'];
        runNumber++;
      }
      if (apft['puScore'] != 0 &&
          apft['suScore'] != 0 &&
          apft['runScore'] != 0) {
        total = total + apft['puScore'] + apft['suScore'] + apft['runScore'];
        totalNumber++;
      }
      bool failed = false;
      if (!apft['pass']) {
        failed = true;
      }
      children.add(TableRow(children: [
        tableField('${apft['rank']} ${apft['name']}, ${apft['firstName']}', 2.5,
            failed),
        tableField(apft['date'], 1.5, failed),
        tableField(apft['puScore'].toString(), 0.625, failed),
        tableField(apft['suScore'].toString(), 0.625, failed),
        tableField(apft['runScore'].toString(), 0.625, failed),
        tableField(apft['total'].toString(), 0.625, failed),
      ]));
    }
    pu = pu ~/ puNumber;
    su = su ~/ suNumber;
    run = run ~/ runNumber;
    total = total ~/ totalNumber;

    children.add(TableRow(children: [
      headerField('Average', 2.5),
      headerField('', 1.5),
      headerField(pu.toString(), 0.625),
      headerField(su.toString(), 0.625),
      headerField(run.toString(), 0.625),
      headerField(total.toString(), 0.625),
    ]));
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

    return pdfDownload(pdf, 'apftStats');
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

    return pdfDownload(pdf, 'apftStats');
  }
}
