// ignore_for_file: file_names

import 'dart:async';
import 'package:leaders_book/methods/download_methods.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AcftsPdf {
  AcftsPdf(
    this.documents,
  );

  final List<DocumentSnapshot> documents;

  Widget tableField(
      String text, double width, bool failed, TextAlign textAlign) {
    return SizedBox(
        width: width * 72,
        height: 24.0,
        child: Container(
            padding: const EdgeInsets.all(5.0),
            decoration:
                failed ? const BoxDecoration(color: PdfColor(1, 0, 0)) : null,
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
    int mdl = 0,
        mdlNumber = 0,
        spt = 0,
        sptNumber = 0,
        pu = 0,
        puNumber = 0,
        sdc = 0,
        sdcNumber = 0,
        plk = 0,
        plkNumber = 0,
        run = 0,
        runNumber = 0,
        total = 0,
        totalNumber = 0;
    List<TableRow> children = [
      TableRow(children: [
        headerField('Name', 2.75),
        headerField('MDL', 0.75),
        headerField('SPT', 0.75),
        headerField('HRP', 0.75),
        headerField('SDC', 0.75),
        headerField('PLK', 0.75),
        headerField('2MR', 0.75),
        headerField('Date/Total', 1.75)
      ])
    ];
    for (DocumentSnapshot acft in documents) {
      if (acft['deadliftScore'] != 0) {
        mdl = mdl + acft['deadliftScore'];
        mdlNumber++;
      }
      if (acft['powerThrowScore'] != 0) {
        spt = spt + acft['powerThrowScore'];
        sptNumber++;
      }
      if (acft['puScore'] != 0) {
        pu = pu + acft['puScore'];
        puNumber++;
      }
      if (acft['dragScore'] != 0) {
        sdc = sdc + acft['dragScore'];
        sdcNumber++;
      }
      if (acft['legTuckScore'] != 0) {
        plk = plk + acft['legTuckScore'];
        plkNumber++;
      }
      if (acft['runScore'] != 0) {
        run = run + acft['runScore'];
        runNumber++;
      }
      if (acft['deadliftScore'] != 0 &&
          acft['powerThrowScore'] != 0 &&
          acft['puScore'] != 0 &&
          acft['dragScore'] != 0 &&
          acft['legTuckScore'] != 0 &&
          acft['runScore'] != 0) {
        total = total +
            acft['deadliftScore'] +
            acft['powerThrowScore'] +
            acft['puScore'] +
            acft['dragScore'] +
            acft['legTuckScore'] +
            acft['runScore'];
        totalNumber++;
      }
      bool failed = false;
      if (!acft['pass']) {
        failed = true;
      }
      children.add(TableRow(children: [
        tableField('${acft['rank']} ${acft['name']}, ${acft['firstName']}',
            2.75, failed, TextAlign.left),
        tableField(acft['deadliftRaw'], 0.75, failed, TextAlign.left),
        tableField(acft['powerThrowRaw'], 0.75, failed, TextAlign.left),
        tableField(acft['puRaw'], 0.75, failed, TextAlign.left),
        tableField(acft['dragRaw'], 0.75, failed, TextAlign.left),
        tableField(acft['legTuckRaw'], 0.75, failed, TextAlign.left),
        tableField(acft['runRaw'], 0.75, failed, TextAlign.left),
        tableField(acft['date'], 1.75, failed, TextAlign.left),
      ]));
      children.add(TableRow(children: [
        tableField('', 2.75, failed, TextAlign.right),
        tableField(
            acft['deadliftScore'].toString(), 0.75, failed, TextAlign.left),
        tableField(
            acft['powerThrowScore'].toString(), 0.75, failed, TextAlign.left),
        tableField(acft['puScore'].toString(), 0.75, failed, TextAlign.left),
        tableField(acft['dragScore'].toString(), 0.75, failed, TextAlign.left),
        tableField(
            acft['legTuckScore'].toString(), 0.75, failed, TextAlign.left),
        tableField(acft['runScore'].toString(), 0.75, failed, TextAlign.left),
        tableField(acft['total'].toString(), 1.75, failed, TextAlign.left),
      ]));
    }
    mdl = mdl ~/ mdlNumber;
    spt = spt ~/ sptNumber;
    pu = pu ~/ puNumber;
    sdc = sdc ~/ sdcNumber;
    plk = plk ~/ plkNumber;
    run = run ~/ runNumber;
    total = total ~/ totalNumber;

    children.add(TableRow(children: [
      headerField('Average', 2.75),
      headerField(mdl.toString(), 0.75),
      headerField(spt.toString(), 0.75),
      headerField(pu.toString(), 0.75),
      headerField(sdc.toString(), 0.75),
      headerField(plk.toString(), 0.75),
      headerField(run.toString(), 0.75),
      headerField(total.toString(), 1.75),
    ]));

    return children;
  }

  List<TableRow> halfTableChildren() {
    int mdl = 0,
        mdlNumber = 0,
        spt = 0,
        sptNumber = 0,
        pu = 0,
        puNumber = 0,
        sdc = 0,
        sdcNumber = 0,
        plk = 0,
        plkNumber = 0,
        run = 0,
        runNumber = 0,
        total = 0,
        totalNumber = 0;
    List<TableRow> children = [
      TableRow(children: [
        headerField('Name', 2.5),
        headerField('MDL/SDC', 0.875),
        headerField('SPT/LTK', 0.875),
        headerField('HRP/2MR', 0.875),
        headerField('Date/Total', 1.375),
      ])
    ];
    for (DocumentSnapshot acft in documents) {
      if (acft['deadliftScore'] != 0) {
        mdl = mdl + acft['deadliftScore'];
        mdlNumber++;
      }
      if (acft['powerThrowScore'] != 0) {
        spt = spt + acft['powerThrowScore'];
        sptNumber++;
      }
      if (acft['puScore'] != 0) {
        pu = pu + acft['puScore'];
        puNumber++;
      }
      if (acft['dragScore'] != 0) {
        sdc = sdc + acft['dragScore'];
        sdcNumber++;
      }
      if (acft['legTuckScore'] != 0) {
        plk = plk + acft['legTuckScore'];
        plkNumber++;
      }
      if (acft['runScore'] != 0) {
        run = run + acft['runScore'];
        runNumber++;
      }
      if (acft['deadliftScore'] != 0 &&
          acft['powerThrowScore'] != 0 &&
          acft['puScore'] != 0 &&
          acft['dragScore'] != 0 &&
          acft['legTuckScore'] != 0 &&
          acft['runScore'] != 0) {
        total = total +
            acft['deadliftScore'] +
            acft['powerThrowScore'] +
            acft['puScore'] +
            acft['dragScore'] +
            acft['legTuckScore'] +
            acft['runScore'];
        totalNumber++;
      }
      bool failed = false;
      if (!acft['pass']) {
        failed = true;
      }
      children.add(TableRow(children: [
        tableField('${acft['rank']} ${acft['name']}, ${acft['firstName']}', 2.5,
            failed, TextAlign.left),
        tableField(
            acft['deadliftScore'].toString(), 0.875, failed, TextAlign.left),
        tableField(
            acft['powerThrowScore'].toString(), 0.875, failed, TextAlign.left),
        tableField(acft['puScore'].toString(), 0.875, failed, TextAlign.left),
        tableField(acft['date'].toString(), 1.375, failed, TextAlign.left),
      ]));
      children.add(TableRow(children: [
        tableField('', 2.5, failed, TextAlign.right),
        tableField(acft['dragScore'].toString(), 0.875, failed, TextAlign.left),
        tableField(
            acft['legTuckScore'].toString(), 0.875, failed, TextAlign.left),
        tableField(acft['runScore'].toString(), 0.875, failed, TextAlign.left),
        tableField(acft['total'].toString(), 1.375, failed, TextAlign.left),
      ]));
    }
    mdl = mdl ~/ mdlNumber;
    spt = spt ~/ sptNumber;
    pu = pu ~/ puNumber;
    sdc = sdc ~/ sdcNumber;
    plk = plk ~/ plkNumber;
    run = run ~/ runNumber;
    total = total ~/ totalNumber;

    children.add(TableRow(children: [
      headerField('Average', 2.5),
      headerField('${mdl.toString()}/${spt.toString()}', 0.875),
      headerField('${pu.toString()}/${sdc.toString()}', 0.875),
      headerField('${plk.toString()}/${run.toString()}', 0.875),
      headerField(total.toString(), 1.375),
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

    return pdfDownload(pdf, 'acftStats');
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

    return pdfDownload(pdf, 'acftStats');
  }
}
