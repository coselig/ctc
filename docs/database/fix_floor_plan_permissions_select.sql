-- ========================================
-- 修復設計圖權限的 SELECT 策略
-- ========================================
-- 問題：檢視者和編輯者無法查看自己的權限記錄
-- 原因：floor_plan_permissions_select_policy 只允許管理員和擁有者查看
-- 解決：允許用戶查看「自己的」權限記錄

SELECT '🔧 開始修復 floor_plan_permissions SELECT 策略...' AS status;

-- ============================================
-- 第一步：刪除現有的 SELECT 策略
-- ============================================

DROP POLICY IF EXISTS "floor_plan_permissions_select_policy" ON floor_plan_permissions;

SELECT '✅ 步驟 1 完成：已刪除舊的 SELECT 策略' AS status;

-- ============================================
-- 第二步：創建新的 SELECT 策略
-- ============================================
-- 允許以下用戶查看權限記錄：
-- 1. 設計圖的擁有者和管理員（has_floor_plan_admin_access）
-- 2. 被授權的用戶（user_id = auth.uid()）查看自己的權限

CREATE POLICY "floor_plan_permissions_select_policy"
ON floor_plan_permissions
FOR SELECT
TO authenticated
USING (
  -- 條件 1：設計圖的擁有者或管理員可以查看所有權限
  has_floor_plan_admin_access(floor_plan_id, auth.uid())
  OR
  -- 條件 2：被授權的用戶可以查看自己的權限記錄
  user_id = auth.uid()
);

SELECT '✅ 步驟 2 完成：已創建新的 SELECT 策略' AS status;

-- ============================================
-- 第三步：驗證策略
-- ============================================

-- 檢查策略是否正確創建
SELECT 
  schemaname AS "Schema",
  tablename AS "Table",
  policyname AS "Policy Name",
  permissive AS "Permissive",
  cmd AS "Command",
  qual AS "USING Expression"
FROM pg_policies
WHERE tablename = 'floor_plan_permissions'
  AND policyname = 'floor_plan_permissions_select_policy';

-- 測試查詢（以當前用戶身份）
SELECT 
  COUNT(*) AS "我的權限記錄數量"
FROM floor_plan_permissions
WHERE user_id = auth.uid();

SELECT '✅ 修復完成！' AS status;

-- ============================================
-- 測試說明
-- ============================================
/*
修復後的行為：

1. 設計圖擁有者和管理員：
   - 可以查看該設計圖的所有權限記錄
   - 用於權限管理頁面

2. 檢視者和編輯者：
   - 可以查看自己的權限記錄（user_id = auth.uid()）
   - 用於 getUserFloorPlans() 查詢被授權的設計圖

3. 其他用戶：
   - 無法查看不相關的權限記錄

測試步驟：
1. 以檢視者/編輯者身份登入
2. 執行以下查詢：
   SELECT * FROM floor_plan_permissions WHERE user_id = auth.uid();
3. 應該能看到自己的權限記錄
4. 在照片記錄頁面應該能看到被授權的設計圖
*/

-- ============================================
-- 完整的診斷查詢
-- ============================================

-- 查看當前用戶的所有設計圖（包含被授權的）
WITH user_own_plans AS (
  -- 自己的設計圖
  SELECT 
    id,
    name,
    'owner' as role,
    3 as permission_level,
    created_at
  FROM floor_plans
  WHERE user_id = auth.uid()
),
user_shared_plans AS (
  -- 被授權的設計圖
  SELECT 
    fp.id,
    fp.name,
    CASE fpp.permission_level
      WHEN 1 THEN 'viewer'
      WHEN 2 THEN 'editor'
      WHEN 3 THEN 'admin'
    END as role,
    fpp.permission_level,
    fp.created_at
  FROM floor_plan_permissions fpp
  JOIN floor_plans fp ON fp.id = fpp.floor_plan_id
  WHERE fpp.user_id = auth.uid()
)
SELECT 
  id AS "設計圖ID",
  name AS "設計圖名稱",
  role AS "角色",
  permission_level AS "權限等級",
  created_at AS "創建時間"
FROM (
  SELECT * FROM user_own_plans
  UNION ALL
  SELECT * FROM user_shared_plans
) combined
ORDER BY created_at DESC;
