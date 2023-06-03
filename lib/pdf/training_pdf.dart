import 'dart:async';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../methods/download_methods.dart';
import '../models/training.dart';

class TrainingPdf {
  TrainingPdf({
    required this.trainings,
  });

  final List<Training> trainings;

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

  List<Row> halfPageAddTraining(List<dynamic> addTrainings) {
    List<Row> rows = [];
    int loopLength = addTrainings.length > 20 ? 20 : addTrainings.length;
    for (int i = 0; i < loopLength; i++) {
      if (i.isEven) {
        rows.add(
          Row(
            children: [
              createLabeledField(
                  addTrainings[i]['date'], addTrainings[i]['name'], 2.375),
              i + 1 < loopLength
                  ? createLabeledField(addTrainings[i + 1]['date'],
                      addTrainings[i + 1]['name'], 2.375)
                  : createField('', 2.375),
            ],
          ),
        );
      }
    }
    int extraLoopLength = 20 - loopLength;
    if (extraLoopLength > 0) {
      extraLoopLength = (extraLoopLength / 2).floor();
    }
    for (int i = 0; i < extraLoopLength; i++) {
      rows.add(
        Row(
          children: [
            createField('', 2.375),
            createField('', 2.375),
          ],
        ),
      );
    }
    return rows;
  }

  List<Widget> halfPageColumn(Training training) {
    return [
      Row(
        children: [
          createField(
              '${training.rank} ${training.name}, ${training.firstName}',
              2.375),
          createField(training.section, 2.375),
        ],
      ),
      Row(
        children: [
          createLabeledField(training.cyber, 'Cyber', 2.375),
          createLabeledField(training.gat, 'GAT', 2.375),
        ],
      ),
      Row(
        children: [
          createLabeledField(training.opsec, 'OPSEC', 2.375),
          createLabeledField(training.sere, 'SERE', 2.375),
        ],
      ),
      Row(
        children: [
          createLabeledField(training.antiTerror, 'AT Lvl 1', 2.375),
          createLabeledField(training.tarp, 'Tarp', 2.375),
        ],
      ),
      Row(
        children: [
          createLabeledField(training.lawOfWar, 'Law of War', 2.375),
          createLabeledField(training.eo, 'EO', 2.375),
        ],
      ),
      Row(
        children: [
          createLabeledField(training.persRec, 'Pers Recovery', 2.375),
          createLabeledField(training.asap, 'ASAP', 2.375),
        ],
      ),
      Row(
        children: [
          createLabeledField(training.infoSec, 'Info Security', 2.375),
          createLabeledField(training.suicide, 'Suicide Prev', 2.375),
        ],
      ),
      Row(
        children: [
          createLabeledField(training.ctip, 'CTIP', 2.375),
          createLabeledField(training.sharp, 'SHARP', 2.375),
        ],
      ),
      ...halfPageAddTraining(training.addTraining!),
    ];
  }

  List<Row> fullPageAddTraining(List<dynamic> addTrainings) {
    List<Row> rows = [];
    int loopLength = addTrainings.length > 24 ? 24 : addTrainings.length;
    for (int i = 0; i < loopLength; i++) {
      if (i.isEven) {
        rows.add(
          Row(
            children: [
              createField(addTrainings[i]['name'], 2.0),
              createField(addTrainings[i]['date'], 1.25),
              createField(
                  i + 1 < loopLength ? addTrainings[i + 1]['name'] : '', 2.0),
              createField(
                  i + 1 < loopLength ? addTrainings[i + 1]['date'] : '', 1.25),
            ],
          ),
        );
      }
    }
    int extraLoopLength = 24 - loopLength;
    if (extraLoopLength > 0) {
      extraLoopLength = (extraLoopLength / 2).floor();
    }
    for (int i = 0; i < extraLoopLength; i++) {
      rows.add(
        Row(
          children: [
            createField('', 2.0),
            createField('', 1.25),
            createField('', 2.0),
            createField('', 1.25),
          ],
        ),
      );
    }
    return rows;
  }

  Future<String> createFullPage() async {
    final Document pdf = Document();

    for (Training training in trainings) {
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
                        '${training.rank}, ${training.name}, ${training.firstName}',
                        'Name',
                        3.25),
                    createLabeledField(training.section, 'Section', 3.25),
                  ],
                ),
                Row(
                  children: [
                    createField('Cyber Awareness', 2.0),
                    createField(training.cyber, 1.25),
                    createField('GAT', 2.0),
                    createField(training.gat, 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField('OPSEC', 2.0),
                    createField(training.opsec, 1.25),
                    createField('SERE', 2.0),
                    createField(training.sere, 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField('AT Level 1', 2.0),
                    createField(training.antiTerror, 1.25),
                    createField('TARP', 2.0),
                    createField(training.tarp, 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField('Law of War', 2.0),
                    createField(training.lawOfWar, 1.25),
                    createField('Equal Opportunity', 2.0),
                    createField(training.eo, 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField('Personnel Recovery', 2.0),
                    createField(training.persRec, 1.25),
                    createField('ASAP', 2.0),
                    createField(training.asap, 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField('Information Security', 2.0),
                    createField(training.infoSec, 1.25),
                    createField('Suicide Prevention', 2.0),
                    createField(training.suicide, 1.25),
                  ],
                ),
                Row(
                  children: [
                    createField('CTIP', 2.0),
                    createField(training.ctip, 1.25),
                    createField('SHARP', 2.0),
                    createField(training.sharp, 1.25),
                  ],
                ),
                ...fullPageAddTraining(training.addTraining!),
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

    for (int i = 0; i < trainings.length; i += 2) {
      pdf.addPage(
        Page(
          pageFormat: PdfPageFormat.letter,
          orientation: PageOrientation.landscape,
          margin: const EdgeInsets.all(0.75 * 72.0),
          build: (Context context) {
            return Row(
              children: [
                Column(
                  children: halfPageColumn(trainings[i]),
                ),
                Column(
                  children: i + 1 == trainings.length
                      ? [SizedBox()]
                      : halfPageColumn(trainings[i + 1]),
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
