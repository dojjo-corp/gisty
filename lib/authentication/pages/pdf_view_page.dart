import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<void> loadPDF() async {
    try {
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child('Project Documents/$pdfUrl');

      final tempDir = await getTemporaryDirectory();
      localPDFPath = '${tempDir.path}/my_pdf.pdf';

      await ref.writeToFile(File(localPDFPath));
      setState(() {});
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer from Firebase'),
      ),
      body: localPDFPath.isNotEmpty
          ? PDFView(
              filePath: localPDFPath,
              enableSwipe: true,
              // swipeHorizontal: true,
              autoSpacing: false,
              pageFling: false,
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: PDFViewPage(pdfPath: 'your_pdf_path_in_firebase.pdf'),
  ));
}
