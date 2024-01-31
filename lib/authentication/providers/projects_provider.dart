// ignore_for_file: prefer_final_fields, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProjectProvider extends ChangeNotifier {
  ProjectProvider();

  final store = FirebaseFirestore.instance;

  final iconList = [
    'assets/category_icons/web-mobile-development.png',
    'assets/category_icons/ai.png',
    'assets/category_icons/cyber.png',
    'assets/category_icons/data.png',
    'assets/category_icons/data-science.png',
    'assets/category_icons/desktop.png',
    'assets/category_icons/iot.png',
    'assets/category_icons/robotics.png',
    'assets/category_icons/research.png',
    'assets/category_icons/embedded-systems.png',
    'assets/category_icons/digital-asset-management.png',
    'assets/category_icons/gear.png',
    'assets/category_icons/green-technology.png',
    'assets/category_icons/nanotechnology.png',
    'assets/category_icons/project-management.png',
    'assets/category_icons/responsive.png',
    'assets/category_icons/science.png',
    'assets/category_icons/technological.png',
    'assets/category_icons/technology.png',
    'assets/category_icons/world-wide-web.png',
  ];

  Map categories = {};

  // todo: PROJECT CATEGORIES GETTER AND SETTER
  Map<String, dynamic> categoryMap = {
    'Web & Mobile Development': {
      'color': const Color(0xFF3986C6).value,
      'image': 'assets/category_icons/web-mobile-development.png',
      'x': 0,
    },
    'AI & ML': {
      'color': const Color(0xFFEAAF40).value,
      'image': 'assets/category_icons/ai.png',
      'x': 1,
    },
    'Cyber Security & Network Security': {
      'color': const Color(0xFFBC89C5).value,
      'image': 'assets/category_icons/cyber.png',
      'x': 2
    },
    'Data Science & Analytics': {
      'color': const Color(0xFF068604).value,
      'image': 'assets/category_icons/data.png',
      'x': 3
    },
    'Desktop Development': {
      'color': const Color(0xFF04865F).value,
      'image': 'assets/category_icons/desktop.png',
      'x': 4
    },
    'IoT': {
      'color': const Color(0xFF860441).value,
      'image': 'assets/category_icons/iot.png',
      'x': 5
    },
    'Robotics & Automation': {
      'color': const Color(0xFF864504).value,
      'image': 'assets/category_icons/robotics.png',
      'x': 6
    },
    'Research Works': {
      'color': const Color(0xFF04865F).value,
      'image': 'assets/category_icons/research.png',
      'x': 7
    },
    'Embedded Systems': {
      'color': const Color(0xFFEACE40).value,
      'image': 'assets/category_icons/embedded-systems.png',
      'x': 8
    },
  };

  // todo: UPDATE CATEGORIES LOCALLY
  Future<void> setCategories() async {
    final snapshot = await store.collection('Project Cateogries').get();
    final docs = snapshot.docs;

    if (docs.isNotEmpty) {
      Map<String, dynamic> catMap = {};

      for (var doc in docs) {
        final data = doc.data();
        catMap[doc.id] = data;
      }

      // make available globally (notify provider listeners)
      categoryMap = catMap;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // todo: ALL PROJECTS GETTER AND SETTER
  Map<String, Map<String, dynamic>> _allProjects = {};
  Map<String, Map<String, dynamic>> get allProjects => _allProjects;

  // GET AND STORE ALL PROJECTS IN PROVIDER
  void setAllProjects(Map<String, Map<String, dynamic>> projects) {
    _allProjects = projects;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // todo: GET USER'S SAVED PROJECTS
  List<Map<String, dynamic>?> _savedProjects = [];
  List<Map<String, dynamic>?> get savedProjects => _savedProjects;

  Future<void> setSavedProjects() async {
    // Fetch user information from Firestore
    final DocumentSnapshot<Map<String, dynamic>> userSnapshot = await store
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

  // todo: PROJECT ANALYTICS DATA
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
