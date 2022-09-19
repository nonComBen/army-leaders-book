// ignore_for_file: file_names

import 'dart:async';
import 'package:leaders_book/methods/download_methods.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HandReceiptPdf {
  HandReceiptPdf(
    this.documents,
  );

  final List<DocumentSnapshot> documents;

  Widget createLabeledField(String value, String label, double inches) {
    double width = inches * 72;
    return DecoratedBox(
        decoration: const BoxDecoration(
            border: TableBorder(
                left: BorderSide(),
                top: BorderSide(),
                right: BorderSide(),
                bottom: BorderSide())),
        child: SizedBox(
            width: width,
            height: 28,
            child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('$label: $value'))));
  }

  Widget createField(String value, double inches) {
    double width = inches * 72;
    return DecoratedBox(
        decoration: const BoxDecoration(
            border: TableBorder(
                left: BorderSide(),
                top: BorderSide(),
                right: BorderSide(),
                bottom: BorderSide())),
        child: SizedBox(
            width: width,
            height: 28,
            child: Padding(
                padding: const EdgeInsets.all(5.0), child: Text(value))));
  }

  List<Widget> halfPageColumn(DocumentSnapshot doc) {
    return [
      Row(children: [
        createField(
            '${doc['rank']} ${doc['name']}, ${doc['firstName']}', 2.375),
        createField(doc['item'], 2.375),
      ]),
      Row(children: [
        createLabeledField(doc['model'], 'Model', 1.75),
        createLabeledField(doc['serial'], 'Serial', 1.5),
        createLabeledField(doc['nsn'], 'NSN', 1.5),
      ]),
      Row(children: [
        createLabeledField(doc['value'], 'Value', 2.375),
        createLabeledField(doc['location'], 'Location', 2.375),
      ]),
      subComponentsHalfPage(doc['subComponents']),
      Row(children: [
        createLabeledField(doc['comments'], 'Comments', 4.75),
      ]),
    ];
  }

  Widget subComponentsHalfPage(List<dynamic> list) {
    return ListView.builder(
        itemBuilder: (context, index) {
          return Row(children: [
            createLabeledField(list[index]['item'], 'Sub', 1.75),
            createLabeledField(list[index]['nsn'], 'NSN', 1.875),
            createLabeledField(
                '${list[index]['onHand']}/${list[index]['required']}',
                'Qty',
                1.125),
          ]);
        },
        itemCount: list.length);
  }

  Widget subComponentsFullPage(List<dynamic> list) {
    List<Widget> children = [];
    for (int i = 0; i < list.length; i = i + 2) {
      children.add(Row(children: [
        createField(list[i]['item'], 1.25),
        createField(list[i]['nsn'], 1.25),
        createField('${list[i]['onHand']}/${list[i]['required']}', 0.75),
        if (i + 1 < list.length) createField(list[i + 1]['item'], 1.25),
        if (i + 1 < list.length) createField(list[i + 1]['nsn'], 1.25),
        if (i + 1 < list.length)
          createField(
              '${list[i + 1]['onHand']}/${list[i + 1]['required']}', 0.75),
        if (i + 1 >= list.length) createField('', 3.25)
      ]));
    }
    return Column(children: children);
  }

  Future<String> createFullPage() async {
    final Document pdf = Document();

    for (DocumentSnapshot document in documents) {
      pdf.addPage(Page(
          pageFormat: PdfPageFormat.letter,
          orientation: PageOrientation.portrait,
          margin: const EdgeInsets.all(72.0),
          build: (Context context) {
            return Column(children: [
              Row(children: [
                createLabeledField(
                    '${document['rank']} ${document['name']}, ${document['firstName']}',
                    'Name',
                    3.25),
                createLabeledField(document['item'], 'Item', 3.25),
              ]),
              Row(children: [
                createLabeledField(document['model'], 'Model #', 2.25),
                createLabeledField(document['serial'], 'Serial #', 2.00),
                createLabeledField(document['nsn'], 'NSN #', 2.25),
              ]),
              Row(children: [
                createLabeledField(document['value'], 'Value', 3.25),
                createLabeledField(document['location'], 'Location', 3.25),
              ]),
              subComponentsFullPage(document['subComponents']),
              Row(children: [
                createLabeledField(document['comments'], 'Comments', 6.50),
              ]),
            ]);
          }));
    }

    return pdfDownload(pdf, 'handReceipt');
  }

  Future<String> createHalfPage() async {
    final Document pdf = Document();

    for (int i = 0; i < documents.length; i += 2) {
      pdf.addPage(Page(
          pageFormat: PdfPageFormat.letter,
          orientation: PageOrientation.landscape,
          margin: const EdgeInsets.all(0.75 * 72.0),
          build: (Context context) {
            return Row(children: [
              Column(children: halfPageColumn(documents[i])),
              Column(
                  children: i + 1 == documents.length
                      ? [SizedBox()]
                      : halfPageColumn(documents[i + 1]))
            ]);
          }));
    }

    return pdfDownload(pdf, 'handReceipt');
  }
}
