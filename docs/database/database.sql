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

-- 檢查並添加 project_id 外鍵約束（如果不存在）
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'floor_plans_project_id_fkey' 
        AND table_name = 'floor_plans'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.floor_plans 
        ADD CONSTRAINT floor_plans_project_id_fkey 
        FOREIGN KEY (project_id) REFERENCES public.projects(id);
    END IF;
END $$;

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

-- 10. 職位空缺管理 (人力資源模組)
CREATE TABLE IF NOT EXISTS public.job_vacancies (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  department text NOT NULL,
  location text NOT NULL,
  type text NOT NULL DEFAULT '全職',
  requirements text[] NOT NULL DEFAULT '{}',
  responsibilities text[] NOT NULL DEFAULT '{}',
  description text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT job_vacancies_pkey PRIMARY KEY (id)
);

-- 職位空缺索引優化
CREATE INDEX IF NOT EXISTS idx_job_vacancies_active ON public.job_vacancies(is_active);
CREATE INDEX IF NOT EXISTS idx_job_vacancies_department ON public.job_vacancies(department);
CREATE INDEX IF NOT EXISTS idx_job_vacancies_type ON public.job_vacancies(type);
CREATE INDEX IF NOT EXISTS idx_job_vacancies_created_at ON public.job_vacancies(created_at DESC);

-- 職位空缺更新時間觸發器
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ language 'plpgsql';

-- 檢查並創建觸發器（如果不存在）
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.triggers 
        WHERE trigger_name = 'update_job_vacancies_updated_at'
        AND event_object_table = 'job_vacancies'
        AND event_object_schema = 'public'
    ) THEN
        CREATE TRIGGER update_job_vacancies_updated_at 
        BEFORE UPDATE ON public.job_vacancies 
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- 職位空缺行級安全性設定
ALTER TABLE public.job_vacancies ENABLE ROW LEVEL SECURITY;

-- 檢查並創建 RLS 政策（如果不存在）
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE policyname = 'Anyone can view active job vacancies'
        AND tablename = 'job_vacancies'
        AND schemaname = 'public'
    ) THEN
        CREATE POLICY "Anyone can view active job vacancies" ON public.job_vacancies
        FOR SELECT USING (is_active = true);
    END IF;
END $$;

-- 注意：示例資料已移至 sample_data.sql 文件中

-- 職位空缺表格註釋
COMMENT ON TABLE public.job_vacancies IS '職位空缺資料表';
COMMENT ON COLUMN public.job_vacancies.id IS '職位ID (UUID)';
COMMENT ON COLUMN public.job_vacancies.title IS '職位名稱';
COMMENT ON COLUMN public.job_vacancies.department IS '所屬部門';
COMMENT ON COLUMN public.job_vacancies.location IS '工作地點';
COMMENT ON COLUMN public.job_vacancies.type IS '職位類型 (全職/兼職/實習)';
COMMENT ON COLUMN public.job_vacancies.requirements IS '應徵條件列表';
COMMENT ON COLUMN public.job_vacancies.responsibilities IS '工作職責列表';
COMMENT ON COLUMN public.job_vacancies.description IS '職位詳細描述';
COMMENT ON COLUMN public.job_vacancies.is_active IS '是否為活躍職位';
COMMENT ON COLUMN public.job_vacancies.created_at IS '建立時間';
COMMENT ON COLUMN public.job_vacancies.updated_at IS '更新時間';

-- ======================================
-- 11. 員工資料管理系統 (人力資源模組)
-- ======================================

-- 員工主表
CREATE TABLE IF NOT EXISTS public.employees (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  employee_id text UNIQUE NOT NULL, -- 員工編號（如：EMP001）
  name text NOT NULL,
  email text UNIQUE,
  phone text,
  department text NOT NULL,
  position text NOT NULL,
  hire_date date NOT NULL,
  salary decimal(10,2),
  status text DEFAULT 'active'::text CHECK (
    status = ANY (ARRAY['active'::text, 'inactive'::text, 'resigned'::text, 'terminated'::text])
  ),
  manager_id uuid, -- 直屬主管
  avatar_url text,
  address text,
  emergency_contact_name text,
  emergency_contact_phone text,
  notes text,
  created_by uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT employees_pkey PRIMARY KEY (id),
  CONSTRAINT employees_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id),
  CONSTRAINT employees_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.employees(id)
);

-- 員工技能表
CREATE TABLE IF NOT EXISTS public.employee_skills (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  employee_id uuid NOT NULL,
  skill_name text NOT NULL,
  proficiency_level integer NOT NULL CHECK (proficiency_level >= 1 AND proficiency_level <= 5),
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT employee_skills_pkey PRIMARY KEY (id),
  CONSTRAINT employee_skills_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE,
  CONSTRAINT unique_employee_skill UNIQUE (employee_id, skill_name)
);

-- 員工考勤記錄表
CREATE TABLE IF NOT EXISTS public.employee_attendance (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  employee_id uuid NOT NULL,
  date date NOT NULL,
  check_in_time timestamp with time zone,
  check_out_time timestamp with time zone,
  break_duration integer DEFAULT 0, -- 休息時間（分鐘）
  total_hours decimal(4,2),
  status text DEFAULT 'present'::text CHECK (
    status = ANY (ARRAY['present'::text, 'absent'::text, 'late'::text, 'sick_leave'::text, 'annual_leave'::text, 'personal_leave'::text])
  ),
  notes text,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT employee_attendance_pkey PRIMARY KEY (id),
  CONSTRAINT employee_attendance_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE,
  CONSTRAINT unique_employee_date UNIQUE (employee_id, date)
);

-- 員工績效評估表
CREATE TABLE IF NOT EXISTS public.employee_evaluations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  employee_id uuid NOT NULL,
  evaluation_period text NOT NULL, -- 評估期間（如：2025Q1）
  overall_rating integer CHECK (overall_rating >= 1 AND overall_rating <= 5),
  performance_goals text,
  achievements text,
  areas_for_improvement text,
  evaluator_id uuid NOT NULL,
  evaluation_date date NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT employee_evaluations_pkey PRIMARY KEY (id),
  CONSTRAINT employee_evaluations_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE,
  CONSTRAINT employee_evaluations_evaluator_id_fkey FOREIGN KEY (evaluator_id) REFERENCES auth.users(id)
);

-- 員工管理系統索引優化
CREATE INDEX IF NOT EXISTS idx_employees_department ON public.employees(department);
CREATE INDEX IF NOT EXISTS idx_employees_position ON public.employees(position);
CREATE INDEX IF NOT EXISTS idx_employees_status ON public.employees(status);
CREATE INDEX IF NOT EXISTS idx_employees_hire_date ON public.employees(hire_date DESC);
CREATE INDEX IF NOT EXISTS idx_employees_manager_id ON public.employees(manager_id);
CREATE INDEX IF NOT EXISTS idx_employees_employee_id ON public.employees(employee_id);
CREATE INDEX IF NOT EXISTS idx_attendance_employee_date ON public.employee_attendance(employee_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_attendance_status ON public.employee_attendance(status);
CREATE INDEX IF NOT EXISTS idx_evaluations_employee ON public.employee_evaluations(employee_id, evaluation_period);

-- 員工資料更新時間觸發器
CREATE OR REPLACE FUNCTION update_employee_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ language 'plpgsql';

-- 檢查並創建員工觸發器（如果不存在）
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.triggers 
        WHERE trigger_name = 'update_employees_updated_at'
        AND event_object_table = 'employees'
        AND event_object_schema = 'public'
    ) THEN
        CREATE TRIGGER update_employees_updated_at 
        BEFORE UPDATE ON public.employees 
        FOR EACH ROW EXECUTE FUNCTION update_employee_updated_at();
    END IF;
END $$;

-- 員工管理系統行級安全性設定
ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_evaluations ENABLE ROW LEVEL SECURITY;

-- 員工資料政策：只有認證用戶可以查看和管理員工資料
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE policyname = 'Authenticated users can manage employees'
        AND tablename = 'employees'
        AND schemaname = 'public'
    ) THEN
        CREATE POLICY "Authenticated users can manage employees" ON public.employees
        FOR ALL USING (auth.role() = 'authenticated');
    END IF;
END $$;

-- 技能資料政策
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE policyname = 'Authenticated users can manage employee skills'
        AND tablename = 'employee_skills'
        AND schemaname = 'public'
    ) THEN
        CREATE POLICY "Authenticated users can manage employee skills" ON public.employee_skills
        FOR ALL USING (auth.role() = 'authenticated');
    END IF;
END $$;

-- 考勤資料政策
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE policyname = 'Authenticated users can manage attendance'
        AND tablename = 'employee_attendance'
        AND schemaname = 'public'
    ) THEN
        CREATE POLICY "Authenticated users can manage attendance" ON public.employee_attendance
        FOR ALL USING (auth.role() = 'authenticated');
    END IF;
END $$;

-- 評估資料政策
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE policyname = 'Authenticated users can manage evaluations'
        AND tablename = 'employee_evaluations'
        AND schemaname = 'public'
    ) THEN
        CREATE POLICY "Authenticated users can manage evaluations" ON public.employee_evaluations
        FOR ALL USING (auth.role() = 'authenticated');
    END IF;
END $$;

-- 員工管理系統表格註釋
COMMENT ON TABLE public.employees IS '員工主資料表';
COMMENT ON COLUMN public.employees.id IS '員工系統ID (UUID)';
COMMENT ON COLUMN public.employees.employee_id IS '員工編號 (如：EMP001)';
COMMENT ON COLUMN public.employees.name IS '員工姓名';
COMMENT ON COLUMN public.employees.email IS '電子郵件';
COMMENT ON COLUMN public.employees.phone IS '聯絡電話';
COMMENT ON COLUMN public.employees.department IS '所屬部門';
COMMENT ON COLUMN public.employees.position IS '職位';
COMMENT ON COLUMN public.employees.hire_date IS '入職日期';
COMMENT ON COLUMN public.employees.salary IS '薪資';
COMMENT ON COLUMN public.employees.status IS '狀態 (active/inactive/resigned/terminated)';
COMMENT ON COLUMN public.employees.manager_id IS '直屬主管ID';
COMMENT ON COLUMN public.employees.avatar_url IS '頭像網址';
COMMENT ON COLUMN public.employees.address IS '住址';
COMMENT ON COLUMN public.employees.emergency_contact_name IS '緊急聯絡人姓名';
COMMENT ON COLUMN public.employees.emergency_contact_phone IS '緊急聯絡人電話';

COMMENT ON TABLE public.employee_skills IS '員工技能資料表';
COMMENT ON TABLE public.employee_attendance IS '員工考勤記錄表';
COMMENT ON TABLE public.employee_evaluations IS '員工績效評估表';