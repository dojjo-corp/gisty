import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/custom_back_button.dart';
import '../../helper_methods.dart/analytics.dart';

class ProjectAnalytics extends StatelessWidget {
  final String pid;
  const ProjectAnalytics({super.key, required this.pid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100, left: 15, right: 15, bottom: 10),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('All Projects')
                      .doc(pid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: Text('Loading...'));
                    }

                    if (snapshot.hasError) {
                      return Center(
                          child: Text(
                              'Error Loading Chart Data: ${snapshot.error}'));
                    }

                    final projectData = snapshot.data!.data()!;
                    final numComments =
                        projectData['comments'].length.toDouble();
                    final double numSaved =
                        projectData['saved'].length.toDouble();
                    final double numDownloaded =
                        projectData['downloaded-by'].length.toDouble();
                    // IMPRESSIONS
                    final impressionsData = projectData['impressions'];
                    final nLikes = impressionsData['like'].length;
                    final nSupport = impressionsData['support'].length;
                    final nCelebrate = impressionsData['celebrate'].length;
                    final nInsightful = impressionsData['insightful'].length;
                    final double numImpressions =
                        (nLikes + nSupport + nInsightful + nCelebrate)
                            .toDouble();

                    final barDataList = [
                      {'0': numImpressions},
                      {'1': numSaved},
                      {'2': numDownloaded},
                      {'3': numComments},
                    ];
                    final maxY = sum([numImpressions, numSaved, numDownloaded]);
                    return ListView(
                      children: [
                        Text(
                          'Project Analytics',
                          style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            // get maxY from the sum of all barData
                            BarChartData(
                              maxY: maxY,
                              barGroups: barDataList
                                  .map(
                                    (e) => BarChartGroupData(
                                      x: barDataList.indexOf(e),
                                      barRods: [
                                        BarChartRodData(
                                            toY: e.values.first,
                                            backDrawRodData:
                                                BackgroundBarChartRodData(
                                              show: true,
                                              toY: maxY,
                                              color: Colors.grey,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            width: 25,
                                            color: Colors.blueGrey[200]),
                                      ],
                                    ),
                                  )
                                  .toList(),
                              groupsSpace: 25,
                              alignment: BarChartAlignment.center,
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: const FlTitlesData(
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget:
                                              getBottomTitlesForSingleProject))),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: ListTile(
                                title: const Text('Impressions'),
                                trailing: Text(
                                  numImpressions.toInt().toString(),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                tileColor: Colors.grey[300],
                              ),
                            ),
                            const SizedBox(height: 4),
                            ListTile(
                              title: const Text('Saves'),
                              trailing: Text(
                                numSaved.toInt().toString(),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              tileColor: Colors.grey[300],
                            ),
                            const SizedBox(height: 4),
                            ListTile(
                              title: const Text('Downloads'),
                              trailing: Text(
                                numDownloaded.toInt().toString(),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              tileColor: Colors.grey[300],
                            ),
                            const SizedBox(height: 4),
                            ListTile(
                              title: const Text('Comments'),
                              trailing: Text(
                                numComments.toInt().toString(),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              tileColor: Colors.grey[300],
                            ),
                          ],
                        )
                      ],
                    );
                  }),
            ),
          ),
          const MyBackButton()
        ],
      ),
    );
  }
}

sum(List<double> list) {
  double total = 0;
  for (var number in list) {
    total += number;
  }
  return total;
}
