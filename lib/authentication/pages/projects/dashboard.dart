// ignore_for_file: unused_local_variable, avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/buttons/buttons.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:gt_daily/authentication/providers/connectivity_provider.dart';
import 'package:provider/provider.dart';

import '../../components/project_grid_item.dart';
import '../../providers/projects_provider.dart';
import '../../providers/user_provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _hasRefreshed = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _updatedLatest = [];

  @override
  Widget build(BuildContext context) {
    final projectProvider =
        Provider.of<ProjectProvider>(context, listen: false);
    final projectCategories = projectProvider.categoryMap.keys.toList();
    final categoryMap = projectProvider.categoryMap;

    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: RefreshIndicator(
            onRefresh: updateDashboard,
            child: SingleChildScrollView(
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
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            FirebaseAuth.instance.currentUser?.displayName ??
                                '',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // todo: PROJECT LIST
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('All Projects')
                            .orderBy('time-added', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            // use snapshot docs from last refresh action,
                            // iff dashboard has been refreshed at least once
                            if (_updatedLatest.isNotEmpty) {
                              return Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _updatedLatest
                                      .map(
                                        (project) => ProjectGridItem(
                                          projectData: project.data(),
                                          showLiked: true,
                                        ),
                                      )
                                      .toList(),
                                ),
                              );
                            }

                            // show if dashboard has not been refreshed
                            return const Center(
                              child: Text('No Projects Yet'),
                            );
                          }

                          // on error
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                  'Error loading Projects: ${snapshot.error}'),
                            );
                          }

                          final docs = snapshot.data!.docs;

                          // either docs from
                          final latestProjects = _hasRefreshed
                              ? _updatedLatest
                              : docs.take(10).toList();
                          Map<String, Map<String, dynamic>> allProjects = {};
                          for (var doc in docs) {
                            final category =
                                doc.data()['category'].toLowerCase();
                            final data = doc.data();
                            allProjects[doc.id] = doc.data();
                          }

                          // load and store all projects in provider
                          projectProvider.setAllProjects(allProjects);

                          return Center(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: latestProjects
                                    .map(
                                      (project) => ProjectGridItem(
                                        projectData: project.data(),
                                        showLiked: true,
                                      ),
                                    )
                                    .toList()),
                          );
                        },
                      ),
                      // todo: PROJECT LIST END

                      const SizedBox(height: 20),

                      // todo: PROJECT CATEGORIES BUTTON
                      MyButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/archive');
                        },
                        btnText: 'See More',
                        isPrimary: false,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // todo: ADD NEW PROJECT BUTTON
        context.watch<UserProvider>().userType.toLowerCase() ==
                'university professional'
            ? Positioned(
                bottom: 10,
                right: 10,
                child: Tooltip(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blueGrey[100],
                  ),
                  message: 'Add A New Project',
                  textStyle: TextStyle(color: Colors.grey[700]),
                  triggerMode: TooltipTriggerMode.longPress,
                  child: FloatingActionButton(
                    backgroundColor: const Color.fromARGB(255, 75, 125, 200),
                    onPressed: () {
                      Navigator.pushNamed(context, '/add-project');
                    },
                    child: const Icon(Icons.add, weight: 20),
                  ),
                ),
              )
            : Container()
      ],
    );
  }

  // todo: refresh method
  Future<void> updateDashboard() async {
    final ConnectivityResult connectionState =
        Provider.of<ConnectivityProvider>(context, listen: false)
            .connectivityResult;
    try {
      // get update snapshot from firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('All Projects')
          .orderBy('time-added', descending: true)
          .get();

      // refresh only possible if device is connected to internet
      if (snapshot.docs.isNotEmpty ||
          connectionState != ConnectivityResult.none) {
        final docs = snapshot.docs;

        setState(() {
          _hasRefreshed = true;
          _updatedLatest = docs.take(10).toList();
        });
      } else {
        setState(() {
          _hasRefreshed = false;
        });
        throw 'Couldn\'t refresh dashboard. Check your internet';
      }
    } catch (e) {
      // show error in snackbar
      showSnackBar(context, e.toString());
    }
  }
}
