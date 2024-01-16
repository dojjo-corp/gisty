// ignore_for_file: no_leading_underscores_for_local_identifiers

// import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/pages/user%20account/view_profile_picture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../pages/user authentication/login.dart';
import '../repository/firestore_repo.dart';

Future<void> changePicture(
  BuildContext _context, {
  bool? fromCamera,
  ConnectivityResult? connectionResult,
}) async {
  fromCamera ??= false;
  ImageSource source = fromCamera ? ImageSource.camera : ImageSource.gallery;

  try {
    // Throw error if device is not connected to the internet
    if (connectionResult == ConnectivityResult.none) {
      throw 'You are not connected to the internet';
    }
    final XFile? pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage == null) return;

    final File imageFile = File(pickedImage.path);
    final String fileName = basename(pickedImage.path);
    final Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(
        'Profile Pictures/${FirebaseAuth.instance.currentUser!.email}/$fileName');
    final UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'profile-picture': downloadUrl});
  } catch (e) {
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Text('Error Changing Profile Picture: ${e.toString()}'),
      ),
    );
  }
}

// CURRENT USER'S PROFILE PICTURE
Widget showNoProfilePicture(BuildContext _context) => GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: _context,
          builder: (_context) {
            return SizedBox(
              height: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.camera_alt,
                      color: Theme.of(_context).primaryColor,
                    ),
                    title: const Text('Camera'),
                    onTap: () {
                      Navigator.of(_context).pop();
                      changePicture(_context, fromCamera: true);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.photo_album,
                      color: Theme.of(_context).primaryColor,
                    ),
                    title: const Text('Gallery'),
                    onTap: () async {
                      Navigator.of(_context).pop();
                      await changePicture(_context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: CircleAvatar(
        radius: 75,
        backgroundColor: Colors.transparent,
        child: Icon(
          Icons.person,
          size: 150,
          color: Theme.of(_context).primaryColor,
        ),
      ),
    );

Widget showProfilePicture(String downloadUrl, BuildContext _context) =>
    CircleAvatar(
      radius: 75,
      backgroundColor: Colors.transparent,
      foregroundImage: Image.network(
        downloadUrl,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
            const CircularProgressIndicator(),
      ).image,
      onForegroundImageError: (exception, stackTrace) =>
          showNoProfilePicture(_context),
    );

// OTHER USER'S PROFILE PICTURE
Widget showOtherUserProfilePicture(
  String uid,
  String downloadUrl,
  BuildContext _context,
  double radius,
) =>
    GestureDetector(
      onTap: () {
        Navigator.push(
          _context,
          MaterialPageRoute(
            builder: (context) => ViewProfilePicture(uid: uid),
          ),
        );
      },
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        foregroundImage: Image.network(
          downloadUrl,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
              const CircularProgressIndicator(),
        ).image,
        onForegroundImageError: (exception, stackTrace) =>
            showNoOtherUserProfilePicture(_context, radius * 2),
      ),
    );

Widget showNoOtherUserProfilePicture(BuildContext _context, double size) =>
    Icon(Icons.person, color: Theme.of(_context).primaryColor, size: size);

// DELETE ACCOUNT
void deleteAccount({
  required BuildContext context,
  required String uid,
  required String email,
  ConnectivityResult? connectionResult,
}) async {
  try {
    // Throw error if device is not connected to the internet
    if (connectionResult == ConnectivityResult.none) {
      throw 'You are not connected to the internet';
    }
    await FirestoreRepo().deleteUserRecords(uid: uid, email: email);
    await FirebaseAuth.instance.currentUser!.delete();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(isFromWelcomeScreen: false),
          ),
          (route) => false);
    }
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Account Deleted Successfully!'),
    ));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error Deleting Accout: ${e.toString()}'),
    ));
  }
}

// DELETE PROMPT
Future<Widget?> showDeletePromptDialog({
  required BuildContext context,
  required String uid,
  required String email,
}) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deleteAccount(context: context, uid: uid, email: email);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
