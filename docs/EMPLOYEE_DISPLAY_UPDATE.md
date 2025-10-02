# 員工顯示名稱功能更新

## 🎯 修改目標
將系統主頁的歡迎訊息從顯示郵箱改為：
- **員工用戶**：顯示員工姓名
- **非員工用戶**：顯示郵箱地址

## 📝 修改內容

### 修改檔案：`lib/pages/system_home_page.dart`

#### 1. 新增導入
```dart
import '../models/employee.dart';
import '../services/employee_service.dart';
```

#### 2. 新增狀態變數
```dart
late final EmployeeService _employeeService;
Employee? _currentEmployee;
bool _isLoadingEmployee = true;
```

#### 3. 新增初始化邏輯
```dart
@override
void initState() {
  super.initState();
  _employeeService = EmployeeService(supabase);
  _loadCurrentEmployee();
}
```

#### 4. 新增員工資料載入方法
```dart
Future<void> _loadCurrentEmployee() async {
  // 根據當前用戶的郵箱查詢員工表格
  // 如果找到匹配的員工，儲存到 _currentEmployee
}
```

#### 5. 新增動態顯示邏輯
```dart
Widget _buildWelcomeText(BuildContext context, User? user) {
  if (_isLoadingEmployee) {
    // 顯示載入提示
  }
  
  if (_currentEmployee != null) {
    // 員工：顯示姓名
    displayText = '歡迎您，${_currentEmployee!.name}';
  } else {
    // 非員工：顯示郵箱
    displayText = '歡迎您，${user?.email ?? '使用者'}';
  }
}
```

## 🔄 運作流程

1. **頁面載入時**
   - 顯示「載入用戶資料中...」
   - 獲取當前登入用戶的郵箱

2. **查詢員工資料**
   - 從員工表格中查詢與用戶郵箱匹配的記錄
   - 如果找到，儲存員工資料

3. **動態顯示**
   - **找到員工資料**：顯示「歡迎您，[員工姓名]」
   - **沒找到員工資料**：顯示「歡迎您，[郵箱地址]」

## 🎨 用戶體驗改善

### 之前
```
歡迎您，yunthomas006@gmail.com
```

### 之後
```
員工用戶：歡迎您，張三
非員工用戶：歡迎您，yunthomas006@gmail.com
載入中：載入用戶資料中... (帶載入動畫)
```

## 🛡️ 錯誤處理

- **載入失敗**：自動回退到顯示郵箱
- **網路錯誤**：在控制台記錄錯誤，不影響頁面顯示
- **資料不存在**：優雅處理，顯示郵箱作為備選方案

## ✅ 測試建議

1. **員工用戶測試**
   - 以已存在於員工表格的郵箱登入
   - 確認顯示員工姓名

2. **非員工用戶測試**
   - 以不在員工表格中的郵箱登入
   - 確認顯示郵箱地址

3. **載入狀態測試**
   - 網路較慢時觀察載入提示
   - 確認載入完成後正確顯示

## 📋 相關檔案

- **主要修改**：`lib/pages/system_home_page.dart`
- **依賴服務**：`lib/services/employee_service.dart`
- **資料模型**：`lib/models/employee.dart`
- **測試檔案**：`test/system_home_page_test.dart`

這個修改提供了更個人化的用戶體驗，讓員工看到自己的姓名而不是郵箱地址！