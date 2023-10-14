import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gt_daily/authentication/components/custom_back_button.dart';

import '../../helper_methods.dart/analytics.dart';

class AllProjectsAnalytics extends StatefulWidget {
  const AllProjectsAnalytics({
    super.key,
  });

  @override
  State<AllProjectsAnalytics> createState() => _AllProjectsAnalyticsState();
}

class _AllProjectsAnalyticsState extends State<AllProjectsAnalytics> {
  @override
  Widget build(BuildContext context) {

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
                        height: 200,
                        child: getOverallAnalyticsChart(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const MyBackButton()
        ],
      ),
    );
  }
}
