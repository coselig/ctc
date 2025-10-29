import 'package:ctc/widgets/cards/pdf_preview_mini.dart';
import 'package:ctc/widgets/pdf_viewer_widget.dart';
import 'package:flutter/material.dart';

class PdfCard extends StatelessWidget {
  final String pdfName;
  final String title;
  const PdfCard({
    Key? key,
    required this.pdfName,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(0, 0, 0, 0),
      elevation: 4,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PdfViewerWidget(fileName: pdfName, title: title),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: PdfPreviewMini(fileName: pdfName),
            ),
          ),
        ),
      ),
    );
  }
}
