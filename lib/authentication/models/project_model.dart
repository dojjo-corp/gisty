import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  String title,
      year,
      studentName,
      description,
      category,
      supervisorName,
      supervisorEmail,
      projectDocumentFileName;
  ProjectModel({
    required this.title,
    required this.year,
    required this.studentName,
    required this.description,
    required this.category,
    required this.supervisorName,
    required this.supervisorEmail,
    required this.projectDocumentFileName,
  });

  String get pid =>
      FirebaseFirestore.instance.collection('All Projects').doc().id;

  Map<String, dynamic> toMap() {
    return {
      'pid': pid,
      'title': title,
      'year': year,
      'student-name': studentName,
      'category': category,
      'supervisor-name': supervisorName,
      'supervisor-email': supervisorEmail,
      'description': description,
      'project-document': projectDocumentFileName,
      'comments': [],
      'saved': [],
      'downloaded-by': [],
      'impressions': {
        'like': [],
        'support': [],
        'celebrate': [],
        'insightful': [],
      },
      'time-added': Timestamp.now()
    };
  }
}
