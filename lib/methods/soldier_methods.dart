import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../pages/editPages/edit_soldier_page.dart';
import '../../providers/filtered_soldiers_provider.dart';
import '../../widgets/header_text.dart';
import '../../widgets/my_toast.dart';
import '../models/soldier.dart';
import '../pages/manage_users_page.dart';
import '../pages/share_soldier_page.dart';
import '../pages/transfer_soldier_page.dart';
import '../pages/uploadPages/upload_soldiers_page.dart';
import '../pdf/soldiers_pdf.dart';
import '../widgets/platform_widgets/platform_button.dart';
import '../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import 'custom_alert_dialog.dart';
import 'custom_modal_bottom_sheet.dart';
import 'download_methods.dart';
import 'open_file.dart';
import 'toast_messages/subscription_needed_toast.dart';
import 'web_download.dart';

List<String> getSections(List<Soldier> soldiers) {
  soldiers.sort(
    (a, b) => a.section.compareTo(b.section),
  );
  return soldiers.map((e) => e.section).toList().toSet().toList();
}

void selectFilters(BuildContext context, List<String> sections,
    FilteredSoldiers filteredSoldiers) {
  List<String> filterSections = [];
  Widget content = ListView(
    children: [
      const HeaderText('Select Sections to Filter By'),
      ...sections.map(
        (e) {
          bool isChecked = false;
          return StatefulBuilder(builder: (context, refresh) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: PlatformCheckboxListTile(
                title: Text(e),
                onChanged: (value) {
                  value! ? filterSections.add(e) : filterSections.remove(e);
                  refresh(
                    () {
                      isChecked = value;
                    },
                  );
                },
                value: isChecked,
              ),
            );
          });
        },
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: PlatformButton(
            onPressed: () {
              Navigator.of(context).pop();
              filteredSoldiers.filter(filterSections);
            },
            child: const Text('Apply Filter')),
      )
    ],
  );
  customModalBottomSheet(context, content);
}

void downloadExcel(BuildContext context, List<Soldier> soldiers) async {
  List<List<CellValue>> docsList = [];
  docsList.add(const [
    TextCellValue('Soldier Id'),
    TextCellValue('Rank'),
    TextCellValue('Rank Sort'),
    TextCellValue('Last Name'),
    TextCellValue('First Name'),
    TextCellValue('Middle Initial'),
    TextCellValue('Assigned'),
    TextCellValue('Supervisor'),
    TextCellValue('Section'),
    TextCellValue('DoD ID'),
    TextCellValue('Date of Rank'),
    TextCellValue('MOS'),
    TextCellValue('Duty Position'),
    TextCellValue('Paragraph/Line No.'),
    TextCellValue('Duty MOS'),
    TextCellValue('Loss Date'),
    TextCellValue('ETS'),
    TextCellValue('BASD'),
    TextCellValue('PEBD'),
    TextCellValue('Gain Date'),
    TextCellValue('Civ Ed Level'),
    TextCellValue('Mil Ed Level'),
    TextCellValue('CBRN Suit Size'),
    TextCellValue('CBRN Mask Size'),
    TextCellValue('CBRN Boot Size'),
    TextCellValue('CBRN Glove Size'),
    TextCellValue('Hat Size'),
    TextCellValue('Boot Size'),
    TextCellValue('OCP Top Size'),
    TextCellValue('OCP Trouser Size'),
    TextCellValue('Address'),
    TextCellValue('City'),
    TextCellValue('State'),
    TextCellValue('Zip Code'),
    TextCellValue('Phone Number'),
    TextCellValue('Work Phone'),
    TextCellValue('Email Address'),
    TextCellValue('Work Email'),
    TextCellValue('Next of Kin'),
    TextCellValue('Next of Kin Phone'),
    TextCellValue('Marital Status'),
    TextCellValue('Comments'),
  ]);
  for (Soldier soldier in soldiers) {
    List<dynamic> docs = [
      soldier.id,
      soldier.rank,
      soldier.rankSort,
      soldier.lastName,
      soldier.firstName,
      soldier.mi,
      soldier.assigned.toString(),
      soldier.supervisor,
      soldier.section,
      soldier.dodId,
      soldier.dor,
      soldier.mos,
      soldier.duty,
      soldier.paraLn,
      soldier.reqMos,
      soldier.lossDate,
      soldier.ets,
      soldier.basd,
      soldier.pebd,
      soldier.gainDate,
      soldier.civEd,
      soldier.milEd,
      soldier.nbcSuitSize,
      soldier.nbcMaskSize,
      soldier.nbcBootSize,
      soldier.nbcGloveSize,
      soldier.hatSize,
      soldier.bootSize,
      soldier.acuTopSize,
      soldier.acuTrouserSize,
      soldier.address,
      soldier.city,
      soldier.state,
      soldier.zip,
      soldier.phone,
      soldier.workPhone,
      soldier.email,
      soldier.workEmail,
      soldier.nok,
      soldier.nokPhone,
      soldier.maritalStatus,
      soldier.comments
    ];

    docsList.add(docs.map((e) => TextCellValue(e.toString())).toList());
  }

  var excel = Excel.createExcel();
  var sheet = excel.sheets[excel.getDefaultSheet()];
  for (var docs in docsList) {
    sheet!.appendRow(docs);
  }

  String dir, loc;
  if (kIsWeb) {
    WebDownload webDownload = WebDownload(
        type: 'xlsx', fileName: 'soldiers.xlsx', data: excel.encode());
    webDownload.download();
  } else {
    getPath().then((dirs) {
      dir = dirs[0];
      loc = dirs[1];
      try {
        var bytes = excel.encode()!;
        File('$dir/soldiers.xlsx')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);
        FToast toast = FToast();
        toast.context = context;
        toast.showToast(
          toastDuration: const Duration(seconds: 5),
          child: MyToast(
            message: 'Data successfully downloaded to $loc',
            onPressed: kIsWeb ? null : () => openFile('$dir/soldiers.xlsx'),
            buttonText: kIsWeb ? null : 'Open',
          ),
        );
      } catch (e) {
        // ignore: avoid_print
        print('Error: $e');
      }
    });
  }
}

uploadExcel(BuildContext context, bool isSubscribed) {
  if (isSubscribed) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const UploadSoldierPage()));
  } else {
    uploadRequiresSub(context);
  }
}

void shareSoldiers(
    BuildContext context, List<Soldier> selectedSoldiers, String userId) {
  if (selectedSoldiers.isEmpty) {
    FToast toast = FToast();
    toast.context = context;
    toast.showToast(
      child: const MyToast(
        message: 'You must select at least one record',
      ),
    );
    return;
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ShareSoldierPage(
        userId: userId,
        soldiers: selectedSoldiers,
      ),
    ),
  );
}

void transferSoldier(
    BuildContext context, List<Soldier> selectedSoldiers, String userId) {
  if (selectedSoldiers.isEmpty) {
    FToast toast = FToast();
    toast.context = context;
    toast.showToast(
      child: const MyToast(
        message: 'You must select at least one record',
      ),
    );
    return;
  }
  List<Soldier> soldierList = [];
  for (Soldier soldier in selectedSoldiers) {
    if (soldier.owner != userId) {
      FToast toast = FToast();
      toast.context = context;
      toast.showToast(
        child: const MyToast(
          message: 'You can only transfer records you own',
        ),
      );
      return;
    }
    soldierList.add(soldier);
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TransferSoldierPage(
        userId: userId,
        soldiers: soldierList,
      ),
    ),
  );
}

void manageUsers(BuildContext context, List<Soldier> soldiers, String userId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ManageUsersPage(userId: userId, soldiers: soldiers),
    ),
  );
}

void downloadPdf(BuildContext context, bool isSubscribed,
    List<Soldier> selectedSoldiers, String userId) async {
  if (isSubscribed) {
    if (selectedSoldiers.isEmpty) {
      FToast toast = FToast();
      toast.context = context;
      toast.showToast(
        child: const MyToast(
          message: 'You must select at least one record',
        ),
      );
      return;
    }
    Widget title = const Text('Download PDF');
    Widget content = Container(
      padding: const EdgeInsets.all(8.0),
      child: const Text('Select full page or half page format.'),
    );
    customAlertDialog(
      context: context,
      title: title,
      content: content,
      primaryText: 'Full Page',
      primary: () {
        completePdfDownload(context, true, selectedSoldiers, userId);
      },
      secondaryText: 'Half Page',
      secondary: () {
        completePdfDownload(context, false, selectedSoldiers, userId);
      },
    );
  } else {
    pdfRequiresSub(context);
  }
}

void completePdfDownload(BuildContext context, bool fullPage,
    List<Soldier> selectedSoldiers, String userId) async {
  SoldierPdf soldierPdf =
      SoldierPdf(soldiers: selectedSoldiers, userId: userId);
  soldierPdf.createPdf(fullPage).then((location) {
    String message;
    if (location == '') {
      message = 'Failed to download pdf';
    } else {
      String directory =
          kIsWeb ? '/Downloads' : '\'On My iPhone(iPad)/Leader\'s Book\'';
      message = kIsWeb
          ? 'Pdf successfully downloaded to $directory'
          : 'Pdf successfully downloaded to temporary storage. Please open and save to permanent location.';
    }
    FToast toast = FToast();
    toast.context = context;
    toast.showToast(
      toastDuration: const Duration(seconds: 5),
      child: MyToast(
        message: message,
        onPressed: kIsWeb ? null : () => openFile('$location/soldiers.pdf'),
        buttonText: kIsWeb ? null : 'Open',
      ),
    );
  });
}

void editSoldier(BuildContext context, List<Soldier> selectedSoldiers) {
  if (selectedSoldiers.length != 1) {
    FToast toast = FToast();
    toast.context = context;
    toast.showToast(
        child: const MyToast(message: 'You must select exactly one record'));
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSoldierPage(
          soldier: selectedSoldiers.first,
        ),
      ),
    );
  }
}
