-- 獲取所有使用者的 RPC 函數
-- 在 Supabase SQL Editor 中執行這個腳本

-- 首先檢查並刪除可能存在的舊策略
DROP POLICY IF EXISTS "Allow authenticated users to view profiles" ON public.profiles;
DROP POLICY IF EXISTS "Allow users to update own profile" ON public.profiles;

-- 創建 RPC 函數
CREATE OR REPLACE FUNCTION get_all_users()
RETURNS TABLE (
    id text,
    email text,
    created_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        au.id::text,
        au.email::text,
        au.created_at
    FROM auth.users au
    WHERE au.email IS NOT NULL
    ORDER BY au.created_at DESC;
END;
$$;

-- 設置函數權限
GRANT EXECUTE ON FUNCTION get_all_users() TO authenticated;
GRANT EXECUTE ON FUNCTION get_all_users() TO anon;

-- 創建 profiles 表（如果不存在）
CREATE TABLE IF NOT EXISTS public.profiles (
    id uuid REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email text,
    display_name text,
    avatar_url text,
    created_at timestamptz DEFAULT NOW(),
    updated_at timestamptz DEFAULT NOW()
);

-- 設置 RLS 策略
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 允許所有已認證使用者查看 profiles（修正類型匹配問題）
CREATE POLICY "Allow authenticated users to view profiles" ON public.profiles
    FOR SELECT TO authenticated USING (true);

-- 允許使用者更新自己的 profile（修正類型匹配問題）
CREATE POLICY "Allow users to update own profile" ON public.profiles
    FOR UPDATE TO authenticated 
    USING (auth.uid()::uuid = id);

-- 允許使用者插入自己的 profile
CREATE POLICY "Allow users to insert own profile" ON public.profiles
    FOR INSERT TO authenticated 
    WITH CHECK (auth.uid()::uuid = id);

-- 自動同步 auth.users 到 profiles 表的觸發器
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.profiles (id, email, display_name)
    VALUES (
        new.id,
        new.email,
        COALESCE(new.raw_user_meta_data->>'display_name', new.email)
    );
    RETURN new;
END;
$$;

-- 刪除舊觸發器並創建新的
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 手動同步現有使用者到 profiles 表
INSERT INTO public.profiles (id, email, display_name, created_at)
SELECT 
    id, 
    email, 
    COALESCE(raw_user_meta_data->>'display_name', email),
    created_at
FROM auth.users
WHERE email IS NOT NULL
ON CONFLICT (id) DO NOTHING;
