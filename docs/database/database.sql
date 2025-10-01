-- 1. floor_plans 必須先建立，因為其他表會依賴它
CREATE TABLE IF NOT EXISTS public.floor_plans (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  image_url text NOT NULL,
  user_id uuid, -- 暫時允許 NULL，稍後處理
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT floor_plans_pkey PRIMARY KEY (id)
);

-- 處理現有資料的 NULL user_id 問題
-- 選項1：刪除 user_id 為 NULL 的記錄（如果這些記錄不重要）
DELETE FROM public.floor_plans WHERE user_id IS NULL;

-- 選項2：將 NULL user_id 設為某個預設用戶（請替換為實際的用戶ID）
-- UPDATE public.floor_plans 
-- SET user_id = 'your-default-user-uuid-here' 
-- WHERE user_id IS NULL;

-- 移除 image_url 的 UNIQUE 約束（如果存在）
ALTER TABLE public.floor_plans DROP CONSTRAINT IF EXISTS floor_plans_image_url_key;

-- 現在設定 user_id 為 NOT NULL
ALTER TABLE public.floor_plans ALTER COLUMN user_id SET NOT NULL;

-- 檢查並添加外鍵約束（如果不存在）
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'floor_plans_user_id_fkey' 
        AND table_name = 'floor_plans'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.floor_plans 
        ADD CONSTRAINT floor_plans_user_id_fkey 
        FOREIGN KEY (user_id) REFERENCES auth.users(id);
    END IF;
END $$;
-- 2. floor_plan_permissions 依賴 floor_plans
CREATE TABLE IF NOT EXISTS public.floor_plan_permissions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  floor_plan_id uuid NOT NULL,
  user_id uuid NOT NULL,
  permission_level integer NOT NULL CHECK (permission_level >= 1 AND permission_level <= 3),
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT floor_plan_permissions_pkey PRIMARY KEY (id),
  CONSTRAINT floor_plan_permissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT floor_plan_permissions_floor_plan_id_fkey FOREIGN KEY (floor_plan_id) REFERENCES public.floor_plans(id)
);

-- 3. photo_records 也依賴 floor_plans
CREATE TABLE IF NOT EXISTS public.photo_records (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  floor_plan_id uuid NOT NULL,
  x_coordinate double precision NOT NULL,
  y_coordinate double precision NOT NULL,
  image_url text NOT NULL, -- 改用 image_url 直接存儲圖片網址
  image_id uuid, -- 可選：關聯到 images 表格
  description text,
  user_id uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT photo_records_pkey PRIMARY KEY (id),
  CONSTRAINT photo_records_floor_plan_id_fkey FOREIGN KEY (floor_plan_id) REFERENCES public.floor_plans(id),
  CONSTRAINT photo_records_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT photo_records_image_id_fkey FOREIGN KEY (image_id) REFERENCES public.images(id)
);

-- 4. projects - 專案/工地管理
CREATE TABLE IF NOT EXISTS public.projects (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  address text,
  status text DEFAULT 'active'::text CHECK (
    status = ANY (ARRAY['active'::text, 'completed'::text, 'paused'::text, 'cancelled'::text])
  ),
  owner_id uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT projects_pkey PRIMARY KEY (id),
  CONSTRAINT projects_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES auth.users(id)
);

-- 5. project_members - 專案成員管理
CREATE TABLE IF NOT EXISTS public.project_members (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL,
  user_id uuid NOT NULL,
  role text DEFAULT 'member'::text CHECK (
    role = ANY (ARRAY['owner'::text, 'admin'::text, 'member'::text, 'viewer'::text])
  ),
  joined_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT project_members_pkey PRIMARY KEY (id),
  CONSTRAINT project_members_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE,
  CONSTRAINT project_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT unique_project_user UNIQUE (project_id, user_id)
);

-- 6. 修改 floor_plans 增加 project_id
ALTER TABLE public.floor_plans ADD COLUMN IF NOT EXISTS project_id uuid;
ALTER TABLE public.floor_plans ADD CONSTRAINT floor_plans_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);

-- 7. profiles 則只依賴 auth.users，不依賴 floor_plans
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid NOT NULL,
  email text,
  full_name text,
  avatar_url text,
  theme_preference text DEFAULT 'system'::text CHECK (
    theme_preference = ANY (ARRAY['light'::text, 'dark'::text, 'system'::text])
  ),
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);

-- 8. 系統設定表 (可選)
CREATE TABLE IF NOT EXISTS public.system_settings (
  key text NOT NULL,
  value text,
  description text,
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT system_settings_pkey PRIMARY KEY (key)
);

-- 9. 圖片庫管理 (針對你的 assets bucket)
CREATE TABLE IF NOT EXISTS public.images (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  filename text NOT NULL,
  original_name text,
  file_path text NOT NULL,
  file_size integer,
  mime_type text,
  project_id uuid,
  uploaded_by uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT images_pkey PRIMARY KEY (id),
  CONSTRAINT images_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id),
  CONSTRAINT images_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES auth.users(id)
);