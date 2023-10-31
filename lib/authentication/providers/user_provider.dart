import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  UserProvider();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> get allUsers => _allUsers;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  /// Whether the current user is an Admin
  bool get isUserAdmin =>
      getUserDataFromEmail(
          FirebaseAuth.instance.currentUser?.email)?['admin'] ??
      false;

  /// The current user's [user-type]
  String get userType {
    String userType = '';
    for (var user in _allUsers) {
      if (user['email'] == FirebaseAuth.instance.currentUser?.email) {
        userType = user['user-type'].toLowerCase();
      }
    }
    return userType;
  }

  /// Returns the user info of the user with the given [email]
  Map<String, dynamic>? getUserDataFromEmail(String? email) {
    for (var user in _allUsers) {
      if (user['email'].toLowerCase() == email!.toLowerCase()) {
        return user;
      }
    }
    return null;
  }

  /// Retrieve and update the local store of users info
  Future<void> setAllUsers() async {
    // Fetch user information from Firestore
    final QuerySnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    // Parse the data and store it in the provider
    final finalList = <Map<String, dynamic>>[];

    for (var doc in userSnapshot.docs) {
      finalList.add(doc.data() as Map<String, dynamic>);
    }

    _allUsers = finalList;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

}
