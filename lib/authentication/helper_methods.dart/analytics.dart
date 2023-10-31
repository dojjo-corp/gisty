// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously, unused_import

import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/providers/connectivity_provider.dart';
import 'package:gt_daily/authentication/providers/projects_provider.dart';
import 'package:provider/provider.dart';

// todo BOTTOM TITLES FOF SINGLE PROJECT ANALYTICS CHART
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

// todo BOTTOM TITLES FOR ALL PROJECTS ANALYTICS CHART
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

// todo ALL PROJECT ANALYTICS DATA
Future<Map<String, dynamic>>? getOverallAnalyticsChart(
    BuildContext _context) async {
  // take maximum of 15 seconds to load all data from firestore
  final docs = await FirebaseFirestore.instance
      .collection('All Projects')
      .get()
      .timeout(const Duration(seconds: 30), onTimeout: () {
    final connectionState =
        Provider.of<ConnectivityProvider>(_context, listen: false)
            .connectivityResult;
    if (connectionState == ConnectivityResult.none) {
      throw 'Unable to load analytics data\nCheck your internet connection';
    }
    throw 'Some error occured when loading analytics data';
  });

  // store all projects data in a list
  final allProjectsData = [];
  for (var doc in docs.docs) {
    allProjectsData.add(doc.data());
  }

  // store analytics data for each project category
  Map<String, dynamic> mapToUse = {};
  final categoryMap =
      Provider.of<ProjectProvider>(_context, listen: false).categoryMap;
  final categoryNames = categoryMap.keys.toList();
  final categoryData = categoryMap.values.toList();
  List<int> industryImpressions =
      []; // for finding category with the highest impressions from industry professionals
  List engagements = []; // for finding category with highest engagement
  List maxYs =
      []; // For finding the maxY value to use for the multiple-rod chart.

  // ignore: unused_local_variable
  double maxY = 0;
  int totalProjectsNum = 0;
  int totalSaves = 0,
      totalDownloads = 0,
      totalComments = 0,
      totalImpressions = 0;

  for (int i = 0; i < categoryNames.length; i++) {
    double saved = 0, downloads = 0, comments = 0, impressionsSum = 0;

    // get list of all projects in each category
    final listForCategory = allProjectsData
        .where(
          (element) =>
              element['category'].toLowerCase() ==
              categoryNames[i].toLowerCase(),
        )
        .toList();

    // add up to total number of projects
    totalProjectsNum += listForCategory.length;

    // get required analytics data for each project under a category
    for (var project in listForCategory) {
      // calculate sum of impressions given for project
      final impressions = project['impressions'].values.toList();
      impressionsSum += sum(impressions);

      // Number of impressions from industry professionals
      industryImpressions.add(project['industry-impressions-sum'] ?? 0);

      // sum of saved
      saved += project['saved'].length;
      // downloads
      downloads += project['downloaded-by'].length;
      // comments
      comments += project['comments'].length;
    }

    // sum of total engagement for category
    final engagementSum = saved + downloads + comments + impressionsSum;
    totalSaves += saved.toInt();
    totalDownloads += downloads.toInt();
    totalComments += comments.toInt();
    totalImpressions += impressionsSum.toInt();

    // maxY for barchart with individual engagement bars
    maxY = getMax([saved, downloads, comments, impressionsSum]);

    engagements.add(engagementSum);
    maxYs.add(maxY);

    // store category analytics data
    mapToUse[categoryNames[i]] = {
      'toY': [
        saved,
        downloads,
        comments,
        impressionsSum,
      ],
      'x': i,
      'color': categoryData[i]['color'],
      'user-engagement': engagementSum
    };
  }

  final indexOfIndustryFavoriteCategory = maxYs.indexOf(getMax(maxYs));
  mapToUse['maxY'] = getMax(maxYs);
  mapToUse['maxEngagement'] = getMax(engagements);
  mapToUse['total-projects'] = totalProjectsNum;
  mapToUse['total-saves'] = totalSaves;
  mapToUse['total-downloads'] = totalDownloads;
  mapToUse['total-comments'] = totalComments;
  mapToUse['total-impressions'] = totalImpressions;
  mapToUse['industry-favorite-category'] =
      categoryNames[indexOfIndustryFavoriteCategory];

  return mapToUse;
}

double sum(List values) {
  double sum = 0;
  for (var value in values) {
    sum += value.length;
  }
  return sum;
}

double getMax(List values) {
  double max = 0;
  for (var i = 0; i < values.length; i++) {
    if (values[i].toDouble() > max) {
      max = values[i];
    }
  }
  return max;
}

// BOTOM
