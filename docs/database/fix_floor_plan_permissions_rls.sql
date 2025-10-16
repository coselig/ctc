-- 修正 floor_plan_permissions RLS 無限遞迴問題
-- 
-- 問題：floor_plan_permissions 的策略中查詢自己的表，造成無限遞迴
-- 解決方案：簡化策略，只檢查 floor_plans 表的 user_id，不查詢 permissions 表本身

-- 確保啟用 RLS
ALTER TABLE public.floor_plan_permissions ENABLE ROW LEVEL SECURITY;

-- 刪除所有舊的策略
DROP POLICY IF EXISTS "Users can view permissions for their floor plans" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "Owners can manage permissions" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "Admins can manage permissions" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "Users can view permissions for accessible floor plans" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "Owners and admins can manage permissions" ON public.floor_plan_permissions;

-- 創建簡化的策略（避免遞迴）

-- 1. 只有設計圖擁有者可以查看權限列表
CREATE POLICY "Only floor plan owners can view permissions"
ON public.floor_plan_permissions
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.floor_plans fp
    WHERE fp.id = floor_plan_permissions.floor_plan_id
    AND fp.user_id = auth.uid()
  )
);

-- 2. 只有設計圖擁有者可以管理權限（新增/更新/刪除）
CREATE POLICY "Only floor plan owners can manage permissions"
ON public.floor_plan_permissions
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.floor_plans fp
    WHERE fp.id = floor_plan_permissions.floor_plan_id
    AND fp.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.floor_plans fp
    WHERE fp.id = floor_plan_permissions.floor_plan_id
    AND fp.user_id = auth.uid()
  )
);

-- 注意：
-- - 管理員權限功能需要在應用層實現
-- - 如需支援管理員管理權限，應該通過 SECURITY DEFINER 函數實現
-- - 這樣可以避免 RLS 遞迴問題

COMMENT ON POLICY "Only floor plan owners can view permissions" ON public.floor_plan_permissions IS 
'簡化策略：只允許設計圖擁有者查看權限列表，避免 RLS 遞迴';

COMMENT ON POLICY "Only floor plan owners can manage permissions" ON public.floor_plan_permissions IS 
'簡化策略：只允許設計圖擁有者管理權限，管理員功能應通過應用層或 RPC 函數實現';
