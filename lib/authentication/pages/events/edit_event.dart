import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/components/buttons/buttons.dart';
import 'package:gt_daily/authentication/components/loading_circle.dart';
import 'package:gt_daily/authentication/components/textfields/multi_line_textfeld.dart';
import 'package:gt_daily/authentication/components/textfields/simple_textfield.dart';
import 'package:gt_daily/authentication/helper_methods.dart/global.dart';
import 'package:gt_daily/authentication/repository/firestore_repo.dart';

import '../../components/buttons/custom_back_button.dart';
import '../../components/page_title.dart';
import '../../helper_methods.dart/date_and_time.dart';

class EditEventDetailsPage extends StatefulWidget {
  final String eventId;
  const EditEventDetailsPage({super.key, required this.eventId});

  @override
  State<EditEventDetailsPage> createState() => _EditEventDetailsPageState();
}

class _EditEventDetailsPageState extends State<EditEventDetailsPage> {
  bool _dataLoaded = false;
  bool _isLoading = false;
  final eventTitleController = TextEditingController();
  final organizersController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactController = TextEditingController();

  late String dateText;
  Color dateIconColor = Colors.grey;

  Color timeIconColor = Colors.grey;
  late String timeText;

  @override
  initState() {
    super.initState();
    loadEventDetails().then((value) {
      setState(() {
        _dataLoaded = true;
        eventTitleController.text = value['title'];
        organizersController.text = value['organizers'];
        locationController.text = value['location'];
        contactController.text = value['contacts'].join(', ');
        descriptionController.text = value['details'];
        dateText = value['event-date'];
        timeText = value['event-time'];
      });
    });
  }

  Future<Map<String, dynamic>> loadEventDetails() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('All Events')
          .doc(widget.eventId)
          .get();
      if (!snapshot.exists) throw 'Event Details Not Found';
      return snapshot.data()!;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_dataLoaded
        ? const LoadingCircle()
        : Scaffold(
            floatingActionButton:
                _isLoading ? const LinearProgressIndicator() : null,
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 100, left: 15, right: 15, bottom: 10),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PageTitle(title: 'Edit Event'),
                          Text(
                            'Event Title',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SimpleTextField(
                            controller: eventTitleController,
                            hintText: 'Event Title',
                            iconData: Icons.title,
                            isWithIcon: true,
                            autofillHints: null,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Organizers',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SimpleTextField(
                            controller: organizersController,
                            hintText: 'Organizers',
                            iconData: Icons.groups_2_rounded,
                            isWithIcon: true,
                            autofillHints: null,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Location',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SimpleTextField(
                            controller: locationController,
                            hintText: 'Location',
                            iconData: Icons.location_on_rounded,
                            isWithIcon: true,
                            autofillHints: null,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Contacts',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SimpleTextField(
                            controller: contactController,
                            hintText: 'Contacts',
                            iconData: Icons.phone_rounded,
                            isWithIcon: true,
                            autofillHints: null,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Event Date',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          getDateTile(),
                          const SizedBox(height: 5),
                          Text(
                            'Event Time',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          getTimeTile(),
                          const SizedBox(height: 5),
                          Text(
                            'Description',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          MultiLineTextField(
                            controller: descriptionController,
                            hintText: 'Description',
                            maxLines: 20,
                          ),
                          const SizedBox(height: 20),
                          MyButton(
                            onPressed: uploadChanges,
                            btnText: 'Saved Changes',
                            isPrimary: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const MyBackButton()
              ],
            ),
          );
  }

  // todo: Convenience Methods
  /// Uplad changes
  void uploadChanges() async {
    /// Get contact(s).
    /// Multiple contacts can only be retreived if they're separated by '/' or ','
    List<String> contacts;
    if (contactController.text.characters.contains(',')) {
      contacts = contactController.text.trim().split(',');
    } else if (contactController.text.characters.contains('/')) {
      contacts = contactController.text.trim().split('/');
    } else {
      contacts = [contactController.text.trim()];
    }

    final Map<String, dynamic> eventDetails = {
      'title': eventTitleController.text.trim(),
      'organizers': organizersController.text.trim(),
      'location': locationController.text.trim(),
      'details': descriptionController.text.trim(),
      'contacts': contacts,
      'event-date': dateText,
      'event-time': timeText,
    };

    setState(() {
      _isLoading = true;
    });
    try {
      await FirestoreRepo()
          .updateEvents(eventDetails: eventDetails, id: widget.eventId);

      if (mounted) {
        showSnackBar(context, 'Success!');
        Navigator.pop(context);
      }
    } catch (e) {
      showSnackBar(
        context,
        'Error Uploading Changes: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget getDateTile() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2023),
          lastDate: DateTime(2030, 12, 31),
        );
        if (date != null) {
          final dateTextRaw = date.toString().split(' ')[0];
          // get month in text format. Example: 1 == 'Jan'
          String month = ', ${formatMonth(date.month)} ';
          final splitText = dateTextRaw.split('-');
          // replace month num with month text
          splitText.replaceRange(1, 2, [month]);
          // concatenate list
          final dateFormatted = splitText.join();

          setState(() {
            dateText = dateFormatted;
            dateIconColor = Theme.of(context).primaryColor;
          });
        }
      },
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[100]!),
        ),
        tileColor: Colors.white,
        leading: Icon(
          Icons.calendar_month_rounded,
          color: dateIconColor,
        ),
        title: Text(dateText),
      ),
    );
  }

  Widget getTimeTile() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (time != null) {
          setState(() {
            timeText =
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
            timeIconColor = Theme.of(context).primaryColor;
          });
        }
      },
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[100]!),
        ),
        tileColor: Colors.white,
        leading: Icon(
          Icons.timer_rounded,
          color: timeIconColor,
        ),
        title: Text(timeText),
      ),
    );
  }
}
