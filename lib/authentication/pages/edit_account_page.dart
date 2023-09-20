import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/buttons.dart';

import '../components/custom_back_button.dart';

class EditAccount extends StatefulWidget {
  const EditAccount({super.key});

  @override
  State<EditAccount> createState() => _EditAccountState();
}

class _EditAccountState extends State<EditAccount> {
  bool _isLoading = false;
  final _key = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  Color _prefixIconColorName = Colors.grey;
  Color _prefixIconColorEmail = Colors.grey;
  Color _prefixIconColorContact = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 80, left: 15, right: 15, bottom: 10),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Form(
                key: _key,
                child: ListView(
                  children: [
                    Text(
                      'Edit Your Profile',
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
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person_rounded),
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
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: contactController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person_rounded),
                          prefixIconColor: _prefixIconColorContact,
                          hintText: 'Enter Your Contact'),
                      onChanged: (value) {
                        if (contactController.text.isNotEmpty) {
                          setState(() {
                            _prefixIconColorContact =
                                Theme.of(context).primaryColor;
                          });
                        } else {
                          setState(() {
                            _prefixIconColorContact = Colors.grey;
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
                      onPressed: () async {
                        if (_key.currentState!.validate()) {
                          _key.currentState!.save();
                          try {
                            setState(() {
                              _isLoading = true;
                            });
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              'fullname': nameController.text.trim(),
                              'email': emailController.text.trim(),
                              'contact': contactController.text.trim(),
                            });
                            nameController.clear();
                            emailController.clear();
                            contactController.clear();
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Profile Updated Successfully. Restart App To See Changes.'),
                                duration: Duration(seconds: 10),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error Updating Profile: ${e.toString()}'),
                              ),
                            );
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                      btnText: 'Update Profile',
                      isPrimary: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(top: 20, left: 10, child: MyBackButton())
        ],
      ),
      floatingActionButton: _isLoading ? const LinearProgressIndicator() : null,
    );
  }
}
