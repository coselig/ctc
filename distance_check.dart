import 'dart:math';

void main() {
  // 您的實際座標
  double yourLat = 24.202445;
  double yourLng = 120.655053;
  
  // 我之前設定的座標
  double oldLat = 24.1886;
  double oldLng = 120.6875;
  
  // 更新後的座標
  double newLat = 24.202445;
  double newLng = 120.655053;
  
  // 計算距離 (使用 Haversine 公式)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // 地球半徑 (公尺)
    
    double dLat = (lat2 - lat1) * (pi / 180);
    double dLon = (lon2 - lon1) * (pi / 180);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) * cos(lat2 * (pi / 180)) *
        sin(dLon / 2) * sin(dLon / 2);
        
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  double oldDistance = calculateDistance(yourLat, yourLng, oldLat, oldLng);
  double newDistance = calculateDistance(yourLat, yourLng, newLat, newLng);
  
  print('=== 座標距離計算 ===');
  print('您的實際位置: ($yourLat, $yourLng)');
  print('舊的設定座標: ($oldLat, $oldLng)');
  print('新的設定座標: ($newLat, $newLng)');
  print('');
  print('與舊座標的距離: ${oldDistance.toStringAsFixed(1)} 公尺');
  print('與新座標的距離: ${newDistance.toStringAsFixed(1)} 公尺');
  print('');
  if (oldDistance > 100) {
    print('❌ 舊座標超出100公尺範圍，難怪無法偵測！');
  }
  if (newDistance <= 100) {
    print('✅ 新座標在100公尺範圍內，應該可以正常偵測！');
  }
}