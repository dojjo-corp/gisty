import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/pages/projects/project_details.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../components/buttons/custom_back_button.dart';
import '../../providers/projects_provider.dart';

class SupervisedProjects extends StatelessWidget {
  const SupervisedProjects({super.key});

  @override
  Widget build(BuildContext context) {
    final allProjects = Provider.of<ProjectProvider>(context).allProjects;

    // get supervised projects for this university professional
    List<Map<String, dynamic>> supervisedProjects = [];
    for (var project in allProjects.values.toList()) {
      if (project['supervisor-email'] ==
          FirebaseAuth.instance.currentUser!.email) {
        supervisedProjects.add(project);
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 90, bottom: 10, right: 20, left: 20),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Projects You Supervised',
                      style: GoogleFonts.poppins(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    supervisedProjects.isNotEmpty?
                    Column(
                      children: supervisedProjects
                          .map((e) => GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProjectDetails(
                                        projectData: e,
                                        goToComment: false,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    ListTile(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      tileColor: Colors.white70,
                                      title: Text(
                                        e['title'],
                                        style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(e['student-name']),
                                      trailing: Text(e['year']),
                                    ),
                                    const SizedBox(height: 10)
                                  ],
                                ),
                              ),)
                          .toList(),
                    ):const Text('You Have Not Supervised Any Project Yet')
                  ],
                ),
              ),
            ),
          ),
          const MyBackButton()
        ],
      ),
    );
  }
}
