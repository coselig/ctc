# AuthRetryableFetchException 診斷報告

## 最新診斷結果 (2025-11-10)

### ✅ 系統狀態確認

**數據庫連接**: ✅ **成功**
```
PostgreSQL 15.8 on x86_64-pc-linux-gnu
編譯器: gcc (GCC) 13.2.0, 64-bit
狀態: 運行正常
```

**Supabase 客戶端**: ✅ 已連接  
**網路連接**: ✅ 連接正常  
**Auth Session**: ✅ 有效  
**Access Token**: ✅ 正常 (745 字符)

### ❌ 問題描述

**錯誤**: Database error saving new user  
**狀態碼**: 500  
**錯誤類型**: AuthRetryableFetchException

### 🔍 問題分析

**重要發現**: 數據庫連接完全正常，但用戶創建操作失敗。

這表明問題不在於：
- ❌ 數據庫連接問題
- ❌ 網路連接問題  
- ❌ API 金鑰錯誤
- ❌ Supabase 服務不可用

問題可能在於：
- ⚠️ **Row Level Security (RLS) 政策限制**
- ⚠️ **auth.users 表權限設置**
- ⚠️ **數據驗證規則**
- ⚠️ **數據庫觸發器錯誤**
- ⚠️ **唯一約束衝突**
- ⚠️ **並發操作衝突**

## 🛠️ 解決步驟

### 步驟 1: 檢查 Supabase Auth 日誌

1. 登入 [Supabase Dashboard](https://supabase.com/dashboard)
2. 選擇您的項目
3. 導航至 **Auth** > **Logs**
4. 查找最近的錯誤記錄
5. 記錄具體的錯誤訊息

### 步驟 2: 檢查 RLS 政策

```sql
-- 檢查 auth.users 表的 RLS 狀態
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'auth' AND tablename = 'users';

-- 查看 auth schema 的所有政策
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
WHERE schemaname = 'auth'
ORDER BY tablename, policyname;
```

### 步驟 3: 檢查權限設置

```sql
-- 檢查 service_role 權限
SELECT 
  grantee,
  privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'auth' 
  AND table_name = 'users';

-- 檢查 anon 和 authenticated 角色權限
SELECT 
  r.rolname,
  r.rolsuper,
  r.rolinherit,
  r.rolcreaterole,
  r.rolcreatedb,
  r.rolcanlogin
FROM pg_roles r
WHERE r.rolname IN ('anon', 'authenticated', 'service_role');
```

### 步驟 4: 檢查觸發器

```sql
-- 查看 auth.users 表的觸發器
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement,
  action_timing
FROM information_schema.triggers
WHERE event_object_schema = 'auth'
  AND event_object_table = 'users';
```

### 步驟 5: 測試用戶創建

```sql
-- 直接在 SQL Editor 中測試創建用戶
-- 注意：這需要 service_role 權限
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  confirmation_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'test@example.com',
  crypt('testpassword123', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{}',
  false,
  encode(gen_random_bytes(32), 'hex')
);

-- 如果上述操作失敗，檢查錯誤訊息
```

## 🎯 常見問題和解決方案

### 問題 1: RLS 政策過於嚴格

**症狀**: "new row violates row-level security policy"

**解決方案**:
```sql
-- 暫時禁用 RLS 以測試（僅用於開發環境）
ALTER TABLE auth.users DISABLE ROW LEVEL SECURITY;

-- 或者創建允許插入的政策
CREATE POLICY "Allow service role to insert users" 
ON auth.users 
FOR INSERT 
TO service_role 
WITH CHECK (true);
```

### 問題 2: Email 已存在

**症狀**: "duplicate key value violates unique constraint"

**檢查方法**:
```sql
-- 檢查郵箱是否已被使用
SELECT id, email, created_at, deleted_at
FROM auth.users
WHERE email = 'test@example.com';

-- 如果需要清理測試數據
DELETE FROM auth.users WHERE email LIKE '%@example.com';
```

### 問題 3: 數據庫配置問題

**檢查配置**:
```sql
-- 檢查重要配置
SELECT name, setting, unit, category 
FROM pg_settings 
WHERE name IN (
  'max_connections',
  'shared_buffers',
  'effective_cache_size',
  'work_mem',
  'maintenance_work_mem'
);
```

### 問題 4: Auth 配置問題

在 Supabase Dashboard 檢查：

1. **Authentication** > **Settings**
2. 確認以下設置：
   - ✅ Enable Email provider
   - ✅ Confirm email (可以暫時關閉用於測試)
   - ✅ Secure password (檢查密碼要求)

3. **Authentication** > **URL Configuration**
   - 確認 Site URL 正確
   - 確認 Redirect URLs 包含您的應用 URL

## 🔧 快速修復建議

### 方案 1: 使用 Supabase Auth Admin API

如果 RLS 是問題所在，使用 service_role key：

```dart
// 使用 service_role key 創建用戶
final supabase = SupabaseClient(
  'YOUR_SUPABASE_URL',
  'YOUR_SERVICE_ROLE_KEY', // 注意：僅在後端使用
);

final response = await supabase.auth.admin.createUser(
  UserAttributes(
    email: 'test@example.com',
    password: 'securepassword123',
    emailConfirm: true,
  ),
);
```

### 方案 2: 檢查並修復 RLS 政策

```sql
-- 查看當前的 RLS 政策
\d+ auth.users

-- 如果需要，創建適當的政策
CREATE POLICY "Enable insert for service role" 
ON auth.users 
FOR INSERT 
TO service_role 
USING (true) 
WITH CHECK (true);
```

### 方案 3: 檢查 Email 設置

```sql
-- 檢查 auth 配置
SELECT * FROM auth.config;

-- 檢查是否需要 email 確認
SELECT * FROM auth.users WHERE email_confirmed_at IS NULL;
```

## 📊 監控和日誌

### 在 Supabase Dashboard 監控

1. **Database** > **Logs**
   - 查看 Postgres 日誌
   - 篩選 error 級別

2. **Auth** > **Logs**
   - 查看認證相關錯誤
   - 檢查失敗的註冊嘗試

3. **API** > **Logs**
   - 查看 API 請求
   - 檢查狀態碼 500 的請求

### 設置告警

考慮設置以下告警：
- Auth 錯誤率超過閾值
- 數據庫連接失敗
- API 5xx 錯誤增加

## 🚀 下一步行動

1. **立即執行**:
   - [ ] 檢查 Supabase Auth Logs
   - [ ] 查看具體的錯誤訊息
   - [ ] 檢查測試郵箱是否已存在

2. **技術檢查**:
   - [ ] 執行 RLS 檢查 SQL
   - [ ] 驗證權限設置
   - [ ] 檢查觸發器

3. **配置確認**:
   - [ ] 確認 Auth 配置正確
   - [ ] 檢查 Email 驗證設置
   - [ ] 驗證 Redirect URLs

4. **修復後測試**:
   - [ ] 重新測試用戶註冊
   - [ ] 使用系統診斷工具驗證
   - [ ] 檢查 Auth Logs 確認成功

## 📝 相關資源

- [Supabase Auth 文檔](https://supabase.com/docs/guides/auth)
- [Row Level Security 指南](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase Logs 文檔](https://supabase.com/docs/guides/platform/logs)
- [PostgreSQL 權限管理](https://www.postgresql.org/docs/current/user-manag.html)