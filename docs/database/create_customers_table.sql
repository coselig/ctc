-- ==========================================
-- 客戶資料表 (Customers Table)
-- ==========================================
-- 用於儲存註冊為客戶的用戶資料
-- 客戶可以查看被授權的專案資料

-- 創建客戶表
CREATE TABLE IF NOT EXISTS public.customers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE, -- 關聯到 auth.users.id，每個用戶只能有一筆客戶記錄
  name text NOT NULL,
  company text, -- 公司名稱（選填）
  email text,
  phone text,
  address text,
  notes text,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT customers_pkey PRIMARY KEY (id),
  CONSTRAINT customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- 創建索引以加速查詢
CREATE INDEX IF NOT EXISTS idx_customers_user_id ON public.customers(user_id);
CREATE INDEX IF NOT EXISTS idx_customers_email ON public.customers(email);
CREATE INDEX IF NOT EXISTS idx_customers_company ON public.customers(company);

-- 添加註解
COMMENT ON TABLE public.customers IS '客戶資料表 - 儲存註冊為客戶的用戶資料';
COMMENT ON COLUMN public.customers.user_id IS '關聯到 auth.users.id 的用戶 ID';
COMMENT ON COLUMN public.customers.name IS '客戶姓名';
COMMENT ON COLUMN public.customers.company IS '客戶所屬公司名稱';

-- ==========================================
-- 更新時間觸發器
-- ==========================================

-- 創建或更新 updated_at 觸發器函數（如果尚未存在）
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ language 'plpgsql';

-- 為客戶表添加更新時間觸發器
DROP TRIGGER IF EXISTS update_customers_updated_at ON public.customers;
CREATE TRIGGER update_customers_updated_at
  BEFORE UPDATE ON public.customers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ==========================================
-- Row Level Security (RLS) 政策
-- ==========================================

-- 啟用 RLS
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

-- 刪除舊政策（如果存在）
DROP POLICY IF EXISTS "Users can view their own customer profile" ON public.customers;
DROP POLICY IF EXISTS "Users can update their own customer profile" ON public.customers;
DROP POLICY IF EXISTS "Users can insert their own customer profile" ON public.customers;
DROP POLICY IF EXISTS "Employees can view all customers" ON public.customers;

-- 政策 1: 客戶可以查看自己的資料
CREATE POLICY "Users can view their own customer profile"
ON public.customers
FOR SELECT
USING (auth.uid() = user_id);

-- 政策 2: 客戶可以更新自己的資料
CREATE POLICY "Users can update their own customer profile"
ON public.customers
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 政策 3: 用戶可以創建自己的客戶資料
CREATE POLICY "Users can insert their own customer profile"
ON public.customers
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- 政策 4: 員工可以查看所有客戶資料（用於管理）
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

-- ==========================================
-- 完成！
-- ==========================================

-- 使用說明：
-- 1. 客戶註冊後，會創建 auth.users 記錄
-- 2. 客戶完善資料時，會創建 customers 記錄
-- 3. 客戶只能查看/編輯自己的資料
-- 4. 員工可以查看所有客戶資料（用於管理和客服）
-- 5. 專案權限透過 project_clients 表關聯
