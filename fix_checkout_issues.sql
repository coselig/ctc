-- 補下班打卡問題修復 SQL 腳本
-- 執行此腳本來修復最常見的權限和跨日問題

-- 1. 檢查當前的 RLS 政策
SELECT 
    schemaname,
    tablename, 
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'attendance_records' AND cmd = 'UPDATE'
ORDER BY policyname;

-- 2. 確保有正確的更新政策
DROP POLICY IF EXISTS "Users can update own recent attendance" ON public.attendance_records;

CREATE POLICY "Users can update own recent attendance" ON public.attendance_records 
FOR UPDATE 
USING (
  (employee_id = auth.uid()) 
  AND 
  (check_in_time >= NOW() - INTERVAL '30 days') -- 延長到30天
) 
WITH CHECK (
  (employee_id = auth.uid())
  AND 
  (check_in_time >= NOW() - INTERVAL '30 days')
);

-- 3. 檢查並優化現有的 RPC 函數
DROP FUNCTION IF EXISTS update_cross_day_checkout;

CREATE OR REPLACE FUNCTION update_cross_day_checkout(
  record_id UUID,
  checkout_time TIMESTAMPTZ,
  work_hours NUMERIC DEFAULT NULL,
  location_text TEXT DEFAULT NULL,
  notes_text TEXT DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
  updated_record JSON;
  calculated_hours NUMERIC;
  current_record RECORD;
BEGIN
  -- 檢查記錄是否存在且屬於當前用戶
  SELECT * INTO current_record
  FROM attendance_records 
  WHERE id = record_id AND employee_id = auth.uid();
  
  IF NOT FOUND THEN
    RAISE EXCEPTION '找不到指定的打卡記錄或權限不足 (記錄ID: %)', record_id;
  END IF;
  
  -- 記錄操作日誌
  RAISE NOTICE '更新打卡記錄: ID=%, 員工=%, 原下班時間=%, 新下班時間=%', 
    record_id, current_record.employee_id, current_record.check_out_time, checkout_time;

  -- 如果沒有提供工作時數，自動計算
  IF work_hours IS NULL THEN
    calculated_hours := EXTRACT(EPOCH FROM (checkout_time - current_record.check_in_time)) / 3600.0;
    calculated_hours := GREATEST(calculated_hours, 0);
  ELSE
    calculated_hours := work_hours;
  END IF;

  -- 更新打卡記錄
  UPDATE attendance_records 
  SET 
    check_out_time = checkout_time,
    work_hours = calculated_hours,
    location = COALESCE(location_text, location),
    notes = COALESCE(notes_text, notes),
    updated_at = NOW(),
    is_manual_entry = true
  WHERE id = record_id
  RETURNING to_json(attendance_records.*) INTO updated_record;
    
  IF updated_record IS NULL THEN
    RAISE EXCEPTION '更新打卡記錄失敗';
  END IF;
  
  RAISE NOTICE '打卡記錄更新成功: 工作時數=%, 下班時間=%', calculated_hours, checkout_time;
  
  RETURN updated_record;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. 授予權限
GRANT EXECUTE ON FUNCTION update_cross_day_checkout TO authenticated;

-- 5. 創建管理員專用的補打卡函數（繞過所有限制）
CREATE OR REPLACE FUNCTION admin_update_attendance(
  record_id UUID,
  checkin_time TIMESTAMPTZ DEFAULT NULL,
  checkout_time TIMESTAMPTZ DEFAULT NULL,
  work_hours NUMERIC DEFAULT NULL,
  location_text TEXT DEFAULT NULL,
  notes_text TEXT DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
  updated_record JSON;
  calculated_hours NUMERIC;
  current_record RECORD;
  current_user_role TEXT;
BEGIN
  -- 檢查當前用戶是否為管理員
  SELECT role INTO current_user_role
  FROM employees 
  WHERE id = auth.uid();
  
  IF current_user_role NOT IN ('boss', 'hr') THEN
    RAISE EXCEPTION '只有管理員可以使用此功能';
  END IF;
  
  -- 獲取現有記錄
  SELECT * INTO current_record
  FROM attendance_records 
  WHERE id = record_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION '找不到指定的打卡記錄 (記錄ID: %)', record_id;
  END IF;
  
  -- 計算工作時數
  IF work_hours IS NULL AND checkin_time IS NOT NULL AND checkout_time IS NOT NULL THEN
    calculated_hours := EXTRACT(EPOCH FROM (checkout_time - checkin_time)) / 3600.0;
    calculated_hours := GREATEST(calculated_hours, 0);
  ELSIF work_hours IS NULL AND checkout_time IS NOT NULL THEN
    calculated_hours := EXTRACT(EPOCH FROM (checkout_time - COALESCE(checkin_time, current_record.check_in_time))) / 3600.0;
    calculated_hours := GREATEST(calculated_hours, 0);
  ELSE
    calculated_hours := work_hours;
  END IF;

  -- 更新打卡記錄
  UPDATE attendance_records 
  SET 
    check_in_time = COALESCE(checkin_time, check_in_time),
    check_out_time = COALESCE(checkout_time, check_out_time),
    work_hours = COALESCE(calculated_hours, work_hours),
    location = COALESCE(location_text, location),
    notes = COALESCE(notes_text, notes),
    updated_at = NOW(),
    is_manual_entry = true
  WHERE id = record_id
  RETURNING to_json(attendance_records.*) INTO updated_record;
  
  RETURN updated_record;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION admin_update_attendance TO authenticated;

-- 6. 測試查詢：檢查最近的補下班打卡失敗案例
SELECT 
  alr.id,
  alr.employee_name,
  alr.request_type,
  alr.request_date,
  alr.request_time,
  alr.check_in_time,
  alr.status,
  ar.id as attendance_id,
  ar.check_in_time as actual_checkin,
  ar.check_out_time as actual_checkout
FROM attendance_leave_requests alr
LEFT JOIN attendance_records ar ON (
  ar.employee_id = alr.employee_id 
  AND DATE(ar.check_in_time) = alr.request_date
)
WHERE alr.request_type = 'check_out' 
  AND alr.status = 'approved'
ORDER BY alr.created_at DESC
LIMIT 10;

-- 7. 創建診斷視圖
CREATE OR REPLACE VIEW checkout_diagnosis AS
SELECT 
  alr.id as request_id,
  alr.employee_name,
  alr.request_date,
  alr.request_time as requested_checkout,
  alr.check_in_time as requested_checkin_change,
  alr.status as request_status,
  ar.id as attendance_record_id,
  ar.check_in_time as actual_checkin,
  ar.check_out_time as actual_checkout,
  ar.work_hours,
  ar.updated_at as last_updated,
  CASE 
    WHEN ar.id IS NULL THEN 'NO_ATTENDANCE_RECORD'
    WHEN ar.check_out_time IS NULL THEN 'NO_CHECKOUT_TIME'
    WHEN ar.check_out_time = alr.request_time THEN 'CHECKOUT_MATCHES'
    ELSE 'CHECKOUT_MISMATCH'
  END as diagnosis
FROM attendance_leave_requests alr
LEFT JOIN attendance_records ar ON (
  ar.employee_id = alr.employee_id 
  AND DATE(ar.check_in_time) = alr.request_date
)
WHERE alr.request_type = 'check_out' 
  AND alr.status = 'approved'
ORDER BY alr.created_at DESC;

-- 8. 顯示診斷結果
SELECT * FROM checkout_diagnosis LIMIT 20;