import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/loading_circle.dart';

import '../../components/buttons/custom_back_button.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventId;
  const EventDetailsPage({super.key, required this.eventId});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late Map<String, dynamic> loadedEventDetails;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    loadEventDetails().then((value) {
      setState(() {
        _isLoaded = true;
        loadedEventDetails = value!;
      });
    }).onError((error, stackTrace) {
      setState(() {
        loadedEventDetails = {};
      });
    }).timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        setState(() {
          loadedEventDetails = {};
        });
      },
    );
  }

  /// Retrieves the latest / updated event details from firestore.
  /// Throws an exception if the event document no longer exists
  Future<Map<String, dynamic>?> loadEventDetails() async {
    try {
      /// Holds updated snapshot of event's firestore document
      final snapshot = await FirebaseFirestore.instance
          .collection('All Events')
          .doc(widget.eventId)
          .get();
      if (snapshot.exists) return snapshot.data()!;

      throw 'Event Can Not Be Found';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_isLoaded
        ? const LoadingCircle()
        : Scaffold(
            body: loadedEventDetails.isEmpty
                ? const Center(
                    child: Text('Sorry, Event Details Could Not Be Found'),
                  )
                : Stack(
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
                                        title:
                                            Text(loadedEventDetails['title']),
                                      ),
                                      body: Center(
                                        child: Image.network(
                                          loadedEventDetails['images'][0],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                /// Event Topic - Image
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  height: 260,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[600],
                                    image: DecorationImage(
                                      image: Image.network(
                                              loadedEventDetails['images'][0])
                                          .image,
                                      fit: BoxFit.fill,
                                      opacity: 0.9,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    loadedEventDetails['title'],
                                    style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        backgroundColor: Colors.black54),
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Event Organizers
                                  ListTile(
                                    contentPadding: const EdgeInsets.all(0),
                                    leading: Icon(
                                      Icons.apartment_rounded,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    title: const Text(
                                      'Organizers',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle:
                                        Text(loadedEventDetails['organizers']),
                                  ),

                                  /// Event Location
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.all(0),
                                          leading: Icon(
                                            Icons.location_on,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          title: const Text(
                                            'Location',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(
                                              loadedEventDetails['location']),
                                        ),
                                      ),
                                      Expanded(
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.all(0),
                                          leading: Icon(
                                            Icons.date_range_rounded,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          title: const Text(
                                            'Date',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(
                                              loadedEventDetails['location']),
                                        ),
                                      ),
                                    ],
                                  ),

                                  /// Event Contacts
                                  ListTile(
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
                                        loadedEventDetails['contacts']
                                            .join('/')),
                                  ),

                                  const SizedBox(height: 25),

                                  /// Event details
                                  Text(
                                    'Details',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    loadedEventDetails['details'],
                                    style: GoogleFonts.poppins(
                                      height: 2,
                                      wordSpacing: 2,
                                      // fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    'Event Images',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 200,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (contex, index) {
                                        if (loadedEventDetails['images']
                                                .isEmpty ||
                                            loadedEventDetails['images'] ==
                                                null) {
                                          return const Text('No images');
                                        }

                                        return GestureDetector(
                                          onTap: () =>
                                              Navigator.of(context).push(
                                            MaterialPageRoute(
                                              /// Navigate to a new page to view the image
                                              builder: (context) => Scaffold(
                                                appBar: AppBar(
                                                  title: Text(
                                                      loadedEventDetails[
                                                          'title']),
                                                ),
                                                body: Center(
                                                  child: Image.network(
                                                    loadedEventDetails['images']
                                                        [index],
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
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Image.network(
                                              loadedEventDetails['images']
                                                  [index],
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 10),
                                      itemCount: loadedEventDetails['images']
                                              ?.length ??
                                          0,
                                    ),
                                  ),
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
