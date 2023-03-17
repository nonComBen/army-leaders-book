import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertTile extends StatelessWidget {
  const AlertTile(
      {Key? key,
      required this.soldier,
      required this.phone,
      required this.workPhone})
      : super(key: key);
  final String soldier;
  final String phone;
  final String workPhone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Theme.of(context).colorScheme.primary,
        child: Container(
          padding: const EdgeInsets.all(4.0),
          constraints: const BoxConstraints(maxWidth: 900),
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
                        if (phone.isNotEmpty) {
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
                        if (workPhone.isNotEmpty) {
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
