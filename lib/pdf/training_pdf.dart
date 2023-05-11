import 'dart:async';
import 'package:leaders_book/methods/download_methods.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingPdf {
  TrainingPdf({
    required this.documents,
  });

  final List<DocumentSnapshot> documents;

  Widget createLabeledField(String? value, String? label, double inches) {
    double width = inches * 72;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: TableBorder.all(),
      ),
      child: SizedBox(
        width: width,
        height: 28,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text('$label: $value'),
        ),
      ),
    );
  }

  Widget createField(String value, double inches) {
    double width = inches * 72;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: TableBorder.all(),
      ),
      child: SizedBox(
        width: width,
        height: 28,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(value),
        ),
      ),
    );
  }

  List<Widget> halfPageColumn(DocumentSnapshot doc) {
    return [
      Row(
        children: [
          createField(
              '${doc['rank']} ${doc['name']}, ${doc['firstName']}', 2.375),
          createField(doc['section'], 2.375),
        ],
      ),
      Row(
        children: [
          createLabeledField(doc['cyber'], 'Cyber', 2.375),
          createLabeledField(doc['gat'], 'GAT', 2.375),
        ],
      ),
      Row(
        children: [
          createLabeledField(doc['opsec'], 'OPSEC', 2.375),
          createLabeledField(doc['sere'], 'SERE', 2.375),
        ],
      ),
      Row(
        children: [
          createLabeledField(doc['antiTerror'], 'AT Lvl 1', 2.375),
          createLabeledField(doc['tarp'], 'Tarp', 2.375),
        ],
      ),
      Row(
        children: [
          createLabeledField(doc['lawOfWar'], 'Law of War', 2.375),
          createLabeledField(doc['eo'], 'EO', 2.375),
        ],
      ),
      Row(
        children: [
          createLabeledField(doc['persRec'], 'Pers Recovery', 2.375),
          createLabeledField(doc['asap'], 'ASAP', 2.375),
        ],
      ),
      Row(
        children: [
          createLabeledField(doc['infoSec'], 'Info Security', 2.375),
          createLabeledField(doc['suicide'], 'Suicide Prev', 2.375),
        ],
      ),
      Row(
        children: [
          createLabeledField(doc['ctip'], 'CTIP', 2.375),
          createLabeledField(doc['sharp'], 'SHARP', 2.375),
        ],
      ),
      Row(
        children: [
          doc['add1'] == ''
              ? createField('', 2.375)
              : createLabeledField(doc['add1Date'], doc['add1'], 2.375),
          doc['add2'] == ''
              ? createField('', 2.375)
              : createLabeledField(doc['add2Date'], doc['add2'], 2.375),
        ],
      ),
      Row(
        children: [
          doc['add3'] == ''
              ? createField('', 2.375)
              : createLabeledField(doc['add3Date'], doc['add3'], 2.375),
          doc['add4'] == ''
              ? createField('', 2.375)
              : createLabeledField(doc['add4Date'], doc['add4'], 2.375),
        ],
      ),
      Row(
        children: [
          doc['add5'] == ''
              ? createField('', 2.375)
              : createLabeledField(doc['add5Date'], doc['add5'], 2.375),
          createField('', 2.375),
        ],
      ),
      Row(
        children: [
          createField('', 2.375),
          createField('', 2.375),
        ],
      ),
      Row(
        children: [
          createField('', 2.375),
          createField('', 2.375),
        ],
      ),
      Row(
        children: [
          createField('', 2.375),
          createField('', 2.375),
        ],
      ),
    ];
  }

  Future<String> createFullPage() async {
    final Document pdf = Document();

    for (DocumentSnapshot document in documents) {
      pdf.addPage(
        Page(
          pageFormat: PdfPageFormat.letter,
          orientation: PageOrientation.portrait,
          margin: const EdgeInsets.all(72.0),
          build: (Context context) {
            return Column(
              children: [
                Row(
                  children: [
                    createLabeledField(
                        '${document['rank']}, ${document['name']}, ${document['firstName']}',
                        'Name',
                        3.25),
                    createLabeledField(document['section'], 'Section', 3.25),
                  ],
                ),
                Row(
                  children: [
                    createField('Cyber Awareness', 2.0),
                    createField(document['cyber'], 1.25),
                    createField('GAT', 2.0),
                    createField(document['gat'], 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField('OPSEC', 2.0),
                    createField(document['opsec'], 1.25),
                    createField('SERE', 2.0),
                    createField(document['sere'], 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField('AT Level 1', 2.0),
                    createField(document['antiTerror'], 1.25),
                    createField('TARP', 2.0),
                    createField(document['tarp'], 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField('Law of War', 2.0),
                    createField(document['lawOfWar'], 1.25),
                    createField('Equal Opportunity', 2.0),
                    createField(document['eo'], 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField('Personnel Recovery', 2.0),
                    createField(document['persRec'], 1.25),
                    createField('ASAP', 2.0),
                    createField(document['asap'], 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField('Information Security', 2.0),
                    createField(document['infoSec'], 1.25),
                    createField('Suicide Prevention', 2.0),
                    createField(document['suicide'], 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField('CTIP', 2.0),
                    createField(document['ctip'], 1.25),
                    createField('SHARP', 2.0),
                    createField(document['sharp'], 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField(document['add1'], 2.0),
                    createField(document['add1Date'], 1.25),
                    createField(document['add2'], 2.0),
                    createField(document['add2Date'], 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField(document['add3'], 2.0),
                    createField(document['add3Date'], 1.25),
                    createField(document['add4'], 2.0),
                    createField(document['add4Date'], 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField(document['add5'], 2.0),
                    createField(document['add5Date'], 1.25),
                    createField('', 2.0),
                    createField('', 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField('', 2.0),
                    createField('', 1.25),
                    createField('', 2.0),
                    createField('', 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField('', 2.0),
                    createField('', 1.25),
                    createField('', 2.0),
                    createField('', 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField('', 2.0),
                    createField('', 1.25),
                    createField('', 2.0),
                    createField('', 1.25),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    return pdfDownload(pdf, 'training');
  }

  Future<String> createHalfPage() async {
    final Document pdf = Document();

    for (int i = 0; i < documents.length; i += 2) {
      pdf.addPage(
        Page(
          pageFormat: PdfPageFormat.letter,
          orientation: PageOrientation.landscape,
          margin: const EdgeInsets.all(0.75 * 72.0),
          build: (Context context) {
            return Row(
              children: [
                Column(
                  children: halfPageColumn(documents[i]),
                ),
                Column(
                  children: i + 1 == documents.length
                      ? [SizedBox()]
                      : halfPageColumn(documents[i + 1]),
                )
              ],
            );
          },
        ),
      );
    }

    return pdfDownload(pdf, 'training');
  }
}
