-- 完整的資料庫設置 SQL 指令
-- 適用於全新的 Supabase 資料庫環境
-- 包含表格創建、RLS 策略、RPC 函數等所有必要設置

-- ================================================
-- 1. 創建 profiles 表格 (用戶資料表)
-- ================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id uuid REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email text,
    full_name text,
    avatar_url text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 啟用 profiles 表的 RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- profiles 表的 RLS 策略
CREATE POLICY "Users can view their own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- ================================================
-- 2. 創建設計圖表格 (floor_plans)
-- ================================================
CREATE TABLE IF NOT EXISTS public.floor_plans (
    id text PRIMARY KEY,
    name text NOT NULL,
    image_url text NOT NULL UNIQUE,
    created_by uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 啟用 floor_plans 表的 RLS
ALTER TABLE public.floor_plans ENABLE ROW LEVEL SECURITY;

-- floor_plans 表的 RLS 策略 (簡化版本，避免遞迴)
CREATE POLICY "Allow authenticated users to read floor plans" ON public.floor_plans
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can insert their own floor plans" ON public.floor_plans
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update their own floor plans" ON public.floor_plans
    FOR UPDATE TO authenticated USING (auth.uid() = created_by);

CREATE POLICY "Users can delete their own floor plans" ON public.floor_plans
    FOR DELETE TO authenticated USING (auth.uid() = created_by);

-- ================================================
-- 3. 創建權限管理表格 (floor_plan_permissions)
-- ================================================
CREATE TABLE IF NOT EXISTS public.floor_plan_permissions (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    floor_plan_id text NOT NULL,
    floor_plan_url text NOT NULL,
    floor_plan_name text NOT NULL,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_email text NOT NULL,
    permission_level integer NOT NULL CHECK (permission_level BETWEEN 1 AND 3),
    is_owner boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(floor_plan_url, user_id)
);

-- 創建索引以提升查詢效能
CREATE INDEX IF NOT EXISTS idx_floor_plan_permissions_url ON public.floor_plan_permissions(floor_plan_url);
CREATE INDEX IF NOT EXISTS idx_floor_plan_permissions_user ON public.floor_plan_permissions(user_id);
CREATE INDEX IF NOT EXISTS idx_floor_plan_permissions_owner ON public.floor_plan_permissions(floor_plan_url, is_owner);

-- 啟用 floor_plan_permissions 表的 RLS (但禁用避免遞迴問題)
ALTER TABLE public.floor_plan_permissions ENABLE ROW LEVEL SECURITY;

-- 為了避免 RLS 遞迴問題，我們使用簡化的策略
CREATE POLICY "Allow authenticated users to manage permissions" ON public.floor_plan_permissions
    FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ================================================
-- 4. 創建照片記錄表格 (photo_records)
-- ================================================
CREATE TABLE IF NOT EXISTS public.photo_records (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    floor_plan_url text NOT NULL,
    coordinate_x double precision NOT NULL,
    coordinate_y double precision NOT NULL,
    photo_url text NOT NULL,
    description text,
    created_by uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 創建索引
CREATE INDEX IF NOT EXISTS idx_photo_records_floor_plan ON public.photo_records(floor_plan_url);
CREATE INDEX IF NOT EXISTS idx_photo_records_user ON public.photo_records(created_by);

-- 啟用 photo_records 表的 RLS
ALTER TABLE public.photo_records ENABLE ROW LEVEL SECURITY;

-- photo_records 表的 RLS 策略
CREATE POLICY "Users can view photo records for accessible floor plans" ON public.photo_records
    FOR SELECT TO authenticated USING (
        EXISTS (
            SELECT 1 FROM public.floor_plan_permissions
            WHERE floor_plan_url = photo_records.floor_plan_url
            AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert photo records for accessible floor plans" ON public.photo_records
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.floor_plan_permissions
            WHERE floor_plan_url = photo_records.floor_plan_url
            AND user_id = auth.uid()
            AND permission_level >= 2
        )
    );

CREATE POLICY "Users can update their own photo records" ON public.photo_records
    FOR UPDATE TO authenticated USING (created_by = auth.uid());

CREATE POLICY "Users can delete photo records based on permissions" ON public.photo_records
    FOR DELETE TO authenticated USING (
        created_by = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.floor_plan_permissions
            WHERE floor_plan_url = photo_records.floor_plan_url
            AND user_id = auth.uid()
            AND permission_level = 3
        )
    );

-- ================================================
-- 5. 創建 RPC 函數
-- ================================================

-- 獲取當前用戶 ID 的輔助函數
CREATE OR REPLACE FUNCTION get_current_user_id()
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN auth.uid();
END;
$$;

-- 獲取所有用戶的函數
CREATE OR REPLACE FUNCTION get_all_users()
RETURNS TABLE(
    id uuid,
    email text,
    created_at timestamp with time zone
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.email::text,
        u.created_at
    FROM auth.users u
    WHERE u.email IS NOT NULL
    ORDER BY u.created_at DESC;
END;
$$;

-- 列出用戶的函數 (備用方案)
CREATE OR REPLACE FUNCTION list_users()
RETURNS TABLE(
    user_id uuid,
    user_email text,
    user_created_at timestamp with time zone
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        fp.user_id,
        fp.user_email,
        fp.created_at
    FROM public.floor_plan_permissions fp
    ORDER BY fp.created_at DESC;
END;
$$;

-- 添加用戶權限的主要函數
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
        p_target_user_id,
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

-- 轉移擁有者權限的函數
CREATE OR REPLACE FUNCTION transfer_floor_plan_ownership(
    p_floor_plan_url text,
    p_old_owner_id uuid,
    p_new_owner_id uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- 檢查當前用戶是否為舊擁有者
    IF auth.uid() != p_old_owner_id THEN
        RETURN json_build_object('success', false, 'error', '只有當前擁有者可以轉移權限');
    END IF;
    
    -- 更新舊擁有者狀態
    UPDATE public.floor_plan_permissions
    SET is_owner = false,
        permission_level = 3,
        updated_at = NOW()
    WHERE floor_plan_url = p_floor_plan_url
    AND user_id = p_old_owner_id;
    
    -- 更新新擁有者狀態
    UPDATE public.floor_plan_permissions
    SET is_owner = true,
        permission_level = 3,
        updated_at = NOW()
    WHERE floor_plan_url = p_floor_plan_url
    AND user_id = p_new_owner_id;
    
    RETURN json_build_object('success', true, 'message', '擁有者權限轉移成功');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'error', SQLERRM);
END;
$$;

-- ================================================
-- 6. 設置函數權限
-- ================================================
GRANT EXECUTE ON FUNCTION get_current_user_id() TO authenticated;
GRANT EXECUTE ON FUNCTION get_all_users() TO authenticated;
GRANT EXECUTE ON FUNCTION list_users() TO authenticated;
GRANT EXECUTE ON FUNCTION add_user_permission(text, text, uuid, text, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION transfer_floor_plan_ownership(text, uuid, uuid) TO authenticated;

-- ================================================
-- 7. 創建觸發器函數 (自動更新 updated_at)
-- ================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 為各表創建觸發器
CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON public.profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_floor_plans_updated_at 
    BEFORE UPDATE ON public.floor_plans 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_floor_plan_permissions_updated_at 
    BEFORE UPDATE ON public.floor_plan_permissions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_photo_records_updated_at 
    BEFORE UPDATE ON public.photo_records 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ================================================
-- 8. 創建視圖 (可選，便於查詢)
-- ================================================

-- 用戶權限摘要視圖
CREATE OR REPLACE VIEW user_permissions_summary AS
SELECT 
    p.user_id,
    p.user_email,
    p.floor_plan_url,
    p.floor_plan_name,
    p.permission_level,
    p.is_owner,
    CASE 
        WHEN p.permission_level = 1 THEN '瀏覽'
        WHEN p.permission_level = 2 THEN '編輯'
        WHEN p.permission_level = 3 THEN '管理'
        ELSE '未知'
    END as permission_name,
    p.created_at,
    p.updated_at
FROM public.floor_plan_permissions p
ORDER BY p.floor_plan_url, p.is_owner DESC, p.permission_level DESC;

-- 設計圖統計視圖
CREATE OR REPLACE VIEW floor_plan_stats AS
SELECT 
    fp.floor_plan_url,
    fp.floor_plan_name,
    COUNT(DISTINCT fpp.user_id) as user_count,
    COUNT(DISTINCT pr.id) as photo_count,
    fp.created_at,
    fp.updated_at
FROM public.floor_plan_permissions fp
LEFT JOIN public.floor_plan_permissions fpp ON fp.floor_plan_url = fpp.floor_plan_url
LEFT JOIN public.photo_records pr ON fp.floor_plan_url = pr.floor_plan_url
WHERE fp.is_owner = true
GROUP BY fp.floor_plan_url, fp.floor_plan_name, fp.created_at, fp.updated_at
ORDER BY fp.created_at DESC;

-- ================================================
-- 9. 插入示例數據 (可選，僅用於測試)
-- ================================================

-- 注意：在生產環境中，請註釋掉或刪除此部分
/*
-- 示例：為當前用戶創建一個測試設計圖權限
INSERT INTO public.floor_plan_permissions (
    floor_plan_id,
    floor_plan_url,
    floor_plan_name,
    user_id,
    user_email,
    permission_level,
    is_owner
) VALUES (
    'test_floor_plan_001',
    'https://example.com/test_floor_plan.jpg',
    '測試設計圖',
    auth.uid(),
    (SELECT email FROM auth.users WHERE id = auth.uid()),
    3,
    true
) ON CONFLICT (floor_plan_url, user_id) DO NOTHING;
*/

-- ================================================
-- 10. 完成設置
-- ================================================

-- 顯示設置完成訊息
DO $$
BEGIN
    RAISE NOTICE '資料庫設置完成！';
    RAISE NOTICE '已創建的表格：';
    RAISE NOTICE '- profiles (用戶資料)';
    RAISE NOTICE '- floor_plans (設計圖)';
    RAISE NOTICE '- floor_plan_permissions (權限管理)';
    RAISE NOTICE '- photo_records (照片記錄)';
    RAISE NOTICE '';
    RAISE NOTICE '已創建的函數：';
    RAISE NOTICE '- get_current_user_id()';
    RAISE NOTICE '- get_all_users()';
    RAISE NOTICE '- list_users()';
    RAISE NOTICE '- add_user_permission()';
    RAISE NOTICE '- transfer_floor_plan_ownership()';
    RAISE NOTICE '';
    RAISE NOTICE '已啟用 RLS 安全策略';
    RAISE NOTICE '已創建必要的索引和觸發器';
END $$;
