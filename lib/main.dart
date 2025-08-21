import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

  Future<Position> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return;

      final Position position = await _getLocation();
      
      setState(() {
        records.add(PhotoRecord(
          imagePath: photo.path,
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: records.isEmpty
          ? const Center(
              child: Text('尚未有任何照片記錄'),
            )
          : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Image.file(
                        File(record.imagePath),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '拍攝時間: ${record.timestamp.toString()}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              '位置: ${record.latitude}, ${record.longitude}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        tooltip: '拍照',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class PhotoRecord {
  final String imagePath;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  PhotoRecord({
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
}
