import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/pages/welcome%20screen/welcome_archive.dart';
import 'package:gt_daily/authentication/pages/welcome%20screen/welcome_greetings.dart';
import 'package:gt_daily/authentication/pages/welcome%20screen/welcome_jobs.dart';
import 'package:gt_daily/authentication/pages/welcome%20screen/welcome_messaging.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _pageIndex = 0;
  final List<Widget> welcomePages = [
    const WelcomeGreetings(),
    const WelcomeArchive(),
    const WelcomeMessaging(),
    const WelcomeJobs(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: welcomePages[_pageIndex],
            ),
            _pageIndex != 3 && _pageIndex != 0
                ? Positioned(
                    top: 10,
                    left: 0,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        'Skip',
                        style: GoogleFonts.montserrat(
                          color:
                              const Color.fromARGB(255, 75, 125, 200),
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
      floatingActionButton: _pageIndex != 3
          ? FloatingActionButton(
              onPressed: () => setState(() {
                _pageIndex++;
              }),
              backgroundColor: const Color.fromARGB(255, 75, 125, 200),
              child: const Icon(Icons.double_arrow_rounded),
            )
          : Container(),
    );
  }
}
