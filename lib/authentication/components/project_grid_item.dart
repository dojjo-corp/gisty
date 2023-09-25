import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/pages/projects/project_details.dart';

class ProjectGridItem extends StatefulWidget {
  final Map<String, dynamic> projectData;
  final bool showLiked;
  const ProjectGridItem(
      {super.key, required this.projectData, required this.showLiked});

  @override
  State<ProjectGridItem> createState() => _ProjectGridItemState();
}

class _ProjectGridItemState extends State<ProjectGridItem> {
  Color setProjectColor(String category) {
    switch (category.toLowerCase()) {
      case 'web':
        return const Color.fromARGB(255, 57, 134, 198);
      case 'mobile':
        return const Color.fromARGB(255, 234, 206, 64);
      case 'data':
        return const Color.fromARGB(255, 188, 137, 197);
      case 'hardware':
        return const Color.fromARGB(255, 6, 134, 4);
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String pid = widget.projectData['pid'];
    final String title = widget.projectData['title'];
    final String year = widget.projectData['year'];
    final String student = widget.projectData['student-name'];
    final String description = widget.projectData['description'];
    final String category = widget.projectData['category'];
    final projectColor = setProjectColor(category);

    String userEmail = FirebaseAuth.instance.currentUser!.email!;
    bool isLiked = widget.projectData['saved'].contains(userEmail);
    final likedIcon = Icon(
      Icons.bookmark_added,
      color: projectColor,
    );
    const notLikedIcon = Icon(Icons.bookmark_add_outlined);

    // add project to saved projects
    Future<void> saveProject() async {
      try {
        await FirebaseFirestore.instance
            .collection('All Projects')
            .doc(pid)
            .update({
          'saved': FieldValue.arrayUnion([userEmail])
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'saved-projects': FieldValue.arrayUnion([pid])
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error Unsaving Project: ${e.toString()}'),
          ),
        );
      }
    }

    // remove from saved projects
    Future<void> unsaveProject() async {
      try {
        await FirebaseFirestore.instance
            .collection('All Projects')
            .doc(pid)
            .update({
          'saved': FieldValue.arrayRemove([userEmail])
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'saved-projects': FieldValue.arrayRemove([pid])
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error Unsaving Project: ${e.toString()}'),
          ),
        );
      }
    }

    return Container(
      constraints: const BoxConstraints(
        minWidth: 0,
        maxWidth: double.infinity,
      ),
      height: 180,
      padding: const EdgeInsets.only(right: 10),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
        gradient: LinearGradient(colors: [
          projectColor.withOpacity(0.1),
          projectColor.withOpacity(0.4)
        ]),
      ),
      child: Row(
        children: [
          VerticalDivider(
            thickness: 6,
            color: projectColor,
            width: 9,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Icon(Icons.portrait_rounded),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: projectColor),
                    ),
                    Row(
                      children: [
                        Text(
                          student,
                          style: GoogleFonts.montserrat(
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(year,
                            style:
                                GoogleFonts.montserrat(color: Colors.grey[700]))
                      ],
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                      softWrap: true,
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ProjectDetails(projectData: widget.projectData),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: projectColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Details'),
                    ),
                    widget.showLiked
                        ? IconButton(
                            onPressed: () async {
                              setState(() {
                                isLiked = !isLiked;
                              });
                              isLiked
                                  ? await saveProject()
                                  : await unsaveProject();
                            },
                            icon: isLiked ? likedIcon : notLikedIcon,
                          )
                        : Text(''),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
