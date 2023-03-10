import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/soldiers_provider.dart';

class PerstatRollupCard extends StatelessWidget {
  const PerstatRollupCard(
      {Key key,
      this.title,
      this.leave,
      this.tdy,
      this.other,
      this.button,
      this.button2})
      : super(key: key);

  final String title;
  final int leave, tdy, other;
  final ElevatedButton button, button2;

  @override
  Widget build(BuildContext context) {
    var soldiers = Provider.of<SoldiersProvider>(context).soldiers;
    return Card(
        child: Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text('Assigned: ${soldiers.length}',
                        textAlign: TextAlign.start,
                        style: const TextStyle(fontSize: 16.0)),
                  ),
                  Expanded(
                    child: Text('PDY: ${soldiers.length - leave - tdy - other}',
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 16.0)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text('Leave: $leave',
                        textAlign: TextAlign.start,
                        style: const TextStyle(fontSize: 16.0)),
                  ),
                  Expanded(
                    child: Text('TDY: $tdy',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16.0)),
                  ),
                  Expanded(
                    child: Text('Other: $other',
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 16.0)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ButtonBar(
              children: <Widget>[
                button2,
                button,
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
