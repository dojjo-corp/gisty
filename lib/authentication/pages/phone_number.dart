import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/buttons.dart';

import '../../global/homepage.dart';
import '../components/custom_back_button.dart';

class EnterPhonePage extends StatelessWidget {
  const EnterPhonePage({super.key});

  @override
  Widget build(BuildContext context) {
    void goToVerifyPhone() {
      // navigate to verification page
      Navigator.pushNamed(context, '/verify-phone');
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

                      TextFormField(
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
                          hintText: '+233 241 234 567'
                        ),
                        style: GoogleFonts.poppins(
                            color: Theme.of(context).primaryColor),
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
