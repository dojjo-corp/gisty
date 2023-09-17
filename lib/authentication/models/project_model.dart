class ProjectModel {
  String title, year, studentId, description, category, supervisorId;
  ProjectModel({
    required this.title,
    required this.year,
    required this.studentId,
    required this.description,
    required this.category,
    required this.supervisorId,
  });

  Map<String, dynamic> get projectData => {
        'title': title,
        'year': year,
        'student': studentId,
        'category': category,
        'supervisor-id': supervisorId,
        'description': description,
        'comments': []
      };
}

