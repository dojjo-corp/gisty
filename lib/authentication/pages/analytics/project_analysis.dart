import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/ListTiles/analytics_tile.dart';
import 'package:gt_daily/authentication/components/buttons/custom_back_button.dart';
import 'package:gt_daily/authentication/pages/analytics/bar_graph.dart';

import '../../components/loading_circle.dart';
import '../../helper_methods.dart/analytics.dart';

class AllProjectsAnalytics extends StatefulWidget {
  const AllProjectsAnalytics({
    super.key,
  });

  @override
  State<AllProjectsAnalytics> createState() => _AllProjectsAnalyticsState();
}

class _AllProjectsAnalyticsState extends State<AllProjectsAnalytics> {
  bool _isLoading = true;
  bool isOverallAnalytics = true;
  late Map<String, dynamic> mapForChart;

  @override
  void initState() {
    super.initState();
    getOverallAnalyticsChart(context)?.then((value) {
      mapForChart = value;
      setState(() {
        _isLoading = false;
      });
    }).onError(
      (error, stackTrace) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              error.toString(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final categoryEngagementData = getCategoryEngagementData(mapForChart);

    return _isLoading
        ? const LoadingCircle()
        : Scaffold(
            body: Stack(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 100.0, right: 15, left: 15),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            'All Projects Analytics',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 200,
                            child: MyBarGraph(
                              rawDataMap: mapForChart,
                              isOverallAnalytics: isOverallAnalytics,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AnalyticsTile(
                            title: 'Total Projects',
                            subtitile: mapForChart['total-projects'].toString(),
                            trailing: null,
                          ),
                          AnalyticsTile(
                            title: 'Total Impressions',
                            subtitile:
                                mapForChart['total-impressions'].toString(),
                            trailing: null,
                          ),
                          AnalyticsTile(
                            title: 'Total Saves',
                            subtitile: mapForChart['total-saves'].toString(),
                            trailing: null,
                          ),
                          AnalyticsTile(
                            title: 'Total Comments',
                            subtitile: mapForChart['total-comments'].toString(),
                            trailing: null,
                          ),
                          AnalyticsTile(
                            title: 'Total Downloads',
                            subtitile:
                                mapForChart['total-downloads'].toString(),
                            trailing: null,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const MyBackButton(),
                Positioned(
                  top: 50,
                  right: 5,
                  child: Switch(
                    activeColor: const Color.fromARGB(255, 75, 125, 200),
                    value: isOverallAnalytics,
                    onChanged: (value) {
                      setState(() {
                        isOverallAnalytics = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          );
  }
}

Map<String, num> getCategoryEngagementData(Map<String, dynamic> rawDataMap) {
  Map<String, num> categoryEngagementSum = {};
  for (var entry in rawDataMap.entries) {
    if (entry.value.runtimeType == double || entry.value.runtimeType == int) {
      continue;
    }
    categoryEngagementSum[entry.key] = entry.value['user-engagement'];
  }
  return categoryEngagementSum;
}
