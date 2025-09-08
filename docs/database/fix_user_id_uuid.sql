-- 如果 user_id 欄位是 UUID 類型的修復版本

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
    
    -- 檢查當前用戶是否為設計圖擁有者 (如果 user_id 是 UUID 類型)
    SELECT EXISTS(
        SELECT 1 FROM public.floor_plan_permissions fp
        WHERE fp.floor_plan_url = p_floor_plan_url 
        AND fp.user_id = current_user_id
        AND fp.is_owner = true
    ) INTO is_owner;
    
    IF NOT is_owner THEN
        RETURN json_build_object('success', false, 'error', '只有擁有者可以添加權限');
    END IF;
    
    -- 檢查目標用戶是否已有權限
    IF EXISTS(
        SELECT 1 FROM public.floor_plan_permissions fp
        WHERE fp.floor_plan_url = p_floor_plan_url 
        AND fp.user_id = p_target_user_id
    ) THEN
        RETURN json_build_object('success', false, 'error', '用戶已有此設計圖的權限');
    END IF;
    
    -- 插入新權限記錄 (user_id 直接使用 UUID)
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
        p_target_user_id,  -- 直接使用 UUID
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
