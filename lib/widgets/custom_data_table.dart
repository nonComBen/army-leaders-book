import 'package:flutter/material.dart';

import '../methods/theme_methods.dart';

class CustomDataTable extends StatelessWidget {
  const CustomDataTable({
    super.key,
    this.sortAscending = true,
    this.sortColumnIndex,
    required this.columns,
    required this.rows,
  });
  final bool sortAscending;
  final int? sortColumnIndex;
  final List<DataColumn> columns;
  final List<DataRow> rows;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      checkboxHorizontalMargin: 8.0,
      sortAscending: sortAscending,
      sortColumnIndex: sortColumnIndex,
      columns: columns,
      rows: rows,
      headingTextStyle: TextStyle(color: getTextColor(context)),
      dataTextStyle: TextStyle(color: getTextColor(context)),
    );
  }
}
