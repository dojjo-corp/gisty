import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/buttons.dart';

import '../../global/homepage.dart';
import '../components/custom_back_button.dart';

class EnterPhonePage extends StatelessWidget {
  EnterPhonePage({required this.userId, super.key});
  final String userId;
  final _key = GlobalKey<FormState>();
  final contactController = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    void goToVerifyPhone() async {
      // validate phone number
      if (_key.currentState!.validate()) {
        _key.currentState!.save();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'contact': contactController.text.split(' ').join()});

        // todo: initiate phone number verification process

        // navigate to verification page
        Navigator.pushNamed(context, '/verify-phone');
      }
    }

    void goToHome() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(pageIndex: 0),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(25),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Enter Your Phone Number',
                        style: GoogleFonts.poppins(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 60),
                      Form(
                        key: _key,
                        child: TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12)),
                            prefixIcon: Icon(Icons.phone_rounded,
                                color: Theme.of(context).primaryColor),
                            hintText: '0241 234 567',
                          ),
                          style: GoogleFonts.poppins(
                              color: Theme.of(context).primaryColor),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter phone number';
                            } else if (value.split(' ').join().length != 10) {
                              return 'Number must be 10 digits';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      MyButton(
                          onPressed: goToVerifyPhone,
                          btnText: 'Verification',
                          isPrimary: true),
                      const SizedBox(height: 10),
                      MyButton(
                        onPressed: goToHome,
                        btnText: 'Later',
                        isPrimary: false,
                      )
                    ],
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
