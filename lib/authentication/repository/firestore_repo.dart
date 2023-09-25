import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        'user-type': 'student',
        'departmentId': departmentId,
        'download-id': [],
        'saved-projects': [],
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
      await store.collection('users').doc(uid).set({
        'fullname': fullName,
        'username': userName,
        'email': email,
        'user-type': 'University Professional',
        'contact': contact,
        'department-id': departmentId,
        'download-id': [],
        'saved-projects': [],
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
      await store.collection('users').doc(uid).set({
        'fullname': fullName,
        'username': userName,
        'email': email,
        'user-type': 'Industry Professional',
        'contact': contact,
        'organisation-id': organisationId,
        'download-id': [],
        'saved-projects': [],
      });
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> deleteUserRecords() async {
    try {
      await store
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadAllProjects() async {
    try {
      final projects = await store.collection('All Projects').get();
      final projectsDocs = projects.docs;
      final projectsMap = {};
      projectsDocs.map((doc) {
        projectsMap[doc.id] = doc.data();
      });
    } catch (e) {
      rethrow;
    }
  }

  // ADMIN ONLY METHODS
  Future<void> addProjectToDatabase(
      {required Map<String, dynamic> projectData}) async {
    try {
      await store
          .collection('All Projects')
          .doc(projectData['pid'])
          .set(projectData, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  // Add Events (ie. Jobs/Internships) For Both University and Industry Professionals
  Future<void> addJobsOrIntershipEvents(
      Map<String, dynamic> eventDetails) async {
    try {
      await store
          .collection('All Events')
          .doc(eventDetails['id'])
          .set(eventDetails);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addCommentToProject(String comment, String projectId) async {
    try {
      await store.doc(projectId).set({
        'comments': FieldValue.arrayUnion([comment])
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveProject(String projectId) async {
    try {
      await store.doc(FirebaseAuth.instance.currentUser!.uid).set({
        'saved-projects': FieldValue.arrayUnion([projectId])
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> downloadProject(String projectId) async {
    try {
      // download from firebase cloud store
    } catch (e) {
      rethrow;
    }
  }

  // MESSAGING METHODS
  // create chat room
  Future<String> createChatRoom(receiverEmail) async {
    String roomId = '';
    final ids = [FirebaseAuth.instance.currentUser!.email, receiverEmail];
    ids.sort();
    roomId = ids.join();
    try {
      await store.collection('Chat Rooms').doc(roomId).set({
        'room-id': roomId,
        'messages': FieldValue.arrayUnion([]),
        'users': [receiverEmail, FirebaseAuth.instance.currentUser!.email]
      }, SetOptions(merge: true));
      return roomId;
    } catch (e) {
      rethrow;
    }
  }

  // send messages
  Future<void> sendMessage(String messageText, String roomId) async {
    final messageData = {
      'text': messageText,
      'sender': FirebaseAuth.instance.currentUser!.email,
      'time': Timestamp.now(),
    };
    try {
      await store.collection('Chat Rooms').doc(roomId).update({
        'messages': FieldValue.arrayUnion([messageData])
      });
    } catch (e) {
      rethrow;
    }
  }
}
