import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/buttons.dart';

import '../components/custom_back_button.dart';

class PhoneverificationPage extends StatefulWidget {
  const PhoneverificationPage({super.key});

  @override
  State<PhoneverificationPage> createState() => _PhoneverificationPageState();
}

class _PhoneverificationPageState extends State<PhoneverificationPage> {
  @override
  Widget build(BuildContext context) {
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 30),
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            Text(
                              'Verify Phone Number',
                              style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  height: 2),
                            ),
                            Text(
                              'We Have Sent A Code To Your Number',
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 50),
                            Text(
                              '+233 54 610 2771',
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(5),
                                      counter: null,
                                      counterText: null,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    textAlign: TextAlign.center,
                                    maxLength: 4,
                                    style: GoogleFonts.poppins(
                                        fontSize: 40,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                const SizedBox(width: 5),
                              ],
                            ),
                            const SizedBox(height: 20),
                            MyButton(
                              onPressed: () {},
                              btnText: 'Verify',
                              isPrimary: true,
                            ),
                            const SizedBox(height: 10),
                            MyButton(
                              onPressed: () {},
                              btnText: 'Send Again',
                              isPrimary: false,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 25,
              left: 25,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    MyBackButton(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
