import 'dart:async';
import 'package:leaders_book/methods/download_methods.dart';
import 'package:leaders_book/models/soldier.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SoldierPdf {
  SoldierPdf({this.soldiers, this.userId});
  final List<Soldier> soldiers;
  final String userId;

  Widget createField(String value, String label, double inches) {
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
            child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('$label: $value'))));
  }

  Widget awardField(String text, double inches) {
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
            child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(text, textAlign: TextAlign.center))));
  }

  Widget tableField(String text, double width) {
    return SizedBox(
        width: width * 72,
        height: 24.0,
        child: Padding(padding: const EdgeInsets.all(5.0), child: Text(text)));
  }

  Future<String> createPdf(bool fullPage) async {
    final Document pdf = Document();

    for (Soldier soldier in soldiers) {
      DocumentSnapshot pov;
      DocumentSnapshot pov2;
      QuerySnapshot povSnapshot = await FirebaseFirestore.instance
          .collection('povs')
          .where('owner', isEqualTo: userId)
          .where('soldierId', isEqualTo: soldier.id)
          .get();
      if (povSnapshot.docs.isNotEmpty) {
        pov = povSnapshot.docs[0];
        if (povSnapshot.docs.length > 1) {
          pov2 = povSnapshot.docs[1];
        }
      }

      QuerySnapshot awardSnapshot = await FirebaseFirestore.instance
          .collection('awards')
          .where('owner', isEqualTo: userId)
          .where('soldierId', isEqualTo: soldier.id)
          .get();
      List<DocumentSnapshot> awards = awardSnapshot.docs;

      if (fullPage) {
        pdf.addPage(Page(
            pageFormat: PdfPageFormat.letter,
            orientation: PageOrientation.portrait,
            margin: const EdgeInsets.all(72.0),
            build: (Context context) {
              return Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          createField(
                              '${soldier.rank}${soldier.promotable} ${soldier.lastName}, ${soldier.firstName} ${soldier.mi}',
                              'Name',
                              3.25),
                          createField(soldier.supervisor, 'Supervisor', 3.25)
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          createField(soldier.section, 'Section', 3.25),
                          createField(soldier.duty, 'Duty Position', 3.25)
                        ]),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          createField(
                              soldier.dodId ?? soldier.dodId, 'DoD ID', 2.16),
                          createField('', 'DOB', 2.16),
                          createField(soldier.dor, 'DOR', 2.17)
                        ]),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          createField(soldier.mos, 'MOS', 2.16),
                          createField(soldier.paraLn, 'Para/Ln', 2.16),
                          createField(soldier.reqMos, 'Duty MOS', 2.17),
                        ]),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          createField(soldier.gainDate, 'Gain Date', 3.25),
                          createField(soldier.lossDate, 'Loss Date', 3.25)
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          createField(soldier.basd, 'BASD', 2.16),
                          createField(soldier.pebd, 'PEBD', 2.16),
                          createField(soldier.ets, 'ETS', 2.17)
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          createField(soldier.milEd, 'Mil Ed Level', 3.25),
                          createField(soldier.civEd, 'Civilian Ed', 3.25)
                        ]),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          createField(
                              soldier.nbcSuitSize ?? '', 'CBRN Suit', 2.16),
                          createField(
                              soldier.nbcMaskSize ?? '', 'CBRN Mask', 2.16),
                          createField(
                              soldier.nbcBootSize ?? '', 'CBRN Boot', 2.17),
                        ]),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          createField(
                              soldier.nbcGloveSize ?? '', 'CBRN Glove', 2.16),
                          createField(soldier.hatSize ?? '', 'Hat Size', 2.16),
                          createField(
                              soldier.bootSize ?? '', 'Boot Size', 2.17),
                        ]),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          createField(
                              soldier.acuTopSize ?? '', 'OCP Top Size', 3.25),
                          createField(soldier.acuTrouserSize ?? '',
                              'OCP Trouser Size', 3.25),
                        ]),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          createField(soldier.address ?? '', 'Address', 4.33),
                          createField(soldier.phone, 'Cell No', 2.17)
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          createField(
                              '${soldier.city ?? ''}, ${soldier.state ?? ''} ${soldier.zip ?? ''}',
                              'City/State/Zip',
                              4.33),
                          createField(soldier.workPhone, 'Work No', 2.17)
                        ]),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          createField(soldier.email, 'Email', 3.25),
                          createField(soldier.workEmail, 'Work Email', 3.25)
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          createField(soldier.nok, 'NOK', 3.25),
                          createField(soldier.nokPhone, 'NOK Phone', 3.25)
                        ]),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [createField('', 'NOK Address', 6.50)]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [createField('', 'NOK City/State/Zip', 6.5)]),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          createField(
                              soldier.maritalStatus, 'Marital Status', 3.25),
                          createField('', 'Anniversary', 3.25)
                        ]),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [awardField('Dependents', 6.5)]),
                    Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        border: const TableBorder(
                            left: BorderSide(),
                            top: BorderSide(),
                            right: BorderSide(),
                            bottom: BorderSide(),
                            horizontalInside: BorderSide(),
                            verticalInside: BorderSide()),
                        children: [
                          TableRow(children: [
                            tableField('Spouse:', 2.875),
                            tableField('DOB:', 1.75),
                            tableField('Sex: M/F', 0.875),
                            tableField('EFMP: Y/N', 1.0)
                          ]),
                          TableRow(children: [
                            tableField('Child:', 2.875),
                            tableField('DOB:', 1.75),
                            tableField('Sex: M/F', 0.875),
                            tableField('EFMP: Y/N', 1.0)
                          ]),
                          TableRow(children: [
                            tableField('Child:', 2.875),
                            tableField('DOB:', 1.75),
                            tableField('Sex: M/F', 0.875),
                            tableField('EFMP: Y/N', 1.0)
                          ]),
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          createField(
                              pov == null
                                  ? ''
                                  : '${pov['year']} ${pov['make']} ${pov['model']}',
                              'POV',
                              6.5)
                        ]),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          createField(pov == null ? '' : pov['plate'],
                              "license Plate", 3.25),
                          createField(
                              pov == null ? '' : pov['state'], "State", 1.0),
                          createField(
                              pov == null ? '' : pov['regExp'], 'Exp', 2.25)
                        ]),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          createField(
                              pov == null ? '' : pov['ins'], 'Ins', 2.16),
                          createField('', 'Policy #', 2.16),
                          createField(
                              pov == null ? '' : pov['insExp'], 'Exp', 2.17)
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          createField(
                              pov2 == null
                                  ? ''
                                  : '${pov2['year']} ${pov2['make']} ${pov2['model']}',
                              '2nd POV',
                              6.5)
                        ]),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          createField(pov2 == null ? '' : pov2['plate'],
                              "license Plate", 3.25),
                          createField(
                              pov2 == null ? '' : pov2['state'], "State", 1.0),
                          createField(
                              pov2 == null ? '' : pov2['regExp'], 'Exp', 2.25)
                        ]),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          createField(
                              pov2 == null ? '' : pov2['ins'], 'Ins', 2.16),
                          createField('', 'Policy #', 2.16),
                          createField(
                              pov2 == null ? '' : pov2['insExp'], 'Exp', 2.17)
                        ]),
                  ]));
            }));
        pdf.addPage(Page(
            pageFormat: PdfPageFormat.letter,
            orientation: PageOrientation.portrait,
            margin: const EdgeInsets.all(72.0),
            build: (Context context) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          createField('Y/N', 'Allergies', 1.5),
                          createField('Y/N', 'Hot Injury', 1.625),
                          createField('Y/N', 'Cold Injury', 1.625),
                          createField('', 'Blood Type', 1.75),
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          createField('', 'Allergies', 6.5),
                        ]),
                    Table(
                        border: const TableBorder(
                            left: BorderSide(),
                            top: BorderSide(),
                            right: BorderSide(),
                            bottom: BorderSide(),
                            horizontalInside: BorderSide(),
                            verticalInside: BorderSide()),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(children: [
                            SizedBox(
                                width: 2.0 * 72,
                                height: 20,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text('Award',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                )),
                            SizedBox(
                                width: 1.25 * 72,
                                height: 20,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text('No',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                )),
                            SizedBox(
                                width: 2.0 * 72,
                                height: 20,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text('Award',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                )),
                            SizedBox(
                                width: 1.25 * 72,
                                height: 20,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text('No',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                )),
                          ]),
                          TableRow(children: [
                            tableField(
                                awards.isEmpty ? '' : awards[0]['name'], 2.0),
                            tableField(
                                awards.isEmpty ? '' : awards[0]['number'],
                                1.25),
                            tableField(
                                awards.length < 2 ? '' : awards[1]['name'],
                                2.0),
                            tableField(
                                awards.length < 2 ? '' : awards[1]['number'],
                                1.25),
                          ]),
                          TableRow(children: [
                            tableField(
                                awards.length < 3 ? '' : awards[2]['name'],
                                2.0),
                            tableField(
                                awards.length < 3 ? '' : awards[2]['number'],
                                1.25),
                            tableField(
                                awards.length < 4 ? '' : awards[3]['name'],
                                2.0),
                            tableField(
                                awards.length < 4 ? '' : awards[3]['number'],
                                1.25),
                          ]),
                          TableRow(children: [
                            tableField(
                                awards.length < 5 ? '' : awards[4]['name'],
                                2.0),
                            tableField(
                                awards.length < 5 ? '' : awards[4]['number'],
                                1.25),
                            tableField(
                                awards.length < 6 ? '' : awards[5]['name'],
                                2.0),
                            tableField(
                                awards.length < 6 ? '' : awards[5]['number'],
                                1.25),
                          ]),
                          TableRow(children: [
                            tableField(
                                awards.length < 7 ? '' : awards[6]['name'],
                                2.0),
                            tableField(
                                awards.length < 7 ? '' : awards[6]['number'],
                                1.25),
                            tableField(
                                awards.length < 8 ? '' : awards[7]['name'],
                                2.0),
                            tableField(
                                awards.length < 8 ? '' : awards[7]['number'],
                                1.25),
                          ]),
                          TableRow(children: [
                            tableField(
                                awards.length < 9 ? '' : awards[8]['name'],
                                2.0),
                            tableField(
                                awards.length < 9 ? '' : awards[8]['number'],
                                1.25),
                            tableField(
                                awards.length < 10 ? '' : awards[9]['name'],
                                2.0),
                            tableField(
                                awards.length < 10 ? '' : awards[9]['number'],
                                1.25),
                          ]),
                        ]),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [awardField('Additional Children', 6.5)]),
                    Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        border: const TableBorder(
                            left: BorderSide(),
                            top: BorderSide(),
                            right: BorderSide(),
                            bottom: BorderSide(),
                            horizontalInside: BorderSide(),
                            verticalInside: BorderSide()),
                        children: [
                          TableRow(children: [
                            tableField('Child:', 2.875),
                            tableField('DOB:', 1.75),
                            tableField('Sex: M/F', 0.875),
                            tableField('EFMP: Y/N', 1.0)
                          ]),
                          TableRow(children: [
                            tableField('Child:', 2.875),
                            tableField('DOB:', 1.75),
                            tableField('Sex: M/F', 0.875),
                            tableField('EFMP: Y/N', 1.0)
                          ]),
                          TableRow(children: [
                            tableField('Child:', 2.875),
                            tableField('DOB:', 1.75),
                            tableField('Sex: M/F', 0.875),
                            tableField('EFMP: Y/N', 1.0)
                          ]),
                          TableRow(children: [
                            tableField('Child:', 2.875),
                            tableField('DOB:', 1.75),
                            tableField('Sex: M/F', 0.875),
                            tableField('EFMP: Y/N', 1.0)
                          ]),
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          DecoratedBox(
                              decoration: const BoxDecoration(
                                  border: TableBorder(
                                      left: BorderSide(),
                                      top: BorderSide(),
                                      right: BorderSide(),
                                      bottom: BorderSide())),
                              child: SizedBox(
                                  width: 6.5 * 72,
                                  height: 4.5 * 72,
                                  child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(soldier.comments,
                                          textAlign: TextAlign.left))))
                        ])
                  ]);
            }));
      } else {
        pdf.addPage(Page(
            pageFormat: PdfPageFormat.letter,
            orientation: PageOrientation.landscape,
            margin: const EdgeInsets.all(0.75 * 72.0),
            build: (Context context) {
              return Row(children: [
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(
                        '${soldier.rank}${soldier.promotable} ${soldier.lastName}, ${soldier.firstName} ${soldier.mi}',
                        'Name',
                        3.0),
                    createField(soldier.dodId ?? '', 'DoD Id', 1.75),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(soldier.supervisor, 'Supervisor', 3.0),
                    createField('', 'DOB', 1.75),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(soldier.section, 'Section', 3.0),
                    createField(soldier.mos, 'MOS', 1.75),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(soldier.duty, 'Pos', 3.0),
                    createField(soldier.dor, 'DOR', 1.75),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(soldier.gainDate, 'Gain', 1.5),
                    createField(soldier.lossDate, 'Loss', 1.5),
                    createField(soldier.reqMos, 'Dty MOS', 1.75),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(soldier.paraLn, 'Para/Ln', 1.5),
                    createField(soldier.milEd, 'Mil Ed Lvl', 1.5),
                    createField(soldier.civEd, 'Civ Ed', 1.75),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(soldier.nbcSuitSize ?? '', 'CBRN Suit', 2.375),
                    createField(soldier.nbcMaskSize ?? '', 'CBRN Mask', 2.375),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(soldier.nbcBootSize ?? '', 'CBRN Boot', 2.375),
                    createField(
                        soldier.nbcGloveSize ?? '', 'CBRN Glove', 2.375),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(soldier.hatSize ?? '', 'Hat Size', 2.375),
                    createField(soldier.bootSize ?? '', 'Boot Size', 2.375),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(soldier.acuTopSize ?? '', 'OCP Top', 2.375),
                    createField(
                        soldier.acuTrouserSize ?? '', 'OCP Trousers', 2.375),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(soldier.address ?? '', 'Address', 4.75),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(
                        '${soldier.city ?? ''}, ${soldier.state ?? ''} ${soldier.zip ?? ''}',
                        'City/State/Zip',
                        4.75),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(soldier.phone, 'Cell', 2.375),
                    createField(soldier.workPhone, 'Work', 2.375),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(soldier.email, 'Email', 2.375),
                    createField(soldier.workEmail, 'Work', 2.375),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(soldier.nok, 'NOK', 2.375),
                    createField(soldier.nokPhone, 'Phone', 2.375),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField('', 'NOK Address', 4.75),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField('', 'City/State/Zip', 4.75),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(
                        pov == null
                            ? ''
                            : '${pov['year']} ${pov['make']} ${pov['model']}',
                        'POV',
                        4.75)
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(pov == null ? '' : pov['plate'], 'Plate', 2.25),
                    createField(pov == null ? '' : pov['state'], 'State', 1.0),
                    createField(pov == null ? '' : pov['regExp'], 'Exp', 1.5)
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(pov == null ? '' : pov['ins'], 'Ins', 1.625),
                    createField('', 'Policy', 1.625),
                    createField(pov == null ? '' : pov['insExp'], 'Exp', 1.5)
                  ]),
                ]),
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(
                        pov2 == null
                            ? ''
                            : '${pov2['year']} ${pov2['make']} ${pov2['model']}',
                        '2nd POV',
                        4.75)
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(pov2 == null ? '' : pov2['plate'],
                        "license Plate", 2.25),
                    createField(
                        pov2 == null ? '' : pov2['state'], "State", 1.0),
                    createField(pov2 == null ? '' : pov2['regExp'], 'Exp', 1.5)
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField(pov2 == null ? '' : pov2['ins'], 'Ins', 1.625),
                    createField('', 'Policy', 1.625),
                    createField(pov2 == null ? '' : pov2['insExp'], 'Exp', 1.5)
                  ]),
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        createField('Y/N', 'Allergies', 1.25),
                        createField('Y/N', 'Hot', 1.125),
                        createField('Y/N', 'Cold', 1.125),
                        createField('', 'Blood Type', 1.25),
                      ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    createField('', 'Marital Status', 2.375),
                    createField('', 'Ann', 2.375)
                  ]),
                  Table(
                      border: const TableBorder(
                          left: BorderSide(),
                          top: BorderSide(),
                          right: BorderSide(),
                          bottom: BorderSide(),
                          horizontalInside: BorderSide(),
                          verticalInside: BorderSide()),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(children: [
                          tableField('Spouse:', 2.25),
                          tableField('DOB:', 1.5),
                          tableField('EFMP: Y/N', 1.0)
                        ]),
                        TableRow(children: [
                          tableField('Child:', 2.25),
                          tableField('DOB:', 1.5),
                          tableField('EFMP: Y/N', 1.0)
                        ]),
                        TableRow(children: [
                          tableField('Child:', 2.25),
                          tableField('DOB:', 1.5),
                          tableField('EFMP: Y/N', 1.0)
                        ]),
                        TableRow(children: [
                          tableField('Child:', 2.25),
                          tableField('DOB:', 1.5),
                          tableField('EFMP: Y/N', 1.0)
                        ]),
                        TableRow(children: [
                          tableField('Child:', 2.25),
                          tableField('DOB:', 1.5),
                          tableField('EFMP: Y/N', 1.0)
                        ]),
                        TableRow(children: [
                          tableField('Child:', 2.25),
                          tableField('DOB:', 1.5),
                          tableField('EFMP: Y/N', 1.0)
                        ]),
                      ]),
                  Table(
                      border: const TableBorder(
                          left: BorderSide(),
                          top: BorderSide(),
                          right: BorderSide(),
                          bottom: BorderSide(),
                          horizontalInside: BorderSide(),
                          verticalInside: BorderSide()),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(children: [
                          SizedBox(
                              width: 1.625 * 72,
                              height: 20,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text('Award',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              )),
                          SizedBox(
                              width: 0.75 * 72,
                              height: 20,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text('No',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              )),
                          SizedBox(
                              width: 1.625 * 72,
                              height: 20,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text('Award',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              )),
                          SizedBox(
                              width: 0.75 * 72,
                              height: 20,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text('No',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              )),
                        ]),
                        TableRow(children: [
                          tableField(
                              awards.isEmpty ? '' : awards[0]['name'], 1.625),
                          tableField(
                              awards.isEmpty ? '' : awards[0]['number'], 0.75),
                          tableField(awards.length < 2 ? '' : awards[1]['name'],
                              1.625),
                          tableField(
                              awards.length < 2 ? '' : awards[1]['number'],
                              0.75),
                        ]),
                        TableRow(children: [
                          tableField(awards.length < 3 ? '' : awards[2]['name'],
                              1.625),
                          tableField(
                              awards.length < 3 ? '' : awards[2]['number'],
                              0.75),
                          tableField(awards.length < 4 ? '' : awards[3]['name'],
                              1.625),
                          tableField(
                              awards.length < 4 ? '' : awards[3]['number'],
                              0.75),
                        ]),
                        TableRow(children: [
                          tableField(awards.length < 5 ? '' : awards[4]['name'],
                              1.625),
                          tableField(
                              awards.length < 5 ? '' : awards[4]['number'],
                              0.75),
                          tableField(awards.length < 6 ? '' : awards[5]['name'],
                              1.625),
                          tableField(
                              awards.length < 6 ? '' : awards[5]['number'],
                              0.75),
                        ]),
                        TableRow(children: [
                          tableField(awards.length < 7 ? '' : awards[6]['name'],
                              1.625),
                          tableField(
                              awards.length < 7 ? '' : awards[6]['number'],
                              0.75),
                          tableField(awards.length < 8 ? '' : awards[7]['name'],
                              1.625),
                          tableField(
                              awards.length < 8 ? '' : awards[7]['number'],
                              0.75),
                        ]),
                      ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    DecoratedBox(
                        decoration: const BoxDecoration(
                            border: TableBorder(
                                left: BorderSide(),
                                top: BorderSide(),
                                right: BorderSide(),
                                bottom: BorderSide())),
                        child: SizedBox(
                            width: 4.75 * 72,
                            height: 1.35 * 72,
                            child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(soldier.comments,
                                    textAlign: TextAlign.left))))
                  ])
                ])
              ]);
            }));
      }
    }

    return pdfDownload(pdf, 'soldiers');
  }
}
