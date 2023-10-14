import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../components/custom_back_button.dart';
import '../../components/dashboard_card.dart';
import '../../providers/projects_provider.dart';
import '../../repository/navigation_reo.dart';

class ProjectArchive extends StatelessWidget {
  const ProjectArchive({super.key});

  void onTap() {
    NavigationService().navigateTo('/');
  }

  void goToPage() {}

  @override
  Widget build(BuildContext context) {
    final categories =
        context.read<ProjectProvider>().categoryMap.keys.toList();
    final categoryMap = context.read<ProjectProvider>().categoryMap;
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
                      'Project Archive',
                      style: GoogleFonts.poppins(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Tap A Category To See All Projects Under It',
                      style: GoogleFonts.montserrat(color: Colors.grey[700]),
                    ),
                    Column(
                      children: categories
                          .map((category) => DashboardCard(
                              name: category,
                              number: 0,
                              bottomMargin: 5,
                              imagePath: categoryMap[category]['image']))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const MyBackButton()
        ],
      ),
    );
  }
}
