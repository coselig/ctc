-- 驗證和測試所有 RLS 權限修正
-- 
-- 這個腳本用於：
-- 1. 檢查所有 SECURITY DEFINER 函數是否已創建
-- 2. 檢查所有 RLS 策略是否已更新
-- 3. 列出可能有問題的舊策略

-- ============================================
-- 第一部分：檢查 SECURITY DEFINER 函數
-- ============================================

SELECT 
  '🔍 檢查 SECURITY DEFINER 函數' AS step;

-- 專案管理函數
SELECT 
  CASE 
    WHEN COUNT(*) = 2 THEN '✅ 專案管理函數：已創建 (2/2)'
    ELSE '❌ 專案管理函數：缺少 ' || (2 - COUNT(*)) || ' 個函數'
  END AS status
FROM pg_proc 
WHERE proname IN ('has_project_access', 'has_project_admin_access')
  AND prosecdef = true;

-- 設計圖管理函數
SELECT 
  CASE 
    WHEN COUNT(*) = 3 THEN '✅ 設計圖管理函數：已創建 (3/3)'
    ELSE '❌ 設計圖管理函數：缺少 ' || (3 - COUNT(*)) || ' 個函數'
  END AS status
FROM pg_proc 
WHERE proname IN ('has_floor_plan_access', 'has_floor_plan_edit_access', 'has_floor_plan_admin_access')
  AND prosecdef = true;

-- 列出所有已創建的權限函數
SELECT 
  proname AS function_name,
  prosecdef AS is_security_definer,
  '✅' AS status
FROM pg_proc 
WHERE proname LIKE 'has_%_access'
ORDER BY proname;

-- ============================================
-- 第二部分：檢查 RLS 策略
-- ============================================

SELECT 
  '🔍 檢查 RLS 策略' AS step;

-- 專案管理相關表的策略
SELECT 
  tablename,
  COUNT(*) AS policy_count,
  CASE 
    WHEN tablename = 'projects' AND COUNT(*) >= 4 THEN '✅'
    WHEN tablename = 'project_members' AND COUNT(*) >= 2 THEN '✅'
    WHEN tablename = 'project_tasks' AND COUNT(*) >= 2 THEN '✅'
    WHEN tablename = 'project_comments' AND COUNT(*) >= 4 THEN '✅'
    WHEN tablename = 'project_timeline' AND COUNT(*) >= 2 THEN '✅'
    WHEN tablename = 'project_clients' AND COUNT(*) >= 2 THEN '✅'
    ELSE '⚠️ 策略數量可能不足'
  END AS status
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename LIKE 'project%'
GROUP BY tablename
ORDER BY tablename;

-- 設計圖相關表的策略
SELECT 
  tablename,
  COUNT(*) AS policy_count,
  CASE 
    WHEN tablename = 'floor_plans' AND COUNT(*) >= 4 THEN '✅'
    WHEN tablename = 'floor_plan_permissions' AND COUNT(*) >= 2 THEN '✅'
    WHEN tablename = 'photo_records' AND COUNT(*) >= 4 THEN '✅'
    ELSE '⚠️ 策略數量可能不足'
  END AS status
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('floor_plans', 'floor_plan_permissions', 'photo_records')
GROUP BY tablename
ORDER BY tablename;

-- ============================================
-- 第三部分：列出所有現有策略（詳細）
-- ============================================

SELECT 
  '📋 專案管理相關策略列表' AS step;

SELECT 
  tablename,
  policyname,
  cmd AS command,
  CASE 
    WHEN policyname LIKE '%accessible%' OR 
         policyname LIKE '%members%' OR 
         policyname LIKE '%admins%' THEN '✅ 新策略'
    ELSE '⚠️ 可能是舊策略'
  END AS policy_type
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename LIKE 'project%'
ORDER BY tablename, policyname;

SELECT 
  '📋 設計圖相關策略列表' AS step;

SELECT 
  tablename,
  policyname,
  cmd AS command,
  CASE 
    WHEN policyname LIKE '%accessible%' OR 
         policyname LIKE '%admin%' OR 
         policyname LIKE '%edit%' THEN '✅ 新策略'
    ELSE '⚠️ 可能是舊策略'
  END AS policy_type
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('floor_plans', 'floor_plan_permissions', 'photo_records')
ORDER BY tablename, policyname;

-- ============================================
-- 第四部分：檢查問題策略（可能導致遞迴）
-- ============================================

SELECT 
  '🔍 檢查可能有問題的策略' AS step;

-- 檢查是否有策略使用了直接的 EXISTS 查詢（可能導致遞迴）
SELECT 
  schemaname,
  tablename,
  policyname,
  '⚠️ 可能使用了直接查詢，建議檢查是否應該改用 SECURITY DEFINER 函數' AS warning
FROM pg_policies
WHERE schemaname = 'public'
  AND (tablename LIKE 'project%' OR tablename IN ('floor_plans', 'floor_plan_permissions', 'photo_records'))
  AND policyname NOT LIKE '%accessible%'
  AND policyname NOT LIKE '%members%'
  AND policyname NOT LIKE '%admin%'
  AND policyname NOT LIKE '%edit%'
  AND policyname NOT LIKE '%own%'
ORDER BY tablename, policyname;

-- ============================================
-- 第五部分：生成清理舊策略的 SQL
-- ============================================

SELECT 
  '🧹 生成清理舊策略的 SQL 語句' AS step;

-- 生成 DROP POLICY 語句
SELECT 
  'DROP POLICY IF EXISTS "' || policyname || '" ON ' || schemaname || '.' || tablename || ';' AS cleanup_sql
FROM pg_policies
WHERE schemaname = 'public'
  AND (tablename LIKE 'project%' OR tablename IN ('floor_plans', 'floor_plan_permissions', 'photo_records'))
  AND policyname NOT LIKE '%accessible%'
  AND policyname NOT LIKE '%members%'
  AND policyname NOT LIKE '%admin%'
  AND policyname NOT LIKE '%edit%'
  AND policyname NOT LIKE '%own%'
  AND policyname NOT LIKE '%insert%'
  AND policyname NOT LIKE '%update%'
  AND policyname NOT LIKE '%delete%'
  AND policyname NOT LIKE '%view%'
  AND policyname NOT LIKE '%manage%'
ORDER BY tablename, policyname;

-- ============================================
-- 第六部分：測試權限函數
-- ============================================

SELECT 
  '🧪 測試權限函數（需要替換 UUID）' AS step;

-- 測試專案權限函數（需要替換成實際的 UUID）
-- SELECT has_project_access('your-project-uuid', auth.uid()) AS has_access;
-- SELECT has_project_admin_access('your-project-uuid', auth.uid()) AS has_admin;

-- 測試設計圖權限函數（需要替換成實際的 UUID）
-- SELECT has_floor_plan_access('your-floor-plan-uuid', auth.uid()) AS has_access;
-- SELECT has_floor_plan_edit_access('your-floor-plan-uuid', auth.uid()) AS has_edit;
-- SELECT has_floor_plan_admin_access('your-floor-plan-uuid', auth.uid()) AS has_admin;

SELECT 
  '✅ 驗證完成！請檢查上述結果。' AS final_message,
  '如果看到 ❌ 或 ⚠️，請執行相應的修正腳本。' AS next_step;
