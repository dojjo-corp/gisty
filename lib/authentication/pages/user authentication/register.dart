import 'dart:developer';
// import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/buttons/buttons.dart';
import 'package:gt_daily/authentication/components/page_title.dart';
import 'package:gt_daily/authentication/components/textfields/simple_textfield.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:gt_daily/authentication/pages/user%20authentication/phone_number.dart';
import 'package:gt_daily/authentication/repository/authentication_repo.dart';
import 'package:gt_daily/authentication/repository/firestore_repo.dart';

import '../../components/buttons/custom_back_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  Color _prefixIconColorPassword = Colors.grey;
  final _key = GlobalKey<FormState>();
  Color _prefixIconColorConfirmPassword = Colors.grey;
  final nameController = TextEditingController();
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final startYearController = TextEditingController();
  final endYearController = TextEditingController();
  bool _passwordbscureText = true;
  bool _confirmObscureText = true;
  bool _isLoading = false;
  bool _isStudent = false;
  String selectedUserType = 'Choose User Type';
  final List<String> userTypes = [
    'Choose User Type',
    'Student',
    'University professional',
    'Industry professional'
  ];

  // firebase models
  final firestoreRepo = FirestoreRepo();
  final auth = AuthRepository();

  @override
  Widget build(BuildContext context) {
    // registration function
    Future<void> register() async {
      if (_key.currentState!.validate()) {
        _key.currentState!.save();

        try {
          setState(() {
            _isLoading = true;
          });
          // authenticate user with firebase auth
          final userCredential = await auth.register(
            email: emailController.text,
            password: passwordController.text,
          );
          final user = userCredential?.user;

          // make firestore entry for user
          if (userCredential != null) {
            final userId = FirebaseAuth.instance.currentUser!.uid;
            final fcmToken = await FirebaseMessaging.instance.getToken();
            switch (selectedUserType.toLowerCase()) {
              case 'student':
                await firestoreRepo.createStudentDoc(
                  uid: userId,
                  fullName: nameController.text,
                  userName: userNameController.text,
                  email: emailController.text,
                  startYear: startYearController.text,
                  endYear: endYearController.text,
                );
                break;
              case 'industry professional':
                await firestoreRepo.createIndustryProfessionalDoc(
                  uid: userId,
                  fullName: nameController.text,
                  userName: userNameController.text,
                  email: emailController.text,
                );
                break;
              case 'university professional':
                await firestoreRepo.createUniversityProfessionalDoc(
                  uid: userId,
                  fullName: nameController.text,
                  userName: userNameController.text,
                  email: emailController.text,
                );
                break;
              default:
                log('Invalid user type');
            }

            // todo: Get And Store User's Device FCMToken
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .update({'fcm-token': fcmToken});
            await user?.updateDisplayName(nameController.text.split(' ')[0]);

            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const EnterPhonePage(),
                ),
              );
            }
          }
        } catch (e) {
          showSnackBar(context, 'Error registering user: ${e.toString()}');
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }

    return Scaffold(
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
                  child: Form(
                    key: _key,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PageTitle(title: 'Create Your Account'),
                        SimpleTextField(
                          controller: nameController,
                          hintText: 'Enter Your Fullname',
                          iconData: Icons.person,
                          isWithIcon: true,
                          autofillHints: null,
                        ),
                        const SizedBox(height: 10),
                        SimpleTextField(
                          controller: emailController,
                          hintText: 'Enter Your Email',
                          iconData: Icons.mail_rounded,
                          isWithIcon: true,
                          autofillHints: null,
                        ),
                        const SizedBox(height: 10),
                        SimpleTextField(
                          controller: idController,
                          hintText: 'Enter Your Id Number',
                          iconData: Icons.web_rounded,
                          isWithIcon: true,
                          autofillHints: null,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          value: selectedUserType,
                          items: userTypes
                              .map(
                                (String category) => DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedUserType = value!;
                              // show student specific text fields
                              if (value.toLowerCase() == 'student') {
                                _isStudent = true;
                              } else {
                                _isStudent = false;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        // show start and end years textfield if user is a student
                        _isStudent
                            ? Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SimpleTextField(
                                          controller: startYearController,
                                          hintText: 'Start Year',
                                          iconData: Icons.date_range_rounded,
                                          isWithIcon: true,
                                          autofillHints: null,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: SimpleTextField(
                                          controller: endYearController,
                                          hintText: 'End Year',
                                          iconData:
                                              Icons.calendar_month_rounded,
                                          isWithIcon: true,
                                          autofillHints: null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              )
                            : Container(),
                        TextFormField(
                          controller: passwordController,
                          obscureText: _passwordbscureText,
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
                                  _passwordbscureText = !_passwordbscureText;
                                });
                              },
                              child: _passwordbscureText
                                  ? const Icon(
                                      Icons.visibility_rounded,
                                      color: Colors.grey,
                                    )
                                  : const Icon(
                                      Icons.visibility_off_rounded,
                                      color: Colors.grey,
                                    ),
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
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: _confirmObscureText,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.lock_rounded),
                            prefixIconColor: _prefixIconColorConfirmPassword,
                            hintText: 'Confirm Password',
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _confirmObscureText = !_confirmObscureText;
                                });
                              },
                              child: _confirmObscureText
                                  ? const Icon(
                                      Icons.visibility_rounded,
                                      color: Colors.grey,
                                    )
                                  : const Icon(
                                      Icons.visibility_off_rounded,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              value.isNotEmpty
                                  ? _prefixIconColorConfirmPassword =
                                      Theme.of(context).primaryColor
                                  : _prefixIconColorConfirmPassword =
                                      Colors.grey;
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Field can\'t be empty!';
                            }
                            if (value != passwordController.text) {
                              return 'Passwords Don\'t Match!';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        MyButton(
                          onPressed: register,
                          btnText: 'Register',
                          isPrimary: true,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already Have An Account?'),
                            GestureDetector(
                              onTap: () => Navigator.of(context)
                                  .popAndPushNamed('/login'),
                              child: Text(
                                ' Sign In',
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
          ),
          const MyBackButton()
        ],
      ),
    );
  }
}
