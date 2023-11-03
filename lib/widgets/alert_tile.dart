import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../methods/theme_methods.dart';

class AlertTile extends StatelessWidget {
  const AlertTile(
      {super.key,
      required this.soldier,
      required this.phone,
      required this.workPhone});
  final String soldier;
  final String phone;
  final String workPhone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: getContrastingBackgroundColor(context),
        child: Container(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: <Widget>[
              Text(
                soldier,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: TextButton(
                      child: Text(
                        'P: $phone',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      onPressed: () {
                        if (!kIsWeb && phone.isNotEmpty) {
                          launchUrl(Uri.parse('tel:$phone'));
                        }
                      },
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: TextButton(
                      child: Text(
                        'W: $workPhone',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      onPressed: () {
                        if (!kIsWeb && workPhone.isNotEmpty) {
                          launchUrl(Uri.parse('tel:$workPhone'));
                        }
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
