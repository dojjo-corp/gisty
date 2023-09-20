import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/buttons.dart';
import 'package:gt_daily/authentication/components/custom_back_button.dart';
import 'package:gt_daily/authentication/pages/pdf_view_page.dart';
import 'package:path_provider/path_provider.dart';

import '../components/comment_tile.dart';

class ProjectDetails extends StatefulWidget {
  final Map<String, dynamic> projectData;
  const ProjectDetails({super.key, required this.projectData});

  @override
  State<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  final storage = FirebaseStorage.instance;
  final store = FirebaseFirestore.instance;
  final commentController = TextEditingController();
  final _key = GlobalKey<FormFieldState>();
  bool _isLoading = false;

  void downloadProjectDoc() async {
    final docFileName = widget.projectData['project-document'];
    final downloadFileRef =
        storage.ref().child('Project Documents/$docFileName');
    setState(() {
      _isLoading = true;
    });
    try {
      final Directory? tempDir = await getDownloadsDirectory();
      final File tempFile = File('${tempDir?.path}/$docFileName');
      await downloadFileRef.writeToFile(tempFile);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File downloaded to: ${tempDir?.path}/'),
          action: SnackBarAction(label: 'Open', onPressed: () async {}),
        ),
      );
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

  void viewProjectDoc() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PDFViewPage(pdfPath: widget.projectData['project-document']),
      ),
    );
  }

  void sendComment() async {
    if (commentController.text.isNotEmpty) {
      try {
        _key.currentState!.save();
        final commentData = {
          'commenter': FirebaseAuth.instance.currentUser!.email!,
          'comment-text': commentController.text,
          'timestamp': Timestamp.now(),
        };
        await store
            .collection('All Projects')
            .doc(widget.projectData['pid'])
            .update({
          'comments': FieldValue.arrayUnion([commentData])
        });
        commentController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending comment: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  right: 15, left: 15, top: 90, bottom: 75),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.projectData['student-name'],
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.projectData['category'],
                          style: GoogleFonts.montserrat(
                              fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Short Description',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.projectData['description'],
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: MyButton(
                            onPressed: viewProjectDoc,
                            btnText: 'View Project Document',
                            isPrimary: false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MyButton(
                            onPressed: downloadProjectDoc,
                            btnText: 'Download Project Document',
                            isPrimary: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Comments',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('All Projects')
                            .doc(widget.projectData['pid'])
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: Text(
                                  'Be The First To Comment On This Project!'),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                  'Error loading comments: ${snapshot.error}'),
                            );
                          }

                          final comments =
                              snapshot.data!.data()!['comments'] as List;
                          return Column(
                            children: comments
                                .map((e) => CommentTile(
                                      commenter: e['commenter'],
                                      commentText: e['comment-text'],
                                      timestamp: e['timestamp'],
                                    ))
                                .toList(),
                          );
                        }),
                  ],
                ),
              ),
            ),
            const Positioned(
              top: 20,
              left: 20,
              child: MyBackButton(),
            ),
            Positioned(
              bottom: 10,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: _key,
                          controller: commentController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white60,
                            border: InputBorder.none,
                            alignLabelWithHint: true,
                            hintText: 'Comment',
                          ),
                          maxLines: 2,
                          onChanged: (value) {
                            if (value.isNotEmpty) {}
                          },
                        ),
                      ),
                      IconButton(
                          onPressed: sendComment,
                          icon: const Icon(Icons.arrow_circle_up_rounded))
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        floatingActionButton:
            _isLoading ? const LinearProgressIndicator() : null,
      ),
    );
  }
}
