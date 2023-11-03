import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/root_provider.dart';
import './formatted_text_button.dart';

class AnonWarningBanner extends ConsumerWidget {
  const AnonWarningBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rootService = ref.read(rootProvider.notifier);
    return Card(
      color: Colors.redAccent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: const Text('Guest Account'),
          subtitle: const Text('Create account or your data will be lost'),
          trailing: FormattedTextButton(
            onPressed: () {
              rootService.linkAnonymous();
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
