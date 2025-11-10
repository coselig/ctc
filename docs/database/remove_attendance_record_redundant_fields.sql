-- 移除 attendance_records 表中的冗餘欄位
-- employee_name 和 employee_email 可以透過 employee_id 從 employees 表中獲取
-- work_hours 改用 calculatedWorkHours getter 即時計算

-- 步驟 1: 先查看現有的 RLS 政策
-- 執行以下查詢查看所有相關政策：
-- SELECT schemaname, tablename, policyname, qual, with_check 
-- FROM pg_policies 
-- WHERE tablename = 'attendance_records';

-- 步驟 2: 刪除依賴 employee_email 的舊政策
DROP POLICY IF EXISTS "Employees can view own attendance records" ON attendance_records;

-- 步驟 3: 建立新的政策，使用 employee_id 而不是 email
-- 員工可以查看自己的打卡記錄
-- 注意: employees 表的 id 就是 auth.users.id，所以可以直接比對
CREATE POLICY "Employees can view own attendance records" 
ON attendance_records 
FOR SELECT 
USING (
  employee_id IN (
    SELECT id FROM employees WHERE id = auth.uid()
  )
);

-- 步驟 4: 重新建立其他可能需要的政策（如果有的話）
-- 員工可以插入自己的打卡記錄
DROP POLICY IF EXISTS "Employees can insert own attendance records" ON attendance_records;
CREATE POLICY "Employees can insert own attendance records" 
ON attendance_records 
FOR INSERT 
WITH CHECK (
  employee_id IN (
    SELECT id FROM employees WHERE id = auth.uid()
  )
);

-- 員工可以更新自己的打卡記錄
DROP POLICY IF EXISTS "Employees can update own attendance records" ON attendance_records;
CREATE POLICY "Employees can update own attendance records" 
ON attendance_records 
FOR UPDATE 
USING (
  employee_id IN (
    SELECT id FROM employees WHERE id = auth.uid()
  )
);

-- HR 可以查看所有打卡記錄
DROP POLICY IF EXISTS "HR can view all attendance records" ON attendance_records;
CREATE POLICY "HR can view all attendance records" 
ON attendance_records 
FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM employees 
    WHERE id = auth.uid() 
    AND role IN ('admin', 'hr')
  )
);

-- HR 可以管理所有打卡記錄
DROP POLICY IF EXISTS "HR can manage all attendance records" ON attendance_records;
CREATE POLICY "HR can manage all attendance records" 
ON attendance_records 
FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM employees 
    WHERE id = auth.uid() 
    AND role IN ('admin', 'hr')
  )
);

-- 步驟 5: 刪除依賴 work_hours 的視圖
-- 先刪除依賴 work_hours 欄位的 checkout_diagnosis 視圖
DROP VIEW IF EXISTS checkout_diagnosis CASCADE;

-- 步驟 6: 現在可以安全地移除欄位了
ALTER TABLE attendance_records DROP COLUMN IF EXISTS employee_name;
ALTER TABLE attendance_records DROP COLUMN IF EXISTS employee_email;
ALTER TABLE attendance_records DROP COLUMN IF EXISTS work_hours;

-- 步驟 7: 重新建立 checkout_diagnosis 視圖（如果需要的話）
-- 使用計算的工作時數而不是儲存的欄位
CREATE OR REPLACE VIEW checkout_diagnosis AS
SELECT 
  id,
  employee_id,
  check_in_time,
  check_out_time,
  -- 即時計算工作時數
  CASE 
    WHEN check_out_time IS NOT NULL THEN
      EXTRACT(EPOCH FROM (check_out_time - check_in_time)) / 3600.0
    ELSE NULL
  END AS calculated_work_hours,
  location,
  notes,
  is_manual_entry,
  created_at,
  updated_at,
  -- 診斷資訊
  CASE 
    WHEN check_out_time IS NULL THEN '未打卡下班'
    WHEN EXTRACT(EPOCH FROM (check_out_time - check_in_time)) / 3600.0 < 1 THEN '工時異常（小於1小時）'
    WHEN EXTRACT(EPOCH FROM (check_out_time - check_in_time)) / 3600.0 > 16 THEN '工時異常（大於16小時）'
    ELSE '正常'
  END AS status
FROM attendance_records;

-- 注意：執行此 SQL 前請先確保：
-- 1. 已經備份資料庫
-- 2. 已經更新應用程式碼，不再使用這些欄位
-- 3. employees 表的 id 欄位是使用 auth.users.id（已確認）
-- 4. work_hours 欄位已改用 calculatedWorkHours getter 計算（已確認）
-- 5. 如果 checkout_diagnosis 視圖在應用程式中被使用，請更新查詢以使用 calculated_work_hours
