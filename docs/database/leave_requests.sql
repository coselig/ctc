-- ========================================
-- 請假系統資料表
-- ========================================

-- 1. 請假申請表
CREATE TABLE IF NOT EXISTS leave_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    employee_name TEXT NOT NULL,
    leave_type TEXT NOT NULL CHECK (leave_type IN (
        'sick',        -- 病假
        'personal',    -- 事假
        'annual',      -- 特休
        'parental',    -- 育嬰假
        'marriage',    -- 婚假
        'bereavement', -- 喪假
        'official',    -- 公假
        'maternity',   -- 產假
        'paternity',   -- 陪產假
        'menstrual'    -- 生理假
    )),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    start_period TEXT NOT NULL DEFAULT 'full_day' CHECK (start_period IN ('full_day', 'morning', 'afternoon')),
    end_period TEXT NOT NULL DEFAULT 'full_day' CHECK (end_period IN ('full_day', 'morning', 'afternoon')),
    total_days NUMERIC(5, 1) NOT NULL CHECK (total_days > 0),
    reason TEXT NOT NULL,
    attachment_url TEXT, -- 證明文件 URL
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
    reviewer_id UUID REFERENCES employees(id) ON DELETE SET NULL,
    reviewer_name TEXT,
    review_comment TEXT,
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT valid_date_range CHECK (end_date >= start_date),
    CONSTRAINT status_logic CHECK (
        (status = 'pending' AND reviewed_at IS NULL) OR
        (status IN ('approved', 'rejected') AND reviewed_at IS NOT NULL AND reviewer_id IS NOT NULL)
    )
);

-- 2. 員工假別額度表
CREATE TABLE IF NOT EXISTS leave_balances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    leave_type TEXT NOT NULL CHECK (leave_type IN (
        'sick', 'personal', 'annual', 'parental', 'marriage', 
        'bereavement', 'official', 'maternity', 'paternity', 'menstrual'
    )),
    year INTEGER NOT NULL,
    total_days NUMERIC(5, 1) NOT NULL DEFAULT 0,
    used_days NUMERIC(5, 1) NOT NULL DEFAULT 0,
    pending_days NUMERIC(5, 1) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(employee_id, leave_type, year),
    CONSTRAINT valid_days CHECK (
        total_days >= 0 AND 
        used_days >= 0 AND 
        pending_days >= 0 AND
        (used_days + pending_days) <= total_days
    )
);

-- 索引
CREATE INDEX IF NOT EXISTS idx_leave_requests_employee ON leave_requests(employee_id);
CREATE INDEX IF NOT EXISTS idx_leave_requests_status ON leave_requests(status);
CREATE INDEX IF NOT EXISTS idx_leave_requests_dates ON leave_requests(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_leave_requests_created ON leave_requests(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_leave_balances_employee ON leave_balances(employee_id);
CREATE INDEX IF NOT EXISTS idx_leave_balances_year ON leave_balances(year);

-- 自動更新 updated_at 的觸發器
CREATE OR REPLACE FUNCTION update_leave_requests_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_leave_requests_updated_at
    BEFORE UPDATE ON leave_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_leave_requests_updated_at();

CREATE OR REPLACE FUNCTION update_leave_balances_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_leave_balances_updated_at
    BEFORE UPDATE ON leave_balances
    FOR EACH ROW
    EXECUTE FUNCTION update_leave_balances_updated_at();

-- ========================================
-- RLS 政策
-- ========================================

-- 啟用 RLS
ALTER TABLE leave_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE leave_balances ENABLE ROW LEVEL SECURITY;

-- leave_requests 政策
-- 1. 員工可以查看自己的請假申請
CREATE POLICY "員工可查看自己的請假申請"
    ON leave_requests FOR SELECT
    USING (
        employee_id = auth.uid()
    );

-- 2. 員工可以建立自己的請假申請
CREATE POLICY "員工可建立請假申請"
    ON leave_requests FOR INSERT
    WITH CHECK (
        employee_id = auth.uid()
    );

-- 3. 員工可以更新自己待審核的請假申請（取消）
CREATE POLICY "員工可取消待審核的請假"
    ON leave_requests FOR UPDATE
    USING (
        employee_id = auth.uid() AND
        status = 'pending'
    );

-- 4. HR/老闆可以查看所有請假申請
CREATE POLICY "管理者可查看所有請假申請"
    ON leave_requests FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM employees
            WHERE id = auth.uid()
            AND role IN ('boss', 'hr')
        )
    );

-- 5. HR/老闆可以審核請假申請
CREATE POLICY "管理者可審核請假申請"
    ON leave_requests FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM employees
            WHERE id = auth.uid()
            AND role IN ('boss', 'hr')
        )
    );

-- leave_balances 政策
-- 1. 員工可以查看自己的假別額度
CREATE POLICY "員工可查看自己的假別額度"
    ON leave_balances FOR SELECT
    USING (
        employee_id = auth.uid()
    );

-- 2. HR/老闆可以查看所有員工的假別額度
CREATE POLICY "管理者可查看所有假別額度"
    ON leave_balances FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM employees
            WHERE id = auth.uid()
            AND role IN ('boss', 'hr')
        )
    );

-- 3. 系統可以新增和更新假別額度（透過服務角色）
CREATE POLICY "服務角色可管理假別額度"
    ON leave_balances FOR ALL
    USING (auth.role() = 'service_role');

-- ========================================
-- 初始化假別額度的函數
-- ========================================

CREATE OR REPLACE FUNCTION initialize_leave_balance(
    p_employee_id UUID,
    p_leave_type TEXT,
    p_year INTEGER,
    p_total_days NUMERIC
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO leave_balances (
        employee_id,
        leave_type,
        year,
        total_days,
        used_days,
        pending_days
    )
    VALUES (
        p_employee_id,
        p_leave_type,
        p_year,
        p_total_days,
        0,
        0
    )
    ON CONFLICT (employee_id, leave_type, year)
    DO UPDATE SET
        total_days = EXCLUDED.total_days,
        updated_at = NOW();
END;
$$;

-- ========================================
-- 更新假別額度的函數（當請假申請狀態改變時）
-- ========================================

CREATE OR REPLACE FUNCTION update_leave_balance_on_request_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_year INTEGER;
BEGIN
    v_year := EXTRACT(YEAR FROM NEW.start_date);
    
    -- 確保該員工該年度的假別額度記錄存在
    INSERT INTO leave_balances (employee_id, leave_type, year, total_days)
    VALUES (NEW.employee_id, NEW.leave_type, v_year, 0)
    ON CONFLICT (employee_id, leave_type, year) DO NOTHING;
    
    -- 如果是新增記錄
    IF TG_OP = 'INSERT' THEN
        IF NEW.status = 'pending' THEN
            -- 增加 pending_days
            UPDATE leave_balances
            SET pending_days = pending_days + NEW.total_days
            WHERE employee_id = NEW.employee_id
              AND leave_type = NEW.leave_type
              AND year = v_year;
        ELSIF NEW.status = 'approved' THEN
            -- 增加 used_days
            UPDATE leave_balances
            SET used_days = used_days + NEW.total_days
            WHERE employee_id = NEW.employee_id
              AND leave_type = NEW.leave_type
              AND year = v_year;
        END IF;
        
    -- 如果是更新記錄
    ELSIF TG_OP = 'UPDATE' THEN
        -- 先還原舊狀態
        IF OLD.status = 'pending' THEN
            UPDATE leave_balances
            SET pending_days = pending_days - OLD.total_days
            WHERE employee_id = OLD.employee_id
              AND leave_type = OLD.leave_type
              AND year = v_year;
        ELSIF OLD.status = 'approved' THEN
            UPDATE leave_balances
            SET used_days = used_days - OLD.total_days
            WHERE employee_id = OLD.employee_id
              AND leave_type = OLD.leave_type
              AND year = v_year;
        END IF;
        
        -- 套用新狀態
        IF NEW.status = 'pending' THEN
            UPDATE leave_balances
            SET pending_days = pending_days + NEW.total_days
            WHERE employee_id = NEW.employee_id
              AND leave_type = NEW.leave_type
              AND year = v_year;
        ELSIF NEW.status = 'approved' THEN
            UPDATE leave_balances
            SET used_days = used_days + NEW.total_days
            WHERE employee_id = NEW.employee_id
              AND leave_type = NEW.leave_type
              AND year = v_year;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;

-- 建立觸發器
CREATE TRIGGER trigger_update_leave_balance
    AFTER INSERT OR UPDATE ON leave_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_leave_balance_on_request_change();

-- ========================================
-- 查詢員工假別額度的函數
-- ========================================

CREATE OR REPLACE FUNCTION get_employee_leave_balance(
    p_employee_id UUID,
    p_year INTEGER DEFAULT NULL
)
RETURNS TABLE (
    employee_id UUID,
    leave_type TEXT,
    total_days NUMERIC,
    used_days NUMERIC,
    pending_days NUMERIC,
    remaining_days NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        lb.employee_id,
        lb.leave_type,
        lb.total_days,
        lb.used_days,
        lb.pending_days,
        (lb.total_days - lb.used_days - lb.pending_days) AS remaining_days
    FROM leave_balances lb
    WHERE lb.employee_id = p_employee_id
      AND (p_year IS NULL OR lb.year = p_year)
    ORDER BY lb.leave_type;
END;
$$;

-- ========================================
-- 範例資料（測試用）
-- ========================================

-- 註：初始化員工的假別額度
-- 使用方式:
-- SELECT initialize_leave_balance('員工UUID', 'annual', 2025, 14);
-- SELECT initialize_leave_balance('員工UUID', 'sick', 2025, 30);
-- SELECT initialize_leave_balance('員工UUID', 'personal', 2025, 14);
