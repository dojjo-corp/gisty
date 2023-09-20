import 'package:flutter/material.dart';

class ProjectProvider extends ChangeNotifier {
  ProjectProvider();

  Map<String, Map<String, dynamic>> _allProjects = {};

  // ignore: no_leading_underscores_for_local_identifiers
  void setAllProjects(Map<String, Map<String, dynamic>> projects) {
    _allProjects = projects;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Perform your operation here
      notifyListeners();
    });
  }

  Map<String, Map<String, dynamic>> get allProjects => _allProjects;
}
