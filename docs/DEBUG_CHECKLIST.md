# ✅ 調試檢查清單

## 📋 現在的狀況

### ✅ 已完成
1. **清理並重新編譯** - `flutter clean && flutter pub get`
2. **添加詳細日誌** - 在關鍵位置添加了 15+ 個日誌點
3. **修復代碼問題** - Customer.fromJson null 安全、CustomerHomePage const
4. **啟動 Debug 模式** - 正在啟動 `flutter run -d web-server`

### 🚀 應用正在啟動
當前終端正在編譯和啟動 Flutter Web 應用（Debug 模式）

## 📝 測試步驟

### 1️⃣ 等待啟動完成
終端會顯示：
```
✓ Built build/web
Launching lib/main.dart on Web Server in debug mode...
http://localhost:8080
```

### 2️⃣ 打開瀏覽器
```
http://localhost:8080
```

### 3️⃣ 登入測試帳號
- Email: `testcustomer@gmail.com`
- Password: (您的密碼)

### 4️⃣ 查看控制台日誌
**期望看到的日誌順序：**

```plaintext
App: initState 開始
getCurrentUserType: 開始檢查用戶類型 - testcustomer@gmail.com
getCurrentUserType: isEmployee = false
用戶 testcustomer@gmail.com 不在員工列表中
getCurrentUserType: isCustomer = false
用戶 testcustomer@gmail.com 不在客戶列表中
getCurrentUserType: 返回 UserType.guest
_buildHomeWidget: user = testcustomer@gmail.com, userType = UserType.guest
_buildHomeWidget: 顯示 GuestWelcome
```

**然後應該看到「歡迎」頁面，有兩個按鈕：**
- 🙋 我是客戶
- 👔 我是員工

## ⚠️ 如果還是出現錯誤

### 情況 A：看到不同的日誌
**例如：**
```
getCurrentUserType: 返回 UserType.customer  ← 這不對！
_buildHomeWidget: 顯示 CustomerHomePage     ← 這會導致錯誤
```

**說明：**系統誤判為客戶，需要檢查 Supabase 中是否有重複記錄

**解決：**
```sql
-- 在 Supabase SQL Editor 執行
DELETE FROM public.customers 
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'testcustomer@gmail.com');
```

### 情況 B：看到 null check 錯誤
**日誌可能顯示：**
```
getCurrentUserType: isCustomer = false
_buildHomeWidget: 顯示 CustomerHomePage  ← 矛盾！
Null check operator used on a null value
```

**說明：**用戶類型判定正確，但路由選擇錯誤

**可能原因：**
1. `_userType` 狀態沒有正確更新
2. 有緩存的舊狀態
3. `setState` 調用時機問題

**解決：**使用無痕模式/私密瀏覽打開，完全清除緩存

### 情況 C：看到資料庫錯誤
```
PostgrestException: relation "public.customers" does not exist
```

**說明：**customers 表尚未創建

**解決：**
1. 登入 Supabase Dashboard
2. 打開 SQL Editor
3. 複製 `docs/database/create_customers_table.sql` 內容
4. 執行

### 情況 D：完全沒有日誌輸出
**說明：**瀏覽器控制台沒有打開或日誌被過濾

**解決：**
1. 按 F12 打開開發者工具
2. 切換到 Console 標籤
3. 確保沒有過濾（All levels 顯示）

## 🎯 成功標準

### ✅ 登入後看到「歡迎」頁面
- 有「我是客戶」按鈕
- 有「我是員工」按鈕
- 有「登出」按鈕
- 控制台顯示 `_buildHomeWidget: 顯示 GuestWelcome`

### ✅ 點擊「我是客戶」
- 打開註冊表單
- 可以填寫資料
- Email 已自動填入

### ✅ 提交表單（需要先執行 SQL）
- 顯示「註冊成功」
- 自動跳轉到客戶主頁
- 下次登入直接進入客戶主頁

## 📞 需要幫助？

如果看到任何異常，請提供：
1. **完整的控制台輸出**（從登入到錯誤）
2. **錯誤截圖**
3. **瀏覽器資訊**（Chrome/Firefox/Edge 版本）

---

**當前狀態：** 🟡 等待應用啟動完成
**下一步：** 在瀏覽器中打開 http://localhost:8080 並登入測試
