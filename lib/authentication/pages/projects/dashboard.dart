import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/dashboard_card.dart';
import 'package:gt_daily/authentication/providers/projects_provider.dart';
import 'package:provider/provider.dart';

import '../../components/project_grid_item.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Widget noProjectToDisplay() => const Center(
        child: Text('No Project To Display!'),
      );

  @override
  Widget build(BuildContext context) {
    final projectProvider =
        Provider.of<ProjectProvider>(context, listen: false);
    final projectCategories =
        context.watch<ProjectProvider>().categoryMap.keys.toList();

    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Hello, ',
                      style: GoogleFonts.poppins(fontSize: 25),
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser!.displayName!,
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('All Projects')
                      .orderBy('time-added', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text('No Projects Yet'),
                      );
                    }

                    // on error
                    if (snapshot.hasError) {
                      return Center(
                        child:
                            Text('Error loading Projects: ${snapshot.error}'),
                      );
                    }

                    final docs = snapshot.data!.docs;
                    final latestProject = docs[0];
                    Map<String, Map<String, dynamic>> allProjects = {};
                    List<Map<String, dynamic>> webProjects = [];
                    List<Map<String, dynamic>> mobileProjects = [];
                    List<Map<String, dynamic>> dataProjects = [];
                    List<Map<String, dynamic>> hardwareProjects = [];
                    for (var doc in docs) {
                      final category = doc.data()['category'].toLowerCase();
                      final data = doc.data();
                      allProjects[doc.id] = doc.data();
                      if (category == 'web') {
                        if (webProjects.isNotEmpty) {
                          continue;
                        }
                        webProjects.add(data);
                      } else if (category == 'mobile') {
                        if (webProjects.isNotEmpty) {
                          continue;
                        }
                        mobileProjects.add(data);
                      } else if (category == 'data') {
                        if (webProjects.isNotEmpty) {
                          continue;
                        }
                        dataProjects.add(data);
                      } else if (category == 'hardware') {
                        if (webProjects.isNotEmpty) {
                          continue;
                        }
                        hardwareProjects.add(data);
                      }
                    }
                    // load and store all projects in provider
                    projectProvider.setAllProjects(allProjects);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Check The Latest Project!'),
                        ProjectGridItem(
                            projectData: latestProject.data(), showLiked: true),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                const Text('Project Categories'),
                Column(
                  children: projectCategories
                      .map((category) => DashboardCard(
                            name: category,
                            number: 0,
                            iconData: Icons.handshake_rounded,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
