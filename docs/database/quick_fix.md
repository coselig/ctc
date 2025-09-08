# 臨時解決方案：暫時禁用 RLS 進行測試

如果您急於測試權限管理功能，可以暫時禁用 RLS 來避免遞迴問題：

## 🚧 臨時禁用 RLS（僅供測試）

```sql
-- 暫時禁用 RLS
ALTER TABLE floor_plan_permissions DISABLE ROW LEVEL SECURITY;
```

這將允許所有操作正常進行，但會暫時移除安全限制。

## ✅ 測試完成後重新啟用安全性

測試完成後，請按照 `database_fix_guide.md` 中的完整步驟重新設定 RLS。

## 🔧 快速修復命令

如果您想立即解決問題：

```sql
-- 1. 禁用現有 RLS
ALTER TABLE floor_plan_permissions DISABLE ROW LEVEL SECURITY;

-- 2. 清理可能有問題的策略
DROP POLICY IF EXISTS "Owners can manage permissions" ON floor_plan_permissions;
DROP POLICY IF EXISTS "System can create owner permissions" ON floor_plan_permissions;

-- 3. 創建簡單的檢查函數
CREATE OR REPLACE FUNCTION check_floor_plan_ownership(
    user_id_param UUID,
    floor_plan_url_param TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM floor_plan_permissions 
        WHERE user_id = user_id_param 
          AND floor_plan_url = floor_plan_url_param 
          AND is_owner = TRUE
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. 重新啟用 RLS（可選，用於生產環境）
-- ALTER TABLE floor_plan_permissions ENABLE ROW LEVEL SECURITY;
```

現在您應該能夠正常上傳設計圖並創建權限了！
