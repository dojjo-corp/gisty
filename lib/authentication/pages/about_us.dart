import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/page_title.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../components/buttons/buttons.dart';
import '../components/buttons/custom_back_button.dart';
import '../providers/user_provider.dart';
import 'administrator/edit_about_me.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isUserAdmin =
        Provider.of<UserProvider>(context, listen: false).isUserAdmin;
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
                    StreamBuilder(
                      initialData: const {
                        'description':
                            'Deserunt tempor sint tempor fugiat voluptate tempor cupidatat ex minim consectetur do incididunt. Proident amet laborum aliqua occaecat ad reprehenderit est mollit ullamco. Sit duis veniam nisi pariatur tempor consectetur reprehenderit. Laborum et in enim officia dolor sit consequat do fugiat. Elit nisi exercitation sunt elit. Enim non laboris commodo qui occaecat incididunt.'
                      },
                      stream: FirebaseFirestore.instance
                          .collection('Our Info')
                          .doc('About Us')
                          .snapshots()
                          .throttleTime(
                            const Duration(seconds: 1),
                          ),
                      builder: (context, snapshot) {
                        // BEFORE ANY DATA GETS LOADED FROM FIREBASE
                        dynamic data;
                        if (snapshot.hasError ||
                            snapshot.connectionState == ConnectionState.none) {
                          data = snapshot.data as Map<String, dynamic>;
                          return Text(
                            data['description']!,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          );
                        }

                        // WHEN DATA IS LOADED FROM FIREBASE SUCCESSFULLY
                        data = snapshot.data;
                        return Text(
                          data['description']!,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
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
          const MyBackButton(),
          isUserAdmin
              ? Positioned(
                  top: 45,
                  right: 5,
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditAboutMe(),
                        ),
                      );
                    },
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
