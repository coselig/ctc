/// 權限等級枚舉
enum PermissionLevel {
  /// 第一級：可以上傳圖片&刪除自己上傳的圖片座標點
  level1,

  /// 第二級：有第一級的權限+刪除其他人座標點
  level2,

  /// 第三級：有第二級權限+刪除設計圖
  level3;

  /// 從數字轉換為權限等級
  static PermissionLevel fromValue(int value) {
    switch (value) {
      case 1:
        return PermissionLevel.level1;
      case 2:
        return PermissionLevel.level2;
      case 3:
        return PermissionLevel.level3;
      default:
        return PermissionLevel.level1;
    }
  }
}

extension PermissionLevelExtension on PermissionLevel {
  /// 獲取權限等級的中文描述
  String get displayName {
    switch (this) {
      case PermissionLevel.level1:
        return '一般用戶';
      case PermissionLevel.level2:
        return '進階用戶';
      case PermissionLevel.level3:
        return '管理員';
    }
  }

  /// 獲取權限等級的詳細描述
  String get description {
    switch (this) {
      case PermissionLevel.level1:
        return '可以上傳圖片和刪除自己上傳的座標點';
      case PermissionLevel.level2:
        return '可以上傳圖片、刪除自己和其他人的座標點';
      case PermissionLevel.level3:
        return '可以上傳圖片、刪除所有座標點和設計圖';
    }
  }

  /// 獲取權限等級的圖標
  String get icon {
    switch (this) {
      case PermissionLevel.level1:
        return '👤';
      case PermissionLevel.level2:
        return '⭐';
      case PermissionLevel.level3:
        return '👑';
    }
  }

  /// 轉換為數字
  int get value {
    switch (this) {
      case PermissionLevel.level1:
        return 1;
      case PermissionLevel.level2:
        return 2;
      case PermissionLevel.level3:
        return 3;
    }
  }

  /// 檢查是否可以刪除他人的座標點
  bool get canDeleteOthersCoordinates {
    return this == PermissionLevel.level2 || this == PermissionLevel.level3;
  }

  /// 檢查是否可以刪除設計圖
  bool get canDeleteFloorPlan {
    return this == PermissionLevel.level3;
  }

  /// 檢查是否可以上傳圖片
  bool get canUploadImages {
    return true; // 所有等級都可以上傳圖片
  }

  /// 檢查是否可以刪除自己的座標點
  bool get canDeleteOwnCoordinates {
    return true; // 所有等級都可以刪除自己的座標點
  }
}
