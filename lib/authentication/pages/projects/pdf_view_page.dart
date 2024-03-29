import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import '../../components/buttons/custom_back_button.dart';
import '../../components/loading_circle.dart';

class PDFViewPage extends StatefulWidget {
  final String pdfPath;

  const PDFViewPage({super.key, required this.pdfPath});

  @override
  State<PDFViewPage> createState() => _PDFViewPageState();
}

class _PDFViewPageState extends State<PDFViewPage> {
  late String pdfUrl;
  String localPDFPath = '';

  @override
  void initState() {
    super.initState();
    pdfUrl = widget.pdfPath;
    loadPDF();
  }

  Future<void> loadPDF({
    ConnectivityResult? connectionResult,
  }) async {
    try {
      // Throw error if device is not connected to the internet
      if (connectionResult == ConnectivityResult.none) {
        throw 'You are not connected to the internet';
      }
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child('Project Documents/$pdfUrl');

      final tempDir = await getTemporaryDirectory();
      localPDFPath = '${tempDir.path}/my_pdf.pdf';

      await ref.writeToFile(File(localPDFPath));
      setState(() {});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return localPDFPath.isNotEmpty
        ? Scaffold(
            body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 100, bottom: 10, right: 15, left: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pdfUrl,
                      style: GoogleFonts.poppins(
                          fontSize: 30, fontWeight: FontWeight.bold),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Expanded(
                      child: PDFView(
                        filePath: localPDFPath,
                        enableSwipe: true,
                        // swipeHorizontal: true,
                        autoSpacing: false,
                        pageFling: false,
                      ),
                    ),
                  ],
                ),
              ),
              const MyBackButton()
            ],
          ))
        : const LoadingCircle();
  }
}
