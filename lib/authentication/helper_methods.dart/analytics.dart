// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/providers/projects_provider.dart';
import 'package:provider/provider.dart';

import '../pages/analytics/bar_graph.dart';


// BOTTOM TITLES FOF SINGLE PROJECT ANALYTICS CHART
Widget getBottomTitlesForSingleProject(double value, TitleMeta meta) {
  const style =
      TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14);

  Widget text;
  String tooltip;
  switch (value.toInt()) {
    case 0:
      text = const Text('I', style: style);
      tooltip = 'Impressions';
      break;
    case 1:
      text = const Text('S', style: style);
      tooltip = 'Saves';
      break;
    case 2:
      text = const Text('D', style: style);
      tooltip = 'Downloads';
      break;
    case 3:
      text = const Text('C', style: style);
      tooltip = 'Comments';
      break;

    default:
      text = const Text('', style: style);
      tooltip = '';
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Tooltip(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blueGrey[100],
      ),
      message: tooltip,
      textStyle: TextStyle(color: Colors.grey[700]),
      triggerMode: TooltipTriggerMode.tap,
      child: text,
    ),
  );
}

// BOTTOM TITLES FOF ALL PROJECTS ANALYTICS CHART
Widget getBottomTitlesForAllProjects(
    BuildContext _context, double value, TitleMeta meta) {
  Widget image;
  String tooltip;
  final categoryMap = _context.read<ProjectProvider>().categoryMap;
  final categoryNames = categoryMap.keys.toList();
  switch (value.toInt()) {
    case 0:
      image = Image.asset(categoryMap[categoryNames[0]]['image'], height: 15);
      tooltip = categoryNames[0];
      break;
    case 1:
      image = Image.asset(categoryMap[categoryNames[1]]['image'], height: 15);
      tooltip = categoryNames[1];
      break;
    case 2:
      image = Image.asset(categoryMap[categoryNames[2]]['image'], height: 15);
      tooltip = categoryNames[2];
      break;
    case 3:
      image = Image.asset(categoryMap[categoryNames[3]]['image'], height: 15);
      tooltip = categoryNames[3];
      break;
    case 4:
      image = Image.asset(categoryMap[categoryNames[4]]['image'], height: 15);
      tooltip = categoryNames[4];
      break;
    case 5:
      image = Image.asset(categoryMap[categoryNames[5]]['image'], height: 15);
      tooltip = categoryNames[5];
      break;
    case 6:
      image = Image.asset(categoryMap[categoryNames[6]]['image'], height: 15);
      tooltip = categoryNames[6];
      break;
    case 7:
      image = Image.asset(categoryMap[categoryNames[7]]['image'], height: 15);
      tooltip = categoryNames[7];
      break;
    case 8:
      image = Image.asset(categoryMap[categoryNames[8]]['image'], height: 15);
      tooltip = categoryNames[8];
      break;

    default:
      image = Image.asset(categoryMap[categoryNames[0]]['image'], height: 15);
      tooltip = '';
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Tooltip(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blueGrey[100],
      ),
      message: tooltip,
      textStyle: TextStyle(color: Colors.grey[700]),
      triggerMode: TooltipTriggerMode.tap,
      child: image,
    ),
  );
}


// ALL PROJECT ANALYTICS CHART
Widget? getOverallAnalyticsChart(BuildContext _context) {
  return StreamBuilder(
    stream: FirebaseFirestore.instance.collection('All Projects').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const SizedBox(height: 50, child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Text('Error Loading Data: ${snapshot.error}');
      }

      final docs = snapshot.data!.docs;
      final allProjectsData = [];
      for (var doc in docs) {
        allProjectsData.add(doc.data());
      }

      Map<String, dynamic> mapToUse = {};
      final categoryMap = _context.watch<ProjectProvider>().categoryMap;
      final categoryNames = categoryMap.keys.toList();
      final categoryData = categoryMap.values.toList();
      double saved = 0, downloads = 0, comments = 0, impressionsSum = 0;

      for (int i = 0; i < categoryNames.length; i++) {
        // get list of all projects in each category
        final listForCategory = allProjectsData
            .where(
              (element) =>
                  element['category'].toLowerCase() ==
                  categoryNames[i].toLowerCase(),
            )
            .toList();

        // get required analytics data for each project under a category
        for (var item in listForCategory) {
          // calculate sum of impressions given for project
          final impressions = item['impressions'].values.toList();
          impressionsSum += sum(impressions);
          saved += item['saved'].length;
          downloads += item['downloaded-by'].length;
          comments += item['comments'].length;
        }

        // store analytics data
        mapToUse[categoryNames[i]] = {
          'toY': [
            saved,
            downloads,
            comments,
            impressionsSum,
          ],
          'x': i,
          'color': categoryData[i]['color'],
        };
      }
      return MyBarGraph(
        rawDataMap: mapToUse,
      );
    },
  );
}

double sum(List values) {
  double sum = 0;
  for (var value in values) {
    sum += value.length;
  }
  return sum;
}


// BOTOM