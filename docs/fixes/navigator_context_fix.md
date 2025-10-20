# 🔧 Navigator Context 錯誤修復

## 📋 問題描述

**錯誤訊息：**
```
Navigator operation requested with a context that does not include a Navigator.
The context used to push or pop routes from the Navigator must be that of a widget that is a descendant of a Navigator widget.
```

## 🔍 問題原因

在 `app.dart` 中的 `_buildGuestWelcome()` 方法直接返回一個 Widget 作為 `MaterialApp.home`，但在這個 Widget 內部嘗試使用 `Navigator.of(context).push()`。

**問題代碼：**
```dart
Widget _buildGuestWelcome() {
  return Scaffold(
    body: Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(...);  // ❌ context 還沒有 Navigator！
        },
      ),
    ),
  );
}
```

此時的 `context` 來自 `AppRoot` 的 `build` 方法，而 `Navigator` 是在 `MaterialApp` 內部創建的。所以當 `_buildGuestWelcome()` 被用作 `home` 時，它的 context 並沒有訪問 Navigator 的能力。

## ✅ 解決方案

將 `_buildGuestWelcome()` 方法提取為獨立的 `GuestWelcomePage` widget。

### 修改內容

#### 1️⃣ 創建新文件 `lib/pages/guest_welcome_page.dart`

```dart
class GuestWelcomePage extends StatelessWidget {
  final VoidCallback? onCustomerRegistered;

  const GuestWelcomePage({
    super.key,
    this.onCustomerRegistered,
  });

  @override
  Widget build(BuildContext context) {
    // 現在這個 context 來自 MaterialApp 的子組件
    // 所以可以正常使用 Navigator
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result = await Navigator.of(context).push<bool>(...);
            if (result == true && onCustomerRegistered != null) {
              onCustomerRegistered!();
            }
          },
          child: const Text('我是客戶'),
        ),
      ),
    );
  }
}
```

#### 2️⃣ 修改 `lib/app.dart`

**移除：**
- `import 'pages/customer/customer_registration_page.dart';`
- 整個 `_buildGuestWelcome()` 方法（約 100 行）

**添加：**
```dart
import 'pages/guest_welcome_page.dart';
```

**修改路由：**
```dart
case UserType.guest:
  return GuestWelcomePage(
    onCustomerRegistered: _checkUserType,  // 註冊成功後重新檢查用戶類型
  );
```

## 🎯 為什麼這樣修復有效？

### Context 層級關係

**修復前：**
```
MaterialApp (創建 Navigator)
  └─ home: _buildGuestWelcome()
       └─ Scaffold
            └─ Button (嘗試使用 Navigator) ❌ context 太早了
```

**修復後：**
```
MaterialApp (創建 Navigator)
  └─ home: GuestWelcomePage()
       └─ Builder (新的 context)
            └─ Scaffold
                 └─ Button (使用 Navigator) ✅ context 正確！
```

當 `GuestWelcomePage` 被放在 `MaterialApp.home` 時，它的 `build` 方法會接收一個**新的** context，這個 context 是 `MaterialApp` 的子孫，所以可以訪問 Navigator。

## 📝 相關文件

- ✅ 已修復：`lib/app.dart`
- ✅ 已創建：`lib/pages/guest_welcome_page.dart`
- ℹ️ 無需修改：`lib/pages/customer/customer_registration_page.dart`

## 🧪 測試步驟

1. **啟動應用**
   ```bash
   flutter run -d web-server --web-port 8080
   ```

2. **登入測試帳號**
   - Email: `testcustomer@gmail.com`

3. **驗證功能**
   - ✅ 應該看到「歡迎」頁面
   - ✅ 點擊「我是客戶」按鈕
   - ✅ 應該正常導航到客戶註冊頁面（不再出現 Navigator 錯誤）
   - ✅ 填寫並提交表單
   - ✅ 註冊成功後應該自動重新檢查用戶類型並導航到客戶主頁

## 💡 設計改進

### 回調機制
添加了 `onCustomerRegistered` 回調：
```dart
GuestWelcomePage(
  onCustomerRegistered: _checkUserType,  // 註冊完成後重新檢查
)
```

這樣當用戶完成客戶註冊後：
1. `CustomerRegistrationPage` 返回 `true`
2. `GuestWelcomePage` 接收到 `true`
3. 調用 `onCustomerRegistered()`
4. `app.dart` 中的 `_checkUserType()` 被執行
5. 檢測到用戶現在是客戶
6. `setState` 更新 `_userType = UserType.customer`
7. 重新 build 時顯示 `CustomerHomePage`

## 🔗 相關 Flutter 概念

### BuildContext 的作用域
- Context 是 Widget tree 中的位置標記
- 每個 Widget 的 `build` 方法都會接收一個新的 context
- 這個 context 包含了該 Widget 所有祖先的信息
- `Navigator.of(context)` 會向上查找最近的 `Navigator` widget

### 為什麼要獨立文件？
1. **清晰的責任分離**：每個頁面一個文件
2. **正確的 context 管理**：StatelessWidget 自動處理
3. **更好的可測試性**：可以單獨測試 GuestWelcomePage
4. **代碼重用**：可以在其他地方使用這個頁面

---

**修復狀態：** ✅ 完成
**下一步：** 測試應用，確認導航功能正常
