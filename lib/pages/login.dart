import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../providers/auth_provider.dart';
import '../models/leader.dart';
import '../../providers/root_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/center_progress_indicator.dart';
import '../../widgets/form_frame.dart';
import '../../widgets/logo_widget.dart';
import '../apple_sign_in_available.dart';
import '../providers/soldiers_provider.dart';
import '../providers/leader_provider.dart';
import '../widgets/my_toast.dart';
import '../widgets/padded_text_field.dart';
import '../widgets/platform_widgets/platform_button.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';
import '../widgets/platform_widgets/platform_text_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

enum FormType { login, forgotPassword }

class LoginPageState extends ConsumerState<LoginPage> {
  final formKey = GlobalKey<FormState>();

  FormType _formType = FormType.login;
  SharedPreferences? prefs;
  late PackageInfo pInfo;
  late RootService rootService;
  bool localAuthAvail = false, isLoggingIn = false;
  final LocalAuthentication localAuth = LocalAuthentication();
  FToast toast = FToast();

  final _passwordController = TextEditingController();
  final _rankController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rankController.dispose();
    _nameController.dispose();
  }

  @override
  void initState() {
    super.initState();
    rootService = ref.read(rootProvider.notifier);
    init();
  }

  void init() async {
    prefs = await SharedPreferences.getInstance();
    if (!kIsWeb) {
      pInfo = await PackageInfo.fromPlatform();
      localAuthAvail = await localAuth.isDeviceSupported();
    } else {
      localAuthAvail = false;
    }
    if (prefs!.getBool("Agree") == null || !prefs!.getBool('Agree')!) {
      prefs!.setBool('Agree', true);
      if (!kIsWeb) {
        prefs!.setString('Version', pInfo.version);
      }
    }
    if (mounted) {
      setState(() {
        _emailController.text = prefs!.getString('email') ?? '';
      });
    }
  }

  void createAccount(User user) async {
    ref.read(soldiersProvider.notifier).loadSoldiers(user.uid);
    ref.read(settingsProvider.notifier).init(user.uid);

    if (user.metadata.creationTime!.isBefore(
      DateTime.now().subtract(
        const Duration(minutes: 1),
      ),
    )) {
      FirebaseFirestore.instance.doc('users/${user.uid}').update(
          {'created': user.metadata.creationTime, 'lastLogin': DateTime.now()});
      ref.read(leaderProvider).init(user.uid);
      return;
    }
    final leader = Leader(
      userId: user.uid,
      userEmail: user.email ?? 'anonymous@email.com',
      userName: user.displayName ?? '',
      updatedUserArray: true,
      agreeDate: DateTime.now(),
      createdDate: DateTime.now(),
      lastLoginDate: DateTime.now(),
    );
    await FirebaseFirestore.instance
        .doc('users/${user.uid}')
        .set(leader.toMap());

    ref.read(leaderProvider).init(user.uid);
  }

  bool validateAndSave() {
    final form = formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit(String loginType) async {
    User? user;
    try {
      var auth = ref.read(authProvider);
      if (_formType == FormType.login) {
        // show progress bar while signing in
        setState(() {
          isLoggingIn = true;
        });
        if (loginType == 'email' && validateAndSave()) {
          prefs!.setString('email', _emailController.text);
          user = await auth.signInWithEmailAndPassword(
              _emailController.text, _passwordController.text);
          createAccount(user!);
        } else if (loginType == 'google') {
          user = await auth.signInWithGoogle();
          createAccount(user!);
        } else {
          user = await auth.signInWithApple();
          createAccount(user!);
        }
        rootService.signIn();
      } else {
        await auth.resetPassword(_emailController.text).then((result) {
          toast.showToast(
            child: const MyToast(
              message: 'Check email to reset password',
            ),
          );
        }).catchError((error) {
          toast.showToast(
            child: const MyToast(
              message:
                  'Failed to send reset email. Did you enter your correct address?',
            ),
          );
        });
      }
    } catch (e) {
      // return to login screen if login fails
      setState(() {
        isLoggingIn = false;
      });
      toast.showToast(
        child: MyToast(
          message: e.toString(),
        ),
      );
    }
  }

  void signInAnonymously() async {
    setState(() {
      isLoggingIn = true;
    });
    var auth = ref.read(authProvider);
    final user = (await auth.createAnonymousUser())!;
    createAccount(user);
    rootService.signIn();
  }

  void moveToLogin() {
    formKey.currentState!.reset();
    if (mounted) {
      setState(() {
        _formType = FormType.login;
      });
    }
  }

  void moveToForgotPassword() {
    formKey.currentState!.reset();
    if (mounted) {
      setState(() {
        _formType = FormType.forgotPassword;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    toast.context = context;
    final rootService = ref.read(rootProvider.notifier);
    final appleSignInAvailable =
        ref.read(appleSignInAvailableProvider).isAvailable;
    return PlatformScaffold(
      title: 'Login',
      body: isLoggingIn
          ? const CenterProgressIndicator()
          : FormFrame(
              formKey: formKey,
              children: [
                const LogoWidget(),
                PaddedTextField(
                  label: 'Email',
                  decoration: const InputDecoration(
                      labelText: 'Email', icon: Icon(Icons.mail)),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? 'Email can\'t be empty' : null,
                ),
                if (_formType == FormType.login)
                  PaddedTextField(
                    controller: _passwordController,
                    label: 'Password',
                    decoration: const InputDecoration(
                        labelText: 'Password', icon: Icon(Icons.lock)),
                    validator: (value) =>
                        value!.isEmpty ? 'Password can\'t be empty' : null,
                    obscureText: true,
                  ),
                if (_formType == FormType.login)
                  PlatformButton(
                      buttonPadding: kIsWeb
                          ? 18.0
                          : Platform.isAndroid
                              ? 12.0
                              : 0.0,
                      child: const Text(
                        'Sign in',
                        style: TextStyle(fontSize: 18.0),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        validateAndSubmit('email');
                      }),
                if (_formType == FormType.login)
                  PlatformButton(
                      buttonPadding: kIsWeb
                          ? 18.0
                          : Platform.isAndroid
                              ? 12.0
                              : 0.0,
                      child: const Text(
                        'Sign in with Google',
                        style: TextStyle(fontSize: 18.0),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        validateAndSubmit('google');
                      }),
                if (_formType == FormType.login && appleSignInAvailable)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SignInWithAppleButton(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      iconAlignment: IconAlignment.center,
                      onPressed: () {
                        validateAndSubmit('apple');
                      },
                    ),
                  ),
                if (_formType == FormType.login)
                  PlatformButton(
                    buttonPadding: kIsWeb
                        ? 18.0
                        : Platform.isAndroid
                            ? 12.0
                            : 0.0,
                    onPressed: signInAnonymously,
                    child: const Text(
                      'Sign in as Guest',
                      style: TextStyle(fontSize: 18.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_formType == FormType.forgotPassword)
                  PlatformButton(
                      buttonPadding: kIsWeb
                          ? 18.0
                          : Platform.isAndroid
                              ? 12.0
                              : 0.0,
                      child: const Text(
                        'Send reset password email',
                        style: TextStyle(fontSize: 18.0),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        validateAndSubmit('reset');
                      }),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PlatformTextButton(
                    child: const Text(
                      'Create an account',
                      style: TextStyle(fontSize: 18.0, color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      rootService.createAccout();
                    },
                  ),
                ),
                if (_formType == FormType.login)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PlatformTextButton(
                      onPressed: moveToForgotPassword,
                      child: const Text(
                        'Forgot password',
                        style: TextStyle(fontSize: 18.0, color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (_formType == FormType.forgotPassword)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PlatformTextButton(
                      onPressed: moveToLogin,
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(fontSize: 18.0, color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
