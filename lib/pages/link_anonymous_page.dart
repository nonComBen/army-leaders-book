import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/root_provider.dart';
import '../auth_provider.dart';
import '../../models/user.dart';
import '../widgets/form_frame.dart';
import '../widgets/my_toast.dart';
import '../widgets/padded_text_field.dart';
import '../widgets/platform_widgets/platform_button.dart';
import '../widgets/platform_widgets/platform_checkbox_list_tile.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';

class LinkAnonymousPage extends ConsumerStatefulWidget {
  const LinkAnonymousPage({
    Key? key,
  }) : super(key: key);

  @override
  LinkAnonymousPageState createState() => LinkAnonymousPageState();
}

class LinkAnonymousPageState extends ConsumerState<LinkAnonymousPage> {
  final formKey = GlobalKey<FormState>();
  bool tosAgree = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _rankController = TextEditingController();
  final _nameController = TextEditingController();
  User? user;

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
      toast.context = context;
      toast.showToast(
        child: const MyToast(
          message:
              'You must agree to the Terms and Conditions to create an account.',
        ),
      );
      return false;
    }
    final form = formKey.currentState!;
    if (form.validate() &&
        _emailController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndLink() async {
    final auth = ref.read(authProvider);
    if (validateAndSave()) {
      try {
        await auth.linkEmailAccount(
            _emailController.text, _passwordController.text, user!);
        UserObj userObj = UserObj(
          userId: user!.uid,
          userRank: _rankController.text,
          userName: _nameController.text,
          userEmail: _emailController.text,
          tosAgree: true,
          createdDate: DateTime.now(),
          lastLoginDate: DateTime.now(),
          agreeDate: DateTime.now(),
        );
        FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .set(userObj.toMap(), SetOptions(merge: true));
        ref.read(rootProvider.notifier).signIn();
      } catch (e) {
        FToast toast = FToast();
        toast.context = context;
        toast.showToast(
          child: MyToast(message: e.toString()),
        );
      }
    } else {
      FToast toast = FToast();
      toast.context = context;
      toast.showToast(
        child: const MyToast(
          message:
              'Form is Invalid - Email cannot be blank and password fields must match.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rootService = ref.read(rootProvider.notifier);
    var auth = ref.read(authProvider);
    user = auth.currentUser();
    return PlatformScaffold(
      title: 'Create Account',
      body: FormFrame(
        formKey: formKey,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 96.0,
              child: Image.asset('assets/icon-512.png'),
            ),
          ),
          PaddedTextField(
            label: 'Rank (Optional)',
            decoration: const InputDecoration(
              labelText: 'Rank (Optional)',
            ),
            keyboardType: TextInputType.text,
            controller: _rankController,
          ),
          PaddedTextField(
            label: 'Name (Optional)',
            decoration: const InputDecoration(
              labelText: 'Name (Optional)',
            ),
            keyboardType: TextInputType.text,
            controller: _nameController,
          ),
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
            title: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: TextButton(
                child: const Text(
                  'I agree toTerms and Conditions',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onPressed: () => _launchURL(
                    'https://www.termsfeed.com/terms-conditions/0424a9962833498977879c797842c626'),
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            value: tosAgree,
            onChanged: (value) {
              setState(() {
                tosAgree = value!;
              });
            },
          ),
          PlatformButton(
            child:
                const Text('Create Account', style: TextStyle(fontSize: 18.0)),
            onPressed: () {
              validateAndLink();
            },
          ),
          PlatformButton(
            child: const Text(
              'Return Without Creating Account',
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            onPressed: () {
              rootService.signIn();
            },
          ),
        ],
      ),
    );
  }
}
