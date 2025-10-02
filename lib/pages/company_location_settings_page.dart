import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// 公司位置設定頁面
class CompanyLocationSettingsPage extends StatefulWidget {
  const CompanyLocationSettingsPage({super.key});

  @override
  State<CompanyLocationSettingsPage> createState() => _CompanyLocationSettingsPageState();
}

class _CompanyLocationSettingsPageState extends State<CompanyLocationSettingsPage> {
  final _companyNameController = TextEditingController(text: '光悅科技股份有限公司');
  final _latitudeController = TextEditingController(text: '25.041875');
  final _longitudeController = TextEditingController(text: '121.566317');
  final _radiusController = TextEditingController(text: '100');
  
  bool _isGettingLocation = false;
  String _currentLocationInfo = '';

  @override
  void dispose() {
    _companyNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  /// 獲取當前位置作為公司位置
  Future<void> _getCurrentLocationForCompany() async {
    try {
      setState(() => _isGettingLocation = true);

      // 檢查權限等...
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showMessage('位置權限被拒絕');
          return;
        }
      }

      // 獲取位置
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
      });

      // 獲取地址信息
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          final placemark = placemarks[0];
          final address = [
            placemark.street,
            placemark.subLocality,
            placemark.locality,
          ].where((part) => part != null && part.isNotEmpty).join(', ');
          
          setState(() {
            _currentLocationInfo = address;
          });
        }
      } catch (e) {
        setState(() {
          _currentLocationInfo = '地址解析失敗';
        });
      }

      _showMessage('已獲取當前位置');

    } catch (e) {
      _showMessage('獲取位置失敗: $e');
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _saveSettings() {
    // TODO: 儲存到資料庫或 SharedPreferences
    _showMessage('公司位置設定已儲存');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('公司位置設定'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              '儲存',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 說明卡片
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          '地理圍欄設定',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '設定公司位置和範圍，當員工在此範圍內打卡時，'
                      '系統將自動顯示公司名稱而非具體地址。',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 公司名稱
            TextField(
              controller: _companyNameController,
              decoration: const InputDecoration(
                labelText: '公司名稱',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),

            // 位置資訊
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: '緯度',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.place),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(
                      labelText: '經度',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 獲取當前位置按鈕
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGettingLocation ? null : _getCurrentLocationForCompany,
                icon: _isGettingLocation 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
                label: Text(_isGettingLocation ? '定位中...' : '使用當前位置'),
              ),
            ),
            const SizedBox(height: 8),

            // 當前位置資訊
            if (_currentLocationInfo.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, 
                             size: 16, 
                             color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          '當前位置',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentLocationInfo,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 範圍半徑
            TextField(
              controller: _radiusController,
              decoration: const InputDecoration(
                labelText: '範圍半徑 (公尺)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.radio_button_unchecked),
                suffixText: 'm',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // 範圍說明
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, 
                           size: 16, 
                           color: Colors.orange.shade700),
                      const SizedBox(width: 4),
                      Text(
                        '範圍建議',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• 小型辦公室：50-100公尺\n'
                    '• 中型建築：100-200公尺\n'
                    '• 大型園區：200-500公尺',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}