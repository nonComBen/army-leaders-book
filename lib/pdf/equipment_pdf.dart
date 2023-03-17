import 'dart:async';
import 'package:leaders_book/methods/download_methods.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentPdf {
  EquipmentPdf({
    required this.documents,
  });

  final List<DocumentSnapshot> documents;

  Widget createLabeledField(String? value, String label, double inches) {
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
          createLabeledField(doc['weapon'], 'Weapon', 1.75),
          createLabeledField(doc['buttStock'], 'Butt Stock', 1.375),
          createLabeledField(doc['serial'], 'Serial', 1.625),
        ],
      ),
      Row(
        children: [
          createLabeledField(doc['optic'], 'Optics', 2.375),
          createLabeledField(doc['opticSerial'], 'Serial', 2.375),
        ],
      ),
      Row(
        children: [
          createLabeledField(doc['weapon2'], '2nd Weapon', 1.75),
          createLabeledField(doc['buttStock2'], 'Butt Stock', 1.375),
          createLabeledField(doc['serial2'], 'Serial', 1.625),
        ],
      ),
      Row(
        children: [
          createLabeledField(doc['optic2'], '2nd Optics', 2.375),
          createLabeledField(doc['opticSerial2'], 'Serial', 2.375),
        ],
      ),
      Row(
        children: [
          createLabeledField(doc['mask'], 'Mask', 1.25),
          createLabeledField(doc['vehType'], 'Vehicle', 2.0),
          createLabeledField(doc['veh'], 'Bumper', 1.5),
        ],
      ),
      Row(
        children: [
          createField(doc['misc'], 2.375),
          createLabeledField(doc['miscSerial'], 'Serial #', 2.375),
        ],
      ),
      Row(
        children: [
          createField('', 2.375),
          createLabeledField('', 'Serial #', 2.375),
        ],
      ),
      Row(
        children: [
          createField('', 2.375),
          createLabeledField('', 'Serial #', 2.375),
        ],
      ),
      Row(
        children: [
          createField('', 2.375),
          createLabeledField('', 'Serial #', 2.375),
        ],
      ),
      Row(
        children: [
          createField('', 2.375),
          createLabeledField('', 'Serial #', 2.375),
        ],
      ),
      Row(
        children: [
          createField('', 2.375),
          createLabeledField('', 'Serial #', 2.375),
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
                    createLabeledField(document['weapon'], 'Weapon', 2.5),
                    createLabeledField(
                        document['buttStock'], 'Butt Stock #', 1.75),
                    createLabeledField(document['serial'], 'Serial #', 2.25),
                  ],
                ),
                Row(
                  children: [
                    createLabeledField(document['optic'], 'Optics', 3.25),
                    createLabeledField(
                        document['opticSerial'], 'Optics Serial #', 3.25),
                  ],
                ),
                Row(
                  children: [
                    createLabeledField(
                        document['weapon2'], 'Secondary Weapon', 2.5),
                    createLabeledField(
                        document['buttStock2'], 'Butt Stock #', 1.75),
                    createLabeledField(document['serial2'], 'Serial 2 #', 2.25),
                  ],
                ),
                Row(
                  children: [
                    createLabeledField(
                        document['optic2'], 'Secondary Optics', 3.25),
                    createLabeledField(
                        document['opticSerial2'], 'Serial #', 3.25),
                  ],
                ),
                Row(
                  children: [
                    createLabeledField(document['mask'], 'Mask #', 1.75),
                    createLabeledField(document['vehType'], 'Vehicle', 2.5),
                    createLabeledField(document['veh'], 'Bumper #', 2.25),
                  ],
                ),
                Row(
                  children: [
                    createField(document['misc'], 3.25),
                    createLabeledField(
                        document['miscSerial'], 'Serial #', 3.25),
                  ],
                ),
                Row(
                  children: [
                    createField('', 3.25),
                    createLabeledField('', 'Serial #', 3.25),
                  ],
                ),
                Row(
                  children: [
                    createField('', 3.25),
                    createLabeledField('', 'Serial #', 3.25),
                  ],
                ),
                Row(
                  children: [
                    createField('', 3.25),
                    createLabeledField('', 'Serial #', 3.25),
                  ],
                ),
                Row(
                  children: [
                    createField('', 3.25),
                    createLabeledField('', 'Serial #', 3.25),
                  ],
                ),
                Row(
                  children: [
                    createField('', 3.25),
                    createLabeledField('', 'Serial #', 3.25),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    return pdfDownload(pdf, 'equipment');
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
                  children: halfPageColumn(
                    documents[i],
                  ),
                ),
                Column(
                  children: i + 1 == documents.length
                      ? [SizedBox()]
                      : halfPageColumn(
                          documents[i + 1],
                        ),
                )
              ],
            );
          },
        ),
      );
    }

    return pdfDownload(pdf, 'equipment');
  }
}
