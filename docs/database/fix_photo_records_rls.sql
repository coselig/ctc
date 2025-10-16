-- 快速修正照片記錄（photo_records）RLS 問題
-- 
-- 這個腳本確保照片記錄的 RLS 策略正確設置
-- 讓被授權用戶可以查看有權限的設計圖的照片

-- ============================================
-- 確保 floor_plan 權限函數存在
-- ============================================

-- 如果函數不存在，先創建
CREATE OR REPLACE FUNCTION has_floor_plan_access(
  p_floor_plan_id uuid,
  p_user_id uuid DEFAULT auth.uid()
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
  -- 檢查是否為擁有者
  IF EXISTS (
    SELECT 1 FROM public.floor_plans
    WHERE id = p_floor_plan_id
    AND user_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  -- 檢查是否有任何等級的權限
  IF EXISTS (
    SELECT 1 FROM public.floor_plan_permissions
    WHERE floor_plan_id = p_floor_plan_id
    AND user_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  RETURN FALSE;
END;
$$;

CREATE OR REPLACE FUNCTION has_floor_plan_edit_access(
  p_floor_plan_id uuid,
  p_user_id uuid DEFAULT auth.uid()
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
  -- 檢查是否為擁有者
  IF EXISTS (
    SELECT 1 FROM public.floor_plans
    WHERE id = p_floor_plan_id
    AND user_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  -- 檢查是否有編輯或管理權限
  IF EXISTS (
    SELECT 1 FROM public.floor_plan_permissions
    WHERE floor_plan_id = p_floor_plan_id
    AND user_id = p_user_id
    AND permission_level >= 2
  ) THEN
    RETURN TRUE;
  END IF;
  
  RETURN FALSE;
END;
$$;

GRANT EXECUTE ON FUNCTION has_floor_plan_access(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION has_floor_plan_edit_access(uuid, uuid) TO authenticated;

-- ============================================
-- 修正 photo_records 表的 RLS 策略
-- ============================================

ALTER TABLE public.photo_records ENABLE ROW LEVEL SECURITY;

-- 刪除所有可能存在的舊策略
DROP POLICY IF EXISTS "Users can view their own photo records" ON public.photo_records;
DROP POLICY IF EXISTS "Users can insert their own photo records" ON public.photo_records;
DROP POLICY IF EXISTS "Users can update their own photo records" ON public.photo_records;
DROP POLICY IF EXISTS "Users can delete their own photo records" ON public.photo_records;
DROP POLICY IF EXISTS "Users can view accessible photo records" ON public.photo_records;
DROP POLICY IF EXISTS "Users can insert photo records with edit permission" ON public.photo_records;
DROP POLICY IF EXISTS "Users can insert photo records with edit access" ON public.photo_records;

-- 創建新的策略

-- 1. 查看：自己的記錄 或 有權限的設計圖的記錄
CREATE POLICY "Users can view accessible photo records"
ON public.photo_records
FOR SELECT
USING (
  user_id = auth.uid()
  OR has_floor_plan_access(floor_plan_id, auth.uid())
);

-- 2. 新增：自己的設計圖 或 有編輯權限的設計圖
CREATE POLICY "Users can insert photo records with edit access"
ON public.photo_records
FOR INSERT
WITH CHECK (
  user_id = auth.uid()
  AND (
    -- 檢查設計圖是否屬於自己或有編輯權限
    EXISTS (
      SELECT 1 FROM public.floor_plans
      WHERE id = photo_records.floor_plan_id
      AND user_id = auth.uid()
    )
    OR has_floor_plan_edit_access(floor_plan_id, auth.uid())
  )
);

-- 3. 更新：自己的記錄
CREATE POLICY "Users can update their own photo records"
ON public.photo_records
FOR UPDATE
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 4. 刪除：自己的記錄
CREATE POLICY "Users can delete their own photo records"
ON public.photo_records
FOR DELETE
USING (user_id = auth.uid());

-- ============================================
-- 同時確保 floor_plans 表的策略正確
-- ============================================

ALTER TABLE public.floor_plans ENABLE ROW LEVEL SECURITY;

-- 刪除可能存在的舊策略
DROP POLICY IF EXISTS "Users can view their own floor plans" ON public.floor_plans;
DROP POLICY IF EXISTS "Users can insert their own floor plans" ON public.floor_plans;
DROP POLICY IF EXISTS "Users can update their own floor plans" ON public.floor_plans;
DROP POLICY IF EXISTS "Users can delete their own floor plans" ON public.floor_plans;
DROP POLICY IF EXISTS "Users can view accessible floor plans" ON public.floor_plans;
DROP POLICY IF EXISTS "Users can update floor plans with admin permission" ON public.floor_plans;
DROP POLICY IF EXISTS "Users can update floor plans with admin access" ON public.floor_plans;

-- 1. 查看：自己的設計圖 或 有權限的設計圖
CREATE POLICY "Users can view accessible floor plans"
ON public.floor_plans
FOR SELECT
USING (
  user_id = auth.uid()
  OR has_floor_plan_access(id, auth.uid())
);

-- 2. 新增：只能新增自己的設計圖
CREATE POLICY "Users can insert their own floor plans"
ON public.floor_plans
FOR INSERT
WITH CHECK (user_id = auth.uid());

-- 3. 更新：自己的設計圖（簡化版，不需要管理員權限）
CREATE POLICY "Users can update their own floor plans"
ON public.floor_plans
FOR UPDATE
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 4. 刪除：只能刪除自己的設計圖
CREATE POLICY "Users can delete their own floor plans"
ON public.floor_plans
FOR DELETE
USING (user_id = auth.uid());

-- ============================================
-- 驗證設置
-- ============================================

-- 檢查函數
SELECT 
  'photo_records RLS 修正完成！' AS message,
  '✅ 已創建/更新 SECURITY DEFINER 函數' AS step1,
  '✅ 已更新 photo_records 的 RLS 策略' AS step2,
  '✅ 已更新 floor_plans 的 RLS 策略' AS step3;

-- 列出 photo_records 的策略
SELECT 
  '📋 photo_records 策略：' AS info,
  policyname,
  cmd AS command
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'photo_records'
ORDER BY cmd, policyname;

-- 列出 floor_plans 的策略
SELECT 
  '📋 floor_plans 策略：' AS info,
  policyname,
  cmd AS command
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'floor_plans'
ORDER BY cmd, policyname;

COMMENT ON FUNCTION has_floor_plan_access(uuid, uuid) IS 
'檢查用戶是否有設計圖的存取權限（任何等級）。使用 SECURITY DEFINER 繞過 RLS，避免遞迴。';

COMMENT ON FUNCTION has_floor_plan_edit_access(uuid, uuid) IS 
'檢查用戶是否有設計圖的編輯權限（等級 >= 2）。使用 SECURITY DEFINER 繞過 RLS，避免遞迴。';
