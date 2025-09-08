# VS Code 調試指南 - CTC 權限管理問題

## 🔧 調試環境已設置完成

您的 VS Code 已經配置好 Flutter 調試環境，包含：

- Debug、Release、Profile 三種模式
- Chrome Web 調試配置
- 自動熱重載設定
- 調試控制台優化

## 🎯 調試權限管理使用者載入問題

### 方法 1：使用專用調試頁面

1. **開啟調試頁面**

   ```dart
   // 在您的應用中導航到調試頁面
   Navigator.push(context, MaterialPageRoute(
     builder: (context) => DebugUserListPage(),
   ));
   ```

2. **設置斷點**
   - 在 `debug_user_list_page.dart` 第 25 行設置斷點
   - 在 `permission_service.dart` 第 337 行設置斷點

3. **開始調試**
   - 按 `F5` 啟動調試
   - 選擇 "ctc (Chrome Web Debug)" 配置
   - 點擊調試頁面的 "測試載入使用者" 按鈕

### 方法 2：直接調試權限管理頁面

1. **關鍵斷點位置**

   ```
   permission_service.dart:
   - 第 337 行：print('開始獲取所有使用者...')
   - 第 339 行：final response = await client.auth.admin.listUsers()
   - 第 350 行：return userList

   permission_management_page.dart:
   - 第 377 行：final users = await widget.permissionService.getAllUsers()
   - 第 450 行：else if (_filteredUsers.isNotEmpty && _selectedUser == null)
   ```

2. **調試步驟**
   - 在上述行號點擊左側設置斷點（紅點）
   - 按 `F5` 啟動調試
   - 導航到權限管理頁面
   - 點擊 ➕ 添加使用者按鈕
   - 觀察程式在斷點處停止

## 🔍 調試檢查項目

### 1. Supabase 連接檢查

```dart
// 在調試控制台檢查
final currentUser = Supabase.instance.client.auth.currentUser;
print('當前使用者: ${currentUser?.email}');
print('使用者角色: ${currentUser?.role}');
```

### 2. API 權限檢查

```dart
// 檢查是否有 admin 權限
try {
  final response = await client.auth.admin.listUsers();
  print('Admin API 調用成功: ${response.length} 使用者');
} catch (e) {
  print('Admin API 失敗: $e');
}
```

### 3. 使用者資料格式檢查

```dart
// 檢查返回的使用者資料結構
for (var user in response) {
  print('使用者 ID: ${user.id}');
  print('使用者 email: ${user.email}');
  print('註冊時間: ${user.createdAt}');
}
```

## 🛠️ 常見問題和解決方案

### 問題 1：Admin API 權限不足

**症狀**: 調用 `client.auth.admin.listUsers()` 失敗
**解決方案**:

- 檢查 Supabase 專案的 RLS 設定
- 確認當前使用者有 admin 權限
- 檢查 API Key 是否為 service_role key

### 問題 2：使用者清單為空

**症狀**: API 調用成功但返回空清單
**可能原因**:

- 資料庫中確實沒有使用者
- 使用者資料被 RLS 策略過濾
- API 返回格式問題

### 問題 3：UI 不顯示使用者

**症狀**: 有使用者資料但 UI 不顯示
**檢查點**:

- `_filteredUsers.isNotEmpty` 條件
- `_selectedUser == null` 條件
- `_isLoadingUsers` 狀態

## 📱 使用 VS Code 調試功能

### 調試控制台

- 查看 `print()` 輸出
- 檢查例外和錯誤訊息
- 監控變數值變化

### 變數監控

- 在調試面板添加監控：
  - `_allUsers`
  - `_filteredUsers`
  - `_isLoadingUsers`
  - `_selectedUser`

### 調用堆疊

- 追蹤方法調用順序
- 檢查非同步操作流程

### 斷點功能

- **一般斷點**: 程式會在此處停止
- **條件斷點**: 右鍵設置條件，例如 `users.length > 0`
- **日誌斷點**: 不停止程式，只輸出日誌

## 🚀 開始調試

1. **打開 VS Code**
2. **開啟 CTC 專案資料夾**
3. **按 F5 啟動調試**
4. **選擇 "ctc (Chrome Web Debug)"**
5. **設置斷點並開始測試**

調試愉快！🐛➡️🎯
