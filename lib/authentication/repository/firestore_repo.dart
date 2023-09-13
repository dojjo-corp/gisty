import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRepo {
  FirestoreRepo();
  final store = FirebaseFirestore.instance;

  Future<void> createStudentDoc({
    required String fullName,
    required String userName,
    required String email,
    required String uid,
    String contact = '',
    departmentId = '',
  }) async {
    try {
      await store.collection('users').doc(uid).set({
        'fullname': fullName,
        'username': userName,
        'email': email,
        'contact': contact,
        'departmentId': departmentId,
        'download-id': []
      });
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> createUniversityProfessionalDoc({
    required String fullName,
    required String userName,
    required String email,
    required String uid,
    String contact = '',
    String departmentId = '',
  }) async {
    try {
      await store
          .collection('University Professional')
          .doc(uid)
          .set({
        'fullname': fullName,
        'username': userName,
        'email': email,
        'contact': contact,
        'department-id': departmentId,
        'download-id': []
      });
    } on FirebaseException {
      rethrow;
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> createIndustryProfessionalDoc({
    required String fullName,
    required String userName,
    required String email,
    required String uid,
    String contact = '',
    String organisationId = '',
  }) async {
    try {
      await store.collection('Industry Professional').doc(uid).set({
        'full-name': fullName,
        'user-name': userName,
        'email': email,
        'contact': contact,
        'organisation-id': organisationId,
        'download-id': []
      });
    } on FirebaseException {
      rethrow;
    }
  }
}
