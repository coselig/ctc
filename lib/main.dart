import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '工地照片記錄',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PhotoRecordPage(title: '工地照片記錄'),
    );
  }
}

class PhotoRecordPage extends StatefulWidget {
  const PhotoRecordPage({super.key, required this.title});
  final String title;

  @override
  State<PhotoRecordPage> createState() => _PhotoRecordPageState();
}

class _PhotoRecordPageState extends State<PhotoRecordPage> {
  List<PhotoRecord> records = [];
  final ImagePicker _picker = ImagePicker();
  Offset? selectedPoint;
  PhotoRecord? selectedRecord;

  Future<void> _takePicture(Offset point) async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return;
      
      setState(() {
        final record = PhotoRecord(
          imagePath: photo.path,
          point: point,
          timestamp: DateTime.now(),
        );
        records.add(record);
        selectedRecord = record;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  PhotoRecord? _findNearestRecord(Offset point) {
    const double threshold = 20.0; // 點擊容差範圍
    PhotoRecord? nearest;
    double minDistance = double.infinity;

    for (var record in records) {
      final distance = (record.point - point).distance;
      if (distance < threshold && distance < minDistance) {
        minDistance = distance;
        nearest = record;
      }
    }

    return nearest;
  }

  void _handleTapUp(TapUpDetails details) {
    final nearest = _findNearestRecord(details.localPosition);
    
    setState(() {
      if (nearest != null) {
        // 如果點擊位置附近有existing標記，就顯示該照片
        selectedRecord = nearest;
        selectedPoint = nearest.point;
      } else {
        // 如果是新位置，就拍新照片
        selectedPoint = details.localPosition;
        selectedRecord = null;
        _takePicture(details.localPosition);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: GestureDetector(
                onTapUp: _handleTapUp,
                child: Stack(
                  children: [
                    // 底圖
                    Image.asset(
                      'assets/floorplan.png',
                      fit: BoxFit.contain,
                    ),
                    // 繪製標記點
                    CustomPaint(
                      painter: MarkerPainter(
                        records: records,
                        selectedPoint: selectedPoint,
                        selectedRecord: selectedRecord,
                      ),
                      child: Container(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (selectedRecord != null) Expanded(
            flex: 1,
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: Image.file(
                      File(selectedRecord!.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '拍攝時間: ${selectedRecord!.timestamp}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MarkerPainter extends CustomPainter {
  final List<PhotoRecord> records;
  final Offset? selectedPoint;
  final PhotoRecord? selectedRecord;

  MarkerPainter({
    required this.records,
    this.selectedPoint,
    this.selectedRecord,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 繪製所有記錄點
    final dotPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 10
      ..style = PaintingStyle.fill;

    for (var record in records) {
      if (record == selectedRecord) {
        dotPaint.color = Colors.green;
      } else {
        dotPaint.color = Colors.red;
      }
      canvas.drawCircle(record.point, 8, dotPaint);
    }

    // 繪製選中的點
    if (selectedPoint != null) {
      final selectedPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 10
        ..style = PaintingStyle.fill;
      canvas.drawCircle(selectedPoint!, 8, selectedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MarkerPainter oldDelegate) {
    return oldDelegate.records != records ||
        oldDelegate.selectedPoint != selectedPoint ||
        oldDelegate.selectedRecord != selectedRecord;
  }
}

class PhotoRecord {
  final String imagePath;
  final Offset point;
  final DateTime timestamp;

  PhotoRecord({
    required this.imagePath,
    required this.point,
    required this.timestamp,
  });
}