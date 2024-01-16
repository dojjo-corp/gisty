import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:gt_daily/authentication/pages/projects/pdf_view_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/pages/analytics/project_analytics.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../../global/homepage.dart';
import '../../components/buttons/buttons.dart';
import '../../components/ListTiles/comment_tile.dart';
import '../../components/buttons/custom_back_button.dart';
import '../../helper_methods.dart/projects.dart';
import '../../providers/projects_provider.dart';
import '../../providers/user_provider.dart';
import '../user account/other_user_account_page.dart';
import 'edit_project.dart';

class ProjectDetails extends StatefulWidget {
  final Map<String, dynamic> projectData;
  final bool goToComment;
  const ProjectDetails({
    super.key,
    required this.projectData,
    required this.goToComment,
  });

  @override
  State<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  late Map<String, dynamic> projectData;

  final storage = FirebaseStorage.instance;
  final store = FirebaseFirestore.instance;
  final commentController = TextEditingController();
  final _key = GlobalKey<FormFieldState>();
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool _isLoading = false;
  bool _isDownloaded = false;

  List<bool> impressions = [false, false, false, false];
  List<String> impressionNames = [
    'celebrate',
    'support',
    'insightful',
    'like',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final categoryMap = context.read<ProjectProvider>().categoryMap;
    final isUserIndustryPro =
        Provider.of<UserProvider>(context, listen: false).userType ==
            'industry professional';
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                right: 15, left: 15, top: 100, bottom: 75),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ListView(
                children: [
                  Text(
                    widget.projectData['title'],
                    style: GoogleFonts.poppins(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        SizedBox(
                          height: 45,
                          width: 45,
                          child: Image.asset(
                            categoryMap[widget.projectData['category']]
                                ['image'],
                            height: 45,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.projectData['student-name'],
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                maxLines: 3,
                              ),
                              Text(
                                widget.projectData['category'],
                                style: GoogleFonts.montserrat(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Supervised By: '),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtherUserAccountPage(
                                  otherUserEmail:
                                      widget.projectData['supervisor-email']),
                            ),
                          );
                        },
                        child: Text(
                          widget.projectData['supervisor-name'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // SHORT DESCRIPTION OF PROJECT (INTRODUCTION OF SORTS)
                  Text(
                    'Short Description',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(widget.projectData['description'],
                        style: GoogleFonts.poppins()),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: MyButton(
                            onPressed: viewProjectDoc,
                            btnText: 'View Project Document',
                            isPrimary: false),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MyButton(
                            onPressed: downloadProjectDoc,
                            btnText: 'Download Project Document',
                            isPrimary: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // IMPRESSIONS
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('All Projects')
                          .doc(widget.projectData['pid'])
                          .snapshots()
                          .throttleTime(const Duration(milliseconds: 100)),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: Text(
                                  'Be The First To Comment On This Project!'));
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text(
                                  'Error loading comments: ${snapshot.error}'));
                        }

                        // NO ERRORS AND DATA HAS BEEN LOADED SUCCESSFULLY

                        final comments =
                            snapshot.data!.data()!['comments'] as List;
                        final impressionsData = snapshot.data!
                            .data()!['impressions'] as Map<String, dynamic>;
                        // get impressions data
                        final int numCelebrate =
                            impressionsData['celebrate'].length;
                        final int numLike = impressionsData['like'].length;
                        final int numSupport =
                            impressionsData['support'].length;
                        final int numInsightful =
                            impressionsData['insightful'].length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // IMPRESSIONS
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color:
                                            Colors.grey[300]!.withOpacity(0.6)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              // celebrate
                                              GestureDetector(
                                                onTap: () {
                                                  toggleImpressions(
                                                    0,
                                                    context: context,
                                                    pid: widget
                                                        .projectData['pid'],
                                                    isUserIndustryPro:
                                                        isUserIndustryPro,
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    Tooltip(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: Colors
                                                            .blueGrey[100],
                                                      ),
                                                      message: 'Celebrate',
                                                      textStyle: TextStyle(
                                                          color:
                                                              Colors.grey[700]),
                                                      triggerMode:
                                                          TooltipTriggerMode
                                                              .longPress,
                                                      child: FaIcon(
                                                        FontAwesomeIcons
                                                            .handsClapping,
                                                        color: impressionsData[
                                                                    'celebrate']
                                                                .contains(
                                                                    currentUser
                                                                        .email)
                                                            ? Colors.green
                                                            : Colors.grey[600],
                                                        size: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                        numCelebrate.toString(),
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[500],
                                                            fontSize: 12))
                                                  ],
                                                ),
                                              ),

                                              // support
                                              GestureDetector(
                                                onTap: () {
                                                  toggleImpressions(
                                                    1,
                                                    context: context,
                                                    pid: widget
                                                        .projectData['pid'],
                                                    isUserIndustryPro:
                                                        isUserIndustryPro,
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    Tooltip(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: Colors
                                                            .blueGrey[100],
                                                      ),
                                                      message: 'Support',
                                                      textStyle: TextStyle(
                                                          color:
                                                              Colors.grey[700]),
                                                      triggerMode:
                                                          TooltipTriggerMode
                                                              .longPress,
                                                      child: FaIcon(
                                                        FontAwesomeIcons
                                                            .solidHeart,
                                                        color: impressionsData[
                                                                    'support']
                                                                .contains(
                                                                    currentUser
                                                                        .email)
                                                            ? Colors.red
                                                            : Colors.grey[600],
                                                        size: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(numSupport.toString(),
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[500],
                                                            fontSize: 12))
                                                  ],
                                                ),
                                              ),

                                              // insightful
                                              GestureDetector(
                                                onTap: () {
                                                  toggleImpressions(
                                                    2,
                                                    context: context,
                                                    pid: widget
                                                        .projectData['pid'],
                                                    isUserIndustryPro:
                                                        isUserIndustryPro,
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    Tooltip(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: Colors
                                                            .blueGrey[100],
                                                      ),
                                                      message: 'Insightful',
                                                      textStyle: TextStyle(
                                                          color:
                                                              Colors.grey[700]),
                                                      triggerMode:
                                                          TooltipTriggerMode
                                                              .longPress,
                                                      child: FaIcon(
                                                        FontAwesomeIcons
                                                            .solidLightbulb,
                                                        color: impressionsData[
                                                                    'insightful']
                                                                .contains(
                                                                    currentUser
                                                                        .email)
                                                            ? Colors.yellow
                                                            : Colors.grey[600],
                                                        size: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                        numInsightful
                                                            .toString(),
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[500],
                                                            fontSize: 12))
                                                  ],
                                                ),
                                              ),

                                              // like
                                              GestureDetector(
                                                onTap: () {
                                                  toggleImpressions(
                                                    3,
                                                    context: context,
                                                    pid: widget
                                                        .projectData['pid'],
                                                    isUserIndustryPro:
                                                        isUserIndustryPro,
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    Tooltip(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: Colors
                                                            .blueGrey[100],
                                                      ),
                                                      message: 'Like',
                                                      textStyle: TextStyle(
                                                          color:
                                                              Colors.grey[700]),
                                                      triggerMode:
                                                          TooltipTriggerMode
                                                              .longPress,
                                                      child: FaIcon(
                                                        FontAwesomeIcons
                                                            .solidThumbsUp,
                                                        color: impressionsData[
                                                                    'like']
                                                                .contains(
                                                                    currentUser
                                                                        .email)
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : Colors.grey[600],
                                                        size: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(numLike.toString(),
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[500],
                                                            fontSize: 12))
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProjectAnalytics(
                                                  pid:
                                                      widget.projectData['pid'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text('Analytics'),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Comments',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Column(
                              children: comments
                                  .map((e) => CommentTile(
                                        commenter: e['commenter'],
                                        commentText: e['comment-text'],
                                        timestamp: e['timestamp'],
                                      ))
                                  .toList(),
                            ),
                          ],
                        );
                      }),
                ],
              ),
            ),
          ),
          const MyBackButton(),

          // OPTIONS ICON BUTTON
          Positioned(
            top: 60,
            right: 15,
            child: GestureDetector(
              onTap: () {
                showOptions(context);
              },
              child: Icon(
                Icons.settings_outlined,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),

          // COMMENT TEXT FIELD
          Positioned(
            bottom: 10,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: _key,
                        controller: commentController,
                        autofocus: widget.goToComment,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignLabelWithHint: true,
                          hintText: 'Comment',
                        ),
                        minLines: 1,
                        maxLines: 2,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Field cannot be empty!';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        sendComment(
                          key: _key,
                          commentController: commentController,
                          pid: widget.projectData['pid'],
                          context: context,
                        );
                      },
                      icon: Icon(
                        Icons.arrow_circle_up_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _isLoading ? const LinearProgressIndicator() : null,
    );
  }

  // todo: Toggle Impressions
  void toggleImpressions(int index,
      {required BuildContext context,
      required String pid,
      ConnectivityResult? connectionResult,
      bool? isUserIndustryPro}) async {
    // if impression is not already selected and is now selected
    try {
      // Throw error if device is not connected to the internet
      if (connectionResult == ConnectivityResult.none) {
        throw 'You are not connected to the internet';
      }

      /// The Reference to the project's firestore document
      final docRef =
          store.collection('All Projects').doc(widget.projectData['pid']);

      /// The snapshot of the document with updated fields
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        int industryImpressions = data['industry-impressions-sum'] ?? 0;

        if (!impressions[index]) {
          for (int i = 0; i < 4; i++) {
            // deselect all other impressions
            if (i != index) {
              await FirebaseFirestore.instance
                  .collection('All Projects')
                  .doc(pid)
                  .update({
                'impressions.${impressionNames[i]}':
                    FieldValue.arrayRemove([currentUser.email!])
              });
              setState(() {
                impressions[i] = false;
              });
            }
          }
          // then select chosen impression
          await FirebaseFirestore.instance
              .collection('All Projects')
              .doc(pid)
              .update({
            'impressions.${impressionNames[index]}':
                FieldValue.arrayUnion([currentUser.email!]),
            'industry-impressions-sum': isUserIndustryPro!
                ? industryImpressions + 1
                : industryImpressions,
          });
          setState(() {
            impressions[index] = true;
          });
        }
        // if impression was already selected
        else {
          await FirebaseFirestore.instance
              .collection('All Projects')
              .doc(pid)
              .update({
            'impressions.${impressionNames[index]}':
                FieldValue.arrayRemove([currentUser.email!]),
            'industry-impressions-sum': isUserIndustryPro!
                ? industryImpressions - 1
                : industryImpressions,
          });
          setState(() {
            impressions[index] = false;
          });
        }
      }
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to add impression: ${e.code}'),
        ),
      );
    }
  }

  void downloadProjectDoc({
    ConnectivityResult? connectionResult,
  }) async {
    final docFileName = widget.projectData['project-document'];
    final downloadFileRef =
        storage.ref().child('Project Documents/$docFileName');

    setState(() {
      _isLoading = true;
    });
    try {
      // Throw error if device is not connected to the internet
      if (connectionResult == ConnectivityResult.none) {
        throw 'You are not connected to the internet';
      }

      final client = HttpClient();
      final downloadUrl = await downloadFileRef.getDownloadURL();
      List<int> downloadData = [];

      // directory for storing downloaded file
      Directory downloadDirectory;
      downloadDirectory = (await getExternalStorageDirectory())!;

      String filePathName = "${downloadDirectory.path}/$docFileName";
      // TODO
      log(filePathName);
      File savedFile = File(filePathName);
      bool fileExists = await savedFile.exists();

      if (fileExists && mounted) {
        showSnackBar(context, "File already downloaded");
        await openDownloadedFile(filePathName);
      } else {
        client.getUrl(Uri.parse(downloadUrl)).then(
          (HttpClientRequest request) {
            return request.close();
          },
        ).then(
          (HttpClientResponse response) {
            response.listen((d) => downloadData.addAll(d), onDone: () async {
              await savedFile.writeAsBytes(downloadData);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Document downloaded to ${downloadDirectory.path}'),
                    action: SnackBarAction(
                      label: 'Open',
                      onPressed: () async {
                        await openDownloadedFile(filePathName);
                      },
                    ),
                  ),
                );
              }
            });
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading: ${e.toString()}'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // open downloaded pdf with device's default pdf viewer
  Future<void> openDownloadedFile(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: ${e.toString()}'),
        ),
      );
    }
  }

  // open pdf in app
  void viewProjectDoc() {
    !_isDownloaded
        // Open pdf in app if not downloaded
        ? Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PDFViewPage(pdfPath: widget.projectData['project-document']),
            ),
          )
        // Open downloaded pdf with device's default pdf viewer if downloaded
        : openDownloadedFile(widget.projectData['project-document']);
  }

  // send comment to firestore
  // shop project options for admins
  /// CONVENIENCE METHODS
  Future<void> showOptions(BuildContext context) async {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => SimpleDialog(
        backgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        children: [
          /// Edit Button
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditProjectDetailsPage(pid: widget.projectData['pid']),
                ),
              );
            },
            child: const Text(
              'Edit',
              style: TextStyle(color: Colors.white),
            ),
          ),

          /// Delete Button
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('All Projects')
                  .doc(widget.projectData['pid'])
                  .delete();

              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(
                      pageIndex: 0,
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
