import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/buttons.dart';

import '../../global/homepage.dart';
import '../components/custom_back_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  Color _prefixIconColorName = Colors.grey;
  Color _prefixIconColorEmail = Colors.grey;
  Color _prefixIconColorPassword = Colors.grey;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
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
                          'Create Your Account',
                          style: GoogleFonts.poppins(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person_rounded),
                              prefixIconColor: _prefixIconColorName,
                              hintText: 'Enter Your Fullname'),
                          onChanged: (value) {
                            if (nameController.text.isNotEmpty) {
                              setState(() {
                                _prefixIconColorName = Theme.of(context).primaryColor;
                              });
                            } else {
                              setState(() {
                                _prefixIconColorName = Colors.grey;
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
                                _prefixIconColorEmail = Theme.of(context).primaryColor;
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
                                  ? const Icon(Icons.visibility_rounded, color: Colors.grey,)
                                  : const Icon(Icons.visibility_off_rounded, color: Colors.grey,),
                            ),
                          ),
                          onChanged: (value) {
                            if (passwordController.text.isNotEmpty) {
                              setState(() {
                                _prefixIconColorPassword = Theme.of(context).primaryColor;
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
                          onPressed: () async {
                            // firebase auth login method
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MyHomePage(title: 'Gisty'),
                              ),
                            );
                          },
                          btnText: 'Register',
                          isPrimary: true,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already Have An Account?'),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pushNamed('/login'),
                              child: Text(
                                'Sign In',
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
             const Positioned(
              top: 25, 
              left:25,
              child: MyBackButton()
            ),
          ],
        ),
      ),
    );
  }
}
