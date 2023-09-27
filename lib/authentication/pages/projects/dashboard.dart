// ignore_for_file: unused_local_variable, avoid_unnecessary_containers

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
    final projectCategories = context
        .watch<ProjectProvider>()
        .categoryMap
        .keys
        .toList()
        .take(3)
        .toList();
    final categoryMap = context.watch<ProjectProvider>().categoryMap;

    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Hi, ',
                        style: GoogleFonts.montserrat(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2
                        ),
                      ),
                      Text(
                        FirebaseAuth.instance.currentUser!.displayName!,
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold, fontSize: 30,letterSpacing: 2),
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
                      for (var doc in docs) {
                        final category = doc.data()['category'].toLowerCase();
                        final data = doc.data();
                        allProjects[doc.id] = doc.data();
                      }
                      // load and store all projects in provider
                      projectProvider.setAllProjects(allProjects);

                      return Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check The Latest Project!',
                              style: GoogleFonts.urbanist(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5, color: Colors.black54),
                            ),
                            const SizedBox(height: 15),
                            ProjectGridItem(
                                projectData: latestProject.data(),
                                showLiked: true),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Project Categories',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: projectCategories
                              .map(
                                (category) => SizedBox(
                                  width: 200,
                                  child: DashboardCard(
                                    name: category,
                                    number: 0,
                                    bottomMargin: 0,
                                    imagePath: categoryMap[category]['image'],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        Container(
                          child: Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/archive');
                              },
                              child: Text(
                                'See more',
                                style: GoogleFonts.openSans(
                                    letterSpacing: 2, color: Colors.black87),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  // const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
