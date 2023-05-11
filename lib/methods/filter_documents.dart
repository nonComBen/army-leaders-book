import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/header_text.dart';
import '../widgets/platform_widgets/platform_button.dart';
import '../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import 'custom_modal_bottom_sheet.dart';

List<String> getSections(List<DocumentSnapshot> docs) {
  return docs.map((e) => e['section'] as String).toList().toSet().toList();
}

void showFilterOptions(BuildContext context, List<String> sections,
    void Function(List<String>) onPressed) {
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
      ).toList(),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: PlatformButton(
            onPressed: () {
              Navigator.of(context).pop();
              onPressed(filterSections);
            },
            child: const Text('Apply Filter')),
      )
    ],
  );
  customModalBottomSheet(context, content);
}
