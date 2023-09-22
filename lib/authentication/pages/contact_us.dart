import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/buttons.dart';
import 'package:gt_daily/authentication/components/custom_back_button.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100, bottom: 10, right: 20, left: 20),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const ListTile(
                      leading: Icon(Icons.phone),
                      title: Text('Phone Number: +1 (123) 456-7890'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.email),
                      title: Text('Email: info@example.com'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text('Address: 123 Main St, City, Country'),
                    ),
                    const SizedBox(height: 20),
                    Provider.of<UserProvider>(context).userType != 'student'
                        ? MyButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/messaging');
                            },
                            btnText: 'Chat With Us!',
                            isPrimary: true,
                          )
                        : const Text(''),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            top: 40,
            left: 10,
            child: MyBackButton(),
          )
        ],
      ),
    );
  }
}
