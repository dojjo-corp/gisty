import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/pages/projects/project_details.dart';
import 'package:gt_daily/authentication/pages/user%20account/other_user_account_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../components/ListTiles/search_tile.dart';
import '../providers/projects_provider.dart';
import '../providers/user_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  Set<Map<String, dynamic>> searchResults = {};
  Color prefixIconColor = Colors.grey;

  // Navigate To Project Details Page
  void goToProjectDetails(Map<String, dynamic> projectData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectDetails(
          projectData: projectData,
          goToComment: false,
        ),
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
    final allProjects = Provider.of<ProjectProvider>(context, listen: false)
        .allProjects
        .values
        .toList();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final allUsers = userProvider.allUsers;
    final isUserStudent = userProvider.userType.toLowerCase() == 'student';

    List<Map<String, dynamic>> getSearchResults(String searchTerm) {
      // always start with a clean (empty) set
      setState(() {
        searchResults.clear();
      });

      // PROJECT SEARCH RESULTS
      for (var map in allProjects) {
        // search projects by year
        if (searchTerm.length == 4 &&
            RegExp(r'^[0-9]+$').hasMatch(searchTerm) &&
            map['year'] == searchTerm) {
          map['type'] = 'project';
          setState(() {
            searchResults.add(map);
          });
        }

        // search projects by title and supervisor
        if (map['title'].toLowerCase().contains(searchTerm.toLowerCase()) ||
            map['supervisor-name']
                .toLowerCase()
                .contains(searchTerm.toLowerCase())) {
          map['type'] = 'project';
          setState(() {
            searchResults.add(map);
          });
        }
      }

      // USER SEARCH RESULTS
      if (!isUserStudent) {
        for (var user in allUsers) {
          if (user['fullname']
                  .toLowerCase()
                  .contains(searchTerm.toLowerCase()) ??
              user['full-name']
                  .toLowerCase()
                  .contains(searchTerm.toLowerCase())) {
            user['type'] = 'user';
            setState(() {
              searchResults.add(user);
            });
          }
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
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.search_rounded),
            prefixIconColor: prefixIconColor,
            hintText: 'Search',
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              setState(() {
                prefixIconColor = Theme.of(context).primaryColor;
              });
              getSearchResults(value);
            } else {
              setState(() {
                prefixIconColor = Colors.grey;
              });
              clearSearchResults();
            }
          },
        ),
        const SizedBox(height: 10),
        searchResults.isNotEmpty
            ? Text(
                'Results',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 20),
              )
            : const Center(
                child: Text('You Can Search For Users And Projects'),
              ),
        Column(
          children: searchResults
              .map(
                (searchData) => GestureDetector(
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
                      const SizedBox(height: 3)
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
