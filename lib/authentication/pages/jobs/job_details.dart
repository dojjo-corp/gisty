import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/loading_circle.dart';

import '../../components/buttons/custom_back_button.dart';

class JobDetailsPage extends StatefulWidget {
  final String jobId;
  const JobDetailsPage({super.key, required this.jobId});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  late Map<String, dynamic> loadedJobDetails;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    loadJobDetails().then((value) {
      setState(() {
        _isLoaded = true;
        loadedJobDetails = value!;
      });
    });
  }

  Future<Map<String, dynamic>?> loadJobDetails() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('All Jobs')
          .doc(widget.jobId)
          .get();
      if (snapshot.exists) return snapshot.data()!;
      throw 'Job Details Not Found...';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_isLoaded
        ? const LoadingCircle()
        : Scaffold(
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 100, bottom: 10, right: 20, left: 20),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: ListView(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              /// Navigate to a new page to view the image
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  title: Text(loadedJobDetails['title']),
                                ),
                                body: Center(
                                  child: Image.network(
                                    loadedJobDetails['images'][0],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          /// Event Topic Image
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            height: 260,
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              image: DecorationImage(
                                image:
                                    Image.network(loadedJobDetails['images'][0])
                                        .image,
                                fit: BoxFit.fill,
                                opacity: 0.85,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              loadedJobDetails['title'],
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                backgroundColor: Colors.black54,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              leading: Icon(
                                Icons.apartment_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: const Text(
                                'Organization',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(loadedJobDetails['company-name']),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(0),
                                    leading: Icon(
                                      Icons.location_on,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    title: const Text(
                                      'Location',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle:
                                        Text(loadedJobDetails['location']),
                                  ),
                                ),
                                Expanded(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(0),
                                    leading: Icon(
                                      Icons.date_range_rounded,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    title: const Text(
                                      'Date',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle:
                                        Text(loadedJobDetails['location']),
                                  ),
                                ),
                              ],
                            ),
                            // const SizedBox(height: 10),
                            ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              leading: Icon(
                                Icons.phone_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: const Text(
                                'Contacts',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  loadedJobDetails['company-contacts']
                                      .join(' / ')),
                            ),
                            const SizedBox(height: 25),
                            Text(
                              'Details',
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              loadedJobDetails['details'],
                              style: GoogleFonts.poppins(
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const MyBackButton(),
              ],
            ),
          );
  }
}
