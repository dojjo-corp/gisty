// ignore_for_file: prefer_final_fields, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProjectProvider extends ChangeNotifier {
  ProjectProvider();
  final iconList = [
    'web-mobile-development.png',
    'ai.png',
    'cyber.png',
    'data.png',
    'data-science.png',
    'desktop.png',
    'iot.png',
    'robotics.png',
    'research.png',
    'embedded-systems.png',
    'digital-asset-management.png',
    'gear.png',
    'green-technology.png',
    'nanotechnology.png',
    'project-management.png',
    'responsive.png',
    'science.png',
    'technological.png',
    'technology.png',
    'world-wide-web.png',
  ];

  Map categories = {};
  Map<String, dynamic> categoryMap = {
    'Web & Mobile Development': {
      'color': const Color(0xFF3986C6),
      'image': 'assets/category_icons/web-mobile-development.png',
      'x': 0,
    },
    'AI & ML': {
      'color': const Color(0xFFEAAF40),
      'image': 'assets/category_icons/ai.png',
      'x': 1,
    },
    'Cyber Security & Network Security': {
      'color': const Color(0xFFBC89C5),
      'image': 'assets/category_icons/cyber.png',
      'x': 2
    },
    'Data Science & Analytics': {
      'color': const Color(0xFF068604),
      'image': 'assets/category_icons/data.png',
      'x': 3
    },
    'Desktop Development': {
      'color': const Color(0xFF04865F),
      'image': 'assets/category_icons/desktop.png',
      'x': 4
    },
    'IoT': {
      'color': const Color(0xFF860441),
      'image': 'assets/category_icons/iot.png',
      'x': 5
    },
    'Robotics & Automation': {
      'color': const Color(0xFF864504),
      'image': 'assets/category_icons/robotics.png',
      'x': 6
    },
    'Research Works': {
      'color': const Color(0xFF04865F),
      'image': 'assets/category_icons/research.png',
      'x': 7
    },
    'Embedded Systems': {
      'color': const Color(0xFFEACE40),
      'image': 'assets/category_icons/embedded-systems.png',
      'x': 8
    },
  };

  void setCategories(Map<String, dynamic> catMap) {
    categoryMap = catMap;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

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
