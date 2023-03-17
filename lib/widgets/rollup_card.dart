import 'package:flutter/material.dart';

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
  final ElevatedButton? button, button2;

  Widget _row1() {
    return Padding(
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
    );
  }

  Widget _buttonBar() {
    if (title == 'Profiles') {
      return ButtonBar(
        children: <Widget>[button!, button2!],
      );
    } else {
      return ButtonBar(
        children: <Widget>[
          button!,
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
              child: Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
              child: _row1(),
            ),
          ),
          Expanded(child: _buttonBar())
        ],
      ),
    ));
  }
}
