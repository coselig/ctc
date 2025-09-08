-- 創建獲取當前用戶 ID 的 RPC 函數
-- 用於調試和確保用戶 ID 格式正確

CREATE OR REPLACE FUNCTION get_current_user_id()
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN auth.uid();
END;
$$;

-- 設置函數權限
GRANT EXECUTE ON FUNCTION get_current_user_id() TO authenticated;
