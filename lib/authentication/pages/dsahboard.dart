import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/greetings.dart';

import '../components/project_grid_item.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Flexible(
            child: ListView(
              children:  [
                const Greetings(),
                const SizedBox(height: 20),

                // WEB CATEGORY OF PROJECTS
                Text(
                  'Web',
                  style: GoogleFonts.poppins(color: Colors.black87),
                ),
                const ProjectGridItem(
                  category: 'web',
                  title: 'FINAL PROJECT',
                  year: '2023',
                  student: 'Martinson Tetteh',
                  description:
                      'Mollit excepteur incididunt id tempor laborum dolore id.',
                ),
                const SizedBox(height: 15),
                const ProjectGridItem(
                  category: 'web',
                  title: 'FINAL PROJECT',
                  year: '2023',
                  student: 'Martinson Tetteh',
                  description: 'Et sit esse eu adipisicing est.',
                ),
                const SizedBox(height: 15),
                const ProjectGridItem(
                  category: 'web',
                  title: 'FINAL PROJECT',
                  year: '2023',
                  student: 'Martinson Tetteh',
                  description:
                      'Anim dolor consectetur consectetur culpa culpa Lorem exercitation.',
                ),
                const SizedBox(height: 15),

                // MOBILE CATEGORY OF PROJECTS
                Text(
                  'Mobile',
                  style: GoogleFonts.poppins(color: Colors.black87),
                ),
                const ProjectGridItem(
                  category: 'mobile',
                  title: 'FINAL PROJECT',
                  year: '2023',
                  student: 'Martinson Tetteh',
                  description:
                      'Ipsum pariatur fugiat occaecat cupidatat mollit esse et laboris consequat.',
                ),
                const SizedBox(height: 15),
                const ProjectGridItem(
                  category: 'mobile',
                  title: 'FINAL PROJECT',
                  year: '2023',
                  student: 'Martinson Tetteh',
                  description:
                      'Exercitation nulla fugiat velit enim nisi ut aute dolore non reprehenderit in aliquip aliquip.',
                ),
                const SizedBox(height: 15),

                // Data CATEGORY OF PROJECTS
                Text(
                  'Data',
                  style: GoogleFonts.poppins(color: Colors.black87),
                ),
                const ProjectGridItem(
                  category: 'data',
                  title: 'FINAL PROJECT',
                  year: '2023',
                  student: 'Martinson Tetteh',
                  description:
                      'Tempor laborum aute culpa excepteur officia anim.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
