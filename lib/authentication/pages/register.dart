import 'dart:developer';
// import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/buttons.dart';
import 'package:gt_daily/authentication/repository/authentication_repo.dart';
import 'package:gt_daily/authentication/repository/firestore_repo.dart';

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
  Color _prefixIconColorId = Colors.grey;
  Color _prefixIconColorPassword = Colors.grey;
  final nameController = TextEditingController();
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
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

        // make firestore entry
        if (userCredential != null) {
          switch (selectedUserType.toLowerCase()) {
            case 'student':
              await firestoreRepo.createStudentDoc(
                uid: idController.text,
                fullName: nameController.text,
                userName: userNameController.text,
                email: emailController.text,
              );
              break;
            case 'industry professional':
              await firestoreRepo.createIndustryProfessionalDoc(
                uid: idController.text,
                fullName: nameController.text,
                userName: userNameController.text,
                email: emailController.text,
              );
              break;
            case 'university professional':
              await firestoreRepo.createUniversityProfessionalDoc(
                uid: idController.text,
                fullName: nameController.text,
                userName: userNameController.text,
                email: emailController.text,
              );
              break;
            default:
              log('Invalid user type');
          }
          await user?.updateDisplayName(nameController.text.split(' ')[0]);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MyHomePage(pageIndex: 0),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error registering user: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }

    return SafeArea(
      child: Scaffold(
        floatingActionButton:
            _isLoading ? const CircularProgressIndicator() : null,
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
                                _prefixIconColorName =
                                    Theme.of(context).primaryColor;
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
                          controller: idController,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.web_rounded),
                              prefixIconColor: _prefixIconColorId,
                              hintText: 'Enter Your Id Number'),
                          onChanged: (value) {
                            if (idController.text.isNotEmpty) {
                              setState(() {
                                _prefixIconColorId =
                                    Theme.of(context).primaryColor;
                              });
                            } else {
                              setState(() {
                                _prefixIconColorId = Colors.grey;
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
                            });
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
                              onTap: () =>
                                  Navigator.of(context).pushNamed('/login'),
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
            const Positioned(top: 25, left: 25, child: MyBackButton()),
          ],
        ),
      ),
    );
  }
}
