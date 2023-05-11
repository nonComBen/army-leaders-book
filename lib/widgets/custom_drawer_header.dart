import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/auth_provider.dart';
import 'package:leaders_book/models/user.dart';

import '../../methods/theme_methods.dart';
import '../../providers/user_provider.dart';
import '../pages/editPages/edit_user_page.dart';

class CustomDrawerHeader extends ConsumerWidget {
  const CustomDrawerHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserObj? user = ref.watch(userProvider).user;
    if (user == null) {
      ref
          .read(userProvider)
          .loadUser(ref.read(authProvider).currentUser()!.uid);
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      String initials = '';
      String name = user.userName;
      name = name.trim();
      if (!name.contains(' ')) {
        if (name.length > 2) {
          initials = name.substring(0, 1);
        }
      } else {
        int space = name.indexOf(' ') + 1;
        initials = name.substring(0, 1) + name.substring(space, space + 1);
      }
      if (kIsWeb || Platform.isAndroid) {
        return UserAccountsDrawerHeader(
          accountName: Text(
            name,
          ),
          accountEmail: Text(
            user.userEmail,
          ),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Text(initials),
          ),
          decoration: BoxDecoration(
            color: getPrimaryColor(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          onDetailsPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditUserPage(
                  userId: user.userId,
                ),
              ),
            );
          },
        );
      } else {
        return Container(
          color: getPrimaryColor(context),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: getOnPrimaryColor(context),
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: getPrimaryColor(context),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    name,
                    style: TextStyle(
                      color: getOnPrimaryColor(context),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    user.userEmail,
                    style: TextStyle(
                      color: getOnPrimaryColor(context),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }
    }
  }
}
