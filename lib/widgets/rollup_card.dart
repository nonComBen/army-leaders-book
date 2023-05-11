import 'package:flutter/material.dart';
import 'package:leaders_book/methods/theme_methods.dart';

class RollupCard extends StatelessWidget {
  const RollupCard({
    Key? key,
    required this.title,
    required this.info1,
    required this.info2,
    required this.button,
    this.button2,
  }) : super(key: key);

  final String title;
  final Widget info1, info2;
  final Widget? button, button2;

  @override
  Widget build(BuildContext context) {
    return Card(
        color: getContrastingBackgroundColor(context),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: getTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: info1,
                      ),
                      Expanded(
                        child: info2,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                  child: ButtonBar(
                layoutBehavior: ButtonBarLayoutBehavior.constrained,
                children: <Widget>[
                  button!,
                  if (button2 != null) button2!,
                ],
              ))
            ],
          ),
        ));
  }
}
