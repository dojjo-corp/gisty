import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/pages/administrator/edit_contact_info.dart';
import 'package:provider/provider.dart';

import '../components/buttons/buttons.dart';
import '../components/buttons/custom_back_button.dart';
import '../components/page_title.dart';
import '../providers/user_provider.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isUserAdmin = Provider.of<UserProvider>(context).isUserAdmin;
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
                    const PageTitle(title: 'Contact Information'),
                    const ListTile(
                      leading: Icon(Icons.phone),
                      title: Text('Phone Number'),
                      subtitle: Text('+1 (123) 456-7890'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.email),
                      title: Text('Email'),
                      subtitle: Text('info@example.com'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text('Address'),
                      subtitle: Text('123 Main St, City, Country'),
                    ),
                    const SizedBox(height: 20),
                    !isUserAdmin
                        ? MyButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/feedback');
                            },
                            btnText: 'Feedback / Report',
                            isPrimary: true,
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
          const MyBackButton(),
          Positioned(
            top: 45,
            right: 5,
            child: Tooltip(
              message: 'Edit Contact Info',
              child: IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditContactInfo(),
                    ),
                  );
                },
                color: Theme.of(context).primaryColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}
