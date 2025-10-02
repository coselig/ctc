import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// 測試定位功能的獨立頁面
class LocationTestPage extends StatefulWidget {
  const LocationTestPage({super.key});

  @override
  State<LocationTestPage> createState() => _LocationTestPageState();
}

class _LocationTestPageState extends State<LocationTestPage> {
  String _locationStatus = '尚未定位';
  String _coordinates = '';
  String _address = '';
  bool _isLoading = false;

  Future<void> _testLocation() async {
    setState(() {
      _isLoading = true;
      _locationStatus = '正在定位...';
      _coordinates = '';
      _address = '';
    });

    try {
      // 檢查位置服務
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = '❌ 位置服務未啟用';
        });
        return;
      }

      // 檢查權限
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = '❌ 位置權限被拒絕';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = '❌ 位置權限被永久拒絕';
        });
        return;
      }

      // 獲取位置
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      setState(() {
        _coordinates = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        _locationStatus = '✅ 定位成功';
      });

      // 地址解析
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          final placemark = placemarks[0];
          final addressParts = [
            placemark.street,
            placemark.subLocality,
            placemark.locality,
            placemark.administrativeArea,
          ].where((part) => part != null && part.isNotEmpty).toList();
          
          setState(() {
            _address = addressParts.join(', ');
          });
        }
      } catch (e) {
        setState(() {
          _address = '地址解析失敗: $e';
        });
      }

    } catch (e) {
      setState(() {
        _locationStatus = '❌ 定位失敗: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('定位功能測試'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, 
                             color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          '定位測試',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('狀態: $_locationStatus'),
                    const SizedBox(height: 8),
                    if (_coordinates.isNotEmpty) ...[
                      Text('座標: $_coordinates'),
                      const SizedBox(height: 8),
                    ],
                    if (_address.isNotEmpty) ...[
                      Text('地址: $_address'),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _testLocation,
                        child: _isLoading 
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('定位中...'),
                              ],
                            )
                          : const Text('開始定位'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '使用說明',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. 確保已開啟位置服務'),
                    Text('2. 點擊「開始定位」按鈕'),
                    Text('3. 允許應用獲取位置權限'),
                    Text('4. 等待定位完成'),
                    SizedBox(height: 8),
                    Text(
                      '注意：首次使用需要位置權限，請在戶外或窗邊測試以獲得最佳效果。',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}