import 'package:geocoding/geocoding.dart';

void main() async {
  try {
    const address = '406台中市北屯區后庄七街215號';
    print('正在查詢地址: $address');
    
    List<Location> locations = await locationFromAddress(address);
    
    if (locations.isNotEmpty) {
      final location = locations[0];
      print('✅ 找到座標:');
      print('   緯度: ${location.latitude}');
      print('   經度: ${location.longitude}');
      print('   完整資訊: $location');
      
      // 反向地理編碼驗證
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude, 
        location.longitude
      );
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        print('\n🔍 反向地理編碼結果:');
        print('   街道: ${placemark.street}');
        print('   城市: ${placemark.locality}');
        print('   行政區: ${placemark.administrativeArea}');
        print('   國家: ${placemark.country}');
      }
    } else {
      print('❌ 找不到對應的座標');
    }
  } catch (e) {
    print('❌ 錯誤: $e');
  }
}