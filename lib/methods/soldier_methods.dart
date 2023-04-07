import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:leaders_book/pages/editPages/edit_soldier_page.dart';
import 'package:leaders_book/widgets/my_toast.dart';
import 'package:leaders_book/widgets/platform_widgets/platform_text_button.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/soldier.dart';
import '../pages/manage_users_page.dart';
import '../pages/share_soldier_page.dart';
import '../pages/transfer_soldier_page.dart';
import '../pages/uploadPages/upload_soldiers_page.dart';
import '../pdf/soldiers_pdf.dart';
import 'custom_alert_dialog.dart';
import 'download_methods.dart';
import 'web_download.dart';

List<String> getSections(List<Soldier> soldiers) {
  List<String> sections = ['All'];
  soldiers.sort(
    (a, b) => a.section.compareTo(b.section),
  );
  sections.addAll(soldiers.map((e) => e.section).toList());
  for (int i = 1; i < sections.length; i++) {
    if (sections[i] == sections[i - 1]) {
      sections.remove(sections[i]);
    }
  }
  return sections;
}

void downloadExcel(BuildContext context, List<Soldier> soldiers) async {
  bool approved = await checkPermission(Permission.storage);
  if (!approved) return;
  List<List<dynamic>> docsList = [];
  docsList.add([
    'Soldier Id',
    'Rank',
    'Rank Sort',
    'Last Name',
    'First Name',
    'Middle Initial',
    'Assigned',
    'Supervisor',
    'Section',
    'DoD ID',
    'Date of Rank',
    'MOS',
    'Duty Position',
    'Paragraph/Line No.',
    'Duty MOS',
    'Loss Date',
    'ETS',
    'BASD',
    'PEBD',
    'Gain Date',
    'Civ Ed Level',
    'Mil Ed Level',
    'CBRN Suit Size',
    'CBRN Mask Size',
    'CBRN Boot Size',
    'CBRN Glove Size',
    'Hat Size',
    'Boot Size',
    'OCP Top Size',
    'OCP Trouser Size',
    'Address',
    'City',
    'State',
    'Zip Code',
    'Phone Number',
    'Work Phone',
    'Email Address',
    'Work Email',
    'Next of Kin',
    'Next of Kin Phone',
    'Marital Status',
    'Comments',
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

    docsList.add(docs);
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
          child: MyToast(contents: [
            Text('Data successfully downloaded to $loc'),
            if (!kIsWeb)
              PlatformTextButton(
                child: const Text('Open'),
                onPressed: () {
                  OpenFile.open('$dir/soldiers.xlsx');
                },
              ),
          ]),
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
    FToast toast = FToast();
    toast.context = context;
    toast.showToast(
      child: const MyToast(
        contents: [
          Text('Uploading Soldiers is only available for subscribed users.')
        ],
      ),
    );
  }
}

void shareSoldiers(
    BuildContext context, List<Soldier> selectedSoldiers, String userId) {
  if (selectedSoldiers.isEmpty) {
    FToast toast = FToast();
    toast.context = context;
    toast.showToast(
      child: const MyToast(
        contents: [Text('You must select at least one record')],
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
        contents: [Text('You must select at least one record')],
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
          contents: [Text('You can only transfer records you own')],
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
          contents: [Text('You must select at least one record')],
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
    FToast toast = FToast();
    toast.context = context;
    toast.showToast(
      child: const MyToast(
        contents: [
          Text('Downloading PDF files is only available for subscribed users.')
        ],
      ),
    );
  }
}

void completePdfDownload(BuildContext context, bool fullPage,
    List<Soldier> selectedSoldiers, String userId) async {
  bool approved = await checkPermission(Permission.storage);
  if (!approved) return;
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
        contents: [
          Text(message),
          if (location != '' && !kIsWeb)
            PlatformTextButton(
              child: const Text('Open'),
              onPressed: () {
                OpenFile.open('$location/soldiers.pdf');
              },
            ),
        ],
      ),
    );
  });
}

void editSoldier(BuildContext context, List<Soldier> selectedSoldiers) {
  if (selectedSoldiers.length != 1) {
    FToast toast = FToast();
    toast.context = context;
    toast.showToast(
        child: const MyToast(
            contents: [Text('You must select exactly one record')]));
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
