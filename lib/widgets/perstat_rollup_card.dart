import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/soldiers_provider.dart';

class PerstatRollupCard extends ConsumerWidget {
  const PerstatRollupCard({
    Key? key,
    required this.title,
    required this.leave,
    required this.tdy,
    required this.other,
    required this.button,
    required this.button2,
  }) : super(key: key);

  final String title;
  final int leave, tdy, other;
  final Widget button, button2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var soldiers = ref.read(soldiersProvider);
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
                      child: Text(
                          'PDY: ${soldiers.length - leave - tdy - other}',
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
      ),
    );
  }
}
