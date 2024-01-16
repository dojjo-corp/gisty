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
import 'package:gt_daily/authentication/pages/user%20authentication/login.dart';
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
  bool _showForStudent = false;
  bool _showForBothUniAndStud = true;

  String selectedUserType = 'Choose User Type';
  final List<String> userTypes = [
    'Choose User Type',
    'Student',
    'University professional',
    'Industry professional'
  ];

  // faculty; for only students and university professionals
  String selectedFaculty = 'Choose your faculty';
  final List<String> faculties = [
    'Choose your faculty',
    'Faculty of Engineering',
    'Faculty of Computing and Information Systems',
    'GCTU Business School'
  ];

  // firebase models
  final firestoreRepo = FirestoreRepo();
  final auth = AuthRepository();

  @override
  Widget build(BuildContext context) {
    // registration function
    Future<void> register() async {
      if (_key.currentState!.validate() && selectedUserType != userTypes[0]) {
        _key.currentState!.save();

        try {
          setState(() {
            _isLoading = true;
          });
          // authenticate user with firebase auth
          final userCredential = await auth.register(
            email: emailController.text.toLowerCase(),
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
                  email: emailController.text.toLowerCase(),
                  startYear: startYearController.text,
                  endYear: endYearController.text,
                  faculty: selectedFaculty,
                );
                break;
              case 'industry professional':
                await firestoreRepo.createIndustryProfessionalDoc(
                  uid: userId,
                  fullName: nameController.text,
                  userName: userNameController.text,
                  email: emailController.text.toLowerCase(),
                );
                break;
              case 'university professional':
                await firestoreRepo.createUniversityProfessionalDoc(
                    uid: userId,
                    fullName: nameController.text,
                    userName: userNameController.text,
                    email: emailController.text.toLowerCase(),
                    faculty: selectedFaculty);
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
                    child: Form(
                      key: _key,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PageTitle(
                            title: 'Create Your Account',
                            // textColor: Theme.of(context).primaryColor,
                          ),

                          // todo: FULLNAME
                          SimpleTextField(
                            controller: nameController,
                            hintText: 'Enter Your Fullname',
                            iconData: Icons.person,
                            isWithIcon: true,
                            autofillHints: null,
                          ),
                          const SizedBox(height: 5),

                          // todo: EMAIL
                          SimpleTextField(
                            controller: emailController,
                            hintText: 'Enter Your Email',
                            iconData: Icons.mail_rounded,
                            isWithIcon: true,
                            autofillHints: null,
                          ),
                          const SizedBox(height: 5),

                          // todo: ID NUMBER
                          SimpleTextField(
                            controller: idController,
                            hintText: 'Enter Your Id Number',
                            iconData: Icons.web_rounded,
                            isWithIcon: true,
                            autofillHints: null,
                          ),
                          const SizedBox(height: 5),

                          // todo: USER TYPE/ROLE
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
                              final val = value?.toLowerCase();
                              setState(() {
                                selectedUserType = value!;

                                // show usertype-specific fields
                                if (val == 'industry professional') {
                                  _showForBothUniAndStud = false;
                                } else {
                                  // either student or university professional
                                  _showForBothUniAndStud = true;
                                  // only student in this cacse
                                  if (val == 'student') {
                                    _showForStudent = true;
                                  } else {
                                    _showForStudent = false;
                                  }
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 5),

                          // todo: STUDENT START AND END YEARS
                          // show start and end years textfield if user is a student
                          _showForStudent
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
                                    const SizedBox(height: 5),
                                  ],
                                )
                              : Container(),

                          // todo FACULTY
                          _showForBothUniAndStud
                              ? Column(
                                  children: [
                                    DropdownButtonFormField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        fillColor: Colors.white,
                                        filled: true,
                                      ),
                                      value: selectedFaculty,
                                      items: faculties
                                          .map(
                                            (String faculty) =>
                                                DropdownMenuItem<String>(
                                              value: faculty,
                                              child: Text(
                                                faculty,
                                                style: TextStyle(
                                                    color: Colors.grey[700]),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedFaculty = value!;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 5),
                                  ],
                                )
                              : Container(),

                          // todo: PASSWORD
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
                          const SizedBox(height: 5),

                          // todo: CONFIRM PASSWORD
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
                          const SizedBox(height: 10),

                          // todo: REGISTER BUTTON
                          MyButton(
                            onPressed: register,
                            btnText: 'Register',
                            isPrimary: true,
                          ),
                          const SizedBox(height: 15),

                          // todo: NAVIGATE TO LOGIN
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already Have An Account?',
                                // style: TextStyle(
                                //   color: Theme.of(context).primaryColor,
                                // ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(
                                      isFromWelcomeScreen: true,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  ' Sign In',
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
            ),
            const MyBackButton()
          ],
        ),
      ),
    );
  }
}
