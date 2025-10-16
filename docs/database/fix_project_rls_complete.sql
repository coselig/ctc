-- 完整修正專案管理權限系統的 RLS 策略
-- 
-- 問題：projects 查詢 project_members 表會造成遞迴
-- 解決方案：使用 SECURITY DEFINER 函數繞過 RLS 進行權限檢查

-- ============================================
-- 第一步：創建權限檢查函數（繞過 RLS）
-- ============================================

-- 函數：檢查用戶是否有專案的存取權限（任何角色）
CREATE OR REPLACE FUNCTION has_project_access(
  p_project_id uuid,
  p_user_id uuid DEFAULT auth.uid()
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER  -- 以函數擁有者權限執行，繞過 RLS
STABLE
AS $$
BEGIN
  -- 檢查是否為擁有者
  IF EXISTS (
    SELECT 1 FROM public.projects
    WHERE id = p_project_id
    AND owner_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  -- 檢查是否為專案成員（任何角色）
  IF EXISTS (
    SELECT 1 FROM public.project_members
    WHERE project_id = p_project_id
    AND user_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  RETURN FALSE;
END;
$$;

-- 函數：檢查用戶是否有專案的管理權限（owner 或 admin）
CREATE OR REPLACE FUNCTION has_project_admin_access(
  p_project_id uuid,
  p_user_id uuid DEFAULT auth.uid()
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
  -- 檢查是否為擁有者
  IF EXISTS (
    SELECT 1 FROM public.projects
    WHERE id = p_project_id
    AND owner_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  -- 檢查是否為管理員
  IF EXISTS (
    SELECT 1 FROM public.project_members
    WHERE project_id = p_project_id
    AND user_id = p_user_id
    AND role = 'admin'
  ) THEN
    RETURN TRUE;
  END IF;
  
  RETURN FALSE;
END;
$$;

-- 授予執行權限
GRANT EXECUTE ON FUNCTION has_project_access(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION has_project_admin_access(uuid, uuid) TO authenticated;

-- ============================================
-- 第二步：修正 projects 表的 RLS 策略
-- ============================================

ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

-- 刪除所有舊策略
DROP POLICY IF EXISTS "Users can view their own projects" ON public.projects;
DROP POLICY IF EXISTS "Users can insert their own projects" ON public.projects;
DROP POLICY IF EXISTS "Users can update their own projects" ON public.projects;
DROP POLICY IF EXISTS "Users can delete their own projects" ON public.projects;
DROP POLICY IF EXISTS "Owners can view their projects" ON public.projects;
DROP POLICY IF EXISTS "Owners can manage their projects" ON public.projects;
DROP POLICY IF EXISTS "Users can view accessible projects" ON public.projects;
DROP POLICY IF EXISTS "Owners and admins can update projects" ON public.projects;
DROP POLICY IF EXISTS "Owners can delete their projects" ON public.projects;

-- 1. 查看：自己擁有的 或 作為成員的專案
CREATE POLICY "Users can view accessible projects"
ON public.projects
FOR SELECT
USING (
  owner_id = auth.uid()
  OR has_project_access(id, auth.uid())
);

-- 2. 新增：只能新增自己擁有的專案
CREATE POLICY "Users can insert their own projects"
ON public.projects
FOR INSERT
WITH CHECK (owner_id = auth.uid());

-- 3. 更新：擁有者 或 管理員可以更新
CREATE POLICY "Owners and admins can update projects"
ON public.projects
FOR UPDATE
USING (
  owner_id = auth.uid()
  OR has_project_admin_access(id, auth.uid())
)
WITH CHECK (
  owner_id = auth.uid()
  OR has_project_admin_access(id, auth.uid())
);

-- 4. 刪除：只有擁有者可以刪除
CREATE POLICY "Owners can delete their projects"
ON public.projects
FOR DELETE
USING (owner_id = auth.uid());

-- ============================================
-- 第三步：修正 project_members 表的 RLS 策略
-- ============================================

ALTER TABLE public.project_members ENABLE ROW LEVEL SECURITY;

-- 刪除所有舊策略
DROP POLICY IF EXISTS "Users can view project members" ON public.project_members;
DROP POLICY IF EXISTS "Project owners can manage members" ON public.project_members;
DROP POLICY IF EXISTS "Project admins can manage members" ON public.project_members;
DROP POLICY IF EXISTS "Members can view other members" ON public.project_members;
DROP POLICY IF EXISTS "Project members can view other members" ON public.project_members;
DROP POLICY IF EXISTS "Owners and admins can manage members" ON public.project_members;

-- 1. 查看：專案成員可以查看其他成員
CREATE POLICY "Project members can view other members"
ON public.project_members
FOR SELECT
USING (
  has_project_access(project_id, auth.uid())
);

-- 2. 管理成員（新增/更新/刪除）：只有擁有者和管理員
CREATE POLICY "Owners and admins can manage members"
ON public.project_members
FOR ALL
USING (
  has_project_admin_access(project_id, auth.uid())
)
WITH CHECK (
  has_project_admin_access(project_id, auth.uid())
);

-- ============================================
-- 第四步：修正其他相關表的 RLS 策略
-- ============================================

-- project_tasks 表
ALTER TABLE public.project_tasks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view project tasks" ON public.project_tasks;
DROP POLICY IF EXISTS "Users can manage project tasks" ON public.project_tasks;
DROP POLICY IF EXISTS "Project members can view tasks" ON public.project_tasks;
DROP POLICY IF EXISTS "Project members can manage tasks" ON public.project_tasks;

CREATE POLICY "Project members can view tasks"
ON public.project_tasks
FOR SELECT
USING (
  has_project_access(project_id, auth.uid())
);

CREATE POLICY "Project members can manage tasks"
ON public.project_tasks
FOR ALL
USING (
  has_project_access(project_id, auth.uid())
)
WITH CHECK (
  has_project_access(project_id, auth.uid())
);

-- project_comments 表
ALTER TABLE public.project_comments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view project comments" ON public.project_comments;
DROP POLICY IF EXISTS "Users can manage their comments" ON public.project_comments;
DROP POLICY IF EXISTS "Project members can view comments" ON public.project_comments;
DROP POLICY IF EXISTS "Project members can add comments" ON public.project_comments;
DROP POLICY IF EXISTS "Users can update their own comments" ON public.project_comments;
DROP POLICY IF EXISTS "Users can delete their own comments" ON public.project_comments;

CREATE POLICY "Project members can view comments"
ON public.project_comments
FOR SELECT
USING (
  has_project_access(project_id, auth.uid())
);

CREATE POLICY "Project members can add comments"
ON public.project_comments
FOR INSERT
WITH CHECK (
  has_project_access(project_id, auth.uid())
  AND user_id = auth.uid()
);

CREATE POLICY "Users can update their own comments"
ON public.project_comments
FOR UPDATE
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete their own comments"
ON public.project_comments
FOR DELETE
USING (user_id = auth.uid());

-- project_timeline 表
ALTER TABLE public.project_timeline ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view project timeline" ON public.project_timeline;
DROP POLICY IF EXISTS "Users can manage timeline" ON public.project_timeline;
DROP POLICY IF EXISTS "Project members can view timeline" ON public.project_timeline;
DROP POLICY IF EXISTS "Project members can manage timeline" ON public.project_timeline;

CREATE POLICY "Project members can view timeline"
ON public.project_timeline
FOR SELECT
USING (
  has_project_access(project_id, auth.uid())
);

CREATE POLICY "Project members can manage timeline"
ON public.project_timeline
FOR ALL
USING (
  has_project_access(project_id, auth.uid())
)
WITH CHECK (
  has_project_access(project_id, auth.uid())
);

-- project_clients 表
ALTER TABLE public.project_clients ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view project clients" ON public.project_clients;
DROP POLICY IF EXISTS "Users can manage clients" ON public.project_clients;
DROP POLICY IF EXISTS "Project members can view clients" ON public.project_clients;
DROP POLICY IF EXISTS "Owners and admins can manage clients" ON public.project_clients;

CREATE POLICY "Project members can view clients"
ON public.project_clients
FOR SELECT
USING (
  has_project_access(project_id, auth.uid())
);

CREATE POLICY "Owners and admins can manage clients"
ON public.project_clients
FOR ALL
USING (
  has_project_admin_access(project_id, auth.uid())
)
WITH CHECK (
  has_project_admin_access(project_id, auth.uid())
);

-- ============================================
-- 第五步：添加註解說明
-- ============================================

COMMENT ON FUNCTION has_project_access(uuid, uuid) IS 
'檢查用戶是否有專案的存取權限（擁有者或任何角色的成員）。使用 SECURITY DEFINER 繞過 RLS，避免遞迴。';

COMMENT ON FUNCTION has_project_admin_access(uuid, uuid) IS 
'檢查用戶是否有專案的管理權限（擁有者或管理員）。使用 SECURITY DEFINER 繞過 RLS，避免遞迴。';

-- ============================================
-- 完成！
-- ============================================

-- 角色說明：
-- owner: 專案擁有者 - 完全控制權限
-- admin: 管理員 - 可以管理成員和專案設置
-- member: 成員 - 可以編輯內容和創建任務
-- viewer: 檢視者 - 只能查看專案內容

-- 測試建議：
-- 1. 測試擁有者可以查看、編輯、刪除自己的專案
-- 2. 測試被加入的成員可以查看專案和相關資料
-- 3. 測試管理員可以管理成員
-- 4. 測試檢視者只能查看不能編輯
-- 5. 測試未授權用戶無法存取其他人的專案
