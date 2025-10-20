# 客戶功能快速設置指南

## ⚠️ 遇到「Null check operator used on a null value」錯誤？

這個錯誤通常是因為數據庫表尚未創建。請按照以下步驟操作：

## 步驟 1：檢查是否已登入

確保您已經成功登入系統。

## 步驟 2：在 Supabase 創建 customers 表

### 方式 A：使用 Supabase Dashboard（推薦）

1. 登入 Supabase Dashboard: https://supabase.com/dashboard
2. 選擇您的專案
3. 點擊左側選單的 **SQL Editor**
4. 點擊 **New Query**
5. 複製貼上以下 SQL 內容（或直接開啟 `docs/database/create_customers_table.sql`）：

```sql
-- 創建客戶表
CREATE TABLE IF NOT EXISTS public.customers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  name text NOT NULL,
  company text,
  email text,
  phone text,
  address text,
  notes text,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT customers_pkey PRIMARY KEY (id),
  CONSTRAINT customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- 創建索引
CREATE INDEX IF NOT EXISTS idx_customers_user_id ON public.customers(user_id);
CREATE INDEX IF NOT EXISTS idx_customers_email ON public.customers(email);
CREATE INDEX IF NOT EXISTS idx_customers_company ON public.customers(company);

-- 添加註解
COMMENT ON TABLE public.customers IS '客戶資料表';
COMMENT ON COLUMN public.customers.user_id IS '關聯到 auth.users.id';

-- 更新時間觸發器
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_customers_updated_at ON public.customers;
CREATE TRIGGER update_customers_updated_at
  BEFORE UPDATE ON public.customers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 啟用 RLS
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

-- RLS 政策
DROP POLICY IF EXISTS "Users can view their own customer profile" ON public.customers;
DROP POLICY IF EXISTS "Users can update their own customer profile" ON public.customers;
DROP POLICY IF EXISTS "Users can insert their own customer profile" ON public.customers;
DROP POLICY IF EXISTS "Employees can view all customers" ON public.customers;

CREATE POLICY "Users can view their own customer profile"
ON public.customers
FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own customer profile"
ON public.customers
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can insert their own customer profile"
ON public.customers
FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Employees can view all customers"
ON public.customers
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.employees
    WHERE id = auth.uid()
    AND status = '在職'
  )
);
```

6. 點擊 **Run** 執行 SQL
7. 確認執行成功（應該看到 "Success. No rows returned"）

### 方式 B：使用命令列工具

如果您有安裝 `psql` 工具：

```bash
cd /home/coselig/ctc
psql -h <your-supabase-host> -U postgres -d postgres -f docs/database/create_customers_table.sql
```

## 步驟 3：驗證表已創建

在 Supabase Dashboard：
1. 點擊左側選單的 **Table Editor**
2. 應該會看到 `customers` 表
3. 確認表有以下欄位：
   - id (uuid)
   - user_id (uuid)
   - name (text)
   - company (text)
   - email (text)
   - phone (text)
   - address (text)
   - notes (text)
   - created_at (timestamp)
   - updated_at (timestamp)

## 步驟 4：測試客戶註冊

1. 重新啟動 App（如果正在運行）
2. 註冊/登入一個新帳號
3. 選擇「我是客戶」
4. 填寫客戶資料表單
5. 提交

## 常見錯誤排查

### 錯誤 1：「relation "public.customers" does not exist」
**原因**：customers 表尚未創建  
**解決**：執行上述 SQL 腳本

### 錯誤 2：「該用戶已經是客戶」
**原因**：該帳號已經註冊為客戶  
**解決**：使用其他帳號，或在 Supabase 刪除該客戶記錄

### 錯誤 3：「電子郵件不能為空」
**原因**：用戶帳號沒有 email，且表單也沒填  
**解決**：在表單中填寫電子郵件

### 錯誤 4：「null check operator used on a null value」
**原因**：可能是以下之一：
1. customers 表不存在
2. user_id 為 null
3. 用戶未登入

**解決步驟**：
1. 檢查是否已登入：查看 Supabase Dashboard > Authentication > Users
2. 確認 customers 表存在：Table Editor
3. 檢查 RLS 政策是否正確設置
4. 查看 Flutter 控制台的詳細錯誤訊息

## 驗證 RLS 政策

在 Supabase SQL Editor 執行：

```sql
-- 查看 customers 表的 RLS 政策
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'customers';
```

應該會看到 4 個政策：
1. Users can view their own customer profile (SELECT)
2. Users can update their own customer profile (UPDATE)
3. Users can insert their own customer profile (INSERT)
4. Employees can view all customers (SELECT)

## 需要幫助？

如果以上步驟都無法解決問題，請提供：
1. 完整的錯誤訊息
2. Flutter 控制台輸出
3. Supabase 是否顯示 customers 表
4. 用戶是否已登入

## 成功指標

客戶註冊成功後：
1. 看到綠色提示「客戶資料建立成功！」
2. 自動跳轉到客戶主頁面
3. 在客戶主頁面看到個人資料卡片
4. 在 Supabase Table Editor > customers 表中看到新記錄
