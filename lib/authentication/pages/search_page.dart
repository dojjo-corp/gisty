import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/pages/projects/project_details.dart';
import 'package:gt_daily/authentication/pages/user%20account/other_user_account_page.dart';
import 'package:gt_daily/authentication/providers/projects_provider.dart';
import 'package:gt_daily/authentication/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../components/search_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  Set<Map<String, dynamic>> searchResults = {};

  // Navigate To Project Details Page
  void goToProjectDetails(Map<String, dynamic> projectData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectDetails(projectData: projectData),
      ),
    );
  }

  // Navigate to Other user's Account Page
  void goToOtherUserAccountPage(String otherUserEmail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtherUserAccountPage(
          otherUserEmail: otherUserEmail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allProjects =
        Provider.of<ProjectProvider>(context, listen: false).allProjects.values;
    final allUsers = Provider.of<UserProvider>(context, listen: false).allUsers;

    List<Map<String, dynamic>> getSearchResults(String searchTerm) {
      // always start with a clean (emppty) set
      setState(() {
        searchResults.clear();
      });

      // PROJECT SEARCH RESULTS
      for (var map in allProjects.toList()) {
        if (map['title'].toLowerCase().contains(searchTerm.toLowerCase())) {
          map['type'] = 'project';
          setState(() {
            searchResults.add(map);
          });
        }
      }

      // USER SEARCH RESULTS
      for (var user in allUsers) {
        if (user['fullname'].toLowerCase().contains(searchTerm.toLowerCase()) ??
            user['full-name']
                .toLowerCase()
                .contains(searchTerm.toLowerCase())) {
          user['type'] = 'user';
          setState(() {
            searchResults.add(user);
          });
        }
      }
      return searchResults.toList();
    }

    // CLEAR SEARCH RESULTS
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
            : const Center(child: Text('You Can Search For Users And Projects')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
              children: searchResults
                  .map((searchData) => GestureDetector(
                        onTap: () {
                          searchData['type'] == 'project'
                              ? goToProjectDetails(searchData)
                              : goToOtherUserAccountPage(searchData['email']);
                        },
                        child: Column(
                          children: [
                            SearchTile(
                              searchMap: searchData,
                              type: searchData['type'],
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
