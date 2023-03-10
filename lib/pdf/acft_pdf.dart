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
        child: Text(text, textAlign: textAlign),
      ),
    );
  }

  Widget headerField(String text, double width) {
    return SizedBox(
      width: width * 72,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Map<String, int> getAverages() {
    List<int> mdl = [];
    List<int> spt = [];
    List<int> hrp = [];
    List<int> sdc = [];
    List<int> plk = [];
    List<int> run = [];
    List<int> total = [];
    for (DocumentSnapshot doc in documents) {
      int events = 0;
      if (doc['deadliftScore'] != 0) {
        mdl.add(doc['deadliftScore']);
        events++;
      }
      if (doc['powerThrowScore'] != 0) {
        spt.add(doc['powerThrowScore']);
        events++;
      }
      if (doc['puScore'] != 0) {
        hrp.add(doc['puScore']);
        events++;
      }
      if (doc['dragScore'] != 0) {
        sdc.add(doc['dragScore']);
        events++;
      }
      if (doc['legTuckScore'] != 0) {
        plk.add(doc['legTuckScore']);
        events++;
      }
      if (doc['runScore'] != 0) {
        run.add(doc['runScore']);
        events++;
      }
      if (events == 6) {
        total.add(
            mdl.last + spt.last + hrp.last + sdc.last + plk.last + run.last);
      }
    }
    return <String, int>{
      'mdl': (mdl.reduce((value, element) => value + element) / mdl.length)
          .floor(),
      'spt': (spt.reduce((value, element) => value + element) / spt.length)
          .floor(),
      'hrp': (hrp.reduce((value, element) => value + element) / hrp.length)
          .floor(),
      'sdc': (sdc.reduce((value, element) => value + element) / sdc.length)
          .floor(),
      'plk': (plk.reduce((value, element) => value + element) / plk.length)
          .floor(),
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
        headerField('MDL', 0.75),
        headerField('SPT', 0.75),
        headerField('HRP', 0.75),
        headerField('SDC', 0.75),
        headerField('PLK', 0.75),
        headerField('2MR', 0.75),
        headerField('Date/Total', 1.75)
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
                failed,
                TextAlign.left),
            tableField(
                documents[i]['deadliftRaw'], 0.75, failed, TextAlign.left),
            tableField(
                documents[i]['powerThrowRaw'], 0.75, failed, TextAlign.left),
            tableField(documents[i]['puRaw'], 0.75, failed, TextAlign.left),
            tableField(documents[i]['dragRaw'], 0.75, failed, TextAlign.left),
            tableField(
                documents[i]['legTuckRaw'], 0.75, failed, TextAlign.left),
            tableField(documents[i]['runRaw'], 0.75, failed, TextAlign.left),
            tableField(documents[i]['date'], 1.75, failed, TextAlign.left),
          ],
        ),
      );
      children.add(
        TableRow(
          children: [
            tableField('', 2.75, failed, TextAlign.right),
            tableField(documents[i]['deadliftScore'].toString(), 0.75, failed,
                TextAlign.left),
            tableField(documents[i]['powerThrowScore'].toString(), 0.75, failed,
                TextAlign.left),
            tableField(documents[i]['puScore'].toString(), 0.75, failed,
                TextAlign.left),
            tableField(documents[i]['dragScore'].toString(), 0.75, failed,
                TextAlign.left),
            tableField(documents[i]['legTuckScore'].toString(), 0.75, failed,
                TextAlign.left),
            tableField(documents[i]['runScore'].toString(), 0.75, failed,
                TextAlign.left),
            tableField(
                documents[i]['total'].toString(), 1.75, failed, TextAlign.left),
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
        headerField(getAverages()['mdl'].toString(), 0.75),
        headerField(getAverages()['spt'].toString(), 0.75),
        headerField(getAverages()['hrp'].toString(), 0.75),
        headerField(getAverages()['sdc'].toString(), 0.75),
        headerField(getAverages()['plk'].toString(), 0.75),
        headerField(getAverages()['run'].toString(), 0.75),
        headerField(getAverages()['total'].toString(), 1.75),
      ],
    );
  }

  TableRow halfPageTableHeader() {
    return TableRow(
      children: [
        headerField('Name', 2.5),
        headerField('MDL/SDC', 0.875),
        headerField('SPT/LTK', 0.875),
        headerField('HRP/2MR', 0.875),
        headerField('Date/Total', 1.375),
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
                failed,
                TextAlign.left),
            tableField(documents[i]['deadliftScore'].toString(), 0.875, failed,
                TextAlign.left),
            tableField(documents[i]['powerThrowScore'].toString(), 0.875,
                failed, TextAlign.left),
            tableField(documents[i]['puScore'].toString(), 0.875, failed,
                TextAlign.left),
            tableField(
                documents[i]['date'].toString(), 1.375, failed, TextAlign.left),
          ],
        ),
      );
      children.add(
        TableRow(
          children: [
            tableField('', 2.5, failed, TextAlign.right),
            tableField(documents[i]['dragScore'].toString(), 0.875, failed,
                TextAlign.left),
            tableField(documents[i]['legTuckScore'].toString(), 0.875, failed,
                TextAlign.left),
            tableField(documents[i]['runScore'].toString(), 0.875, failed,
                TextAlign.left),
            tableField(documents[i]['total'].toString(), 1.375, failed,
                TextAlign.left),
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
        headerField(
            '${getAverages()['mdl'].toString()}/${getAverages()['sdc'].toString()}',
            0.875),
        headerField(
            '${getAverages()['spt'].toString()}/${getAverages()['plk'].toString()}',
            0.875),
        headerField(
            '${getAverages()['hrp'].toString()}/${getAverages()['run'].toString()}',
            0.875),
        headerField(getAverages()['total'].toString(), 1.375),
      ],
    );
  }

  Future<String> createFullPage() async {
    final Document pdf = Document();
    int pages = (documents.length / 8).ceil();

    for (int i = 1; i <= pages; i++) {
      int startIndex = i == 1 ? 0 : (i - 1) * 8;
      int endIndex = documents.length - 1;
      if (documents.length > i * 8) {
        endIndex = (i * 8) - 1;
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
                  if (endIndex == documents.length - 1) fullPageAveRow(),
                ],
              ),
            );
          },
        ),
      );
    }

    return pdfDownload(pdf, 'acftStats');
  }

  Future<String> createHalfPage() async {
    final Document pdf = Document();
    int pages = (documents.length / 5).ceil();

    for (int i = 1; i <= pages; i++) {
      int startIndex = i == 1 ? 0 : (i - 1) * 5;
      int endIndex = documents.length - 1;
      if (documents.length > i * 5) {
        endIndex = (i * 5) - 1;
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
                  if (endIndex == documents.length - 1) halfPageAveRow(),
                ],
              ),
            );
          },
        ),
      );
    }

    return pdfDownload(pdf, 'acftStats');
  }
}
