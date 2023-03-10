import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/root_provider.dart';
import './formatted_text_button.dart';

class AnonWarningBanner extends StatelessWidget {
  const AnonWarningBanner({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootProvider = Provider.of<RootProvider>(context, listen: false);
    return Card(
      color: Colors.redAccent,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ListTile(
          title: const Text('Guest Account'),
          subtitle: const Text('Create account or your data will be lost'),
          trailing: FormattedTextButton(
            onPressed: () {
              rootProvider.linkAnonymous();
              Navigator.popUntil(
                  context, ModalRoute.withName(Navigator.defaultRouteName));
            },
            label: 'Create Account',
          ),
        ),
      ),
    );
  }
}
