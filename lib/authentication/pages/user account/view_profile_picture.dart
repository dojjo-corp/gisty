import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../helper_methods.dart/profile.dart';

class ViewProfilePicture extends StatefulWidget {
  final String uid;
  const ViewProfilePicture({super.key, required this.uid});

  @override
  State<ViewProfilePicture> createState() => _ViewProfilePictureState();
}

class _ViewProfilePictureState extends State<ViewProfilePicture> {
  @override
  Widget build(BuildContext context) {
    bool isForCurrentUser =
        widget.uid == FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
        appBar: AppBar(
          // todo: Only Show [Change Picture] Icon When In Current User's Account Page
          actions: isForCurrentUser
              ? [
                  IconButton(
                    onPressed: () async {
                      changePicture(context);
                    },
                    icon: const Icon(Icons.edit_rounded),
                  )
                ]
              : null,
        ),
        body: Center(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.uid)
                  .snapshots()
                  .throttleTime(const Duration(milliseconds: 100)),
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
