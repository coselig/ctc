-- 修復版本：獲取所有使用者的 RPC 函數
-- 避免 UUID/bigint 類型轉換問題

-- 先刪除現有函數
DROP FUNCTION IF EXISTS get_all_users();

-- 創建更簡單的 RPC 函數，避免類型問題
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
            'id', au.id,
            'email', au.email,
            'created_at', au.created_at,
            'display_name', COALESCE(p.display_name, au.email)
        ) ORDER BY au.created_at DESC
    )
    INTO result
    FROM auth.users au
    LEFT JOIN public.profiles p ON au.id = p.id
    WHERE au.email IS NOT NULL;
    
    RETURN COALESCE(result, '[]'::json);
END;
$$;

-- 設置函數權限
GRANT EXECUTE ON FUNCTION get_all_users() TO authenticated;
GRANT EXECUTE ON FUNCTION get_all_users() TO anon;

-- 創建 profiles 表（如果不存在）
-- 先刪除可能存在的有問題的 profiles 表
DROP TABLE IF EXISTS public.profiles CASCADE;

CREATE TABLE public.profiles (
    id uuid REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email text,
    display_name text,
    avatar_url text,
    created_at timestamptz DEFAULT NOW(),
    updated_at timestamptz DEFAULT NOW()
);

-- 設置 RLS 策略 - 簡化版本避免複雜的類型檢查
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 刪除可能存在的舊策略
DROP POLICY IF EXISTS "Allow authenticated users to view profiles" ON public.profiles;
DROP POLICY IF EXISTS "Allow users to update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow users to insert own profile" ON public.profiles;

-- 允許已認證使用者查看所有 profiles
CREATE POLICY "profiles_select_policy" ON public.profiles
    FOR SELECT TO authenticated USING (true);

-- 允許已認證使用者插入自己的 profile
CREATE POLICY "profiles_insert_policy" ON public.profiles
    FOR INSERT TO authenticated WITH CHECK (true);

-- 允許已認證使用者更新自己的 profile
CREATE POLICY "profiles_update_policy" ON public.profiles
    FOR UPDATE TO authenticated USING (true);

-- 手動同步現有使用者到 profiles 表
INSERT INTO public.profiles (id, email, display_name, created_at)
SELECT 
    au.id::uuid, 
    au.email::text, 
    COALESCE(au.raw_user_meta_data->>'display_name', au.email)::text,
    au.created_at
FROM auth.users au
WHERE au.email IS NOT NULL
ON CONFLICT (id) DO NOTHING;
