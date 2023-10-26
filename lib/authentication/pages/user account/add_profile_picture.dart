// ignore_for_file: prefer_const_constructors, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../global/homepage.dart';
import '../../components/buttons/buttons.dart';
import '../../components/buttons/custom_back_button.dart';
import '../../components/page_title.dart';
import '../../helper_methods.dart/global.dart';
import '../../helper_methods.dart/profile.dart';

class AddProfileImagePage extends StatefulWidget {
  final bool isFromRegistration;
  const AddProfileImagePage({super.key, required this.isFromRegistration});

  @override
  State<AddProfileImagePage> createState() => _AddProfileImagePageState();
}

class _AddProfileImagePageState extends State<AddProfileImagePage> {
  final store = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100, left: 15, right: 15, bottom: 10),
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    PageTitle(title: 'Add Profile Picture'),

                    // USER PROFILE PICTURE
                    StreamBuilder(
                      stream: getThrottledStream(
                        collectionPath: 'users',
                        docPath: auth.currentUser!.uid,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Column(
                            children: const [
                              CircularProgressIndicator(),
                              Text('Loading...')
                            ],
                          );
                        }

                        if (snapshot.hasError) {
                          return Text(
                              'Error Loading Profile Picture: ${snapshot.error}');
                        }

                        final docData = snapshot.data!.data()!;
                        final String? profilePicture =
                            docData['profile-picture'];

                        return profilePicture != null
                            ? showProfilePicture(profilePicture, context)
                            : showNoProfilePicture(context);
                      },
                    ),

                    const SizedBox(height: 20),
                    MyButton(
                      btnText: 'Change Picture',
                      onPressed: () async {
                        await changePicture(context);
                      },
                      isPrimary: false,
                    ),
                    const SizedBox(height: 5),
                    MyButton(
                      btnText: 'Done',
                      onPressed: () {
                        widget.isFromRegistration
                            ?
                            // navigate to home page next if user comes to this page during registration
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MyHomePage(pageIndex: 0),
                                ),
                              )
                            // go to previous page otherwise (the only other time user gets to this page is from the account info page)
                            : Navigator.pop(context);
                      },
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
      floatingActionButton: _isLoading ? const LinearProgressIndicator() : null,
    );
  }
}
