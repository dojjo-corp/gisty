import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../pages/projects/all_projects_in_a_category.dart';
import '../providers/projects_provider.dart';

class DashboardCard extends StatelessWidget {
  final String name;
  final int number;
  final IconData iconData;
  const DashboardCard({
    super.key,
    required this.name,
    required this.number,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    void goToPage() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AllProjectsInACategory(title: name)));
    }

    final categoryMap = context.watch<ProjectProvider>().categoryMap;
    return GestureDetector(
        onTap: goToPage,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                categoryMap[name]!['color']!.withOpacity(0.2),
                categoryMap[name]!['color']!.withOpacity(0.5)
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData),
              Text(
                name,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  // fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ));
  }
}
