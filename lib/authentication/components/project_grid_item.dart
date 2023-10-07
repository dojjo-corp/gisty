// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../pages/projects/project_details.dart';
import '../providers/projects_provider.dart';

class ProjectGridItem extends StatefulWidget {
  final Map<String, dynamic> projectData;
  final bool showLiked;
  const ProjectGridItem(
      {super.key, required this.projectData, required this.showLiked});

  @override
  State<ProjectGridItem> createState() => _ProjectGridItemState();
}

class _ProjectGridItemState extends State<ProjectGridItem> {
  List<bool> impressions = [false, false, false, false];
  List<String> impressionNames = [
    'celebrate',
    'support',
    'insightful',
    'like',
  ];
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    final categoryMap = context.read<ProjectProvider>().categoryMap;
    final String pid = widget.projectData['pid'];
    final String title = widget.projectData['title'];
    final String year = widget.projectData['year'];
    final String student = widget.projectData['student-name'];
    final String description = widget.projectData['description'];
    final String category = widget.projectData['category'];
    final projectColor = categoryMap[category]['color'];

    String userEmail = FirebaseAuth.instance.currentUser!.email!;
    bool isSaved = widget.projectData['saved'].contains(userEmail);
    final savedIcon = Icon(
      Icons.bookmark_added,
      color: projectColor,
    );
    const notSavedIcon = Icon(
      Icons.bookmark_add_outlined,
    );

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

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProjectDetails(
                  projectData: widget.projectData,
                  goToComment: false,
                ),
              ),
            );
          },
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 0,
              maxWidth: double.infinity,
            ),
            padding: const EdgeInsets.only(right: 10, bottom: 10),
            margin: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
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
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                categoryMap[category]['image'],
                                height: 30,
                              ),
                              widget.showLiked
                                  ? IconButton(
                                      onPressed: () async {
                                        setState(() {
                                          isSaved = !isSaved;
                                        });
                                        isSaved
                                            ? await saveProject()
                                            : await unsaveProject();
                                      },
                                      icon: isSaved ? savedIcon : notSavedIcon,
                                    )
                                  : Container(),
                            ],
                          ),
                          // PROJECT TITLE
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
                              const SizedBox(height: 5),
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
                                      style: GoogleFonts.montserrat(
                                          color: Colors.grey[700]))
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                description,
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                softWrap: true,
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300]!.withOpacity(0.6)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('All Projects')
                        .doc(pid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      // NO ERRORS AND DATA HAS BEEN LOADED SUCCESSFULLY
                      final impressionsData =
                          snapshot.data!.data()!['impressions'];
                      // get impressions data
                      final int numCelebrate =
                          impressionsData['celebrate'].length;
                      final int numLike = impressionsData['like'].length;
                      final int numSupport = impressionsData['support'].length;
                      final int numInsightful =
                          impressionsData['insightful'].length;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // celebrate
                          GestureDetector(
                            onTap: () {
                              toggleImpressions(0);
                            },
                            child: Row(
                              children: [
                                Tooltip(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.blueGrey[100],
                                  ),
                                  message: 'Celebrate',
                                  textStyle: TextStyle(color: Colors.grey[700]),
                                  triggerMode: TooltipTriggerMode.longPress,
                                  child: FaIcon(
                                    FontAwesomeIcons.handsClapping,
                                    color: impressionsData['celebrate']
                                            .contains(currentUser.email)
                                        ? Colors.green
                                        : Colors.grey[600],
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(numCelebrate.toString(),
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 12))
                              ],
                            ),
                          ),

                          // support
                          GestureDetector(
                            onTap: () {
                              toggleImpressions(1);
                            },
                            child: Row(
                              children: [
                                Tooltip(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.blueGrey[100],
                                  ),
                                  message: 'Support',
                                  textStyle: TextStyle(color: Colors.grey[700]),
                                  triggerMode: TooltipTriggerMode.longPress,
                                  child: FaIcon(
                                    FontAwesomeIcons.solidHeart,
                                    color: impressionsData['support']
                                            .contains(currentUser.email)
                                        ? Colors.red
                                        : Colors.grey[600],
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(numSupport.toString(),
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 12))
                              ],
                            ),
                          ),

                          // insightful
                          GestureDetector(
                            onTap: () {
                              toggleImpressions(2);
                            },
                            child: Row(
                              children: [
                                Tooltip(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.blueGrey[100],
                                  ),
                                  message: 'Insightful',
                                  textStyle: TextStyle(color: Colors.grey[700]),
                                  triggerMode: TooltipTriggerMode.longPress,
                                  child: FaIcon(
                                    FontAwesomeIcons.solidLightbulb,
                                    color: impressionsData['insightful']
                                            .contains(currentUser.email)
                                        ? Colors.yellow
                                        : Colors.grey[600],
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(numInsightful.toString(),
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 12))
                              ],
                            ),
                          ),

                          // like
                          GestureDetector(
                            onTap: () {
                              toggleImpressions(3);
                            },
                            child: Row(
                              children: [
                                Tooltip(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.blueGrey[100],
                                  ),
                                  message: 'Like',
                                  textStyle: TextStyle(color: Colors.grey[700]),
                                  triggerMode: TooltipTriggerMode.longPress,
                                  child: FaIcon(
                                    FontAwesomeIcons.solidThumbsUp,
                                    color: impressionsData['like']
                                            .contains(currentUser.email)
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey[600],
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(numLike.toString(),
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 12))
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProjectDetails(
                        projectData: widget.projectData,
                        goToComment: true,
                      ),
                    ),
                  );
                },
                child: const Row(
                  children: [
                    FaIcon(FontAwesomeIcons.comments, size: 16),
                    SizedBox(width: 5),
                    Text('Comment')
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  void toggleImpressions(int index) async {
    // if impression is not already selected
    try {
      if (!impressions[index]) {
        for (int i = 0; i < 4; i++) {
          if (i != index) {
            await FirebaseFirestore.instance
                .collection('All Projects')
                .doc(widget.projectData['pid'])
                .update({
              'impressions.${impressionNames[i]}':
                  FieldValue.arrayRemove([currentUser.email!])
            });
            setState(() {
              impressions[i] = false;
            });
          }
        }
        await FirebaseFirestore.instance
            .collection('All Projects')
            .doc(widget.projectData['pid'])
            .update({
          'impressions.${impressionNames[index]}':
              FieldValue.arrayUnion([currentUser.email!])
        });
        setState(() {
          impressions[index] = true;
        });
        return;
      }
      // if impression was already selected
      await FirebaseFirestore.instance
          .collection('All Projects')
          .doc(widget.projectData['pid'])
          .update({
        'impressions.${impressionNames[index]}':
            FieldValue.arrayRemove([currentUser.email!])
      });
      setState(() {
        impressions[index] = false;
      });
      return;
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to add impression: ${e.code}'),
        ),
      );
    }
  }
}
