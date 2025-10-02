/// 公司位置配置類
class CompanyLocationConfig {
  static const String defaultCompanyName = '光悅科技股份有限公司';
  static const double defaultLatitude = 24.202445;   // 光悅科技實際GPS座標
  static const double defaultLongitude = 120.655053;
  static const double defaultRadius = 100.0; // 100公尺

  // 預設的公司位置列表
  static const List<CompanyLocation> predefinedLocations = [
    CompanyLocation(
      name: '光悅科技股份有限公司',
      address: '406台中市北屯區后庄七街215號',
      latitude: 24.202445,
      longitude: 120.655053,
      radius: 100.0,
    ),
    CompanyLocation(
      name: '光悅科技總部',
      address: '406台中市北屯區后庄七街215號',
      latitude: 24.202445,
      longitude: 120.655053,
      radius: 150.0,
    ),
    CompanyLocation(
      name: '光悅科技 (擴大範圍)',
      address: '406台中市北屯區后庄七街215號',
      latitude: 24.202445,
      longitude: 120.655053,
      radius: 200.0,
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