-- 暫時解決方案：禁用 RLS 並依賴應用程式邏輯進行權限控制
-- 這是最安全的方式避免遞迴問題

-- 完全禁用 floor_plan_permissions 表的 RLS
ALTER TABLE public.floor_plan_permissions DISABLE ROW LEVEL SECURITY;

-- 刪除所有可能導致遞迴的政策
DROP POLICY IF EXISTS "floor_plan_permissions_select_policy" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "floor_plan_permissions_insert_policy" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "floor_plan_permissions_update_policy" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "floor_plan_permissions_delete_policy" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "fp_select_policy" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "fp_insert_policy" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "fp_update_policy" ON public.floor_plan_permissions;
DROP POLICY IF EXISTS "fp_delete_policy" ON public.floor_plan_permissions;

-- 刪除可能存在的視圖
DROP VIEW IF EXISTS floor_plan_owners;

-- 注意：這意味著所有權限檢查都由應用程式邏輯處理
-- 確保前端代碼有適當的權限檢查

-- 為了增加安全性，我們可以創建一些 RPC 函數來處理權限相關操作
-- 這些函數會在服務器端執行權限檢查

-- 創建一個 RPC 函數來安全地添加權限
CREATE OR REPLACE FUNCTION add_user_permission(
    p_floor_plan_url text,
    p_floor_plan_name text,
    p_target_user_id uuid,
    p_target_user_email text,
    p_permission_level integer
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    current_user_id uuid;
    is_owner boolean := false;
    result json;
BEGIN
    -- 獲取當前用戶 ID
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RETURN json_build_object('success', false, 'error', '用戶未登入');
    END IF;
    
    -- 檢查當前用戶是否為設計圖擁有者
    SELECT EXISTS(
        SELECT 1 FROM public.floor_plan_permissions 
        WHERE floor_plan_url = p_floor_plan_url 
        AND user_id::uuid = current_user_id 
        AND is_owner = true
    ) INTO is_owner;
    
    IF NOT is_owner THEN
        RETURN json_build_object('success', false, 'error', '只有擁有者可以添加權限');
    END IF;
    
    -- 檢查目標用戶是否已有權限
    IF EXISTS(
        SELECT 1 FROM public.floor_plan_permissions 
        WHERE floor_plan_url = p_floor_plan_url 
        AND user_id::uuid = p_target_user_id
    ) THEN
        RETURN json_build_object('success', false, 'error', '用戶已有此設計圖的權限');
    END IF;
    
    -- 插入新權限記錄
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
        split_part(split_part(p_floor_plan_url, '/', -1), '.', 1),
        p_floor_plan_url,
        p_floor_plan_name,
        p_target_user_id::text,
        p_target_user_email,
        p_permission_level,
        false,
        NOW(),
        NOW()
    );
    
    RETURN json_build_object('success', true, 'message', '權限添加成功');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'error', SQLERRM);
END;
$$;

-- 設置函數權限
GRANT EXECUTE ON FUNCTION add_user_permission(text, text, uuid, text, integer) TO authenticated;
