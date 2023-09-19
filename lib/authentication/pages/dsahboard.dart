import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/models/project_model.dart';

import '../components/project_grid_item.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget noProjectToDisplay() => const Center(
        child: Text('No Project To Display!'),
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
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
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Web'),
                Tab(text: 'Mobile'),
                Tab(text: 'Data'),
                Tab(text: 'Hardware')
              ],
            ),
            Flexible(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('All Projects')
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
                    List<Map<String, dynamic>> webProjects = [];
                    List<Map<String, dynamic>> mobileProjects = [];
                    List<Map<String, dynamic>> dataProjects = [];
                    List<Map<String, dynamic>> hardwareProjects = [];
                    for (var doc in docs) {
                      final category = doc.data()['category'].toLowerCase();
                      final data = doc.data();
                      if (category == 'web') {
                        webProjects.add(data);
                      } else if (category == 'mobile') {
                        mobileProjects.add(data);
                      } else if (category == 'data') {
                        dataProjects.add(data);
                      } else if (category == 'hardware') {
                        hardwareProjects.add(data);
                      }
                    }
                    

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        // WEB CATEGORY OF PROJECTS
                        webProjects.isNotEmpty
                            ? ListView.separated(
                                itemBuilder: (context, index) {
                                  return ProjectGridItem(
                                      projectData: webProjects[index]);
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemCount: webProjects.length)
                            : noProjectToDisplay(),
                        // MOBILE CATEGORY OF PROJECTS
                        mobileProjects.isNotEmpty
                            ? ListView.separated(
                                itemBuilder: (context, index) {
                                  return ProjectGridItem(
                                      projectData: mobileProjects[index]);
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemCount: webProjects.length)
                            : noProjectToDisplay(),
                        // DATA CATEGORY OF PROJECTS
                        dataProjects.isNotEmpty
                            ? ListView.separated(
                                itemBuilder: (context, index) {
                                  return ProjectGridItem(
                                      projectData: dataProjects[index]);
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemCount: webProjects.length)
                            : noProjectToDisplay(),
                        // HARDWARE CATEGORY OF PROJECTS
                        hardwareProjects.isNotEmpty
                            ? ListView.separated(
                                itemBuilder: (context, index) {
                                  return ProjectGridItem(
                                      projectData: hardwareProjects[index]);
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemCount: webProjects.length)
                            : noProjectToDisplay(),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ],
    );
  }
}
