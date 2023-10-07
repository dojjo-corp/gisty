import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/custom_back_button.dart';

import 'bar_graph.dart';

class AllProjectsAnalytics extends StatefulWidget {
  final Map<String, dynamic> rawData;
  const AllProjectsAnalytics({
    super.key,
    required this.rawData,
  });

  @override
  State<AllProjectsAnalytics> createState() => _AllProjectsAnalyticsState();
}

class _AllProjectsAnalyticsState extends State<AllProjectsAnalytics> {
  @override
  Widget build(BuildContext context) {
    final data = widget.rawData;

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100.0, right: 15, left: 15),
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
                    Center(
                      child: SizedBox(
                        height: 400,
                        child: MyBarGraph(
                          rawDataMap: data,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            top: 40,
            left: 5,
            child: MyBackButton(),
          )
        ],
      ),
    );
  }
}
