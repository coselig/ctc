-- 創建跨日下班打卡的 RPC 函數
-- 這個函數可以繞過 RLS 限制，但仍然確保安全性

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
BEGIN
  -- 如果沒有提供工作時數，自動計算
  IF work_hours IS NULL THEN
    SELECT 
      EXTRACT(EPOCH FROM (checkout_time - check_in_time)) / 3600.0
    INTO calculated_hours
    FROM attendance_records 
    WHERE id = record_id 
      AND employee_id = auth.uid();
    
    -- 確保工作時數不為負數
    calculated_hours := GREATEST(calculated_hours, 0);
  ELSE
    calculated_hours := work_hours;
  END IF;

  -- 更新打卡記錄（繞過 RLS）
  UPDATE attendance_records 
  SET 
    check_out_time = checkout_time,
    work_hours = calculated_hours,
    location = COALESCE(location_text, location),
    notes = COALESCE(notes_text, notes),
    updated_at = NOW()
  WHERE id = record_id 
    AND employee_id = auth.uid()  -- 確保只能更新自己的記錄
    AND check_out_time IS NULL    -- 確保還沒下班打卡
  RETURNING to_json(attendance_records.*) INTO updated_record;
    
  -- 檢查是否有記錄被更新
  IF updated_record IS NULL THEN
    RAISE EXCEPTION '找不到可更新的打卡記錄：可能已經下班打卡或權限不足';
  END IF;
  
  -- 返回更新後的記錄
  RETURN updated_record;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 授予權限給已驗證用戶
GRANT EXECUTE ON FUNCTION update_cross_day_checkout TO authenticated;

-- 創建註釋
COMMENT ON FUNCTION update_cross_day_checkout IS '允許員工進行跨日下班打卡，繞過日期限制的 RLS 政策';

-- 測試函數（可選）
-- SELECT update_cross_day_checkout(
--   '00000000-0000-0000-0000-000000000000'::UUID,
--   NOW(),
--   8.5,
--   '公司',
--   '正常下班'
-- );