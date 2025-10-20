# 客戶功能除錯指南

## 🔍 當前錯誤分析

錯誤訊息：`js_primitives.dart:28 Another exception was thrown: Instance of 'minified:jw<void>'`

這是一個壓縮後的 JavaScript 錯誤，通常出現在 Flutter Web。讓我們逐步診斷。

## 📝 診斷步驟

### 步驟 1：檢查 Flutter 控制台輸出

現在程式碼已添加詳細的日誌。請查看控制台輸出，尋找以下訊息：

```
createCustomer: 開始創建客戶資料
createCustomer: 當前用戶 ID = ...
createCustomer: 檢查是否已有客戶資料
getCurrentCustomer: 查詢用戶 ... 的客戶資料
```

### 步驟 2：確認數據庫表是否存在

#### 方法 A：使用 Supabase Dashboard

1. 登入 Supabase Dashboard
2. 點擊左側 **Table Editor**
3. 查看是否有 `customers` 表

#### 方法 B：使用 SQL 查詢

在 Supabase SQL Editor 執行：

```sql
-- 檢查 customers 表是否存在
SELECT EXISTS (
   SELECT FROM information_schema.tables 
   WHERE table_schema = 'public'
   AND table_name = 'customers'
);
```

應該返回 `true`。如果返回 `false`，請執行：

```sql
-- 執行整個 create_customers_table.sql 的內容
```

### 步驟 3：驗證 RLS 政策

在 Supabase SQL Editor 執行：

```sql
-- 檢查 customers 表的 RLS 是否啟用
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'customers';

-- 查看所有 RLS 政策
SELECT * FROM pg_policies WHERE tablename = 'customers';
```

應該看到：
- `rowsecurity` = `true`
- 4 個政策（view own, update own, insert own, employees view all）

### 步驟 4：測試用戶權限

在 Supabase SQL Editor 執行（替換 YOUR_USER_ID）：

```sql
-- 測試用戶是否能插入客戶資料
-- 先設置用戶上下文（在 Supabase Dashboard 會自動處理）

INSERT INTO public.customers (
  user_id,
  name,
  email,
  created_at,
  updated_at
) VALUES (
  auth.uid(), -- 使用當前登入用戶的 ID
  '測試客戶',
  'test@example.com',
  now(),
  now()
) RETURNING *;
```

### 步驟 5：檢查 user_id

確認當前登入用戶有有效的 ID：

在 Flutter 控制台應該會看到：
```
createCustomer: 當前用戶 ID = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

如果看到 `null` 或錯誤，表示用戶未正確登入。

## 🛠️ 常見問題修復

### 問題 1：表不存在
**症狀**：看到 `relation "public.customers" does not exist`

**解決**：
```bash
# 在 Supabase Dashboard > SQL Editor 執行
docs/database/create_customers_table.sql
```

### 問題 2：RLS 阻擋插入
**症狀**：`new row violates row-level security policy`

**解決**：
```sql
-- 檢查 INSERT 政策
SELECT * FROM pg_policies 
WHERE tablename = 'customers' 
AND cmd = 'INSERT';

-- 確認政策存在且正確
-- 應該有：WITH CHECK (auth.uid() = user_id)
```

### 問題 3：用戶未登入
**症狀**：`必須登入才能創建客戶資料`

**解決**：
1. 確認已經登入
2. 檢查 Supabase 連接
3. 重新登入

### 問題 4：重複的 user_id
**症狀**：`duplicate key value violates unique constraint`

**解決**：
```sql
-- 刪除現有的客戶記錄（在測試環境）
DELETE FROM public.customers 
WHERE user_id = 'YOUR_USER_ID';
```

## 🧪 測試清單

請按順序測試：

- [ ] 1. 數據庫 `customers` 表已創建
- [ ] 2. RLS 已啟用且政策正確
- [ ] 3. 用戶已成功登入
- [ ] 4. 控制台顯示詳細日誌
- [ ] 5. 表單驗證通過
- [ ] 6. Email 欄位有值
- [ ] 7. 沒有重複的客戶記錄

## 📊 預期的成功流程

正確的控制台輸出應該是：

```
_loadUserEmail: 當前用戶 = user@example.com
_loadUserEmail: Email 已設置為 user@example.com
_submitForm: 開始提交表單
_submitForm: 呼叫 createCustomer
createCustomer: 開始創建客戶資料
createCustomer: 當前用戶 ID = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
createCustomer: 檢查是否已有客戶資料
getCurrentCustomer: 查詢用戶 xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx 的客戶資料
getCurrentCustomer: 查詢結果 = null
getCurrentCustomer: 找不到客戶資料
createCustomer: 準備插入資料 - name: 測試客戶, email: user@example.com
createCustomer: 準備插入的 JSON 資料 = {user_id: xxx, name: 測試客戶, ...}
createCustomer: 插入成功，回應資料 = {id: xxx, user_id: xxx, ...}
createCustomer: 客戶資料創建成功 - 測試客戶
_submitForm: 客戶創建成功
```

## 💡 下一步

1. **重新運行 App**，查看控制台的詳細日誌
2. **記錄完整的錯誤訊息**
3. **檢查 Supabase 是否有 customers 表**
4. **如果還是失敗，提供控制台的完整輸出**

現在的程式碼會提供非常詳細的日誌，可以精確定位問題所在！
