-- 員工管理系統示例資料
-- 執行前請確保已經創建了員工管理相關的資料表結構

-- ======================================
-- 員工基本資料示例
-- ======================================

-- 確保系統設定有必要的資料
INSERT INTO public.system_settings (key, value, description) VALUES
('company_name', '光悅科技', '公司名稱'),
('company_address', '台北市信義區', '公司地址'),
('hr_email', 'hr@guangyue.tech', '人資聯絡信箱'),
('company_phone', '02-1234-5678', '公司電話'),
('employee_id_prefix', 'EMP', '員工編號前綴'),
('default_work_hours', '8', '預設工作時數')
ON CONFLICT (key) DO UPDATE SET
  value = EXCLUDED.value,
  description = EXCLUDED.description,
  updated_at = timezone('utc'::text, now());

-- 注意：以下員工示例資料需要有效的 created_by UUID
-- 請將 'your-user-uuid-here' 替換為實際的用戶 UUID

-- 插入員工示例資料（需要先有認證用戶）
-- INSERT INTO public.employees (
--   employee_id, name, email, phone, department, position, 
--   hire_date, salary, status, address, 
--   emergency_contact_name, emergency_contact_phone, 
--   notes, created_by
-- ) VALUES
-- (
--   'EMP001',
--   '王小明',
--   'wang@guangyue.tech',
--   '0912-345-678',
--   '技術部',
--   '前端工程師',
--   '2024-01-15',
--   65000,
--   'active',
--   '台北市大安區忠孝東路四段123號',
--   '王媽媽',
--   '0987-654-321',
--   '表現優秀，具備良好的溝通能力和技術實力',
--   'your-user-uuid-here'
-- ),
-- (
--   'EMP002',
--   '李小華',
--   'lee@guangyue.tech',
--   '0923-456-789',
--   '技術部',
--   '後端工程師',
--   '2024-02-01',
--   68000,
--   'active',
--   '新北市板橋區中山路二段456號',
--   '李爸爸',
--   '0976-543-210',
--   '資深工程師，負責系統架構設計',
--   'your-user-uuid-here'
-- ),
-- (
--   'EMP003',
--   '陳美玲',
--   'chen@guangyue.tech',
--   '0934-567-890',
--   '業務部',
--   '業務代表',
--   '2024-03-01',
--   55000,
--   'active',
--   '台北市松山區南京東路三段789號',
--   '陳先生',
--   '0965-432-109',
--   '具備豐富的客戶服務經驗，善於溝通協調',
--   'your-user-uuid-here'
-- ),
-- (
--   'EMP004',
--   '張志強',
--   'zhang@guangyue.tech',
--   '0945-678-901',
--   '研發部',
--   '硬體工程師',
--   '2024-01-20',
--   72000,
--   'active',
--   '桃園市中壢區中央路一段321號',
--   '張太太',
--   '0954-321-098',
--   '專精於嵌入式系統開發，具備豐富的硬體設計經驗',
--   'your-user-uuid-here'
-- ),
-- (
--   'EMP005',
--   '劉雅婷',
--   'liu@guangyue.tech',
--   '0956-789-012',
--   '產品部',
--   '產品經理',
--   '2023-11-15',
--   78000,
--   'active',
--   '台北市內湖區成功路四段654號',
--   '劉媽媽',
--   '0943-210-987',
--   '具備敏捷開發經驗，善於需求分析和產品規劃',
--   'your-user-uuid-here'
-- );

-- ======================================
-- 員工技能示例資料
-- ======================================

-- 注意：以下技能示例資料需要先有員工資料
-- 請確保對應的員工記錄存在

-- INSERT INTO public.employee_skills (employee_id, skill_name, proficiency_level) VALUES
-- -- 王小明的技能
-- ((SELECT id FROM public.employees WHERE employee_id = 'EMP001'), 'React', 4),
-- ((SELECT id FROM public.employees WHERE employee_id = 'EMP001'), 'Vue.js', 3),
-- ((SELECT id FROM public.employees WHERE employee_id = 'EMP001'), 'JavaScript', 5),
-- ((SELECT id FROM public.employees WHERE employee_id = 'EMP001'), 'HTML/CSS', 4),

-- -- 李小華的技能
-- ((SELECT id FROM public.employees WHERE employee_id = 'EMP002'), 'Node.js', 5),
-- ((SELECT id FROM public.employees WHERE employee_id = 'EMP002'), 'Python', 4),
-- ((SELECT id FROM public.employees WHERE employee_id = 'EMP002'), 'PostgreSQL', 4),
-- ((SELECT id FROM public.employees WHERE employee_id = 'EMP002'), 'Docker', 3),

-- -- 張志強的技能
-- ((SELECT id FROM public.employees WHERE employee_id = 'EMP004'), 'C/C++', 5),
-- ((SELECT id FROM public.employees WHERE employee_id = 'EMP004'), 'Arduino', 4),
-- ((SELECT id FROM public.employees WHERE employee_id = 'EMP004'), 'PCB設計', 4),
-- ((SELECT id FROM public.employees WHERE employee_id = 'EMP004'), '嵌入式系統', 5),

-- -- 劉雅婷的技能
-- ((SELECT id FROM public.employees WHERE employee_id = 'EMP005'), '產品規劃', 5),
-- ((SELECT id FROM public.employees WHERE employee_id = 'EMP005'), '敏捷開發', 4),
-- ((SELECT id FROM public.employees WHERE employee_id = 'EMP005'), '需求分析', 4),
-- ((SELECT id FROM public.employees WHERE employee_id = 'EMP005'), '使用者研究', 3);

-- ======================================
-- 使用說明
-- ======================================

-- 1. 首先確保已經執行 employee_system.sql 創建所有表格結構
-- 2. 登入系統並獲取當前用戶的 UUID
-- 3. 將上述註釋掉的 INSERT 語句中的 'your-user-uuid-here' 替換為實際的用戶 UUID
-- 4. 執行修改後的 INSERT 語句來創建示例員工資料
-- 5. 執行員工技能的 INSERT 語句來添加技能資料

-- 獲取當前用戶 UUID 的查詢：
-- SELECT auth.uid();

-- 刪除示例資料的指令（如有需要）：
-- DELETE FROM public.employee_skills WHERE employee_id IN (
--   SELECT id FROM public.employees WHERE employee_id LIKE 'EMP%'
-- );
-- DELETE FROM public.employees WHERE employee_id LIKE 'EMP%';
-- DELETE FROM public.system_settings WHERE key IN (
--   'company_name', 'company_address', 'hr_email', 'company_phone',
--   'employee_id_prefix', 'default_work_hours'
-- );