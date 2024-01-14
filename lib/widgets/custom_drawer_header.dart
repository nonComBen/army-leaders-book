import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/providers/auth_provider.dart';
import 'package:leaders_book/models/leader.dart';

import '../../methods/theme_methods.dart';
import '../providers/leader_provider.dart';
import '../pages/editPages/edit_user_page.dart';

class CustomDrawerHeader extends ConsumerWidget {
  const CustomDrawerHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Leader? user = ref.watch(leaderProvider).leader;
    if (user == null) {
      ref.read(leaderProvider).init(ref.read(authProvider).currentUser()!.uid);
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
            backgroundColor: getPrimaryColor(context),
            child: Text(initials),
          ),
          decoration: BoxDecoration(
            color: getOnPrimaryColor(context),
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
          color: getOnPrimaryColor(context),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: getPrimaryColor(context),
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: getOnPrimaryColor(context),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    name,
                    style: TextStyle(
                      color: getTextColor(context),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    user.userEmail,
                    style: TextStyle(
                      color: getTextColor(context),
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
