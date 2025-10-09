-- 建立國定假日資料表
CREATE TABLE IF NOT EXISTS holidays (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  date DATE NOT NULL UNIQUE,
  name TEXT NOT NULL,
  year INT NOT NULL,
  description TEXT,
  is_workday BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_holidays_date ON holidays(date);
CREATE INDEX IF NOT EXISTS idx_holidays_year ON holidays(year);
CREATE INDEX IF NOT EXISTS idx_holidays_workday ON holidays(is_workday) WHERE is_workday = FALSE;

-- 建立更新時間觸發器
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_holidays_updated_at
    BEFORE UPDATE ON holidays
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 啟用 RLS
ALTER TABLE holidays ENABLE ROW LEVEL SECURITY;

-- 允許所有認證用戶讀取假日資料
CREATE POLICY "Anyone can read holidays"
ON holidays FOR SELECT
TO authenticated
USING (true);

-- 只有管理員可以新增、更新、刪除假日資料
CREATE POLICY "Only admins can manage holidays"
ON holidays FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM employees
    WHERE employees.id = auth.uid()
    AND employees.role = 'admin'
  )
);

-- 插入一些範例資料（2025年）
INSERT INTO holidays (date, name, year, description, is_workday) VALUES
('2025-01-01', '中華民國開國紀念日', 2025, '依規定放假一日', FALSE),
('2025-01-27', '農曆除夕', 2025, '春節假期', FALSE),
('2025-01-28', '春節', 2025, '春節假期', FALSE),
('2025-01-29', '春節', 2025, '春節假期', FALSE),
('2025-01-30', '春節', 2025, '春節假期', FALSE),
('2025-01-31', '春節', 2025, '春節假期', FALSE),
('2025-02-28', '和平紀念日', 2025, '依規定放假一日', FALSE),
('2025-04-04', '兒童節及民族掃墓節', 2025, '依規定放假一日', FALSE),
('2025-04-05', '民族掃墓節補假', 2025, '補假一日', FALSE),
('2025-05-01', '勞動節', 2025, '依規定放假一日', FALSE),
('2025-05-31', '端午節', 2025, '依規定放假一日', FALSE),
('2025-10-06', '中秋節', 2025, '依規定放假一日', FALSE),
('2025-10-10', '國慶日', 2025, '依規定放假一日', FALSE)
ON CONFLICT (date) DO NOTHING;

COMMENT ON TABLE holidays IS '國定假日資料表';
COMMENT ON COLUMN holidays.date IS '假日日期';
COMMENT ON COLUMN holidays.name IS '假日名稱';
COMMENT ON COLUMN holidays.year IS '年份';
COMMENT ON COLUMN holidays.description IS '備註說明';
COMMENT ON COLUMN holidays.is_workday IS '是否為調整上班日（補班日）';
