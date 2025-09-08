-- 簡化版本：只創建必要的 RPC 函數
-- 如果上面的腳本有問題，請使用這個版本

-- 方案 1: 最簡單的 RPC 函數
CREATE OR REPLACE FUNCTION get_all_users()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    result json;
BEGIN
    SELECT json_agg(
        json_build_object(
            'id', id::text,
            'email', email,
            'created_at', created_at
        )
    )
    INTO result
    FROM auth.users
    WHERE email IS NOT NULL
    ORDER BY created_at DESC;
    
    RETURN COALESCE(result, '[]'::json);
END;
$$;

-- 設置權限
GRANT EXECUTE ON FUNCTION get_all_users() TO authenticated;
GRANT EXECUTE ON FUNCTION get_all_users() TO anon;

-- 方案 2: 如果上面不行，嘗試這個更簡單的版本
CREATE OR REPLACE FUNCTION list_users()
RETURNS TABLE (
    user_id text,
    user_email text,
    user_created_at timestamptz
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT 
        id::text as user_id,
        email as user_email,
        created_at as user_created_at
    FROM auth.users
    WHERE email IS NOT NULL
    ORDER BY created_at DESC;
$$;

-- 設置權限
GRANT EXECUTE ON FUNCTION list_users() TO authenticated;
GRANT EXECUTE ON FUNCTION list_users() TO anon;
