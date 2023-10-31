import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreRepo {
  FirestoreRepo();
  final store = FirebaseFirestore.instance;

  Future<void> createStudentDoc({
    required String fullName,
    required String userName,
    required String email,
    required String uid,
    required String startYear,
    required String endYear,
    String contact = '',
    departmentId = '',
  }) async {
    try {
      await store.collection('users').doc(uid).set({
        'uid': uid,
        'fullname': fullName,
        'username': userName,
        'email': email,
        'contact': contact,
        'user-type': 'student',
        'departmentId': departmentId,
        'start-year': startYear,
        'end-year': endYear,
        'download-id': [],
        'saved-projects': [],
        'online': true,
        'admin': false,
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
    final userData = {
      'uid': uid,
      'fullname': fullName,
      'username': userName,
      'email': email,
      'user-type': 'University Professional',
      'contact': contact,
      'department-id': departmentId,
      'download-id': [],
      'saved-projects': [],
      'online': true,
      'admin': false,
    };
    final collectionRef = store.collection('users');

    try {
      await collectionRef.doc(uid).set(userData);
      // ADMIN
      if (email == 'andrew@gmail.com') {
        userData['admin'] = true;
        // add admin email to admin-emails document
        await collectionRef.doc('admin-emails').set({
          'emails': FieldValue.arrayUnion([email])
        }, SetOptions(merge: true));
      }
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
        'uid': uid,
        'fullname': fullName,
        'username': userName,
        'email': email,
        'user-type': 'Industry Professional',
        'contact': contact,
        'organisation-id': organisationId,
        'download-id': [],
        'saved-projects': [],
        'online': true,
        'admin': false,
      });
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> deleteUserRecords(
      {required String uid, required String email}) async {
    try {
      // delete user's firebase document
      await store.collection('users').doc(uid).delete();

      // delete user's profile picture
      await FirebaseStorage.instance
          .ref()
          .child('Profile Pictures/$email')
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
  Future<void> addJobsOrIntershipEvents(Map<String, dynamic> jobDetails) async {
    try {
      await store
          .collection('All Jobs')
          .doc(jobDetails['id'])
          .set(jobDetails, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addEvents(Map<String, dynamic> eventDetails) async {
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
      'read': false,
    };
    try {
      await store.collection('Chat Rooms').doc(roomId).update({
        'messages': FieldValue.arrayUnion([messageData]),
        'last-text': messageData
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendNotificationToFirestore({
    required String to,
    required String type,
    required String title,
    required String body,
    String? routeName,
    Map<String, dynamic>? routeArgs,
  }) async {
    final String from = FirebaseAuth.instance.currentUser!.email!;
    final notificationData = {
      'title': title,
      'body': body,
      'from': from,
      'type': type,
      'read': false,
      'time-sent': Timestamp.now(),
      'route-name': routeName,
      'route-arguments': routeArgs,
    };
    try {
      await store.collection('Notifications').doc(to).set(
        {
          'my-notifications': FieldValue.arrayUnion([notificationData])
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      rethrow;
    }
  }

  // todo: Send Feedback To Admins
  Future<void> sendFeedback(
      {required String subject, required String description}) async {
    if (subject.isEmpty) throw 'Subject Can\'t Be Empty!';
    if (description.isEmpty) throw 'Description Can\'t Be Empty!';

    final docId =
        '${FirebaseAuth.instance.currentUser?.email}-${Timestamp.now()}';
    final feedbackData = {
      'subject': subject,
      'description': description,
      'time': Timestamp.now(),
    };
    try {
      await store.collection('All Feedbacks').doc(docId).set(
            feedbackData,
            SetOptions(merge: true),
          );
    } catch (e) {
      rethrow;
    }
  }
}
