-- ======================================
-- 添加測試員工腳本
-- coseligtest@gmail.com
-- ======================================

-- 步驟 1: 查詢該用戶是否已註冊
SELECT 
  id, 
  email, 
  created_at
FROM auth.users
WHERE email = 'coseligtest@gmail.com';

-- 步驟 2: 檢查是否已經在員工表中
SELECT 
  id,
  employee_id,
  name,
  email,
  status
FROM public.employees
WHERE email = 'coseligtest@gmail.com';

-- 步驟 3: 插入員工資料
-- 注意：如果已存在會報錯，可以先刪除或跳過此步驟
INSERT INTO public.employees (
  id,
  employee_id,
  name,
  email,
  department,
  position,
  hire_date,
  status,
  created_by
) 
SELECT 
  u.id,  -- 使用 auth.users.id 作為主鍵
  'EMP' || LPAD(
    (SELECT COALESCE(MAX(CAST(SUBSTRING(employee_id FROM 4) AS INTEGER)), 0) + 1 
     FROM public.employees 
     WHERE employee_id ~ '^EMP[0-9]+$')::TEXT, 
    3, '0'
  ),  -- 自動生成員工編號如 EMP001, EMP002...
  'CoSelig 測試用戶',
  u.email,
  '測試部門',
  '測試職位',
  CURRENT_DATE,
  '在職',
  u.id
FROM auth.users u
WHERE u.email = 'coseligtest@gmail.com';

-- 步驟 4: 驗證結果
SELECT 
  e.id,
  e.employee_id,
  e.name,
  e.email,
  e.department,
  e.position,
  e.status,
  e.hire_date,
  u.email as auth_email
FROM public.employees e
JOIN auth.users u ON e.id = u.id
WHERE e.email = 'coseligtest@gmail.com';

-- 步驟 5 (可選): 如果需要刪除該員工資料
-- DELETE FROM public.employees WHERE email = 'coseligtest@gmail.com';
