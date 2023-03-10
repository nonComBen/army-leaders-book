import 'dart:async';
import 'package:leaders_book/methods/download_methods.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class AlertRosterPdf {
  AlertRosterPdf(
    this.documents,
  );

  final List<dynamic> documents;
  List<Widget> children;
  int all = 0;

  Widget alertRow(
      String name, String cell, String work, double padding, bool fullPage) {
    String cellPhone = cell ?? '';
    String workPhone = work ?? '';
    return Padding(
        padding: EdgeInsets.fromLTRB(padding, 0.0, 0.0, 8.0),
        child: DecoratedBox(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                border: TableBorder(
                    left: BorderSide(),
                    top: BorderSide(),
                    right: BorderSide(),
                    bottom: BorderSide())),
            child: SizedBox(
                width: fullPage ? 6.5 * 72 - padding : 4.75 * 72 - padding,
                child: Column(children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(name ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text('Cell: $cellPhone')),
                        Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text('Work: $workPhone'))
                      ])
                ]))));
  }

  void buildChildren(bool fullPage, int page) {}

  List<Widget> alertChildren(bool fullPage, int page) {
    children = [];
    int a, b, c, d, e, current = 1;
    Map<String, dynamic> top = documents
        .firstWhere((doc) => doc['supervisorId'] == 'Top of Hierarchy');
    if (page == 1) {
      children.add(alertRow(
          top['soldier'], top['phone'], top['workPhone'], 0.0, fullPage));
      all = 1;
      //current = 1;
    }
    for (a = 0; a < documents.length; a++) {
      if ((fullPage && all >= page * 12) || (!fullPage && all >= page * 9)) {
        break;
      }
      if (documents[a]['supervisorId'] == top['soldierId']) {
        if (current >= all) {
          children.add(alertRow(documents[a]['soldier'], documents[a]['phone'],
              documents[a]['workPhone'], fullPage ? 36.0 : 18.0, fullPage));
          all++;
        }
        current++;
        for (b = 0; b < documents.length; b++) {
          if ((fullPage && all >= page * 12) ||
              (!fullPage && all >= page * 9)) {
            break;
          }
          if (documents[b]['supervisorId'] == documents[a]['soldierId']) {
            if (current >= all) {
              children.add(alertRow(
                  documents[b]['soldier'],
                  documents[b]['phone'],
                  documents[b]['workPhone'],
                  fullPage ? 72.0 : 36.0,
                  fullPage));
              all++;
            }
            current++;
            for (c = 0; c < documents.length; c++) {
              if ((fullPage && all >= page * 12) ||
                  (!fullPage && all >= page * 9)) break;
              if (documents[c]['supervisorId'] == documents[b]['soldierId']) {
                if (current >= all) {
                  children.add(alertRow(
                      documents[c]['soldier'],
                      documents[c]['phone'],
                      documents[c]['workPhone'],
                      fullPage ? 108.0 : 54.0,
                      fullPage));
                  all++;
                }
                current++;
                for (d = 0; d < documents.length; d++) {
                  if ((fullPage && all >= page * 12) ||
                      (!fullPage && all >= page * 9)) break;
                  if (documents[d]['supervisorId'] ==
                      documents[c]['soldierId']) {
                    if (current >= all) {
                      children.add(alertRow(
                          documents[d]['soldier'],
                          documents[d]['phone'],
                          documents[d]['workPhone'],
                          fullPage ? 144.0 : 72.0,
                          fullPage));
                      all++;
                    }
                    current++;
                    for (e = 0; e < documents.length; e++) {
                      if ((fullPage && all >= page * 12) ||
                          (!fullPage && all >= page * 9)) break;
                      if (documents[e]['supervisorId'] ==
                          documents[d]['soldierId']) {
                        if (current >= all) {
                          children.add(alertRow(
                              documents[e]['soldier'],
                              documents[e]['phone'],
                              documents[e]['workPhone'],
                              fullPage ? 180.0 : 90.0,
                              fullPage));
                          all++;
                        }
                        current++;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return children;
  }

  Future<String> createFullPage() async {
    final Document pdf = Document();

    pdf.addPage(Page(
        pageFormat: PdfPageFormat.letter,
        orientation: PageOrientation.portrait,
        margin: const EdgeInsets.all(72.0),
        build: (Context context) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: alertChildren(true, 1));
        }));

    if (documents.length > 12) {
      pdf.addPage(Page(
          pageFormat: PdfPageFormat.letter,
          orientation: PageOrientation.portrait,
          margin: const EdgeInsets.all(72.0),
          build: (Context context) {
            return Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: alertChildren(true, 2)));
          }));
      if (documents.length > 24) {
        pdf.addPage(Page(
            pageFormat: PdfPageFormat.letter,
            orientation: PageOrientation.portrait,
            margin: const EdgeInsets.all(72.0),
            build: (Context context) {
              return Center(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: alertChildren(true, 3)));
            }));
        if (documents.length > 36) {
          pdf.addPage(Page(
              pageFormat: PdfPageFormat.letter,
              orientation: PageOrientation.portrait,
              margin: const EdgeInsets.all(72.0),
              build: (Context context) {
                return Center(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: alertChildren(true, 4)));
              }));
          if (documents.length > 48) {
            pdf.addPage(Page(
                pageFormat: PdfPageFormat.letter,
                orientation: PageOrientation.portrait,
                margin: const EdgeInsets.all(72.0),
                build: (Context context) {
                  return Center(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: alertChildren(true, 5)));
                }));
            if (documents.length > 60) {
              pdf.addPage(Page(
                  pageFormat: PdfPageFormat.letter,
                  orientation: PageOrientation.portrait,
                  margin: const EdgeInsets.all(72.0),
                  build: (Context context) {
                    return Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: alertChildren(true, 6)));
                  }));
              if (documents.length > 72) {
                pdf.addPage(Page(
                    pageFormat: PdfPageFormat.letter,
                    orientation: PageOrientation.portrait,
                    margin: const EdgeInsets.all(72.0),
                    build: (Context context) {
                      return Center(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: alertChildren(true, 7)));
                    }));
                if (documents.length > 84) {
                  pdf.addPage(Page(
                      pageFormat: PdfPageFormat.letter,
                      orientation: PageOrientation.portrait,
                      margin: const EdgeInsets.all(72.0),
                      build: (Context context) {
                        return Center(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: alertChildren(true, 8)));
                      }));
                  if (documents.length > 96) {
                    pdf.addPage(Page(
                        pageFormat: PdfPageFormat.letter,
                        orientation: PageOrientation.portrait,
                        margin: const EdgeInsets.all(72.0),
                        build: (Context context) {
                          return Center(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: alertChildren(true, 9)));
                        }));
                    if (documents.length > 108) {
                      pdf.addPage(Page(
                          pageFormat: PdfPageFormat.letter,
                          orientation: PageOrientation.portrait,
                          margin: const EdgeInsets.all(72.0),
                          build: (Context context) {
                            return Center(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: alertChildren(true, 10)));
                          }));
                      if (documents.length > 120) {
                        pdf.addPage(Page(
                            pageFormat: PdfPageFormat.letter,
                            orientation: PageOrientation.portrait,
                            margin: const EdgeInsets.all(72.0),
                            build: (Context context) {
                              return Center(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: alertChildren(true, 11)));
                            }));
                        if (documents.length > 132) {
                          pdf.addPage(Page(
                              pageFormat: PdfPageFormat.letter,
                              orientation: PageOrientation.portrait,
                              margin: const EdgeInsets.all(72.0),
                              build: (Context context) {
                                return Center(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: alertChildren(true, 12)));
                              }));
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return pdfDownload(pdf, 'alertRoster');
  }

  Future<String> createHalfPage() async {
    final Document pdf = Document();

    pdf.addPage(Page(
        pageFormat: PdfPageFormat.letter,
        orientation: PageOrientation.landscape,
        margin: const EdgeInsets.all(0.75 * 72.0),
        build: (Context context) {
          return Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: alertChildren(false, 1)));
        }));

    if (documents.length > 9) {
      pdf.addPage(Page(
          pageFormat: PdfPageFormat.letter,
          orientation: PageOrientation.landscape,
          margin: const EdgeInsets.all(0.75 * 72.0),
          build: (Context context) {
            return Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: alertChildren(false, 2)));
          }));

      if (documents.length > 18) {
        pdf.addPage(Page(
            pageFormat: PdfPageFormat.letter,
            orientation: PageOrientation.landscape,
            margin: const EdgeInsets.all(0.75 * 72.0),
            build: (Context context) {
              return Center(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: alertChildren(false, 3)));
            }));

        if (documents.length > 27) {
          pdf.addPage(Page(
              pageFormat: PdfPageFormat.letter,
              orientation: PageOrientation.landscape,
              margin: const EdgeInsets.all(0.75 * 72.0),
              build: (Context context) {
                return Center(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: alertChildren(false, 4)));
              }));

          if (documents.length > 36) {
            pdf.addPage(Page(
                pageFormat: PdfPageFormat.letter,
                orientation: PageOrientation.landscape,
                margin: const EdgeInsets.all(0.75 * 72.0),
                build: (Context context) {
                  return Center(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: alertChildren(false, 5)));
                }));

            if (documents.length > 45) {
              pdf.addPage(Page(
                  pageFormat: PdfPageFormat.letter,
                  orientation: PageOrientation.landscape,
                  margin: const EdgeInsets.all(0.75 * 72.0),
                  build: (Context context) {
                    return Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: alertChildren(false, 6)));
                  }));

              if (documents.length > 54) {
                pdf.addPage(Page(
                    pageFormat: PdfPageFormat.letter,
                    orientation: PageOrientation.landscape,
                    margin: const EdgeInsets.all(0.75 * 72.0),
                    build: (Context context) {
                      return Center(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: alertChildren(false, 7)));
                    }));
                if (documents.length > 63) {
                  pdf.addPage(Page(
                      pageFormat: PdfPageFormat.letter,
                      orientation: PageOrientation.landscape,
                      margin: const EdgeInsets.all(0.75 * 72.0),
                      build: (Context context) {
                        return Center(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: alertChildren(false, 8)));
                      }));
                  if (documents.length > 72) {
                    pdf.addPage(Page(
                        pageFormat: PdfPageFormat.letter,
                        orientation: PageOrientation.landscape,
                        margin: const EdgeInsets.all(0.75 * 72.0),
                        build: (Context context) {
                          return Center(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: alertChildren(false, 9)));
                        }));
                    if (documents.length > 81) {
                      pdf.addPage(Page(
                          pageFormat: PdfPageFormat.letter,
                          orientation: PageOrientation.landscape,
                          margin: const EdgeInsets.all(0.75 * 72.0),
                          build: (Context context) {
                            return Center(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: alertChildren(false, 10)));
                          }));
                      if (documents.length > 90) {
                        pdf.addPage(Page(
                            pageFormat: PdfPageFormat.letter,
                            orientation: PageOrientation.landscape,
                            margin: const EdgeInsets.all(0.75 * 72.0),
                            build: (Context context) {
                              return Center(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: alertChildren(false, 11)));
                            }));
                        if (documents.length > 99) {
                          pdf.addPage(Page(
                              pageFormat: PdfPageFormat.letter,
                              orientation: PageOrientation.landscape,
                              margin: const EdgeInsets.all(0.75 * 72.0),
                              build: (Context context) {
                                return Center(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: alertChildren(false, 12)));
                              }));
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return pdfDownload(pdf, 'alertRoster');
  }
}
