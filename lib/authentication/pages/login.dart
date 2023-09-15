// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/buttons.dart';
import 'package:gt_daily/authentication/repository/authentication_repo.dart';

import '../../global/homepage.dart';
import '../components/custom_back_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  Color _prefixIconColorEmail = Colors.grey;
  Color _prefixIconColorPassword = Colors.grey;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;
  Widget loginBtnChild = const Text('Login');

  @override
  Widget build(BuildContext context) {
    final auth = AuthRepository();
    Future<void> login() async {
      try {
        setState(() {
          loginBtnChild = const CircularProgressIndicator();
        });
        final u = await auth.login(
          email: emailController.text,
          password: passwordController.text,
        );
        if (u != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(pageIndex: 0),
            ),
          );
        }
      } catch (e) {
        setState(() {
          loginBtnChild = const Text('Login');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).dialogBackgroundColor,
          ),
        );
      }
    }

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login Your Account',
                          style: GoogleFonts.poppins(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 30),
                        const SizedBox(height: 15),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: const Icon(Icons.email_rounded),
                                    prefixIconColor: _prefixIconColorEmail,
                                    hintText: 'Enter Your Email'),
                                onChanged: (value) {
                                  if (emailController.text.isNotEmpty) {
                                    setState(() {
                                      _prefixIconColorEmail =
                                          Theme.of(context).primaryColor;
                                    });
                                  } else {
                                    setState(() {
                                      _prefixIconColorEmail = Colors.grey;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Field can\'t be empty!';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: passwordController,
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.lock_rounded),
                                  prefixIconColor: _prefixIconColorPassword,
                                  hintText: 'Password',
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                    child: _obscureText
                                        ? const Icon(Icons.visibility_rounded,
                                            color: Colors.grey)
                                        : const Icon(
                                            Icons.visibility_off_rounded,
                                            color: Colors.grey),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (passwordController.text.isNotEmpty) {
                                    setState(() {
                                      _prefixIconColorPassword =
                                          Theme.of(context).primaryColor;
                                    });
                                  } else {
                                    setState(() {
                                      _prefixIconColorPassword = Colors.grey;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Field can\'t be empty!';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Forgot password?',
                              style: TextStyle(color: Colors.grey[800]),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        MyButton(
                          onPressed: login,
                          btnText: 'Login',
                          isPrimary: true,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Create New Account?'),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.of(context).pushNamed('/register'),
                              child: Text(
                                'Register',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
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
            const Positioned(top: 25, left: 25, child: MyBackButton()),
          ],
        ),
      ),
    );
  }
}
