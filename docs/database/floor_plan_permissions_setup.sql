-- 創建 RPC 函數以獲取設計圖權限列表（包含用戶資訊）
CREATE OR REPLACE FUNCTION get_floor_plan_permissions(p_floor_plan_id uuid)
RETURNS TABLE (
  id uuid,
  floor_plan_id uuid,
  user_id uuid,
  permission_level integer,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  user_email text,
  user_full_name text
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    fpp.id,
    fpp.floor_plan_id,
    fpp.user_id,
    fpp.permission_level,
    fpp.created_at,
    fpp.updated_at,
    p.email as user_email,
    p.full_name as user_full_name
  FROM public.floor_plan_permissions fpp
  LEFT JOIN public.profiles p ON fpp.user_id = p.id
  WHERE fpp.floor_plan_id = p_floor_plan_id
  ORDER BY fpp.created_at DESC;
END;
$$;

-- 授予執行權限
GRANT EXECUTE ON FUNCTION get_floor_plan_permissions(uuid) TO authenticated;

-- 創建索引以提升查詢性能
CREATE INDEX IF NOT EXISTS idx_floor_plan_permissions_floor_plan_id 
ON public.floor_plan_permissions(floor_plan_id);

CREATE INDEX IF NOT EXISTS idx_floor_plan_permissions_user_id 
ON public.floor_plan_permissions(user_id);

-- 確保 floor_plan_permissions 表有正確的 RLS 策略
ALTER TABLE public.floor_plan_permissions ENABLE ROW LEVEL SECURITY;

-- 刪除舊的策略（如果存在）
DROP POLICY IF EXISTS "Users can view permissions for their floor plans" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "Owners can manage permissions" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "Admins can manage permissions" ON public.floor_plan_permissions;

-- 創建新的 RLS 策略

-- 1. 用戶可以查看自己有權限的設計圖的權限列表
CREATE POLICY "Users can view permissions for accessible floor plans"
ON public.floor_plan_permissions
FOR SELECT
USING (
  -- 是設計圖擁有者
  EXISTS (
    SELECT 1 FROM public.floor_plans fp
    WHERE fp.id = floor_plan_permissions.floor_plan_id
    AND fp.user_id = auth.uid()
  )
  OR
  -- 或是該設計圖的管理員
  EXISTS (
    SELECT 1 FROM public.floor_plan_permissions fpp
    WHERE fpp.floor_plan_id = floor_plan_permissions.floor_plan_id
    AND fpp.user_id = auth.uid()
    AND fpp.permission_level = 3
  )
);

-- 2. 擁有者和管理員可以添加/更新/刪除權限
CREATE POLICY "Owners and admins can manage permissions"
ON public.floor_plan_permissions
FOR ALL
USING (
  -- 是設計圖擁有者
  EXISTS (
    SELECT 1 FROM public.floor_plans fp
    WHERE fp.id = floor_plan_permissions.floor_plan_id
    AND fp.user_id = auth.uid()
  )
  OR
  -- 或是該設計圖的管理員
  EXISTS (
    SELECT 1 FROM public.floor_plan_permissions fpp
    WHERE fpp.floor_plan_id = floor_plan_permissions.floor_plan_id
    AND fpp.user_id = auth.uid()
    AND fpp.permission_level = 3
  )
);

-- 更新 photo_records 的 RLS 策略，考慮權限系統
DROP POLICY IF EXISTS "Users can view their own photo records" ON public.photo_records;
DROP POLICY IF EXISTS "Users can insert their own photo records" ON public.photo_records;
DROP POLICY IF EXISTS "Users can update their own photo records" ON public.photo_records;
DROP POLICY IF EXISTS "Users can delete their own photo records" ON public.photo_records;

-- 1. 用戶可以查看：自己的記錄 或 有權限的設計圖的記錄
CREATE POLICY "Users can view accessible photo records"
ON public.photo_records
FOR SELECT
USING (
  user_id = auth.uid()
  OR
  -- 是設計圖擁有者
  EXISTS (
    SELECT 1 FROM public.floor_plans fp
    WHERE fp.id = photo_records.floor_plan_id
    AND fp.user_id = auth.uid()
  )
  OR
  -- 或有任何等級的權限（檢視者、編輯者、管理員）
  EXISTS (
    SELECT 1 FROM public.floor_plan_permissions fpp
    WHERE fpp.floor_plan_id = photo_records.floor_plan_id
    AND fpp.user_id = auth.uid()
  )
);

-- 2. 用戶可以新增記錄：自己的設計圖 或 有編輯權限的設計圖
CREATE POLICY "Users can insert photo records with edit permission"
ON public.photo_records
FOR INSERT
WITH CHECK (
  user_id = auth.uid()
  AND (
    -- 是設計圖擁有者
    EXISTS (
      SELECT 1 FROM public.floor_plans fp
      WHERE fp.id = photo_records.floor_plan_id
      AND fp.user_id = auth.uid()
    )
    OR
    -- 或有編輯權限（編輯者或管理員，permission_level >= 2）
    EXISTS (
      SELECT 1 FROM public.floor_plan_permissions fpp
      WHERE fpp.floor_plan_id = photo_records.floor_plan_id
      AND fpp.user_id = auth.uid()
      AND fpp.permission_level >= 2
    )
  )
);

-- 3. 用戶可以更新：自己的記錄
CREATE POLICY "Users can update their own photo records"
ON public.photo_records
FOR UPDATE
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 4. 用戶可以刪除：自己的記錄
CREATE POLICY "Users can delete their own photo records"
ON public.photo_records
FOR DELETE
USING (user_id = auth.uid());

-- 更新 floor_plans 的 RLS 策略
DROP POLICY IF EXISTS "Users can view their own floor plans" ON public.floor_plans;
DROP POLICY IF EXISTS "Users can insert their own floor plans" ON public.floor_plans;
DROP POLICY IF EXISTS "Users can update their own floor plans" ON public.floor_plans;
DROP POLICY IF EXISTS "Users can delete their own floor plans" ON public.floor_plans;

-- 1. 用戶可以查看：自己的設計圖 或 有權限的設計圖
CREATE POLICY "Users can view accessible floor plans"
ON public.floor_plans
FOR SELECT
USING (
  user_id = auth.uid()
  OR
  EXISTS (
    SELECT 1 FROM public.floor_plan_permissions fpp
    WHERE fpp.floor_plan_id = floor_plans.id
    AND fpp.user_id = auth.uid()
  )
);

-- 2. 用戶可以新增：自己的設計圖
CREATE POLICY "Users can insert their own floor plans"
ON public.floor_plans
FOR INSERT
WITH CHECK (user_id = auth.uid());

-- 3. 用戶可以更新：自己的設計圖 或 有管理權限的設計圖
CREATE POLICY "Users can update floor plans with admin permission"
ON public.floor_plans
FOR UPDATE
USING (
  user_id = auth.uid()
  OR
  EXISTS (
    SELECT 1 FROM public.floor_plan_permissions fpp
    WHERE fpp.floor_plan_id = floor_plans.id
    AND fpp.user_id = auth.uid()
    AND fpp.permission_level = 3
  )
)
WITH CHECK (
  user_id = auth.uid()
  OR
  EXISTS (
    SELECT 1 FROM public.floor_plan_permissions fpp
    WHERE fpp.floor_plan_id = floor_plans.id
    AND fpp.user_id = auth.uid()
    AND fpp.permission_level = 3
  )
);

-- 4. 用戶可以刪除：自己的設計圖
CREATE POLICY "Users can delete their own floor plans"
ON public.floor_plans
FOR DELETE
USING (user_id = auth.uid());
