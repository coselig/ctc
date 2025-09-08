-- 修復 floor_plan_permissions 表的 RLS 政策
-- 解決插入權限記錄被 RLS 阻止的問題

-- 先檢查表是否存在 RLS
-- 如果存在問題的政策，先刪除它們
DROP POLICY IF EXISTS "floor_plan_permissions_select_policy" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "floor_plan_permissions_insert_policy" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "floor_plan_permissions_update_policy" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "floor_plan_permissions_delete_policy" ON public.floor_plan_permissions;

-- 確保 RLS 已啟用
ALTER TABLE public.floor_plan_permissions ENABLE ROW LEVEL SECURITY;

-- 1. SELECT 政策：使用者可以查看自己有權限的記錄或自己是擁有者的記錄
CREATE POLICY "floor_plan_permissions_select_policy" ON public.floor_plan_permissions
    FOR SELECT TO authenticated 
    USING (
        user_id::uuid = auth.uid() 
        OR 
        EXISTS (
            SELECT 1 FROM public.floor_plan_permissions fp2 
            WHERE fp2.floor_plan_url = floor_plan_permissions.floor_plan_url 
            AND fp2.user_id::uuid = auth.uid() 
            AND fp2.is_owner = true
        )
    );

-- 2. INSERT 政策：只有擁有者可以插入新的權限記錄
CREATE POLICY "floor_plan_permissions_insert_policy" ON public.floor_plan_permissions
    FOR INSERT TO authenticated 
    WITH CHECK (
        -- 檢查當前使用者是該設計圖的擁有者
        EXISTS (
            SELECT 1 FROM public.floor_plan_permissions fp_owner 
            WHERE fp_owner.floor_plan_url = floor_plan_url 
            AND fp_owner.user_id::uuid = auth.uid() 
            AND fp_owner.is_owner = true
        )
        OR
        -- 或者這是第一筆記錄（自己成為擁有者）
        (
            is_owner = true 
            AND user_id::uuid = auth.uid()
            AND NOT EXISTS (
                SELECT 1 FROM public.floor_plan_permissions fp_existing 
                WHERE fp_existing.floor_plan_url = floor_plan_url
            )
        )
    );

-- 3. UPDATE 政策：只有擁有者可以更新權限記錄
CREATE POLICY "floor_plan_permissions_update_policy" ON public.floor_plan_permissions
    FOR UPDATE TO authenticated 
    USING (
        EXISTS (
            SELECT 1 FROM public.floor_plan_permissions fp_owner 
            WHERE fp_owner.floor_plan_url = floor_plan_permissions.floor_plan_url 
            AND fp_owner.user_id::uuid = auth.uid() 
            AND fp_owner.is_owner = true
        )
    );

-- 4. DELETE 政策：只有擁有者可以刪除權限記錄
CREATE POLICY "floor_plan_permissions_delete_policy" ON public.floor_plan_permissions
    FOR DELETE TO authenticated 
    USING (
        EXISTS (
            SELECT 1 FROM public.floor_plan_permissions fp_owner 
            WHERE fp_owner.floor_plan_url = floor_plan_permissions.floor_plan_url 
            AND fp_owner.user_id::uuid = auth.uid() 
            AND fp_owner.is_owner = true
        )
    );

-- 測試插入一筆測試記錄來驗證政策（可選）
-- 這個會被正常的應用程式流程取代，這裡只是為了測試
/*
INSERT INTO public.floor_plan_permissions (
    floor_plan_id,
    floor_plan_url,
    floor_plan_name,
    user_id,
    user_email,
    permission_level,
    is_owner,
    created_at,
    updated_at
) VALUES (
    'test_plan',
    'https://example.com/test.jpg',
    'Test Plan',
    auth.uid()::text,
    (SELECT email FROM auth.users WHERE id = auth.uid()),
    3,
    true,
    NOW(),
    NOW()
);
*/
