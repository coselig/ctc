# LogoutButton 組件

一個統一的登出按鈕組件，包含確認對話框和登出邏輯。

## 功能特性

- 🔐 安全的登出確認對話框
- 🎨 支援自訂顏色
- 📱 響應式設計
- 🔄 回調函數支援
- ✨ 完整的錯誤處理

## 使用方法

### 基本使用

```dart
import 'package:ctc/widgets/widgets.dart';

AppBar(
  actions: [
    const LogoutButton(),
  ],
)
```

### 自訂顏色

```dart
AppBar(
  actions: [
    const LogoutButton(
      color: Colors.red,
    ),
  ],
)
```

### 使用回調函數

```dart
AppBar(
  actions: [
    LogoutButton(
      onLogoutStart: () {
        print('開始登出...');
      },
      onLogoutSuccess: () {
        print('登出成功');
      },
      onLogoutError: (error) {
        print('登出失敗: $error');
      },
    ),
  ],
)
```

## 參數說明

| 參數 | 類型 | 必需 | 預設值 | 說明 |
|------|------|------|--------|------|
| `color` | `Color?` | 否 | `Theme.colorScheme.primary` | 按鈕圖標顏色 |
| `onLogoutStart` | `VoidCallback?` | 否 | `null` | 登出開始時的回調 |
| `onLogoutSuccess` | `VoidCallback?` | 否 | `null` | 登出成功時的回調 |
| `onLogoutError` | `ValueChanged<String>?` | 否 | `null` | 登出失敗時的回調 |

## 行為說明

1. 點擊按鈕會顯示確認對話框
2. 用戶確認後執行登出邏輯
3. 自動導航回根頁面
4. 使用 Supabase 進行認證管理
5. 包含完整的錯誤處理和用戶反饋

## 依賴項目

- `flutter/material.dart`
- `supabase_flutter`

## 測試

組件包含完整的單元測試，覆蓋：

- 基本渲染測試
- 對話框顯示測試
- 取消功能測試
- 自訂顏色測試

運行測試：

```bash
flutter test test/logout_button_test.dart
```
