import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView(
                    children: const [
                      ProjectGridItem(
                        category: 'web',
                        title: 'FINAL PROJECT',
                        year: '2023',
                        student: 'Martinson Tetteh',
                        description:
                            'Mollit excepteur incididunt id tempor laborum dolore id.',
                      ),
                      SizedBox(height: 15),
                      ProjectGridItem(
                        category: 'web',
                        title: 'FINAL PROJECT',
                        year: '2023',
                        student: 'Martinson Tetteh',
                        description: 'Et sit esse eu adipisicing est.',
                      ),
                      SizedBox(height: 15),
                      ProjectGridItem(
                        category: 'web',
                        title: 'FINAL PROJECT',
                        year: '2023',
                        student: 'Martinson Tetteh',
                        description:
                            'Anim dolor consectetur consectetur culpa culpa Lorem exercitation.',
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                  // MOBILE CATEGORY OF PROJECTS
                  ListView(
                    children: const [
                      ProjectGridItem(
                        category: 'mobile',
                        title: 'FINAL PROJECT',
                        year: '2023',
                        student: 'Martinson Tetteh',
                        description:
                            'Ipsum pariatur fugiat occaecat cupidatat mollit esse et laboris consequat.',
                      ),
                      SizedBox(height: 15),
                      ProjectGridItem(
                        category: 'mobile',
                        title: 'FINAL PROJECT',
                        year: '2023',
                        student: 'Martinson Tetteh',
                        description:
                            'Exercitation nulla fugiat velit enim nisi ut aute dolore non reprehenderit in aliquip aliquip.',
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                  ListView(
                    children: const [
                      ProjectGridItem(
                        category: 'data',
                        title: 'FINAL PROJECT',
                        year: '2023',
                        student: 'Martinson Tetteh',
                        description:
                            'Tempor laborum aute culpa excepteur officia anim.',
                      ),
                    ],
                  ),
                  ListView(
                    children: const [
                      ProjectGridItem(
                        category: 'hardware',
                        title: 'FINAL PROJECT',
                        year: '2023',
                        student: 'Martinson Tetteh',
                        description:
                            'Tempor laborum aute culpa excepteur officia anim.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
