-- ========================================
-- 診斷腳本：照片記錄頁面的設計圖權限問題
-- ========================================
-- 目的：檢查為什麼檢視者和編輯者無法在照片記錄頁面看到被授權的設計圖

-- 步驟 1：確認當前用戶
SELECT 
  auth.uid() as "當前用戶ID",
  email as "用戶郵箱"
FROM auth.users
WHERE id = auth.uid();

-- 步驟 2：檢查用戶的設計圖權限記錄
SELECT 
  fp.id as "設計圖ID",
  fp.name as "設計圖名稱",
  fp.user_id as "擁有者ID",
  fpp.user_id as "授權用戶ID",
  fpp.permission_level as "權限等級",
  CASE fpp.permission_level
    WHEN 1 THEN '檢視者'
    WHEN 2 THEN '編輯者'
    WHEN 3 THEN '管理員'
    ELSE '未知'
  END as "權限名稱"
FROM floor_plan_permissions fpp
JOIN floor_plans fp ON fp.id = fpp.floor_plan_id
WHERE fpp.user_id = auth.uid()
ORDER BY fp.created_at DESC;

-- 步驟 3：測試 SELECT 查詢（模擬 Flutter 代碼的第一步）
-- 這是 getUserFloorPlans() 的第一步：獲取自己的設計圖
SELECT 
  *,
  user_id as is_owner
FROM floor_plans
WHERE user_id = auth.uid();

-- 步驟 4：測試 SELECT 查詢（模擬 Flutter 代碼的第二步）
-- 這是 getUserFloorPlans() 的第二步：獲取權限記錄
SELECT 
  floor_plan_id,
  permission_level
FROM floor_plan_permissions
WHERE user_id = auth.uid();

-- 步驟 5：檢查 RLS 策略是否正確
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename IN ('floor_plans', 'floor_plan_permissions')
ORDER BY tablename, policyname;

-- 步驟 6：測試函數權限檢查
-- 測試 has_floor_plan_access 函數
SELECT 
  fp.id as "設計圖ID",
  fp.name as "設計圖名稱",
  has_floor_plan_access(fp.id, auth.uid()) as "是否有訪問權限"
FROM floor_plans fp
ORDER BY fp.created_at DESC
LIMIT 10;

-- 步驟 7：檢查完整的設計圖列表（包含權限資訊）
WITH user_permissions AS (
  SELECT 
    floor_plan_id,
    permission_level
  FROM floor_plan_permissions
  WHERE user_id = auth.uid()
)
SELECT 
  fp.id as "設計圖ID",
  fp.name as "設計圖名稱",
  fp.user_id as "擁有者ID",
  (fp.user_id = auth.uid()) as "是否為擁有者",
  up.permission_level as "授權等級",
  CASE 
    WHEN fp.user_id = auth.uid() THEN '擁有者'
    WHEN up.permission_level = 1 THEN '檢視者'
    WHEN up.permission_level = 2 THEN '編輯者'
    WHEN up.permission_level = 3 THEN '管理員'
    ELSE '無權限'
  END as "角色",
  fp.created_at as "創建時間"
FROM floor_plans fp
LEFT JOIN user_permissions up ON up.floor_plan_id = fp.id
WHERE fp.user_id = auth.uid() OR up.permission_level IS NOT NULL
ORDER BY fp.created_at DESC;

-- 步驟 8：檢查 floor_plan_permissions 表的 SELECT 策略
-- 確認用戶是否能查詢自己的權限記錄
DO $$
DECLARE
  test_count integer;
BEGIN
  SELECT COUNT(*) INTO test_count
  FROM floor_plan_permissions
  WHERE user_id = auth.uid();
  
  RAISE NOTICE '用戶有 % 條權限記錄', test_count;
END $$;

-- ========================================
-- 診斷建議
-- ========================================
/*
如果步驟 4 返回空結果，表示：
  - floor_plan_permissions 表的 SELECT 策略可能有問題
  - 需要檢查是否允許用戶查詢自己的權限記錄

如果步驟 7 只顯示自己的設計圖，表示：
  - 可能 RLS 策略阻止了查詢被授權的設計圖
  - 需要修改 floor_plans 表的 SELECT 策略

解決方案：
  確保 floor_plan_permissions 的 SELECT 策略允許：
  - 設計圖擁有者查看所有權限記錄
  - 被授權用戶查看自己的權限記錄
*/
