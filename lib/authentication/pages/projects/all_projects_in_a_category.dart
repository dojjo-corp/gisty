import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/project_grid_item.dart';
import '../../components/custom_back_button.dart';

class AllProjectsInACategory extends StatelessWidget {
  final String title;
  const AllProjectsInACategory({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100, right: 15, bottom: 15, left: 15),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('All Projects')
                          .snapshots(),
                      builder: (context, snapshot) {
                        // no data
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Text('No Projects Available Yet'),
                          );
                        }

                        // Error Loading Projects
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                                'Error Loading Projects: ${snapshot.error}'),
                          );
                        }

                        final docs = snapshot.data!.docs;
                        final List<Map<String, dynamic>> projectList = [];
                        for (var doc in docs) {
                          if (doc.data()['category'].toLowerCase() ==
                              title.toLowerCase()) {
                            projectList.add(doc.data());
                          }
                        }

                        return projectList.isNotEmpty
                            ? Column(
                                children: projectList.map((projectData) {
                                  return ProjectGridItem(
                                    projectData: projectData,
                                    showLiked: true,
                                  );
                                }).toList(),
                              )
                            : SizedBox(
                                height: 200,
                                child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text('No Project On '),
                                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold))
                                      ],
                                    )));
                      })
                ],
              )),
            ),
          ),
          const Positioned(
            top: 40,
            left: 5,
            child: MyBackButton(),
          )
        ],
      ),
    );
  }
}
