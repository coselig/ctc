-- 修復無限遞迴問題的 RLS 政策
-- 使用更簡單的邏輯避免自我引用

-- 先刪除所有現有政策
DROP POLICY IF EXISTS "floor_plan_permissions_select_policy" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "floor_plan_permissions_insert_policy" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "floor_plan_permissions_update_policy" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "floor_plan_permissions_delete_policy" ON public.floor_plan_permissions;

-- 暫時禁用 RLS 來避免遞迴問題
ALTER TABLE public.floor_plan_permissions DISABLE ROW LEVEL SECURITY;

-- 創建一個簡單的視圖來獲取擁有者信息，避免遞迴
CREATE OR REPLACE VIEW floor_plan_owners AS
SELECT DISTINCT 
    floor_plan_url,
    user_id as owner_id
FROM public.floor_plan_permissions 
WHERE is_owner = true;

-- 重新啟用 RLS
ALTER TABLE public.floor_plan_permissions ENABLE ROW LEVEL SECURITY;

-- 1. SELECT 政策：使用者可以查看自己的記錄或擁有者可以查看所有記錄
CREATE POLICY "fp_select_policy" ON public.floor_plan_permissions
    FOR SELECT TO authenticated 
    USING (
        -- 查看自己的記錄
        user_id::uuid = auth.uid() 
        OR 
        -- 或者當前用戶是該設計圖的擁有者
        EXISTS (
            SELECT 1 FROM floor_plan_owners fpo
            WHERE fpo.floor_plan_url = floor_plan_permissions.floor_plan_url 
            AND fpo.owner_id::uuid = auth.uid()
        )
    );

-- 2. INSERT 政策：分兩種情況
CREATE POLICY "fp_insert_policy" ON public.floor_plan_permissions
    FOR INSERT TO authenticated 
    WITH CHECK (
        -- 情況1：創建新設計圖的擁有者記錄（第一筆記錄）
        (
            is_owner = true 
            AND user_id::uuid = auth.uid()
            AND NOT EXISTS (
                SELECT 1 FROM public.floor_plan_permissions fp_check 
                WHERE fp_check.floor_plan_url = floor_plan_url
            )
        )
        OR
        -- 情況2：擁有者添加其他用戶的權限
        (
            is_owner = false
            AND EXISTS (
                SELECT 1 FROM floor_plan_owners fpo
                WHERE fpo.floor_plan_url = floor_plan_url 
                AND fpo.owner_id::uuid = auth.uid()
            )
        )
    );

-- 3. UPDATE 政策：只有擁有者可以更新
CREATE POLICY "fp_update_policy" ON public.floor_plan_permissions
    FOR UPDATE TO authenticated 
    USING (
        EXISTS (
            SELECT 1 FROM floor_plan_owners fpo
            WHERE fpo.floor_plan_url = floor_plan_permissions.floor_plan_url 
            AND fpo.owner_id::uuid = auth.uid()
        )
    );

-- 4. DELETE 政策：只有擁有者可以刪除
CREATE POLICY "fp_delete_policy" ON public.floor_plan_permissions
    FOR DELETE TO authenticated 
    USING (
        EXISTS (
            SELECT 1 FROM floor_plan_owners fpo
            WHERE fpo.floor_plan_url = floor_plan_permissions.floor_plan_url 
            AND fpo.owner_id::uuid = auth.uid()
        )
    );

-- 給視圖設置權限
GRANT SELECT ON floor_plan_owners TO authenticated;
