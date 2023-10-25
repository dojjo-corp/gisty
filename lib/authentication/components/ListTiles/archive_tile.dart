import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../pages/projects/all_projects_in_a_category.dart';
import '../../providers/projects_provider.dart';

class ArchiveTile extends StatelessWidget {
  final String title;
  const ArchiveTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    void goToPage() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AllProjectsInACategory(title: title)));
    }

    final categoryMap = context.watch<ProjectProvider>().categoryMap;
    return GestureDetector(
        onTap: goToPage,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                categoryMap[title]!['color']!.withOpacity(0.2),
                categoryMap[title]!['color']!.withOpacity(0.5)
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.webhook_sharp),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  // fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ));
  }
}
