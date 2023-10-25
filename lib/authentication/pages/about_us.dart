import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/page_title.dart';

import '../components/buttons/buttons.dart';
import '../components/buttons/custom_back_button.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100.0, left: 15, right: 15),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const PageTitle(title: 'About Us'),
                    const CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage(
                          'assets/GCTU-Logo-600x600.png'), // Replace with your logo image
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'GCTU Repo',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed et justo a odio tempus finibus. Nulla facilisi. In eget ante sit amet nisi congue auctor. Cras vel ultricies justo. Vivamus vel ligula eget turpis luctus scelerisque. Integer id orci in metus varius malesuada.',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20.0),
                    MyButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/contact-us');
                      },
                      btnText: 'Contact Us',
                      isPrimary: true,
                    ),
                  ],
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
