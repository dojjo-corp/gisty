import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/loading_circle.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';

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
    }).catchError((e) {
      showSnackBar(context, e.toString());
    });
  }

  Future<Map<String, dynamic>?> loadJobDetails({
    ConnectivityResult? connectionResult,
  }) async {
    try {
      // Throw error if device is not connected to the internet
      if (connectionResult == ConnectivityResult.none) {
        throw 'You are not connected to the internet';
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('All Jobs')
          .doc(widget.jobId)
          .get();
      if (snapshot.exists && snapshot.data()!.isNotEmpty) {
        return snapshot.data()!;
      }
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                backgroundColor: Colors.black87,
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
                            /// Organization
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
                                /// Location
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

                                /// Contacts
                                Expanded(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(0),
                                    leading: Icon(
                                      Icons.phone_rounded,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    title: const Text(
                                      'Contacts',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                        loadedJobDetails['company-contacts']
                                            .join(' / ')),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                /// Deadline
                                Expanded(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(0),
                                    leading: Icon(
                                      Icons.date_range_rounded,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    title: const Text(
                                      'Deadline',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle:
                                        Text(loadedJobDetails['deadline']),
                                  ),
                                ),
                                Expanded(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(0),
                                    leading: Icon(
                                      Icons.work_rounded,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    title: const Text(
                                      'Job Type',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle:
                                        Text(loadedJobDetails['job-type']),
                                  ),
                                )
                              ],
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
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Job Images',
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (contex, index) {
                                  if (loadedJobDetails['images'].isEmpty ||
                                      loadedJobDetails['images'] == null) {
                                    return const Text('No images');
                                  }

                                  return GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        /// Navigate to a new page to view the image
                                        builder: (context) => Scaffold(
                                          appBar: AppBar(
                                            title:
                                                Text(loadedJobDetails['title']),
                                          ),
                                          body: Center(
                                            child: Image.network(
                                              loadedJobDetails['images'][index],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      width: 200,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[600],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Image.network(
                                        loadedJobDetails['images'][index],
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 10),
                                itemCount:
                                    loadedJobDetails['images']?.length ?? 0,
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
