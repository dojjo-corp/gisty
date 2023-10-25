import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  UserProvider();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> get allUsers => _allUsers;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  bool get isUserAdmin =>
      getUserDataFromEmail(
          FirebaseAuth.instance.currentUser?.email)?['admin'] ??
      false;

  String get userType {
    String userType = '';
    for (var user in _allUsers) {
      if (user['email'] == FirebaseAuth.instance.currentUser?.email) {
        userType = user['user-type'].toLowerCase();
      }
    }
    return userType;
  }

  Map<String, dynamic>? getUserDataFromEmail(String? email) {
    for (var user in _allUsers) {
      if (user['email'] == email) {
        return user;
      }
    }
    return null;
  }

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
