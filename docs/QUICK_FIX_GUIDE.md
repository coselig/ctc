# 🔍 診斷和修復指南

## 當前問題分析

根據錯誤日誌：
```
用戶 testcustomer@gmail.com 不在員工列表中  ✅ 正確
用戶 testcustomer@gmail.com 不在客戶列表中  ✅ 正確
Null check operator used on a null value    ❌ 這是問題
```

## 🎯 問題根源

用戶既不是員工也不是客戶，所以應該顯示「身份選擇頁面」(`_buildGuestWelcome`)，但系統卻嘗試渲染了 `CustomerHomePage`，導致錯誤。

## ✅ 已完成的修復

1. **添加了詳細日誌** - 現在會顯示用戶類型判定過程
2. **修正了 Customer.fromJson** - 處理 null 日期
3. **修正了 CustomerHomePage 構造** - 使用 `const`

## 🚀 立即測試步驟

### 步驟 1：重新編譯並運行

```bash
cd /home/coselig/ctc

# 停止當前運行
# Ctrl+C

# 清理並重新運行
flutter clean
flutter pub get
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0 --release
```

### 步驟 2：查看新的日誌輸出

登入後，應該會看到：
```
getCurrentUserType: 開始檢查用戶類型 - testcustomer@gmail.com
getCurrentUserType: isEmployee = false
getCurrentUserType: isCustomer = false
getCurrentUserType: 返回 UserType.guest
_buildHomeWidget: user = testcustomer@gmail.com, userType = UserType.guest
_buildHomeWidget: 顯示 GuestWelcome
```

### 步驟 3：選擇「我是客戶」

點擊按鈕後應該會看到：
```
_loadUserEmail: 當前用戶 = testcustomer@gmail.com
_loadUserEmail: Email 已設置為 testcustomer@gmail.com
```

### 步驟 4：填寫並提交表單

提交後應該會看到：
```
_submitForm: 開始提交表單
createCustomer: 開始創建客戶資料
createCustomer: 當前用戶 ID = xxxxx
getCurrentCustomer: 查詢用戶 xxxxx 的客戶資料
```

## ⚠️ 如果還是失敗

### 情況 A：看到「資料庫尚未設置」

**原因**：`customers` 表不存在

**解決**：
1. 登入 Supabase Dashboard
2. SQL Editor > New Query
3. 複製並執行 `docs/database/create_customers_table.sql`
4. 重試

### 情況 B：還是顯示 null check 錯誤

**可能原因**：
1. 舊的編譯緩存
2. 瀏覽器緩存

**解決**：
```bash
# 完全清理
flutter clean
rm -rf build/
flutter pub get

# 清除瀏覽器緩存
# 使用無痕模式打開瀏覽器
```

### 情況 C：日誌顯示 UserType.customer 但用戶不在列表中

這不應該發生，但如果發生了：

```bash
# 檢查 Supabase 中的客戶記錄
# 在 SQL Editor 執行：

SELECT * FROM public.customers 
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'testcustomer@gmail.com');

# 如果有結果，刪除它重新測試：
DELETE FROM public.customers 
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'testcustomer@gmail.com');
```

## 📊 預期的完整流程

### 1. 首次登入（作為 guest）
```
登入 → 檢查類型 → guest → 顯示身份選擇頁面
```

### 2. 選擇「我是客戶」
```
點擊按鈕 → 打開註冊表單 → 填寫資料 → 提交
```

### 3. 註冊成功
```
創建記錄 → 重新檢查類型 → customer → 顯示客戶主頁
```

### 4. 之後的登入
```
登入 → 檢查類型 → customer → 直接進入客戶主頁
```

## 🛠️ 終極解決方案

如果以上都無效，請提供：

1. **完整的控制台輸出**（從啟動到錯誤）
2. **Supabase 中是否有 customers 表**
   ```sql
   SELECT table_name FROM information_schema.tables 
   WHERE table_schema = 'public' AND table_name = 'customers';
   ```
3. **用戶的 ID**
   ```sql
   SELECT id FROM auth.users WHERE email = 'testcustomer@gmail.com';
   ```

現在重新運行 App，應該會看到非常詳細的日誌，可以精確定位問題！
