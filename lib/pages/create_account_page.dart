import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth_provider.dart';
import '../providers/root_provider.dart';
import '../widgets/form_frame.dart';
import '../widgets/my_toast.dart';
import '../widgets/padded_text_field.dart';
import '../widgets/platform_widgets/platform_button.dart';
import '../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';
import '../widgets/platform_widgets/platform_text_button.dart';
import '../../auth_service.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../widgets/logo_widget.dart';

class CreateAccountPage extends ConsumerStatefulWidget {
  const CreateAccountPage({
    Key? key,
  }) : super(key: key);

  @override
  CreateAccountPageState createState() => CreateAccountPageState();
}

class CreateAccountPageState extends ConsumerState<CreateAccountPage> {
  final formKey = GlobalKey<FormState>();
  bool tosAgree = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  bool validateAndSave() {
    if (!tosAgree) {
      FToast toast = FToast();
      toast.init(context);
      toast.showToast(
        child: const MyToast(
          message:
              'You must agree to the Terms and Conditions to create an account.',
        ),
      );

      return false;
    }
    if (_emailController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text) {
      return true;
    }
    return false;
  }

  void validateAndCreate(AuthService auth) async {
    debugPrint('Validating');
    if (validateAndSave()) {
      try {
        User user = (await auth.createUserWithEmailAndPassword(
            _emailController.text, _passwordController.text))!;
        final userObj = UserObj(
          userId: user.uid,
          userEmail: user.email!,
          userName: user.displayName ?? '',
          createdDate: DateTime.now(),
          lastLoginDate: DateTime.now(),
          updatedUserArray: true,
          tosAgree: true,
          agreeDate: DateTime.now(),
        );
        await FirebaseFirestore.instance
            .doc('users/${user.uid}')
            .set(userObj.toMap());
        ref.read(userProvider).loadUser(user.uid);
        ref.read(rootProvider.notifier).signIn();
      } catch (e) {
        FToast toast = FToast();
        toast.init(context);
        toast.showToast(
          child: MyToast(
            message: e.toString(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rootService = ref.read(rootProvider.notifier);
    var auth = ref.read(authProvider);
    return PlatformScaffold(
      title: 'Create Account',
      body: FormFrame(
        formKey: formKey,
        children: <Widget>[
          const LogoWidget(),
          PaddedTextField(
            controller: _emailController,
            label: 'Email',
            decoration: const InputDecoration(
                labelText: 'Email', icon: Icon(Icons.mail)),
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                value!.isEmpty ? 'Email can\'t be empty' : null,
          ),
          PaddedTextField(
            label: 'Password',
            decoration: const InputDecoration(
                labelText: 'Password', icon: Icon(Icons.lock)),
            controller: _passwordController,
            validator: (value) =>
                value!.isEmpty ? 'Password can\'t be empty' : null,
            obscureText: true,
          ),
          PaddedTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            decoration: const InputDecoration(
                labelText: 'Confirm Password', icon: Icon(Icons.lock)),
            validator: (value) => value != _passwordController.text
                ? 'Password fields must match'
                : null,
            obscureText: true,
          ),
          PlatformCheckboxListTile(
              title: PlatformTextButton(
                child: const Text(
                  'I agree to Terms and Conditions',
                  style: TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                ),
                onPressed: () => _launchURL(
                    'https://www.termsfeed.com/terms-conditions/0424a9962833498977879c797842c626'),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              value: tosAgree,
              onChanged: (value) {
                setState(() {
                  tosAgree = value!;
                });
              }),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PlatformButton(
                buttonPadding: kIsWeb
                    ? 18.0
                    : Platform.isAndroid
                        ? 8.0
                        : 0.0,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child:
                      Text('Create Account', style: TextStyle(fontSize: 18.0)),
                ),
                onPressed: () {
                  validateAndCreate(auth);
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PlatformTextButton(
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Back to Login',
                    style: TextStyle(fontSize: 18.0, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
                onPressed: () {
                  rootService.signOut();
                }),
          ),
        ],
      ),
    );
  }
}
