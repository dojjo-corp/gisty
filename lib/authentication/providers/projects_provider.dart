// ignore_for_file: prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProjectProvider extends ChangeNotifier {
  ProjectProvider();

  final Map<String, dynamic> categoryMap = {
    
    'Web & Mobile Development': {
      'color': const Color.fromARGB(255, 57, 134, 198),
      'image': ''
    },
    'AI & ML': {
      'color': const Color.fromARGB(255, 234, 206, 64),
      'image': ''
    },
    'Cyber Security & Network Security': {
      'color': const Color.fromARGB(255, 188, 137, 197),
      'image': ''
    },
    'Data Science & Analytics': {
      'color': const Color.fromARGB(255, 6, 134, 4),
      'image': ''
    },
    'Desktop Development': {
      'color': const Color.fromARGB(255, 4, 134, 95),
      'image': ''
    },
    'IoT': {
      'color': const Color.fromARGB(255, 134, 4, 65),
      'image': ''
    },
    'Robotics & Automation': {
      'color': const Color.fromARGB(255, 134, 69, 4),
      'image': ''
    },
    'Research Works': {
      'color': const Color.fromARGB(255, 4, 134, 95),
      'image': ''
    },
    'Embedded Systems': {
      'color': const Color.fromARGB(255, 234, 206, 64),
      'image': ''
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

  // GET VARIOUS CATEGORIES OF PROJECTS
  // WEB
  Map<String, Map<String, dynamic>> _webProjects = {};
  Map<String, Map<String, dynamic>> get webProjects {
    // iterate through allProjects and get projects with 'web' as their category
    for (var i = 0; i < _allProjects.keys.length; i++) {
      final data = _allProjects.values.toList()[i];
      final id = data['pid'];
      if (data['category'] == 'web') {
        _webProjects[id] = data;
      }
    }

    return _webProjects;
  }

  // MOBILE
  Map<String, Map<String, dynamic>> _mobileProjects = {};
  Map<String, Map<String, dynamic>> get mobileProjects {
    // iterate through allProjects and get projects with 'web' as their category
    for (var i = 0; i < _allProjects.keys.length; i++) {
      final data = _allProjects.values.toList()[i];
      final id = data['pid'];
      if (data['category'] == 'mobile') {
        _mobileProjects[id] = data;
      }
    }
    return _mobileProjects;
  }

  // DATA
  Map<String, Map<String, dynamic>> _dataProjects = {};
  Map<String, Map<String, dynamic>> get dataProjects {
    // iterate through allProjects and get projects with 'web' as their category
    for (var i = 0; i < _allProjects.keys.length; i++) {
      final data = _allProjects.values.toList()[i];
      final id = data['pid'];
      if (data['category'] == 'data') {
        _dataProjects[id] = data;
      }
    }
    return _dataProjects;
  }

  // AI
  Map<String, Map<String, dynamic>> _aiProjects = {};
  Map<String, Map<String, dynamic>> get aiProjects {
    // iterate through allProjects and get projects with 'web' as their category
    for (var i = 0; i < _allProjects.keys.length; i++) {
      final data = _allProjects.values.toList()[i];
      final id = data['pid'];
      if (data['category'] == 'ai') {
        _aiProjects[id] = data;
      }
    }
    return _aiProjects;
  }

  // BUSINESS
  Map<String, Map<String, dynamic>> _businessProjects = {};
  Map<String, Map<String, dynamic>> get businessProjects {
    // iterate through allProjects and get projects with 'web' as their category
    for (var i = 0; i < _allProjects.keys.length; i++) {
      final data = _allProjects.values.toList()[i];
      final id = data['pid'];
      if (data['category'] == 'business') {
        _businessProjects[id] = data;
      }
    }
    return _businessProjects;
  }

  // ENGINEERING
  Map<String, Map<String, dynamic>> _engineeringProjects = {};
  Map<String, Map<String, dynamic>> get engineeringProjects {
    // iterate through allProjects and get projects with 'web' as their category
    for (var i = 0; i < _allProjects.keys.length; i++) {
      final data = _allProjects.values.toList()[i];
      final id = data['pid'];
      if (data['category'] == 'engineering') {
        _engineeringProjects[id] = data;
      }
    }
    return _engineeringProjects;
  }

  // RESEARCH
  Map<String, Map<String, dynamic>> _researchProjects = {};
  Map<String, Map<String, dynamic>> get researchProjects {
    // iterate through allProjects and get projects with 'web' as their category
    for (var i = 0; i < _allProjects.keys.length; i++) {
      final data = _allProjects.values.toList()[i];
      final id = data['pid'];
      if (data['category'] == 'research') {
        _researchProjects[id] = data;
      }
    }
    return _researchProjects;
  }

  // MANAGEMENT SYSTEM
  Map<String, Map<String, dynamic>> _managementSystemProjects = {};
  Map<String, Map<String, dynamic>> get managementSystemProjects {
    // iterate through allProjects and get projects with 'web' as their category
    for (var i = 0; i < _allProjects.keys.length; i++) {
      final data = _allProjects.values.toList()[i];
      final id = data['pid'];
      if (data['category'] == 'management system') {
        _managementSystemProjects[id] = data;
      }
    }
    return _managementSystemProjects;
  }
}
