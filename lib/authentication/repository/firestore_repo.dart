import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreRepo {
  FirestoreRepo();
  final currentUser = FirebaseAuth.instance.currentUser!;
  final store = FirebaseFirestore.instance;

  Future<void> createUserDoc(fName, lName, email) async {
    await store.collection('users').doc(currentUser.uid).set({
      'fName': fName,
      'lName': lName,
      'email': email,
    });
  }
}
