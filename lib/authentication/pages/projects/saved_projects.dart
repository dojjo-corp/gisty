import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/providers/projects_provider.dart';
import 'package:provider/provider.dart';

import '../../components/custom_back_button.dart';
import '../../components/project_grid_item.dart';

class SavedProjects extends StatefulWidget {
  const SavedProjects({super.key});

  @override
  State<SavedProjects> createState() => _SavedProjectsState();
}

class _SavedProjectsState extends State<SavedProjects> {
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchSavedData().then((value) {
      setState(() {
        _dataLoaded = true;
      });
    });
  }

  Future<void> _fetchSavedData() async {
    final projectProvider =
        Provider.of<ProjectProvider>(context, listen: false);
    await projectProvider.setSavedProjects();
  }

  @override
  Widget build(BuildContext context) {
    final savedProjects = context.watch<ProjectProvider>().savedProjects;

    if (!_dataLoaded) {
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white70,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100, left: 15, right: 15, bottom: 10),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Projects',
                      style: GoogleFonts.poppins(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    savedProjects.isNotEmpty?
                    Column(
                      children: savedProjects
                          .map(
                            (e) => ProjectGridItem(
                              projectData: e!,
                              showLiked: false,
                            ),
                          )
                          .toList(),
                    ): const Center(child: Text('No Saved Projects'))
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            top: 40,
            left: 5,
            child: MyBackButton(),
          )
        ],
      ),
    );
  }
}
