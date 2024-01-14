import 'package:flutter/material.dart';

import '../../methods/theme_methods.dart';
import '../../widgets/header_text.dart';

class RollupCard extends StatelessWidget {
  const RollupCard({
    super.key,
    required this.title,
    required this.infoRow1,
    this.infoRow2 = const [],
    required this.buttons,
  });

  final String title;
  final List<Widget> infoRow1;
  final List<Widget> infoRow2;
  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: getContrastingBackgroundColor(context),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            HeaderText(
              title,
              color: getPrimaryColor(context),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: infoRow1.map((e) => Expanded(child: e)).toList()),
              ),
            ),
            if (infoRow2.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:
                          infoRow2.map((e) => Expanded(child: e)).toList()),
                ),
              ),
            ButtonBar(
              layoutBehavior: ButtonBarLayoutBehavior.constrained,
              children: buttons.map((e) => e).toList(),
            )
          ],
        ),
      ),
    );
  }
}
