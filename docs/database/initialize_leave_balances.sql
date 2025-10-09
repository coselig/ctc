-- ========================================
-- 初始化所有員工的假別額度 (2025 年)
-- ========================================

-- 為所有現有員工初始化 2025 年的假別額度
DO $$
DECLARE
    emp RECORD;
BEGIN
    -- 遍歷所有員工
    FOR emp IN SELECT id, name FROM employees
    LOOP
        RAISE NOTICE '正在為員工 % (%) 初始化假別額度...', emp.name, emp.id;
        
        -- 病假 (30天)
        PERFORM initialize_leave_balance(emp.id, 'sick', 2025, 30);
        
        -- 事假 (14天)
        PERFORM initialize_leave_balance(emp.id, 'personal', 2025, 14);
        
        -- 特休 (14天)
        PERFORM initialize_leave_balance(emp.id, 'annual', 2025, 14);
        
        -- 育嬰假 (730天，約2年)
        PERFORM initialize_leave_balance(emp.id, 'parental', 2025, 730);
        
        -- 婚假 (8天)
        PERFORM initialize_leave_balance(emp.id, 'marriage', 2025, 8);
        
        -- 喪假 (8天)
        PERFORM initialize_leave_balance(emp.id, 'bereavement', 2025, 8);
        
        -- 公假 (365天)
        PERFORM initialize_leave_balance(emp.id, 'official', 2025, 365);
        
        -- 產假 (56天，8週)
        PERFORM initialize_leave_balance(emp.id, 'maternity', 2025, 56);
        
        -- 陪產假 (7天)
        PERFORM initialize_leave_balance(emp.id, 'paternity', 2025, 7);
        
        -- 生理假 (12天，每月1天)
        PERFORM initialize_leave_balance(emp.id, 'menstrual', 2025, 12);
        
        RAISE NOTICE '完成！';
    END LOOP;
END $$;

-- 驗證結果
SELECT 
    e.name AS 員工姓名,
    lb.leave_type AS 假別,
    lb.total_days AS 總天數,
    lb.used_days AS 已使用,
    lb.pending_days AS 審核中,
    (lb.total_days - lb.used_days - lb.pending_days) AS 剩餘天數
FROM leave_balances lb
JOIN employees e ON lb.employee_id = e.id
WHERE lb.year = 2025
ORDER BY e.name, lb.leave_type;
