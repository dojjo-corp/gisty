class ProjectModel {
  String title,
      year,
      studentName,
      description,
      category,
      supervisorName,
      projectDocumentFileName;
  ProjectModel({
    required this.title,
    required this.year,
    required this.studentName,
    required this.description,
    required this.category,
    required this.supervisorName,
    required this.projectDocumentFileName,
  });

  String get pid {
    final List<String> id = [
      studentName.splitMapJoin(' '),
      supervisorName.splitMapJoin(' '),
      year
    ];
    id.sort();
    return id.join();
  }

  Map<String, dynamic> toMap() {
    return {
      'pid': pid,
      'title': title,
      'year': year,
      'student-name': studentName,
      'category': category,
      'supervisor-name': supervisorName,
      'description': description,
      'project-document': projectDocumentFileName,
      'comments': [],
      'saved':[]
    };
  }
}
