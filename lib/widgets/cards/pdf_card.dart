import 'package:ctc/widgets/pdf_viewer_widget.dart';
import 'package:flutter/material.dart';

class PdfCard extends StatelessWidget {
  final String pdfName;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final String? buttonText;

  const PdfCard({
    Key? key,
    required this.pdfName,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ?? () {
          Navigator.push(
            context,
            MaterialPageRoute(
                  builder: (context) =>
                      PdfViewerWidget(fileName: pdfName, title: title),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf, size: 64, color: isDarkMode ? theme.colorScheme.primary : Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              if (buttonText != null)
                ElevatedButton(
                  onPressed: onTap ?? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                            builder: (context) => PdfViewerWidget(
                              fileName: pdfName,
                              title: title,
                            ),
                      ),
                    );
                  },
                  child: Text(buttonText!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
