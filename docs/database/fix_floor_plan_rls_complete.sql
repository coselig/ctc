-- 完整修正設計圖權限系統的 RLS 策略
-- 
-- 問題：floor_plans 和 photo_records 查詢 floor_plan_permissions 表會造成遞迴
-- 解決方案：使用 SECURITY DEFINER 函數繞過 RLS 進行權限檢查

-- ============================================
-- 第一步：創建權限檢查函數（繞過 RLS）
-- ============================================

-- 函數：檢查用戶是否有設計圖的存取權限（任何等級）
CREATE OR REPLACE FUNCTION has_floor_plan_access(
  p_floor_plan_id uuid,
  p_user_id uuid DEFAULT auth.uid()
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER  -- 以函數擁有者權限執行，繞過 RLS
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

-- 函數：檢查用戶是否有編輯權限（等級 >= 2）
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

-- 函數：檢查用戶是否有管理權限（等級 = 3 或擁有者）
CREATE OR REPLACE FUNCTION has_floor_plan_admin_access(
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
  
  -- 檢查是否有管理權限
  IF EXISTS (
    SELECT 1 FROM public.floor_plan_permissions
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
GRANT EXECUTE ON FUNCTION has_floor_plan_edit_access(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION has_floor_plan_admin_access(uuid, uuid) TO authenticated;

-- ============================================
-- 第二步：修正 floor_plan_permissions 策略
-- ============================================

ALTER TABLE public.floor_plan_permissions ENABLE ROW LEVEL SECURITY;

-- 刪除所有舊策略
DROP POLICY IF EXISTS "Users can view permissions for their floor plans" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "Owners can manage permissions" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "Admins can manage permissions" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "Users can view permissions for accessible floor plans" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "Owners and admins can manage permissions" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "Only floor plan owners can view permissions" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "Only floor plan owners can manage permissions" ON public.floor_plan_permissions;

-- 查看權限：擁有者 或 管理員
CREATE POLICY "Owners and admins can view permissions"
ON public.floor_plan_permissions
FOR SELECT
USING (
  has_floor_plan_admin_access(floor_plan_id, auth.uid())
);

-- 管理權限：擁有者 或 管理員
CREATE POLICY "Owners and admins can manage permissions"
ON public.floor_plan_permissions
FOR ALL
USING (
  has_floor_plan_admin_access(floor_plan_id, auth.uid())
)
WITH CHECK (
  has_floor_plan_admin_access(floor_plan_id, auth.uid())
);

-- ============================================
-- 第三步：修正 floor_plans 策略
-- ============================================

ALTER TABLE public.floor_plans ENABLE ROW LEVEL SECURITY;

-- 刪除所有舊策略
DROP POLICY IF EXISTS "Users can view their own floor plans" ON public.floor_plans;
DROP POLICY IF EXISTS "Users can insert their own floor plans" ON public.floor_plans;
DROP POLICY IF EXISTS "Users can update their own floor plans" ON public.floor_plans;
DROP POLICY IF EXISTS "Users can delete their own floor plans" ON public.floor_plans;
DROP POLICY IF EXISTS "Users can view accessible floor plans" ON public.floor_plans;
DROP POLICY IF EXISTS "Users can update floor plans with admin permission" ON public.floor_plans;

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

-- 3. 更新：自己的設計圖 或 有管理權限的設計圖
CREATE POLICY "Users can update floor plans with admin access"
ON public.floor_plans
FOR UPDATE
USING (
  user_id = auth.uid()
  OR has_floor_plan_admin_access(id, auth.uid())
)
WITH CHECK (
  user_id = auth.uid()
  OR has_floor_plan_admin_access(id, auth.uid())
);

-- 4. 刪除：只能刪除自己的設計圖
CREATE POLICY "Users can delete their own floor plans"
ON public.floor_plans
FOR DELETE
USING (user_id = auth.uid());

-- ============================================
-- 第四步：修正 photo_records 策略
-- ============================================

ALTER TABLE public.photo_records ENABLE ROW LEVEL SECURITY;

-- 刪除所有舊策略
DROP POLICY IF EXISTS "Users can view their own photo records" ON public.photo_records;
DROP POLICY IF EXISTS "Users can insert their own photo records" ON public.photo_records;
DROP POLICY IF EXISTS "Users can update their own photo records" ON public.photo_records;
DROP POLICY IF EXISTS "Users can delete their own photo records" ON public.photo_records;
DROP POLICY IF EXISTS "Users can view accessible photo records" ON public.photo_records;
DROP POLICY IF EXISTS "Users can insert photo records with edit permission" ON public.photo_records;

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
-- 第五步：添加註解說明
-- ============================================

COMMENT ON FUNCTION has_floor_plan_access(uuid, uuid) IS 
'檢查用戶是否有設計圖的存取權限（任何等級）。使用 SECURITY DEFINER 繞過 RLS，避免遞迴。';

COMMENT ON FUNCTION has_floor_plan_edit_access(uuid, uuid) IS 
'檢查用戶是否有設計圖的編輯權限（等級 >= 2）。使用 SECURITY DEFINER 繞過 RLS，避免遞迴。';

COMMENT ON FUNCTION has_floor_plan_admin_access(uuid, uuid) IS 
'檢查用戶是否有設計圖的管理權限（等級 = 3 或擁有者）。使用 SECURITY DEFINER 繞過 RLS，避免遞迴。';

-- ============================================
-- 完成！
-- ============================================

-- 權限等級說明：
-- Level 1: 檢視者 - 只能查看設計圖和照片
-- Level 2: 編輯者 - 可以新增和編輯照片
-- Level 3: 管理員 - 可以管理其他成員的權限

-- 測試建議：
-- 1. 測試擁有者可以查看、編輯、刪除自己的設計圖
-- 2. 測試被授權用戶可以根據權限等級查看/編輯設計圖
-- 3. 測試未授權用戶無法存取其他人的設計圖
-- 4. 測試管理員可以管理權限列表
