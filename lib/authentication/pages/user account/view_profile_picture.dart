import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../helper_methods.dart/profile.dart';

class ViewProfilePicture extends StatefulWidget {
  final String profilePicture;
  const ViewProfilePicture({super.key, required this.profilePicture});

  @override
  State<ViewProfilePicture> createState() => _ViewProfilePictureState();
}

class _ViewProfilePictureState extends State<ViewProfilePicture> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () async {
                  changePicture(context);
                },
                icon: const Icon(Icons.edit_rounded))
          ],
        ),
        body: Center(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.hasError ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                final String? profilePicture =
                    snapshot.data!.data()!['profile-picture'];

                if (profilePicture == null) {
                  return const CircularProgressIndicator();
                }
                return Image.network(profilePicture);
              }),
        ));
  }
}
