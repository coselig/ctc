-- 完整修正-- ============================================
-- 第一步:刪除所有依賴的 RLS 策略
-- ============================================

-- 先禁用 RLS 並刪除所有策略(避免函數依賴問題)
ALTER TABLE photo_records DISABLE ROW LEVEL SECURITY;
ALTER TABLE floor_plans DISABLE ROW LEVEL SECURITY;
ALTER TABLE floor_plan_permissions DISABLE ROW LEVEL SECURITY;

-- 刪除 photo_reWITH CHECK (
  has_floor_plan_admin_access(floor_plan_id, auth.uid())
);

SELECT '✅ 步驟 5 完成:floor_plan_permissions RLS 策略已重建' AS status;

-- ============================================
-- 第六步:驗證設置
-- ============================================策略
DO $$ 
DECLARE 
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'photo_records'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.photo_records', pol.policyname);
  END LOOP;
END $$;

-- 刪除 floor_plans 的所有策略
DO $$ 
DECLARE 
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'floor_plans'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.floor_plans', pol.policyname);
  END LOOP;
END $$;

-- 刪除 floor_plan_permissions 的所有策略
DO $$ 
DECLARE 
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'floor_plan_permissions'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.floor_plan_permissions', pol.policyname);
  END LOOP;
END $$;

SELECT '✅ 步驟 1 完成:所有舊策略已刪除' AS status;

-- ============================================
-- 第二步:刪除並重建權限檢查函數
-- ============================================

-- 現在可以安全刪除舊函數(沒有依賴了)
DROP FUNCTION IF EXISTS has_floor_plan_access(uuid, uuid);
DROP FUNCTION IF EXISTS has_floor_plan_edit_access(uuid, uuid);
DROP FUNCTION IF EXISTS has_floor_plan_admin_access(uuid, uuid); - 強化版
-- 
-- 這個腳本會：
-- 1. 強制創建所有必要的函數
-- 2. 完全清理並重建 RLS 策略
-- 3. 確保權限檢查邏輯正確

-- ============================================
-- 第一步：強制創建權限檢查函數
-- ============================================

-- 刪除舊函數（如果存在）
DROP FUNCTION IF EXISTS has_floor_plan_access(uuid, uuid);
DROP FUNCTION IF EXISTS has_floor_plan_edit_access(uuid, uuid);
DROP FUNCTION IF EXISTS has_floor_plan_admin_access(uuid, uuid);

-- 重新創建：檢查用戶是否有設計圖的存取權限（任何等級）
CREATE FUNCTION has_floor_plan_access(
  p_floor_plan_id uuid,
  p_user_id uuid DEFAULT auth.uid()
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER  -- 關鍵：以函數擁有者權限執行，繞過 RLS
STABLE
SET search_path = public
AS $$
BEGIN
  -- 檢查是否為擁有者
  IF EXISTS (
    SELECT 1 FROM floor_plans
    WHERE id = p_floor_plan_id
    AND user_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  -- 檢查是否有任何等級的權限
  IF EXISTS (
    SELECT 1 FROM floor_plan_permissions
    WHERE floor_plan_id = p_floor_plan_id
    AND user_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  RETURN FALSE;
END;
$$;

-- 重新創建：檢查用戶是否有編輯權限（等級 >= 2）
CREATE FUNCTION has_floor_plan_edit_access(
  p_floor_plan_id uuid,
  p_user_id uuid DEFAULT auth.uid()
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
BEGIN
  -- 檢查是否為擁有者
  IF EXISTS (
    SELECT 1 FROM floor_plans
    WHERE id = p_floor_plan_id
    AND user_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  -- 檢查是否有編輯或管理權限
  IF EXISTS (
    SELECT 1 FROM floor_plan_permissions
    WHERE floor_plan_id = p_floor_plan_id
    AND user_id = p_user_id
    AND permission_level >= 2
  ) THEN
    RETURN TRUE;
  END IF;
  
  RETURN FALSE;
END;
$$;

-- 重新創建：檢查用戶是否有管理權限（等級 = 3）
CREATE FUNCTION has_floor_plan_admin_access(
  p_floor_plan_id uuid,
  p_user_id uuid DEFAULT auth.uid()
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
BEGIN
  -- 檢查是否為擁有者
  IF EXISTS (
    SELECT 1 FROM floor_plans
    WHERE id = p_floor_plan_id
    AND user_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  -- 檢查是否有管理權限
  IF EXISTS (
    SELECT 1 FROM floor_plan_permissions
    WHERE floor_plan_id = p_floor_plan_id
    AND user_id = p_user_id
    AND permission_level = 3
  ) THEN
    RETURN TRUE;
  END IF;
  
  RETURN FALSE;
END;
$$;

-- 授予執行權限
GRANT EXECUTE ON FUNCTION has_floor_plan_access(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION has_floor_plan_access(uuid, uuid) TO anon;
GRANT EXECUTE ON FUNCTION has_floor_plan_edit_access(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION has_floor_plan_edit_access(uuid, uuid) TO anon;
GRANT EXECUTE ON FUNCTION has_floor_plan_admin_access(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION has_floor_plan_admin_access(uuid, uuid) TO anon;

-- 添加註解
COMMENT ON FUNCTION has_floor_plan_access(uuid, uuid) IS 
'檢查用戶是否有設計圖的存取權限（任何等級）。使用 SECURITY DEFINER 繞過 RLS，避免遞迴。';

COMMENT ON FUNCTION has_floor_plan_edit_access(uuid, uuid) IS 
'檢查用戶是否有設計圖的編輯權限（等級 >= 2）。使用 SECURITY DEFINER 繞過 RLS，避免遞迴。';

COMMENT ON FUNCTION has_floor_plan_admin_access(uuid, uuid) IS 
'檢查用戶是否有設計圖的管理權限(等級 = 3 或擁有者)。使用 SECURITY DEFINER 繞過 RLS,避免遞迴。';

SELECT '✅ 步驟 2 完成:權限函數已創建' AS status;

-- ============================================
-- 第三步:重建 photo_records 的 RLS 策略
-- ============================================

-- 重新啟用 RLS
ALTER TABLE photo_records ENABLE ROW LEVEL SECURITY;

-- 創建新的策略

-- 1. SELECT：可以查看自己的記錄 或 有權限的設計圖的記錄
CREATE POLICY "photo_records_select_policy"
ON photo_records
FOR SELECT
TO authenticated
USING (
  user_id = auth.uid()
  OR has_floor_plan_access(floor_plan_id, auth.uid())
);

-- 2. INSERT：只能在有編輯權限的設計圖中新增照片
CREATE POLICY "photo_records_insert_policy"
ON photo_records
FOR INSERT
TO authenticated
WITH CHECK (
  user_id = auth.uid()
  AND has_floor_plan_edit_access(floor_plan_id, auth.uid())
);

-- 3. UPDATE：只能更新自己的記錄
CREATE POLICY "photo_records_update_policy"
ON photo_records
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 4. DELETE：只能刪除自己的記錄
CREATE POLICY "photo_records_delete_policy"
ON photo_records
FOR DELETE
TO authenticated
USING (user_id = auth.uid());

SELECT '✅ 步驟 3 完成:photo_records RLS 策略已重建' AS status;

-- ============================================
-- 第四步:重建 floor_plans 的 RLS 策略
-- ============================================

-- 重新啟用 RLS
ALTER TABLE floor_plans ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 第三步：完全重置 floor_plans 的 RLS
-- ============================================

-- 禁用 RLS
ALTER TABLE floor_plans DISABLE ROW LEVEL SECURITY;

-- 刪除所有策略
DO $$ 
DECLARE 
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'floor_plans'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.floor_plans', pol.policyname);
  END LOOP;
END $$;

-- 重新啟用 RLS
ALTER TABLE floor_plans ENABLE ROW LEVEL SECURITY;

-- 創建新的策略

-- 1. SELECT：可以查看自己的 或 有權限的設計圖
CREATE POLICY "floor_plans_select_policy"
ON floor_plans
FOR SELECT
TO authenticated
USING (
  user_id = auth.uid()
  OR has_floor_plan_access(id, auth.uid())
);

-- 2. INSERT：只能新增自己的設計圖
CREATE POLICY "floor_plans_insert_policy"
ON floor_plans
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- 3. UPDATE：只能更新自己的設計圖
CREATE POLICY "floor_plans_update_policy"
ON floor_plans
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 4. DELETE：只能刪除自己的設計圖
CREATE POLICY "floor_plans_delete_policy"
ON floor_plans
FOR DELETE
TO authenticated
USING (user_id = auth.uid());

SELECT '✅ 步驟 4 完成:floor_plans RLS 策略已重建' AS status;

-- ============================================
-- 第五步:重建 floor_plan_permissions 的 RLS 策略
-- ============================================

-- 重新啟用 RLS
ALTER TABLE floor_plan_permissions ENABLE ROW LEVEL SECURITY;

-- 創建新的策略

-- 1. SELECT：擁有者和管理員可以查看權限
CREATE POLICY "floor_plan_permissions_select_policy"
ON floor_plan_permissions
FOR SELECT
TO authenticated
USING (
  has_floor_plan_admin_access(floor_plan_id, auth.uid())
);

-- 2. ALL：擁有者和管理員可以管理權限
CREATE POLICY "floor_plan_permissions_manage_policy"
ON floor_plan_permissions
FOR ALL
TO authenticated
USING (
  has_floor_plan_admin_access(floor_plan_id, auth.uid())
)
WITH CHECK (
  has_floor_plan_admin_access(floor_plan_id, auth.uid())
);

SELECT '✅ 步驟 4 完成：floor_plan_permissions RLS 策略已重建' AS status;

-- ============================================
-- 第五步：驗證設置
-- ============================================

-- 檢查函數
SELECT 
  '檢查函數：' AS info,
  proname AS function_name,
  prosecdef AS is_security_definer
FROM pg_proc
WHERE proname IN ('has_floor_plan_access', 'has_floor_plan_edit_access', 'has_floor_plan_admin_access')
ORDER BY proname;

-- 檢查 photo_records 策略
SELECT 
  '檢查 photo_records 策略：' AS info,
  policyname,
  cmd AS command
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'photo_records'
ORDER BY cmd;

-- 檢查 floor_plans 策略
SELECT 
  '檢查 floor_plans 策略：' AS info,
  policyname,
  cmd AS command
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'floor_plans'
ORDER BY cmd;

-- ============================================
-- 完成！
-- ============================================

SELECT 
  '🎉 完整修正完成！' AS message,
  '✅ 所有函數已創建' AS step1,
  '✅ 所有 RLS 策略已重建' AS step2,
  '✅ 照片記錄權限應該可以正常運作了' AS step3,
  '請測試：被授權的用戶應該可以看到有權限的設計圖和照片記錄' AS next_step;
