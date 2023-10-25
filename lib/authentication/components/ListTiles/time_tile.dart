import 'package:flutter/material.dart';

class TimeTile extends StatefulWidget {
  const TimeTile({super.key});

  @override
  State<TimeTile> createState() => _TimeTileState();
}

class _TimeTileState extends State<TimeTile> {
  Color timeIconColor = Colors.grey;
  String timeText = 'Set Time';
  @override
  Widget build(BuildContext context) {
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
String n = const Stl().word;


class Stl extends StatelessWidget {
  final String word = 'Word';
  const Stl({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}