# 修復權限管理系統的資料庫設定

## 🚨 問題說明

遇到的錯誤：`PostgrestException(message: infinite recursion detected in policy for relation "floor_plan_permissions", code: 42P17)`

**原因**: RLS 策略中的無限遞迴問題，以及上傳設計圖時沒有正確創建擁有者權限。

## 🔧 修復步驟

### 1. 清理現有的 RLS 策略

```sql
-- 刪除可能有問題的策略
DROP POLICY IF EXISTS "Owners can manage permissions" ON floor_plan_permissions;
DROP POLICY IF EXISTS "System can create owner permissions" ON floor_plan_permissions;
DROP POLICY IF EXISTS "Users can view their own permissions" ON floor_plan_permissions;

-- 如果表存在，先禁用 RLS
ALTER TABLE floor_plan_permissions DISABLE ROW LEVEL SECURITY;
```

### 2. 創建輔助函數（避免遞迴）

```sql
-- 創建檢查擁有者權限的函數
CREATE OR REPLACE FUNCTION check_floor_plan_ownership(
    user_id_param UUID,
    floor_plan_url_param TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
    -- 直接查詢是否存在擁有者記錄，不使用 RLS
    RETURN EXISTS (
        SELECT 1 
        FROM floor_plan_permissions 
        WHERE user_id = user_id_param 
          AND floor_plan_url = floor_plan_url_param 
          AND is_owner = TRUE
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 3. 重新啟用 RLS 並創建正確的策略

```sql
-- 重新啟用 RLS
ALTER TABLE floor_plan_permissions ENABLE ROW LEVEL SECURITY;

-- 用戶只能查看自己有權限的設計圖
CREATE POLICY "Users can view their own permissions" ON floor_plan_permissions
    FOR SELECT USING (user_id = auth.uid());

-- 用戶可以插入自己為擁有者的權限記錄（上傳設計圖時）
CREATE POLICY "Users can create owner permissions" ON floor_plan_permissions
    FOR INSERT WITH CHECK (
        user_id = auth.uid() AND is_owner = TRUE
    );

-- 用戶可以插入其他用戶的權限記錄（如果自己是該設計圖的擁有者）
CREATE POLICY "Owners can add user permissions" ON floor_plan_permissions
    FOR INSERT WITH CHECK (
        check_floor_plan_ownership(auth.uid(), floor_plan_url)
    );

-- 擁有者可以更新其他用戶的權限
CREATE POLICY "Owners can update permissions" ON floor_plan_permissions
    FOR UPDATE USING (
        check_floor_plan_ownership(auth.uid(), floor_plan_url)
    ) WITH CHECK (
        check_floor_plan_ownership(auth.uid(), floor_plan_url)
    );

-- 擁有者可以刪除其他用戶的權限
CREATE POLICY "Owners can delete permissions" ON floor_plan_permissions
    FOR DELETE USING (
        check_floor_plan_ownership(auth.uid(), floor_plan_url)
    );
```

### 4. 測試策略是否正常工作

```sql
-- 測試查看權限（這應該只返回當前用戶的權限）
SELECT * FROM floor_plan_permissions;

-- 測試插入擁有者權限（替換為實際的用戶ID和URL）
INSERT INTO floor_plan_permissions (
    floor_plan_id, floor_plan_url, floor_plan_name, 
    user_id, user_email, permission_level, is_owner
) VALUES (
    'test_plan_id', 'https://test.com/test.jpg', 'Test Plan',
    auth.uid(), 'test@example.com', 3, TRUE
);
```

## 🔍 驗證修復

### 1. 檢查策略是否正確創建

```sql
-- 查看當前的 RLS 策略
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'floor_plan_permissions';
```

### 2. 檢查函數是否正確創建

```sql
-- 查看函數
SELECT routine_name, routine_type, security_type
FROM information_schema.routines 
WHERE routine_name = 'check_floor_plan_ownership';
```

### 3. 測試上傳設計圖功能

在應用中嘗試上傳新的設計圖，檢查是否：

1. 設計圖記錄正確插入到 `floor_plans` 表
2. 擁有者權限記錄正確插入到 `floor_plan_permissions` 表
3. 沒有出現遞迴錯誤

## 📝 注意事項

1. **SECURITY DEFINER**: `check_floor_plan_ownership` 函數使用 `SECURITY DEFINER`，這意味著它以創建者（通常是超級用戶）的權限運行，避免了 RLS 的限制。

2. **策略順序**: 策略的順序很重要，確保最寬鬆的策略（如創建擁有者權限）在前面。

3. **測試環境**: 建議先在測試環境中執行這些 SQL，確保沒有問題後再在生產環境中執行。

4. **備份**: 在執行任何 DROP 或 ALTER 操作前，請確保有資料庫備份。

## 🚀 執行完成後

修復完成後，應用程式應該能夠：

- ✅ 正常上傳設計圖
- ✅ 自動為上傳者創建擁有者權限
- ✅ 權限管理功能正常工作
- ✅ 不再出現無限遞迴錯誤

如果仍有問題，請檢查 Supabase 的日誌以獲取更詳細的錯誤信息。
