-- 診斷照片記錄權限問題
-- 請在 Supabase SQL Editor 執行此腳本，並將結果分享給我

-- ============================================
-- 1. 檢查當前用戶資訊
-- ============================================
SELECT 
  '1️⃣ 當前用戶資訊' AS step,
  auth.uid() AS your_user_id,
  auth.email() AS your_email;

-- ============================================
-- 2. 檢查你的 floor_plan_permissions 記錄
-- ============================================
SELECT 
  '2️⃣ 你的設計圖權限' AS step,
  fp.id AS floor_plan_id,
  fp.name AS floor_plan_name,
  fp.user_id AS owner_id,
  fpp.permission_level,
  CASE 
    WHEN fpp.permission_level = 1 THEN '檢視者'
    WHEN fpp.permission_level = 2 THEN '編輯者'
    WHEN fpp.permission_level = 3 THEN '管理員'
  END AS permission_name,
  fpp.created_at AS granted_at
FROM floor_plan_permissions fpp
JOIN floor_plans fp ON fp.id = fpp.floor_plan_id
WHERE fpp.user_id = auth.uid()
ORDER BY fpp.created_at DESC;

-- ============================================
-- 3. 檢查這些設計圖中有多少照片
-- ============================================
SELECT 
  '3️⃣ 你有權限的設計圖的照片數量' AS step,
  fp.id AS floor_plan_id,
  fp.name AS floor_plan_name,
  COUNT(pr.id) AS photo_count
FROM floor_plan_permissions fpp
JOIN floor_plans fp ON fp.id = fpp.floor_plan_id
LEFT JOIN photo_records pr ON pr.floor_plan_id = fp.id
WHERE fpp.user_id = auth.uid()
GROUP BY fp.id, fp.name
ORDER BY photo_count DESC;

-- ============================================
-- 4. 測試權限函數
-- ============================================
-- 注意：請將下面的 'YOUR_FLOOR_PLAN_ID' 替換成實際的設計圖 ID

-- 測試 has_floor_plan_access 函數
SELECT 
  '4️⃣ 測試權限函數' AS step,
  fp.id AS floor_plan_id,
  fp.name AS floor_plan_name,
  has_floor_plan_access(fp.id) AS has_access,
  has_floor_plan_edit_access(fp.id) AS has_edit,
  has_floor_plan_admin_access(fp.id) AS has_admin
FROM floor_plan_permissions fpp
JOIN floor_plans fp ON fp.id = fpp.floor_plan_id
WHERE fpp.user_id = auth.uid()
LIMIT 5;

-- ============================================
-- 5. 檢查 RLS 是否啟用
-- ============================================
SELECT 
  '5️⃣ RLS 狀態檢查' AS step,
  tablename,
  rowsecurity AS rls_enabled
FROM pg_tables
WHERE schemaname = 'public' 
  AND tablename IN ('photo_records', 'floor_plans', 'floor_plan_permissions')
ORDER BY tablename;

-- ============================================
-- 6. 檢查 RLS 策略
-- ============================================
SELECT 
  '6️⃣ RLS 策略檢查' AS step,
  tablename,
  policyname,
  cmd AS command_type,
  qual AS using_expression,
  with_check AS check_expression
FROM pg_policies
WHERE schemaname = 'public' 
  AND tablename IN ('photo_records', 'floor_plans', 'floor_plan_permissions')
ORDER BY tablename, cmd;

-- ============================================
-- 7. 檢查函數是否存在
-- ============================================
SELECT 
  '7️⃣ 權限函數檢查' AS step,
  proname AS function_name,
  prosecdef AS is_security_definer,
  provolatile AS volatility
FROM pg_proc
WHERE proname LIKE 'has_floor_plan%'
ORDER BY proname;

-- ============================================
-- 8. 嘗試直接查詢照片（繞過 RLS 來看實際數據）
-- ============================================
-- 注意：這個查詢需要使用 service_role key 或在 Supabase Dashboard 的 SQL Editor 執行

SELECT 
  '8️⃣ 照片記錄總數（需要 service_role）' AS step,
  fp.id AS floor_plan_id,
  fp.name AS floor_plan_name,
  fp.user_id AS owner_id,
  COUNT(pr.id) AS total_photos
FROM floor_plans fp
LEFT JOIN photo_records pr ON pr.floor_plan_id = fp.id
WHERE fp.id IN (
  SELECT floor_plan_id 
  FROM floor_plan_permissions 
  WHERE user_id = auth.uid()
)
GROUP BY fp.id, fp.name, fp.user_id;

-- ============================================
-- 完成
-- ============================================
SELECT 
  '✅ 診斷完成' AS message,
  '請將以上所有結果截圖或複製給我' AS next_step;
