import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerWidget extends StatelessWidget {
  final String url;
  final String? title;

  const PdfViewerWidget({Key? key, required this.url, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'PDF 預覽'),
      ),
      body: SfPdfViewer.network(url),
    );
  }
}
