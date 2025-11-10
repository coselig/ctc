# Supabase AuthRetryableFetchException 修復指南

## 問題診斷

### 錯誤詳情
```
PostgrestException(
  message: Could not find the function public.version without parameters in the schema cache, 
  code: PGRST202, 
  details: Searched for the function public.version without parameters or with a single unnamed json/jsonb parameter, but no matches were found in the schema cache
)
```

### 診斷結果
- ✅ **Supabase 客戶端**: 已連接
- ❌ **數據庫連接**: 失敗
- ❌ **public.version 函數**: 缺失
- ✅ **Auth Session**: 有效 
- ✅ **Access Token**: 正常 (745 字符)

## 根本原因

**主要問題**: Supabase 數據庫缺少必要的 `public.version()` 函數

**可能成因**:
1. 數據庫初始化不完整
2. Supabase 項目配置問題
3. PostgREST API 配置錯誤
4. 數據庫遷移過程中函數丟失

## 修復步驟

### 方法 1: SQL Editor 修復 (推薦)

1. **登入 Supabase Dashboard**
   ```
   https://supabase.com/dashboard
   ```

2. **選擇您的項目並進入 SQL Editor**
   - 點擊左側導航的 "SQL Editor"
   - 點擊 "New Query"

3. **執行修復 SQL**
   ```sql
   -- 創建 version 函數
   CREATE OR REPLACE FUNCTION public.version()
   RETURNS text AS $$
   BEGIN
     RETURN version();
   END;
   $$ LANGUAGE plpgsql SECURITY DEFINER;

   -- 設置函數權限
   GRANT EXECUTE ON FUNCTION public.version() TO anon;
   GRANT EXECUTE ON FUNCTION public.version() TO authenticated;
   
   -- 創建額外的診斷函數 (可選)
   CREATE OR REPLACE FUNCTION public.health_check()
   RETURNS json AS $$
   BEGIN
     RETURN json_build_object(
       'database', 'ok',
       'timestamp', now(),
       'version', version()
     );
   END;
   $$ LANGUAGE plpgsql SECURITY DEFINER;
   
   GRANT EXECUTE ON FUNCTION public.health_check() TO anon;
   GRANT EXECUTE ON FUNCTION public.health_check() TO authenticated;
   ```

4. **驗證修復**
   ```sql
   -- 測試函數是否正常工作
   SELECT public.version();
   SELECT public.health_check();
   ```

### 方法 2: API 修復檢查

如果方法 1 無效，檢查以下項目：

1. **檢查 Supabase API 設置**
   - 確認 Project URL 正確
   - 確認 anon key 正確
   - 檢查 service_role key (如果使用)

2. **檢查 Row Level Security (RLS)**
   ```sql
   -- 檢查 auth.users 表的 RLS 設置
   SELECT schemaname, tablename, rowsecurity 
   FROM pg_tables 
   WHERE schemaname = 'auth' AND tablename = 'users';
   
   -- 檢查相關政策
   SELECT schemaname, tablename, policyname, roles, cmd 
   FROM pg_policies 
   WHERE schemaname = 'auth';
   ```

3. **檢查數據庫連接設置**
   ```sql
   -- 檢查數據庫配置
   SELECT name, setting FROM pg_settings 
   WHERE name IN ('max_connections', 'shared_preload_libraries');
   ```

## 驗證修復

### 步驟 1: 重新啟動應用
1. 完全關閉並重新啟動您的 Flutter 應用
2. 清除瀏覽器快取 (如果是 Web 應用)

### 步驟 2: 測試功能
1. 嘗試註冊新用戶
2. 測試登入功能
3. 使用系統診斷工具再次檢查

### 步驟 3: 監控錯誤
```dart
// 在 Flutter 中添加錯誤監控
try {
  await supabase.auth.signUp(email: email, password: password);
} on AuthException catch (e) {
  print('Auth error: ${e.message}');
  print('Error code: ${e.statusCode}');
} catch (e) {
  print('Unexpected error: $e');
}
```

## 預防措施

### 1. 定期備份
```sql
-- 備份重要函數
SELECT pg_get_functiondef(oid) 
FROM pg_proc 
WHERE proname = 'version' AND pronamespace = (
  SELECT oid FROM pg_namespace WHERE nspname = 'public'
);
```

### 2. 監控設置
- 設置 Supabase 項目監控
- 配置錯誤日誌收集
- 建立健康檢查端點

### 3. 開發環境同步
- 確保開發、測試、生產環境的數據庫架構一致
- 使用 Supabase 遷移來管理數據庫變更

## 故障排除

### 如果修復後仍有問題:

1. **檢查 Supabase 專案狀態**
   - 前往 Supabase Dashboard
   - 檢查項目設置頁面是否有錯誤提示

2. **檢查網路連接**
   ```bash
   # 測試連接到 Supabase
   curl -I https://your-project.supabase.co/rest/v1/
   ```

3. **檢查 API 金鑰**
   - 確認 anon key 沒有過期
   - 確認 service_role key 權限正確

4. **聯繫支援**
   - Supabase Discord: https://discord.supabase.com
   - Supabase GitHub Issues: https://github.com/supabase/supabase/issues

## 相關資源

- [Supabase Auth 文檔](https://supabase.com/docs/guides/auth)
- [PostgREST 錯誤處理](https://postgrest.org/en/stable/errors.html)
- [PostgreSQL 函數管理](https://www.postgresql.org/docs/current/sql-createfunction.html)