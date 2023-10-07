import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'bar_data.dart';

class MyBarGraph extends StatefulWidget {
  final Map<String,dynamic> rawDataMap;
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
    BarData myBarData = BarData(rawDataMap: widget.rawDataMap
    );
    myBarData.initializeBarData();
    return BarChart(
      BarChartData(
        // get max y  from sum of all likes
        maxY: sum(
          myBarData.barData.map((e) => e.y).toList(),
        ),
        minY: 0,
        barGroups: myBarData.barData
            .map(
              (data) => BarChartGroupData(
                x: data.x,
                barRods: [
                  BarChartRodData(
                      toY: data.y,
                      color: data.barColor,
                      width: 25,
                      borderRadius: BorderRadius.circular(8)),
                ],
              ),
            )
            .toList(),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
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
