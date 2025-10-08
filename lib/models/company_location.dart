/// 公司位置配置類
class CompanyLocationConfig {
  static const String defaultCompanyName = '光悅科技股份有限公司';
  static const double defaultLatitude = 24.1925295; // 根據實際測試修正的GPS座標
  static const double defaultLongitude = 120.6648565;
  static const double defaultRadius = 80.0; // 80公尺（覆蓋WiFi和手機網路誤差）

  // 預設的公司位置列表
  static const List<CompanyLocation> predefinedLocations = [
    CompanyLocation(
      name: '光悅科技股份有限公司',
      address: '406台中市北屯區后庄七街215號',
      latitude: 24.1925295, // 根據實際測試修正
      longitude: 120.6648565,
      radius: 80.0, // 適中範圍
    ),
    CompanyLocation(
      name: '光悅科技總部',
      address: '406台中市北屯區后庄七街215號',
      latitude: 24.1925295,
      longitude: 120.6648565,
      radius: 120.0, // 較大範圍
    ),
    CompanyLocation(
      name: '光悅科技 (擴大範圍)',
      address: '406台中市北屯區后庄七街215號',
      latitude: 24.1925295,
      longitude: 120.6648565,
      radius: 200.0, // 最大範圍
    ),
  ];
}

/// 公司位置資料模型
class CompanyLocation {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double radius;

  const CompanyLocation({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
  }

  factory CompanyLocation.fromJson(Map<String, dynamic> json) {
    return CompanyLocation(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      radius: (json['radius'] ?? 100.0).toDouble(),
    );
  }

  @override
  String toString() {
    return 'CompanyLocation{name: $name, address: $address, lat: $latitude, lng: $longitude, radius: $radius}';
  }
}