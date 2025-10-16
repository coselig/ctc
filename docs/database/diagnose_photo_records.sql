-- 診斷照片記錄權限問題
-- 
-- 執行這個腳本來檢查為什麼看不到照片記錄

-- ============================================
-- 步驟 1：檢查基本表結構
-- ============================================

SELECT '📋 步驟 1：檢查表是否存在' AS step;

SELECT 
  table_name,
  CASE 
    WHEN table_name IS NOT NULL THEN '✅ 存在'
    ELSE '❌ 不存在'
  END AS status
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('floor_plans', 'floor_plan_permissions', 'photo_records')
ORDER BY table_name;

-- ============================================
-- 步驟 2：檢查 RLS 是否啟用
-- ============================================

SELECT '📋 步驟 2：檢查 RLS 是否啟用' AS step;

SELECT 
  tablename,
  rowsecurity AS rls_enabled,
  CASE 
    WHEN rowsecurity THEN '✅ RLS 已啟用'
    ELSE '❌ RLS 未啟用'
  END AS status
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('floor_plans', 'floor_plan_permissions', 'photo_records')
ORDER BY tablename;

-- ============================================
-- 步驟 3：檢查 SECURITY DEFINER 函數
-- ============================================

SELECT '📋 步驟 3：檢查權限函數' AS step;

SELECT 
  proname AS function_name,
  prosecdef AS is_security_definer,
  CASE 
    WHEN prosecdef THEN '✅ 正確（SECURITY DEFINER）'
    ELSE '❌ 錯誤（不是 SECURITY DEFINER）'
  END AS status
FROM pg_proc
WHERE proname IN ('has_floor_plan_access', 'has_floor_plan_edit_access', 'has_floor_plan_admin_access')
ORDER BY proname;

-- 檢查缺少哪些函數
SELECT 
  func_name,
  CASE 
    WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = func_name) THEN '✅ 已創建'
    ELSE '❌ 缺少'
  END AS status
FROM (VALUES 
  ('has_floor_plan_access'),
  ('has_floor_plan_edit_access'),
  ('has_floor_plan_admin_access')
) AS t(func_name);

-- ============================================
-- 步驟 4：檢查 RLS 策略
-- ============================================

SELECT '📋 步驟 4：檢查 photo_records 的 RLS 策略' AS step;

SELECT 
  policyname,
  cmd AS command,
  '✅' AS status
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'photo_records'
ORDER BY cmd, policyname;

-- 檢查是否有必要的策略
SELECT 
  policy_name,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM pg_policies 
      WHERE schemaname = 'public' 
        AND tablename = 'photo_records' 
        AND policyname = policy_name
    ) THEN '✅ 已創建'
    ELSE '❌ 缺少'
  END AS status
FROM (VALUES 
  ('Users can view accessible photo records'),
  ('Users can insert photo records with edit access'),
  ('Users can update their own photo records'),
  ('Users can delete their own photo records')
) AS t(policy_name);

-- ============================================
-- 步驟 5：檢查 floor_plans 的 RLS 策略
-- ============================================

SELECT '📋 步驟 5：檢查 floor_plans 的 RLS 策略' AS step;

SELECT 
  policyname,
  cmd AS command,
  '✅' AS status
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'floor_plans'
ORDER BY cmd, policyname;

-- ============================================
-- 步驟 6：檢查實際數據（需要替換 UUID）
-- ============================================

SELECT '📋 步驟 6：檢查實際數據（示例）' AS step;

-- 檢查你有多少設計圖
SELECT 
  '你擁有的設計圖數量' AS info,
  COUNT(*) AS count
FROM floor_plans
WHERE user_id = auth.uid();

-- 檢查你被授權的設計圖數量
SELECT 
  '你被授權的設計圖數量' AS info,
  COUNT(*) AS count
FROM floor_plan_permissions
WHERE user_id = auth.uid();

-- 列出你被授權的設計圖詳情
SELECT 
  '你被授權的設計圖' AS info,
  fp.id AS floor_plan_id,
  fp.name AS floor_plan_name,
  fpp.permission_level,
  CASE 
    WHEN fpp.permission_level = 1 THEN '檢視者'
    WHEN fpp.permission_level = 2 THEN '編輯者'
    WHEN fpp.permission_level = 3 THEN '管理員'
    ELSE '未知'
  END AS role
FROM floor_plan_permissions fpp
JOIN floor_plans fp ON fpp.floor_plan_id = fp.id
WHERE fpp.user_id = auth.uid();

-- 檢查這些設計圖的照片數量
SELECT 
  '被授權設計圖的照片數量' AS info,
  fpp.floor_plan_id,
  fp.name AS floor_plan_name,
  COUNT(pr.id) AS photo_count
FROM floor_plan_permissions fpp
JOIN floor_plans fp ON fpp.floor_plan_id = fp.id
LEFT JOIN photo_records pr ON pr.floor_plan_id = fp.id
WHERE fpp.user_id = auth.uid()
GROUP BY fpp.floor_plan_id, fp.name;

-- ============================================
-- 步驟 7：測試權限函數（需要替換 UUID）
-- ============================================

SELECT '📋 步驟 7：測試權限函數' AS step;

-- 取得一個你被授權的 floor_plan_id 來測試
DO $$
DECLARE
  test_floor_plan_id uuid;
BEGIN
  -- 嘗試取得一個你被授權的設計圖 ID
  SELECT floor_plan_id INTO test_floor_plan_id
  FROM floor_plan_permissions
  WHERE user_id = auth.uid()
  LIMIT 1;
  
  IF test_floor_plan_id IS NOT NULL THEN
    RAISE NOTICE '測試設計圖 ID: %', test_floor_plan_id;
    
    -- 測試 has_floor_plan_access
    IF has_floor_plan_access(test_floor_plan_id, auth.uid()) THEN
      RAISE NOTICE '✅ has_floor_plan_access 返回 TRUE';
    ELSE
      RAISE NOTICE '❌ has_floor_plan_access 返回 FALSE（這是問題！）';
    END IF;
    
    -- 測試 has_floor_plan_edit_access
    IF has_floor_plan_edit_access(test_floor_plan_id, auth.uid()) THEN
      RAISE NOTICE '✅ has_floor_plan_edit_access 返回 TRUE';
    ELSE
      RAISE NOTICE 'ℹ️ has_floor_plan_edit_access 返回 FALSE（可能沒有編輯權限）';
    END IF;
  ELSE
    RAISE NOTICE 'ℹ️ 沒有找到你被授權的設計圖';
  END IF;
END $$;

-- ============================================
-- 步驟 8：生成修正建議
-- ============================================

SELECT '📋 步驟 8：修正建議' AS step;

-- 如果函數不存在
SELECT 
  '⚠️ 缺少函數，需要執行：fix_photo_records_rls.sql' AS suggestion
WHERE NOT EXISTS (
  SELECT 1 FROM pg_proc 
  WHERE proname = 'has_floor_plan_access' 
    AND prosecdef = true
);

-- 如果策略不存在
SELECT 
  '⚠️ 缺少 RLS 策略，需要執行：fix_photo_records_rls.sql' AS suggestion
WHERE NOT EXISTS (
  SELECT 1 FROM pg_policies 
  WHERE schemaname = 'public' 
    AND tablename = 'photo_records'
    AND policyname = 'Users can view accessible photo records'
);

-- 如果都存在但還是看不到
SELECT 
  '⚠️ 函數和策略都存在，但可能有其他問題。請檢查：
  1. 是否真的被授予權限（檢查 floor_plan_permissions 表）
  2. 策略是否使用了正確的函數
  3. 是否有其他衝突的策略' AS suggestion
WHERE EXISTS (
  SELECT 1 FROM pg_proc 
  WHERE proname = 'has_floor_plan_access' 
    AND prosecdef = true
)
AND EXISTS (
  SELECT 1 FROM pg_policies 
  WHERE schemaname = 'public' 
    AND tablename = 'photo_records'
    AND policyname = 'Users can view accessible photo records'
);

SELECT 
  '✅ 診斷完成！' AS final_message,
  '請檢查上述結果，找出問題所在。' AS next_step;
