import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../../components/buttons/custom_appbar_button.dart';
import '../../components/buttons/custom_back_button.dart';
import '../../components/dashboard_card.dart';
import '../../providers/projects_provider.dart';
import 'add_new_category.dart';

class ProjectArchive extends StatelessWidget {
  const ProjectArchive({super.key});

  void goToPage() {}

  @override
  Widget build(BuildContext context) {
    final _isUserAdmin =
        Provider.of<UserProvider>(context, listen: false).isUserAdmin;
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
                      'Project Categories',
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
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
          const MyBackButton(),
          _isUserAdmin
              ? CustomAppBarButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddNewCategory(),
                      ),
                    );
                  },
                  iconData: Icons.playlist_add_rounded,
                  tooltipMessage: 'Add New Category',
                )
              : Container(),
        ],
      ),
    );
  }
}
