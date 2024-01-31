import 'dart:developer';
import 'package:flutter/material.dart';

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
      if (value.runtimeType == double ||
          value.runtimeType == int ||
          value.runtimeType == String) {
        continue;
      }
      barData.add(
        IndividualBar(
          x: value['x'],
          y: value['toY'],
          barColor: Color(value['color']),
        ),
      );
    }

    maxY = rawDataMap['maxY'];
  }

  void initializeEngagementBarData() {
    final dataEntries = rawDataMap.entries.toList();
    for (var entry in dataEntries) {
      if (entry.value.runtimeType == int ||
          entry.value.runtimeType == double ||
          entry.value.runtimeType == String) {
        continue;
      }
      log(entry.value.runtimeType.toString());

      engagementBarData.add(
        IndividualBar(
          x: dataEntries.indexOf(entry),
          y: [
            entry.value['user-engagement']
          ], // Individual Bar takes a list as it's 'y' field
          barColor: Color(entry.value['color']),
        ),
      );
      maxEngagement = rawDataMap['maxEngagement'];
    }
    log('engagement data length: ${engagementBarData.length}');
  }
}
