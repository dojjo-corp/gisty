// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../pages/user authentication/login.dart';
import '../repository/firestore_repo.dart';

Future<void> changePicture(BuildContext _context) async {
  try {
    final XFile? pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    log('here');
    if (pickedImage == null) return;
    log('here too');
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
    log(e.toString());

    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Text('Error Changing Profile Picture: ${e.toString()}'),
      ),
    );
  }
}

Future<void> deleteFolder(BuildContext _context) async {
  try {
    await FirebaseStorage.instance.ref().child('temp').delete();
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
              height: 130,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Camera'),
                    onTap: () {
                      Navigator.of(_context).pop();
                      changePicture(_context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_album),
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
      foregroundImage: Image.network(downloadUrl).image,
      onForegroundImageError: (exception, stackTrace) =>
          showNoProfilePicture(_context),
    );

// OTHER USER'S PROFILE PICTURE
Widget showOtherUserProfilePicture(String downloadUrl, BuildContext _context, double radius) =>
    CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      foregroundImage: Image.network(downloadUrl).image,
      onForegroundImageError: (exception, stackTrace) =>
          showNoOtherUserProfilePicture(_context, radius*2),
    );

Widget showNoOtherUserProfilePicture(BuildContext _context, double size) =>
    Icon(Icons.person, color: Theme.of(_context).primaryColor, size: size);


// DELETE ACCOUNT
void deleteAccount(BuildContext _context) async {
  try {
    await FirestoreRepo().deleteUserRecords();
    await FirebaseAuth.instance.currentUser!.delete();

    if (_context.mounted) {
      Navigator.pushAndRemoveUntil(
          _context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
          (route) => false);
    }
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(_context).showSnackBar(const SnackBar(
      content: Text('Account Deleted Successfully!'),
    ));
  } catch (e) {
    ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
      content: Text('Error Deleting Accout: ${e.toString()}'),
    ));
  }
}

Future<Widget?> showDeletePromptDialog(BuildContext _context) async {
  return await showDialog(
    context: _context,
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
              deleteAccount(context);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
