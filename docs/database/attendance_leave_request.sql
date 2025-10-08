-- ======================================
-- 補打卡申請系統
-- ======================================

-- 補打卡申請表
CREATE TABLE IF NOT EXISTS public.attendance_leave_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  employee_id uuid NOT NULL, -- 申請人 ID
  employee_name text NOT NULL, -- 申請人姓名（冗餘欄位）
  request_type text NOT NULL CHECK (
    request_type = ANY (ARRAY['check_in'::text, 'check_out'::text, 'full_day'::text])
  ), -- 申請類型：補上班打卡、補下班打卡、補整天打卡
  request_date date NOT NULL, -- 申請補打卡的日期
  request_time timestamp with time zone, -- 申請的打卡時間（如果是單次打卡）
  check_in_time timestamp with time zone, -- 補打卡的上班時間（如果是整天）
  check_out_time timestamp with time zone, -- 補打卡的下班時間（如果是整天）
  reason text NOT NULL, -- 申請原因
  status text NOT NULL DEFAULT 'pending'::text CHECK (
    status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])
  ), -- 狀態：待審核、已核准、已拒絕
  reviewer_id uuid, -- 審核人 ID
  reviewer_name text, -- 審核人姓名
  review_comment text, -- 審核意見
  reviewed_at timestamp with time zone, -- 審核時間
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT attendance_leave_requests_pkey PRIMARY KEY (id),
  CONSTRAINT attendance_leave_requests_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE,
  CONSTRAINT attendance_leave_requests_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.employees(id)
);

-- 索引優化
CREATE INDEX IF NOT EXISTS idx_attendance_leave_requests_employee_id ON public.attendance_leave_requests(employee_id);
CREATE INDEX IF NOT EXISTS idx_attendance_leave_requests_status ON public.attendance_leave_requests(status);
CREATE INDEX IF NOT EXISTS idx_attendance_leave_requests_request_date ON public.attendance_leave_requests(request_date DESC);
CREATE INDEX IF NOT EXISTS idx_attendance_leave_requests_created_at ON public.attendance_leave_requests(created_at DESC);

-- 更新時間觸發器
CREATE OR REPLACE FUNCTION update_attendance_leave_requests_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 檢查並創建觸發器（如果不存在）
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.triggers 
        WHERE trigger_name = 'update_attendance_leave_requests_updated_at'
        AND event_object_table = 'attendance_leave_requests'
        AND event_object_schema = 'public'
    ) THEN
        CREATE TRIGGER update_attendance_leave_requests_updated_at 
        BEFORE UPDATE ON public.attendance_leave_requests 
        FOR EACH ROW EXECUTE FUNCTION update_attendance_leave_requests_updated_at();
    END IF;
END $$;

-- ======================================
-- Row Level Security (RLS) 政策
-- ======================================

ALTER TABLE public.attendance_leave_requests ENABLE ROW LEVEL SECURITY;

-- 政策 1: 員工可以查看自己的申請
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'attendance_leave_requests'
        AND policyname = 'Employees can view own requests'
    ) THEN
        CREATE POLICY "Employees can view own requests" 
        ON public.attendance_leave_requests
        FOR SELECT USING (
          employee_id = auth.uid()
        );
    END IF;
END $$;

-- 政策 2: HR 和老闆可以查看所有申請
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'attendance_leave_requests'
        AND policyname = 'Managers can view all requests'
    ) THEN
        CREATE POLICY "Managers can view all requests" 
        ON public.attendance_leave_requests
        FOR SELECT USING (
          public.get_current_user_role() IN ('boss', 'hr')
        );
    END IF;
END $$;

-- 政策 3: 員工可以新增自己的申請
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'attendance_leave_requests'
        AND policyname = 'Employees can create own requests'
    ) THEN
        CREATE POLICY "Employees can create own requests" 
        ON public.attendance_leave_requests
        FOR INSERT WITH CHECK (
          employee_id = auth.uid()
        );
    END IF;
END $$;

-- 政策 4: HR 和老闆可以更新（審核）申請
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'attendance_leave_requests'
        AND policyname = 'Managers can update requests'
    ) THEN
        CREATE POLICY "Managers can update requests" 
        ON public.attendance_leave_requests
        FOR UPDATE USING (
          public.get_current_user_role() IN ('boss', 'hr')
        );
    END IF;
END $$;

-- 政策 5: 員工可以更新自己待審核的申請（修改或撤回）
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'attendance_leave_requests'
        AND policyname = 'Employees can update own pending requests'
    ) THEN
        CREATE POLICY "Employees can update own pending requests" 
        ON public.attendance_leave_requests
        FOR UPDATE USING (
          employee_id = auth.uid() AND status = 'pending'
        );
    END IF;
END $$;

-- 政策 6: 員工可以刪除自己待審核的申請
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'attendance_leave_requests'
        AND policyname = 'Employees can delete own pending requests'
    ) THEN
        CREATE POLICY "Employees can delete own pending requests" 
        ON public.attendance_leave_requests
        FOR DELETE USING (
          employee_id = auth.uid() AND status = 'pending'
        );
    END IF;
END $$;

-- 表格註釋
COMMENT ON TABLE public.attendance_leave_requests IS '補打卡申請記錄表';
COMMENT ON COLUMN public.attendance_leave_requests.id IS '申請ID (UUID)';
COMMENT ON COLUMN public.attendance_leave_requests.employee_id IS '申請人ID';
COMMENT ON COLUMN public.attendance_leave_requests.employee_name IS '申請人姓名';
COMMENT ON COLUMN public.attendance_leave_requests.request_type IS '申請類型 (check_in=補上班, check_out=補下班, full_day=補整天)';
COMMENT ON COLUMN public.attendance_leave_requests.request_date IS '申請補打卡的日期';
COMMENT ON COLUMN public.attendance_leave_requests.request_time IS '申請的打卡時間（單次打卡）';
COMMENT ON COLUMN public.attendance_leave_requests.check_in_time IS '補打卡的上班時間（整天）';
COMMENT ON COLUMN public.attendance_leave_requests.check_out_time IS '補打卡的下班時間（整天）';
COMMENT ON COLUMN public.attendance_leave_requests.reason IS '申請原因';
COMMENT ON COLUMN public.attendance_leave_requests.status IS '狀態 (pending=待審核, approved=已核准, rejected=已拒絕)';
COMMENT ON COLUMN public.attendance_leave_requests.reviewer_id IS '審核人ID';
COMMENT ON COLUMN public.attendance_leave_requests.reviewer_name IS '審核人姓名';
COMMENT ON COLUMN public.attendance_leave_requests.review_comment IS '審核意見';
COMMENT ON COLUMN public.attendance_leave_requests.reviewed_at IS '審核時間';
