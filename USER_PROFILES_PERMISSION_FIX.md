# 🚨 user_profiles 表權限問題修復指南

## 問題診斷

從 Supabase Auth Logs 發現的根本原因：

```
ERROR: permission denied for table user_profiles (SQLSTATE 42501)
```

**完整錯誤信息**:
```
failed to close prepared statement: ERROR: current transaction is aborted, 
commands ignored until end of transaction block (SQLSTATE 25P02): 
ERROR: permission denied for table user_profiles (SQLSTATE 42501)
```

**發生時間**: 2025-11-10T02:11:53Z (request_id: 49758c08-03dc-4890-82f9-013779666161)

## 🎯 問題說明

當用戶嘗試註冊時：
1. Supabase Auth 成功連接到數據庫 (PostgreSQL 15.8)
2. Auth 服務嘗試在 `auth.users` 表中創建用戶記錄
3. 觸發器或自動流程嘗試在 `public.user_profiles` 表中創建對應記錄
4. **失敗**: `user_profiles` 表的權限不足，導致整個事務回滾

## 🛠️ 修復方案

### 方案 1: 快速修復（推薦）

在 Supabase Dashboard → SQL Editor 中執行：

```sql
-- 1. 授予 service_role 完整權限
GRANT ALL ON public.user_profiles TO service_role;

-- 2. 授予 authenticated 用戶基本權限
GRANT SELECT, INSERT, UPDATE ON public.user_profiles TO authenticated;

-- 3. 如果使用序列（自增 ID），也需要授權
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
```

### 方案 2: 使用 RLS 政策（更安全）

```sql
-- 5. 先刪除舊政策（如果存在），然後創建新政策
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can view their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;

CREATE POLICY "Users can insert their own profile" 
ON public.user_profiles 
FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own profile" 
ON public.user_profiles 
FOR SELECT 
TO authenticated 
USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile" 
ON public.user_profiles 
FOR UPDATE 
TO authenticated 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 5. 授予基本權限
GRANT SELECT, INSERT, UPDATE ON public.user_profiles TO authenticated;
```

### 方案 3: 檢查並修復觸發器權限

如果有自動創建 profile 的觸發器，需要確保函數有適當權限：

```sql
-- 1. 查找相關觸發器
SELECT 
    trigger_name, 
    event_manipulation, 
    action_statement,
    action_timing
FROM information_schema.triggers
WHERE event_object_schema = 'auth'
  AND event_object_table = 'users';

-- 2. 查找處理 user_profiles 的函數
SELECT 
    routine_name,
    routine_type,
    security_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND (routine_definition LIKE '%user_profiles%' 
       OR routine_name LIKE '%user%');

-- 3. 將函數設置為 SECURITY DEFINER（用函數所有者權限執行）
-- 假設函數名為 handle_new_user
ALTER FUNCTION public.handle_new_user() SECURITY DEFINER;

-- 4. 授予執行權限
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO authenticated;
```

## 🔍 驗證步驟

執行以下 SQL 檢查當前狀態：

```sql
-- 1. 檢查表權限
SELECT 
    grantee, 
    privilege_type,
    is_grantable
FROM information_schema.role_table_grants
WHERE table_schema = 'public' 
  AND table_name = 'user_profiles'
ORDER BY grantee, privilege_type;

-- 2. 檢查 RLS 是否啟用
SELECT 
    schemaname, 
    tablename, 
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public' 
  AND tablename = 'user_profiles';

-- 3. 檢查現有的 RLS 政策
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
WHERE schemaname = 'public' 
  AND tablename = 'user_profiles';

-- 4. 檢查觸發器
SELECT 
    trigger_name,
    event_manipulation,
    action_timing,
    action_statement
FROM information_schema.triggers
WHERE event_object_schema = 'public'
  AND event_object_table = 'user_profiles';
```

## 📋 完整修復流程

### 步驟 1: 備份當前設置

```sql
-- 備份當前權限設置
SELECT * FROM information_schema.role_table_grants
WHERE table_name = 'user_profiles'
ORDER BY grantee, privilege_type;

-- 保存結果，以防需要回滾
```

### 步驟 2: 執行修復

選擇上面的方案 1 或方案 2 執行。**推薦使用方案 2（RLS 政策）以獲得更好的安全性。**

### 步驟 3: 測試

在執行修復後，嘗試在應用中註冊新用戶：

1. 打開應用的註冊頁面
2. 輸入測試郵箱（如 test@example.com）
3. 提交註冊
4. 查看是否成功創建

### 步驟 4: 監控日誌

在 Supabase Dashboard → Logs → Auth 中查看是否還有錯誤：

```
✓ 成功: 應該看到 "token_refreshed" 和 "audit_event"
✗ 失敗: 如果仍然看到 "permission denied"，需要進一步檢查
```

## 🎯 預期結果

修復後，Supabase Auth Logs 應該顯示：

```json
{
  "auth_audit_event": {
    "action": "user_signedup",
    "actor_id": "新用戶ID",
    "actor_username": "用戶郵箱",
    "audit_log_id": "...",
    "created_at": "...",
    "log_type": "account"
  },
  "level": "info",
  "msg": "audit_event"
}
```

而不是：

```json
{
  "component": "api",
  "error": "permission denied for table user_profiles",
  "level": "error",
  "msg": "500: Database error saving new user"
}
```

## 🚀 其他建議

### 1. 檢查數據庫角色

```sql
-- 查看當前數據庫角色
SELECT 
    rolname,
    rolsuper,
    rolcreatedb,
    rolcreaterole
FROM pg_roles
WHERE rolname IN ('authenticated', 'service_role', 'anon');
```

### 2. 檢查 user_profiles 表結構

```sql
-- 確保表結構正確
\d public.user_profiles

-- 或
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'user_profiles'
ORDER BY ordinal_position;
```

### 3. 檢查外鍵約束

```sql
-- 查看 user_profiles 的外鍵
SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name = 'user_profiles';
```

## 📞 需要進一步幫助？

如果上述方案都無法解決問題，請提供：

1. `user_profiles` 表的完整結構（`\d public.user_profiles`）
2. 當前的權限設置（執行上面的驗證 SQL）
3. 任何相關的觸發器或函數代碼
4. 完整的 Supabase Auth Logs 錯誤信息

## ⚠️ 常見陷阱

1. **只授予了表權限，忘記授予序列權限**: 如果 user_profiles 有自增 ID，需要 `GRANT USAGE ON SEQUENCE`
2. **RLS 政策配置錯誤**: 確保 `WITH CHECK` 條件允許插入
3. **觸發器函數權限不足**: 觸發器函數需要 `SECURITY DEFINER` 或適當的權限
4. **anon 角色需要權限**: 如果允許匿名註冊，也需要給 `anon` 角色權限

## 🔐 安全最佳實踐

1. **使用 RLS**: 始終啟用 Row Level Security
2. **最小權限原則**: 只授予必要的權限（SELECT, INSERT, UPDATE），避免 DELETE
3. **使用政策**: 用 RLS 政策替代直接的表權限
4. **審計日誌**: 定期檢查 Supabase Auth Logs
5. **測試環境**: 在測試環境中先驗證修復方案

---

**最後更新**: 2025-11-10  
**錯誤代碼**: SQLSTATE 42501  
**影響版本**: PostgreSQL 15.8 + Supabase Auth
