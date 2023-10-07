// ignore_for_file: prefer_final_fields, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProjectProvider extends ChangeNotifier {
  ProjectProvider();

  final Map<String, dynamic> categoryMap = {
    'Web & Mobile Development': {
      'color': const Color.fromARGB(255, 57, 134, 198),
      'image': 'assets/web-mobile-development.png'
    },
    'AI & ML': {
      'color': const Color.fromARGB(255, 234, 206, 64),
      'image': 'assets/ai.png'
    },
    'Cyber Security & Network Security': {
      'color': const Color.fromARGB(255, 188, 137, 197),
      'image': 'assets/cyber.png'
    },
    'Data Science & Analytics': {
      'color': const Color.fromARGB(255, 6, 134, 4),
      'image': 'assets/data.png'
    },
    'Desktop Development': {
      'color': const Color.fromARGB(255, 4, 134, 95),
      'image': 'assets/desktop.png'
    },
    'IoT': {
      'color': const Color.fromARGB(255, 134, 4, 65),
      'image': 'assets/iot.png'
    },
    'Robotics & Automation': {
      'color': const Color.fromARGB(255, 134, 69, 4),
      'image': 'assets/robotics.png'
    },
    'Research Works': {
      'color': const Color.fromARGB(255, 4, 134, 95),
      'image': 'assets/research.png'
    },
    'Embedded Systems': {
      'color': const Color.fromARGB(255, 234, 206, 64),
      'image': 'assets/embedded-systems.png'
    },
  };

  Map<String, Map<String, dynamic>> _allProjects = {};
  Map<String, Map<String, dynamic>> get allProjects => _allProjects;

  // GET AND STORE ALL PROJECTS IN PROVIDER
  void setAllProjects(Map<String, Map<String, dynamic>> projects) {
    _allProjects = projects;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  List<Map<String, dynamic>?> _savedProjects = [];
  List<Map<String, dynamic>?> get savedProjects => _savedProjects;

  // GET USER'S SAVED PROJECTS
  Future<void> setSavedProjects() async {
    // Fetch user information from Firestore
    final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    final List<Map<String, dynamic>?> finalList = [];
    // retrieve list of saved projects (list of project ids)
    final savedProjectIds = userSnapshot.data()!['saved-projects'] as List;
    for (var pid in _allProjects.keys) {
      if (savedProjectIds.contains(pid)) {
        finalList.add(_allProjects[pid]);
      }
    }

    _savedProjects = finalList;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Map<String, double> getProjectAnalyticsData(String pid) {
    final Map<String, double> _projectAnalyticsData = {};
    final Map<String, dynamic>? _projectData = _allProjects[pid];
    final impressions = _projectData?['impressions'];
    
    // saves and downloads
    _projectAnalyticsData['saved'] = _projectData?['saved'].length;
    _projectAnalyticsData['downloads'] = _projectData?['downloaded-by'].length;

    // impressions
    _projectAnalyticsData['likes'] = impressions['like'].length;
    _projectAnalyticsData['celebrate'] = impressions['celebrate'].length;
    _projectAnalyticsData['insightful'] = impressions['insightful'].length;
    _projectAnalyticsData['support'] = impressions['support'].length;

    return _projectAnalyticsData;
  }
}
