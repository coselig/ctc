-- 修復打卡權限問題的 SQL 腳本

-- 1. 首先刪除舊的 RLS 政策
DROP POLICY IF EXISTS "Users can update own today attendance" ON public.attendance_records;

-- 2. 創建新的更寬鬆的更新政策
-- 允許員工更新自己的記錄，條件是：
-- - 是自己的記錄 (employee_id = auth.uid())
-- - 且記錄是最近7天內的 (避免修改太舊的記錄)
-- - 且要麼還沒下班打卡，要麼是今天的記錄 (允許今天修改今天的記錄)
CREATE POLICY "Users can update own recent attendance" ON public.attendance_records 
FOR UPDATE 
USING (
  (employee_id = auth.uid()) 
  AND 
  (check_in_time >= NOW() - INTERVAL '7 days')
  AND 
  (
    check_out_time IS NULL 
    OR 
    date(check_in_time AT TIME ZONE 'Asia/Taipei') = date(NOW() AT TIME ZONE 'Asia/Taipei')
  )
) 
WITH CHECK (
  (employee_id = auth.uid())
  AND 
  (check_in_time >= NOW() - INTERVAL '7 days')
);

-- 3. 確認現有的其他相關政策
-- 檢查是否有衝突的政策

-- 顯示所有 attendance_records 相關的政策
SELECT 
  schemaname,
  tablename, 
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'attendance_records' 
ORDER BY policyname;

-- 4. 檢查 RLS 是否啟用
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'attendance_records' AND schemaname = 'public';