import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../pages/projects/all_projects_in_a_category.dart';
import '../providers/projects_provider.dart';

class DashboardCard extends StatelessWidget {
  final String name, imagePath;
  final double number, bottomMargin;
  const DashboardCard({
    super.key,
    required this.name,
    required this.number,
    required this.imagePath,
    required this.bottomMargin,
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
          margin:   EdgeInsets.only(right: 5, bottom: bottomMargin),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Color(categoryMap[name]!['color']).withOpacity(0.2),
                Color(categoryMap[name]!['color']).withOpacity(0.5)
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: Image.asset(imagePath),
              ),
              Text(
                name,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    letterSpacing: 2),
                softWrap: true,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ));
  }
}
