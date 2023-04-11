import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/auth_provider.dart';
import 'package:leaders_book/models/user.dart';
import 'package:leaders_book/providers/root_provider.dart';
import 'package:leaders_book/widgets/center_progress_indicator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../apple_sign_in_available.dart';
import '../methods/show_on_login.dart';
import '../methods/theme_methods.dart';
import '../providers/soldiers_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/platform_widgets/platform_scaffold.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

enum FormType { login, register, forgotPassword }

class LoginPageState extends ConsumerState<LoginPage> {
  final formKey = GlobalKey<FormState>();

  String? _email;
  String? _password;
  FormType _formType = FormType.login;
  SharedPreferences? prefs;
  late PackageInfo pInfo;
  late RootService rootService;
  bool localAuthAvail = false, isLoggingIn = false;
  final LocalAuthentication localAuth = LocalAuthentication();

  final _passwordController = TextEditingController();
  final _rankController = TextEditingController();
  final _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void createAccount(User user) async {
    ref.read(soldiersProvider.notifier).loadSoldiers(user.uid);

    if (user.metadata.creationTime!.isBefore(
      DateTime.now().subtract(
        const Duration(minutes: 1),
      ),
    )) {
      FirebaseFirestore.instance.doc('users/${user.uid}').update(
          {'lastLogin': DateTime.now(), 'created': user.metadata.creationTime});

      return;
    }
    final userObj = UserObj(
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
        .set(userObj.toMap());

    ref.read(userProvider).loadUser(user.uid);
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
          user = await auth.signInWithEmailAndPassword(_email, _password);
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
        await auth.resetPassword(_email).then((result) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Check email to reset password'),
          ));
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Failed to send reset email. Did you enter your correct address?'),
          ));
        });
      }
    } catch (e) {
      // return to login screen if login fails
      setState(() {
        isLoggingIn = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
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
      bool showNipr = prefs!.getBool('niprWarning') == null
          ? true
          : !prefs!.getBool('niprWarning')!;
      localAuthAvail = false;
      if (mounted && showNipr) {
        showNiprWarning(context, prefs);
      }
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

  @override
  Widget build(BuildContext context) {
    final rootService = ref.read(rootProvider.notifier);
    double width = MediaQuery.of(context).size.width;
    final appleSignInAvailable =
        ref.read(appleSignInAvailableProvider).isAvailable;
    return PlatformScaffold(
      title: 'Login',
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width > 932 ? (width - 916) / 2 : 16),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          constraints: const BoxConstraints(maxWidth: 900.0),
          child: isLoggingIn
              ? const CenterProgressIndicator()
              : Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.always,
                  child: Card(
                    color: getContrastingBackgroundColor(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        shrinkWrap: true,
                        children: sizedBox(32.0) +
                            logo() +
                            sizedBox(32.0) +
                            buildInputs() +
                            buildSubmitButtons(
                                appleSignInAvailable, rootService),
                      ),
                    ),
                  )),
        ),
      ),
    );
  }

  List<Widget> logo() {
    return [
      Hero(
        tag: 'hero',
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 96.0,
          child: Image.asset('assets/icon-512.png'),
        ),
      )
    ];
  }

  List<Widget> sizedBox(height) {
    return [SizedBox(height: height)];
  }

  List<Widget> buildInputs() {
    if (_formType == FormType.login) {
      return emailFormField() + sizedBox(16.0) + passwordFormField();
    } else {
      return emailFormField();
    }
  }

  List<Widget> emailFormField() {
    return [
      TextFormField(
        decoration:
            const InputDecoration(labelText: 'Email', icon: Icon(Icons.mail)),
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) => value!.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value,
      ),
    ];
  }

  List<Widget> passwordFormField() {
    return [
      TextFormField(
        controller: _passwordController,
        decoration: const InputDecoration(
            labelText: 'Password', icon: Icon(Icons.lock)),
        validator: (value) =>
            value!.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value,
        obscureText: true,
      ),
    ];
  }

  List<Widget> rankFormField() {
    return [
      TextFormField(
        controller: _rankController,
        decoration: const InputDecoration(
          labelText: 'Rank (Optional)',
        ),
      ),
    ];
  }

  List<Widget> nameFormField() {
    return [
      TextFormField(
        controller: _nameController,
        validator: (value) => value!.isEmpty ? 'Name can\'t be empty' : null,
        decoration: const InputDecoration(
          labelText: 'Name',
        ),
      ),
    ];
  }

  List<Widget> confirmPasswordField() {
    return [
      TextFormField(
        decoration: const InputDecoration(
            labelText: 'Confirm Password', icon: Icon(Icons.lock)),
        validator: (value) => value != _passwordController.text
            ? 'Password fields must match'
            : null,
        onSaved: (value) => _password = value,
        obscureText: true,
      ),
    ];
  }

  List<Widget> buildSubmitButtons(
      bool appleAvailable, RootService rootService) {
    if (_formType == FormType.login) {
      List<Widget> list = [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(4.0)),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(24.0))))),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Sign in',
                  style: TextStyle(fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),
              ),
              onPressed: () {
                validateAndSubmit('email');
              }),
        ),
      ];
      if (localAuthAvail || kIsWeb) {
        list.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(4.0)),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(24.0))))),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Sign in with Google',
                  style: TextStyle(fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),
              ),
              onPressed: () {
                validateAndSubmit('google');
              }),
        ));
      }
      if (appleAvailable) {
        list.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: SignInWithAppleButton(
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            iconAlignment: IconAlignment.center,
            onPressed: () {
              validateAndSubmit('apple');
            },
          ),
        ));
      }
      list.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
            style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.all(4.0)),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(24.0))))),
            onPressed: signInAnonymously,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Sign in as Guest',
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            )),
      ));
      list.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          child: const Text(
            'Create an account',
            style: TextStyle(fontSize: 18.0),
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            rootService.createAccout();
          },
        ),
      ));
      list.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          onPressed: moveToForgotPassword,
          child: const Text(
            'Forgot password',
            style: TextStyle(fontSize: 18.0),
            textAlign: TextAlign.center,
          ),
        ),
      ));

      return list;
    } else if (_formType == FormType.register) {
      return [
        ElevatedButton(
            style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.all(4.0)),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(24.0))))),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Create an account',
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            ),
            onPressed: () {
              validateAndSubmit('register');
            }),
        TextButton(
          onPressed: moveToLogin,
          child: const Text(
            'Have an account? Login',
            style: TextStyle(fontSize: 18.0),
            textAlign: TextAlign.center,
          ),
        ),
        TextButton(
          onPressed: moveToForgotPassword,
          child: const Text(
            'Forgot password',
            style: TextStyle(fontSize: 18.0),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    } else if (_formType == FormType.forgotPassword) {
      return [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(4.0)),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(24.0))))),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Send reset password email',
                  style: TextStyle(fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),
              ),
              onPressed: () {
                validateAndSubmit('reset');
              }),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: moveToLogin,
            child: const Text(
              'Remember password? Login',
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            child: const Text(
              'Create an account',
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            onPressed: () {
              rootService.createAccout();
            },
          ),
        )
      ];
    } else {
      return [
        ElevatedButton(
          style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.all(4.0)),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                  const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24.0))))),
          child: const Text(
            'Sign in with Google',
            style: TextStyle(fontSize: 18.0),
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            validateAndSubmit('google');
          },
        ),
        TextButton(
          onPressed: moveToLogin,
          child: const Text(
            'Back to Login Page',
            style: TextStyle(fontSize: 18.0),
            textAlign: TextAlign.center,
          ),
        ),
        TextButton(
          child: const Text(
            'Create an account',
            style: TextStyle(fontSize: 18.0),
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            rootService.createAccout();
          },
        )
      ];
    }
  }
}
