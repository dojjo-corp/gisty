import 'package:flutter/material.dart';

import '../components/custom_back_button.dart';

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
              child: const SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    ListTile(
                      leading: Icon(Icons.phone),
                      title: Text('Phone Number: +1 (123) 456-7890'),
                    ),
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text('Email: info@example.com'),
                    ),
                    ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text('Address: 123 Main St, City, Country'),
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
