import 'dart:developer';

import 'individual_bar.dart';

class BarData {
  final Map<String, dynamic> rawDataMap;

  BarData({required this.rawDataMap});

  List<IndividualBar> engagementBarData = [];
  List<IndividualBar> barData = [];
  double maxY = 0;
  double maxEngagement = 0;

  void initializeBarData() {
    for (var value in rawDataMap.values.toList()) {
      if (value.runtimeType == double || value.runtimeType == int) {
        continue;
      }
      barData.add(
        IndividualBar(
          x: value['x'],
          y: value['toY'],
          barColor: value['color'],
        ),
      );
    }

    maxY = rawDataMap['maxY'];
  }

  void initializeEngagementBarData() {
    final dataEntries = rawDataMap.entries.toList();
    for (var entry in dataEntries) {
      if (entry.value.runtimeType == int || entry.value.runtimeType == double) {
        log(entry.key);
        continue;
      }
      log('After number check');

      engagementBarData.add(
        IndividualBar(
          x: dataEntries.indexOf(entry),
          y: [
            entry.value['user-engagement']
          ], // Individual Bar takes a list as it's 'y' field
          barColor: entry.value['color'],
        ),
      );
      maxEngagement = rawDataMap['maxEngagement'];
    }
    log('engagement data length: ${engagementBarData.length}');
  }
}
