# 服務架構重構指南

## 概述

原來的 `SupabaseService` 已經被重構為三個獨立的服務類別，以實現更好的關注點分離和程式碼維護性：

1. **`FloorPlanService`** - 處理平面圖相關操作
2. **`PhotoRecordService`** - 處理照片記錄相關操作  
3. **`IntegratedService`** - 整合服務，提供統一的 API

## 新的服務架構

### 📁 FloorPlanService

- 平面圖上傳、下載、刪除
- 平面圖權限管理和分享
- 平面圖元資料管理

### 📸 PhotoRecordService

- 照片記錄的 CRUD 操作
- 照片上傳和儲存
- 記錄搜尋和統計

### 🔐 PermissionService

- 使用者權限管理
- 權限檢查和驗證
- 權限相關的資料庫操作

### 🔗 IntegratedService

- 提供統一的 API 介面
- 協調不同服務之間的操作
- 向後相容的方法

## 遷移指南

### 方法 1: 使用 IntegratedService（推薦）

如果您想要最小化程式碼變更，可以直接使用 `IntegratedService`：

```dart
// 原來的方式
final supabaseService = SupabaseService(Supabase.instance.client);

// 新的方式 - 直接替換
final integratedService = IntegratedService(Supabase.instance.client);

// API 保持相同
final floorPlans = await integratedService.loadFloorPlans();
final records = await integratedService.loadRecords();
```

### 方法 2: 使用個別服務（進階）

如果您想要更好的架構分離：

```dart
// 分別初始化服務
final floorPlanService = FloorPlanService(Supabase.instance.client);
final photoRecordService = PhotoRecordService(Supabase.instance.client);
final permissionService = PermissionService(Supabase.instance.client);

// 使用特定服務
final floorPlans = await floorPlanService.loadFloorPlans();
final records = await photoRecordService.loadRecords();
```

## API 對照表

### 平面圖相關操作

| 原 SupabaseService | 新 FloorPlanService | IntegratedService |
|-------------------|-------------------|------------------|
| `uploadFloorPlan()` | `uploadFloorPlan()` | `uploadFloorPlan()` |
| `loadFloorPlans()` | `loadFloorPlans()` | `loadFloorPlans()` |
| `deleteFloorPlan()` | `deleteFloorPlan()` | `deleteFloorPlan()` |

### 照片記錄相關操作

| 原 SupabaseService | 新 PhotoRecordService | IntegratedService |
|-------------------|---------------------|------------------|
| `loadRecords()` | `loadRecords()` | `loadRecords()` |
| `uploadPhotoAndCreateRecord()` | `uploadPhotoAndCreateRecord()` | `uploadPhotoAndCreateRecord()` |
| `deletePhotoRecord()` | `deletePhotoRecord()` | `deletePhotoRecord()` |

## 新增功能

重構後新增了許多功能：

### FloorPlanService 新功能

- `getUserOwnedFloorPlans()` - 獲取用戶擁有的平面圖
- `shareFloorPlan()` - 分享平面圖給其他用戶
- `unshareFloorPlan()` - 取消分享
- `getFloorPlanSharedUsers()` - 獲取分享列表
- `updateFloorPlan()` - 更新平面圖資訊

### PhotoRecordService 新功能

- `loadRecordsByFloorPlan()` - 根據平面圖載入記錄
- `loadRecordsByUser()` - 根據用戶載入記錄
- `searchRecords()` - 搜尋記錄
- `getRecordStatistics()` - 獲取統計資訊
- `updateRecord()` - 更新記錄
- `deleteMultipleRecords()` - 批量刪除

### IntegratedService 新功能

- `getFloorPlanDetails()` - 獲取平面圖完整資訊
- `checkFloorPlanPermissions()` - 檢查權限
- `getUserDashboard()` - 獲取用戶儀表板資料

## 實際使用範例

### 原來的程式碼

```dart
class MyWidget extends StatefulWidget {
  // ...
}

class _MyWidgetState extends State<MyWidget> {
  late final SupabaseService _supabaseService;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(Supabase.instance.client);
  }

  Future<void> _loadData() async {
    final floorPlans = await _supabaseService.loadFloorPlans();
    final records = await _supabaseService.loadRecords();
    // 處理資料...
  }
}
```

### 遷移後的程式碼（方法 1 - IntegratedService）

```dart
class MyWidget extends StatefulWidget {
  // ...
}

class _MyWidgetState extends State<MyWidget> {
  late final IntegratedService _integratedService;

  @override
  void initState() {
    super.initState();
    _integratedService = IntegratedService(Supabase.instance.client);
  }

  Future<void> _loadData() async {
    final floorPlans = await _integratedService.loadFloorPlans();
    final records = await _integratedService.loadRecords();
    // 處理資料...
  }
}
```

### 遷移後的程式碼（方法 2 - 個別服務）

```dart
class MyWidget extends StatefulWidget {
  // ...
}

class _MyWidgetState extends State<MyWidget> {
  late final FloorPlanService _floorPlanService;
  late final PhotoRecordService _photoRecordService;

  @override
  void initState() {
    super.initState();
    final client = Supabase.instance.client;
    _floorPlanService = FloorPlanService(client);
    _photoRecordService = PhotoRecordService(client);
  }

  Future<void> _loadData() async {
    final floorPlans = await _floorPlanService.loadFloorPlans();
    final records = await _photoRecordService.loadRecords();
    // 處理資料...
  }
}
```

## 進階功能使用

### 獲取用戶儀表板資料

```dart
final dashboard = await integratedService.getUserDashboard();
print('可存取的平面圖: ${dashboard['accessible_floor_plans'].length}');
print('擁有的平面圖: ${dashboard['owned_floor_plans'].length}');
print('用戶記錄數: ${dashboard['user_records'].length}');
```

### 檢查平面圖權限

```dart
final permissions = await integratedService.checkFloorPlanPermissions(floorPlanUrl);
if (permissions['canEdit']) {
  // 顯示編輯按鈕
}
if (permissions['canShare']) {
  // 顯示分享按鈕
}
```

### 搜尋照片記錄

```dart
final searchResults = await integratedService.searchPhotoRecords(
  description: '搜尋關鍵字',
  startDate: DateTime.now().subtract(Duration(days: 7)),
  limit: 20,
);
```

## 注意事項

1. **向後相容性**: `IntegratedService` 保持了與原 `SupabaseService` 相同的 API
2. **型別安全**: 新服務使用了更明確的型別定義
3. **錯誤處理**: 所有服務都包含適當的錯誤處理
4. **效能**: 個別服務可以避免不必要的依賴載入

## 推薦的遷移步驟

1. **階段 1**: 使用 `IntegratedService` 替換現有的 `SupabaseService`
2. **階段 2**: 逐步將功能遷移到個別的服務
3. **階段 3**: 利用新增的功能改善使用者體驗
4. **階段 4**: 最佳化和清理未使用的程式碼

這樣的重構讓程式碼更容易維護，也為未來的功能擴展提供了更好的基礎。
