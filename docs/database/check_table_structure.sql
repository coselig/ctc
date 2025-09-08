-- 檢查資料庫表結構並確認 user_id 欄位類型

-- 查看 floor_plan_permissions 表結構
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'floor_plan_permissions' 
    AND table_schema = 'public'
ORDER BY ordinal_position;
