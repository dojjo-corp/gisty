// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../global/homepage.dart';
import '../../components/buttons/buttons.dart';
import '../../components/buttons/custom_back_button.dart';
import '../../components/textfields/simple_textfield.dart';
import '../../repository/authentication_repo.dart';

class LoginPage extends StatefulWidget {
  final bool isFromWelcomeScreen;
  const LoginPage({super.key, required this.isFromWelcomeScreen});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  Widget loginBtnChild = const Text('Login');

  @override
  Widget build(BuildContext context) {
    final auth = AuthRepository();

    Future<void> login() async {
      setState(() {
        _isLoading = true;
      });
      try {
        final u = await auth.login(
          email: emailController.text,
          password: passwordController.text,
        );
        if (u != null) {
          final fcmToken = await FirebaseMessaging.instance.getToken();

          // check if user's document exists in firestore
          final docSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(u.user!.uid)
              .get();

          if (docSnapshot.exists) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(u.user!.uid)
                .update({'fcm-token': fcmToken});
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(pageIndex: 0),
                ),
              );
            }
          } else {
            // user's account is inactive/deleted if their document does not exist
            FirebaseAuth.instance.signOut();
            throw 'User Accout Does Not Exist';
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging user in: ${e.toString()}'),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }

    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm'),
            content: const Text('Do you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        floatingActionButton:
            _isLoading ? const CircularProgressIndicator() : null,
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 100, bottom: 10, right: 20, left: 20),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login Your Account',
                          style: GoogleFonts.poppins(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            // color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const SizedBox(height: 15),
                        AutofillGroup(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // todo: Email TextField
                                SimpleTextField(
                                  autofillHints: const [AutofillHints.email],
                                  controller: emailController,
                                  hintText: 'Email',
                                  iconData: Icons.email_rounded,
                                  isWithIcon: true,
                                ),
                                const SizedBox(height: 5),

                                // todo: Password TextField
                                SimpleTextField(
                                  controller: passwordController,
                                  hintText: 'Password',
                                  iconData: Icons.lock_rounded,
                                  isWithIcon: true,
                                  autofillHints: const [AutofillHints.password],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/reset-password');
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(right: 10.0),
                                child: Text(
                                  'Forgot password?',
                                  // style: TextStyle(
                                  //   color: Theme.of(context).primaryColor,
                                  // ),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        MyButton(
                          onPressed: login,
                          btnText: 'Login',
                          isPrimary: true,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Create New Account?',
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context)
                                  .popAndPushNamed('/register'),
                              child: Text(
                                ' Register',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  // color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const MyBackButton(),
          ],
        ),
      ),
    );
  }
}
