import 'dart:convert';
import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/helper_methods.dart/analytics.dart';

import 'bar_data.dart';

class MyBarGraph extends StatefulWidget {
  final Map<String, dynamic> rawDataMap;
  final bool isOverallAnalytics;

  const MyBarGraph({
    super.key,
    required this.rawDataMap,
    required this.isOverallAnalytics,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  @override
  Widget build(BuildContext context) {
    final rawDataMap = widget.rawDataMap;
    // initialize barData
    BarData myBarData = BarData(rawDataMap: rawDataMap);
    myBarData.initializeBarData();
    myBarData.initializeEngagementBarData();

    log(jsonEncode(myBarData.maxEngagement));
    // todo: Inidvidual Engagements (impressions, saves, downloads and comments) as Separate Bars
    BarChartData getOverallAnalyticsBarChart() {
      return BarChartData(
        maxY: myBarData.maxY,
        minY: 0,
        barGroups: myBarData.barData.map(
          (data) {
            // y field of this Individual Bar has four values, hence the iteration
            final barRods = data.y
                .map(
                  (y) => BarChartRodData(
                    toY: y.toDouble(),
                    color: data.barColor,
                    width: 6,
                    backDrawRodData: BackgroundBarChartRodData(
                      show: false,
                      color: Colors.grey[300]?.withOpacity(0.5),
                      toY: myBarData.maxY,
                    ),
                  ),
                )
                .toList();
            return BarChartGroupData(
              x: data.x,
              barRods: barRods,
            );
          },
        ).toList(),
        barTouchData: getTooltips(),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return getBottomTitlesForAllProjects(context, value, meta);
                }),
          ),
        ),
      );
    }

    // todo: All Engagements Put Together As Single Bars
    BarChartData getCategoryEngagementBarChart() {
      return BarChartData(
        maxY: myBarData.maxEngagement,
        minY: 0,
        barGroups: myBarData.engagementBarData
            .map(
              (engagementBar) => BarChartGroupData(
                x: engagementBar.x,
                barRods: [
                  BarChartRodData(
                    // since the y field of this Individual Bar has only one element, only the [first] element holds value
                    toY: engagementBar.y.first.toDouble(),
                    color: engagementBar.barColor,
                    borderRadius: BorderRadius.circular(4),
                    width: 20,
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      color: Colors.grey[300]?.withOpacity(0.5),
                      toY: myBarData.maxEngagement,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
        barTouchData: getSingleTooltips(),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return getBottomTitlesForAllProjects(context, value, meta);
                }),
          ),
        ),
      );
    }

    return BarChart(widget.isOverallAnalytics
        ? getOverallAnalyticsBarChart()
        : getCategoryEngagementBarChart());
  }

  BarTouchData getTooltips() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.blueGrey,
        tooltipHorizontalAlignment: FLHorizontalAlignment.right,
        fitInsideHorizontally: true,
        tooltipMargin: -10,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          String engagementType;
          switch (rodIndex) {
            case 0:
              engagementType = 'Saves';
              break;
            case 1:
              engagementType = 'Downloads';
              break;
            case 2:
              engagementType = 'Comments';
              break;
            case 3:
              engagementType = 'Impressions';
              break;
            default:
              throw Error();
          }
          return BarTooltipItem(
            '$engagementType\n',
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            children: <TextSpan>[
              TextSpan(
                text: (rod.toY.toInt()).toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Gets tooltips to display for chart with single bars per category
  BarTouchData getSingleTooltips() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.blueGrey,
        tooltipHorizontalAlignment: FLHorizontalAlignment.right,
        fitInsideHorizontally: true,
        tooltipMargin: -10,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          
          return BarTooltipItem(
            'Total Engagements\n',
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            children: <TextSpan>[
              TextSpan(
                text: (rod.toY.toInt()).toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double sum(List<double> values) {
    double sum = 0;
    for (var value in values) {
      sum += value;
    }
    return sum;
  }
}
