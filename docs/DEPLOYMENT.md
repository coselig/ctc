# 員工管理系統部署指南

## 1. 資料庫部署

### 步驟 1：連接到 Supabase
1. 登入你的 Supabase 專案控制台
2. 進入 SQL Editor

### 步驟 2：執行資料庫腳本
1. 複製 `docs/database/database.sql` 的內容
2. 在 SQL Editor 中貼上並執行整個腳本
3. 確認所有表格都成功創建

### 步驟 3：驗證表格創建
執行以下查詢來確認表格是否存在：

```sql
-- 檢查所有表格
SELECT schemaname, tablename 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('user_profiles', 'employees', 'floor_plans', 'photo_records');

-- 檢查 user_profiles 表格結構
\d public.user_profiles;

-- 檢查 employees 表格結構  
\d public.employees;
```

## 2. 應用程式配置

### 確認 Supabase 設定
在 `lib/main.dart` 中確認 Supabase 初始化：

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

## 3. 測試系統功能

### 測試用戶註冊流程
1. 在應用程式中註冊新用戶
2. 檢查 `auth.users` 表格中是否有新用戶
3. 檢查 `user_profiles` 表格中是否自動創建了用戶檔案

### 測試員工管理功能
1. 以管理員身份登入
2. 進入員工管理頁面
3. 測試添加、編輯、刪除員工功能
4. 測試從已註冊用戶中選擇創建員工

### 測試用戶選擇功能
1. 進入用戶選擇頁面
2. 確認能看到已註冊但尚未成為員工的用戶
3. 測試搜尋和篩選功能

## 4. 錯誤處理驗證

### 測試備用機制
如果 `user_profiles` 表格暫時不可用，系統應該：
1. 顯示備用的測試用戶資料
2. 記錄錯誤但不影響應用程式運行
3. 在控制台輸出相應的錯誤訊息

## 5. 常見問題解決

### 問題：`relation "public.user_profiles" does not exist`
解決方案：
1. 確認已執行完整的資料庫腳本
2. 檢查 RLS 政策是否正確設置
3. 確認用戶有適當的權限訪問表格

### 問題：用戶註冊後沒有自動創建檔案
解決方案：
1. 檢查觸發器是否正確創建
2. 確認 `handle_new_user()` 函數是否存在
3. 檢查 `auth.users` 表格的觸發器設定

### 問題：員工創建失敗
解決方案：
1. 檢查員工 ID 是否唯一
2. 確認所有必填欄位都已提供
3. 檢查外鍵約束是否滿足

## 6. 監控和日誌

### 檢查系統狀態
定期執行以下查詢：

```sql
-- 檢查用戶和檔案同步狀態
SELECT 
  u.id as user_id,
  u.email as auth_email,
  p.email as profile_email,
  p.display_name
FROM auth.users u
LEFT JOIN public.user_profiles p ON u.id = p.user_id;

-- 檢查員工統計
SELECT 
  department,
  COUNT(*) as employee_count,
  COUNT(CASE WHEN is_active THEN 1 END) as active_count
FROM public.employees
GROUP BY department;
```

### 應用程式日誌
注意控制台中的以下訊息：
- `獲取已註冊用戶失敗` - 表示 user_profiles 表格問題
- `使用備用用戶資料` - 表示正在使用備用機制
- `檢查用戶員工狀態失敗` - 表示員工檢查問題

## 7. 完成檢查清單

- [ ] 資料庫腳本執行成功
- [ ] 所有表格都已創建
- [ ] RLS 政策已啟用
- [ ] 觸發器正常工作
- [ ] 用戶註冊功能正常
- [ ] 員工管理功能正常
- [ ] 用戶選擇功能正常
- [ ] 錯誤處理機制正常
- [ ] 應用程式可以正常運行