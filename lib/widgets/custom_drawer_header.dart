import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/providers/user_provider.dart';

import '../pages/editPages/edit_user_page.dart';

class CustomDrawerHeader extends StatelessWidget {
  const CustomDrawerHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, child) {
        if (ref.read(userProvider).user == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          String initials = '';
          String name = ref.read(userProvider).user!.userName;
          name = name.trim();
          if (!name.contains(' ')) {
            if (name.length > 2) {
              initials = name.substring(0, 1);
            }
          } else {
            int space = name.indexOf(' ') + 1;
            initials = name.substring(0, 1) + name.substring(space, space + 1);
          }
          return UserAccountsDrawerHeader(
            accountName: Text(
              name,
            ),
            accountEmail: Text(
              ref.read(userProvider).user!.userEmail,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Text(initials),
            ),
            onDetailsPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditUserPage(
                    userId: ref.read(userProvider).user!.userId,
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
