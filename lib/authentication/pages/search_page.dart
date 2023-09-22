import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/pages/projects/project_details.dart';
import 'package:gt_daily/authentication/providers/projects_provider.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  Set<Map<String, dynamic>> searchResults = {};

  void goToProjectDetails(Map<String, dynamic> projectData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectDetails(projectData: projectData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider =
        Provider.of<ProjectProvider>(context, listen: false);

    List<Map<String, dynamic>> getSearchResults(String searchTerm) {
      // always start with a clean (emppty) set
      setState(() {
            searchResults.clear();
          });
      final allProjects = projectProvider.allProjects.values;

      for (var map in allProjects.toList()) {
        if (map['title']
            .toString()
            .toLowerCase()
            .contains(searchTerm.toLowerCase())) {
          setState(() {
            searchResults.add(map);
          });
        }
      }
      return searchResults.toList();
    }

    void clearSearchResults() {
      setState(() {
        searchResults.clear();
      });
    }

    return ListView(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                getSearchResults(value);
              } else {
                clearSearchResults();
              }
            },
          ),
        ),
        const SizedBox(height: 10),
        searchResults.isNotEmpty
            ? Text('Results',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 20))
            : const Center(child: Text('Enter Existing Project Titles')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
              children: searchResults
                  .map((projectData) => GestureDetector(
                        onTap: () {
                          goToProjectDetails(projectData);
                        },
                        child: Column(
                          children: [
                            ListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              tileColor: Colors.white70,
                              title: Text(projectData['title']),
                              subtitle: Text(projectData['student-name']),
                            ),
                            const SizedBox(height: 10)
                          ],
                        ),
                      ))
                  .toList()),
        ),
      ],
    );
  }
}
