import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/buttons.dart';
import '../../components/custom_back_button.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final _key = GlobalKey<FormFieldState>();
  Color _prefixIconColorEmail = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100, bottom: 10, right: 20, left: 20),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ListView(
                children: <Widget>[
                  Text(
                    'Reset Your Password',
                    style: GoogleFonts.poppins(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    key: _key,
                    controller: _emailController,
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
                      if (_emailController.text.isNotEmpty) {
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
                  const SizedBox(height: 16.0),
                  MyButton(
                    onPressed: () {
                      _resetPassword(_emailController.text);
                    },
                    btnText: 'Reset Password',
                    isPrimary: true,
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 40,
            left: 5,
            child: MyBackButton(),
          )
        ],
      ),
      floatingActionButton: _isLoading ? const LinearProgressIndicator() : null,
    );
  }

  void _resetPassword(String email) async {
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        _showSuccessDialog('Password reset email sent.');
        _emailController.clear();
      } catch (e) {
        _showErrorDialog(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(
              '$message\nIf you don\' see the email, re-login and try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
