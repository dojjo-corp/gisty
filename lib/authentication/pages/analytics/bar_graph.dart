import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gt_daily/authentication/helper_methods.dart/analytics.dart';

import 'bar_data.dart';

class MyBarGraph extends StatefulWidget {
  final Map<String, dynamic> rawDataMap;
  const MyBarGraph({
    super.key,
    required this.rawDataMap,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  @override
  Widget build(BuildContext context) {
    // initialize barData
    BarData myBarData = BarData(rawDataMap: widget.rawDataMap);
    myBarData.initializeBarData();
    return BarChart(
      BarChartData(
        maxY: 10,
        minY: 0,
        groupsSpace: 2,
        barGroups: myBarData.barData.map(
          (data) {
            final barRods = data.y
                .map(
                  (y) => BarChartRodData(
                      toY: y.toDouble(),
                      color: data.barColor,
                      width: 8,
                      borderRadius: BorderRadius.circular(8),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        color: Colors.grey[400],
                        toY: 10,
                      )),
                )
                .toList();
            return BarChartGroupData(
              x: data.x,
              barRods: barRods,
            );
          },
        ).toList(),
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
