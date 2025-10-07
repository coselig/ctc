-- 🔧 修復 coseligtest@gmail.com 帳號的 SQL 腳本
-- 
-- 問題：coseligtest@gmail.com 在已註冊帳號中找不到
-- 解決：直接在 employees 表中創建員工記錄

-- 第一步：檢查帳號是否已存在
SELECT 'user_profiles 檢查:' as check_type, email, display_name, created_at 
FROM user_profiles 
WHERE email = 'coseligtest@gmail.com'

UNION ALL

SELECT 'employees 檢查:' as check_type, email, name, created_at::text
FROM employees 
WHERE email = 'coseligtest@gmail.com';

-- 第二步：如果不存在，創建員工記錄
-- 注意：請先運行上面的檢查查詢，如果沒有結果才運行下面的插入語句

INSERT INTO employees (
    employee_id,
    name,
    email,
    department,
    position,
    hire_date,
    status,
    notes,
    created_by,
    created_at,
    updated_at
) 
SELECT 
    'COSELIG001' as employee_id,
    'Coselig Test User' as name,
    'coseligtest@gmail.com' as email,
    '研發部' as department,
    '軟體工程師' as position,
    CURRENT_DATE as hire_date,
    'active' as status,
    '手動修復創建的員工記錄' as notes,
    (SELECT id FROM auth.users LIMIT 1) as created_by,  -- 使用第一個找到的用戶作為創建者
    NOW() as created_at,
    NOW() as updated_at
WHERE NOT EXISTS (
    -- 只在不存在時才插入
    SELECT 1 FROM employees WHERE email = 'coseligtest@gmail.com'
);

-- 第三步：驗證結果
SELECT 
    '✅ 修復完成' as status,
    employee_id,
    name,
    email,
    department,
    position,
    status,
    hire_date
FROM employees 
WHERE email = 'coseligtest@gmail.com';

-- 🎯 使用說明：
-- 1. 將此腳本複製到 Supabase SQL Editor
-- 2. 先運行第一個查詢檢查現有記錄
-- 3. 如果沒有找到記錄，運行第二個 INSERT 語句
-- 4. 最後運行第三個查詢驗證結果
--
-- 完成後，coseligtest@gmail.com 就會出現在員工管理系統的已註冊用戶列表中！