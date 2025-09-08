# 修復使用者清單顯示問題 - 設置指南

## 🎯 問題說明

您遇到的問題是 Supabase 註冊的使用者沒有顯示在權限管理的選擇視窗中。

## 🔧 解決方案

我已經修改了 `getAllUsers()` 方法，現在它會嘗試多種方式來獲取使用者：

### 方法 1：設置資料庫 RPC 函數（推薦）

1. **在 Supabase Dashboard 中**：
   - 進入您的專案
   - 點擊左側的 "SQL Editor"
   - 複製 `docs/database/create_user_functions.sql` 中的內容
   - 執行這個 SQL 腳本

2. **腳本會創建**：
   - `get_all_users()` RPC 函數
   - `profiles` 表（如果不存在）
   - 自動同步觸發器

### 方法 2：手動創建 profiles 表

如果您不想使用 RPC 函數，可以手動創建 profiles 表：

```sql
-- 創建 profiles 表
CREATE TABLE IF NOT EXISTS public.profiles (
    id uuid REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email text,
    display_name text,
    created_at timestamptz DEFAULT NOW()
);

-- 啟用 RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 允許查看所有 profiles
CREATE POLICY "Allow all to view profiles" ON public.profiles
    FOR SELECT USING (true);

-- 同步現有使用者
INSERT INTO public.profiles (id, email, display_name, created_at)
SELECT 
    id, 
    email, 
    email,
    created_at
FROM auth.users
WHERE email IS NOT NULL
ON CONFLICT (id) DO NOTHING;
```

### 方法 3：備用方案

如果以上都不行，應用會從權限表中提取唯一使用者作為備用方案。

## 🧪 測試步驟

1. **執行上述 SQL 腳本**
2. **重新啟動應用**
3. **進入權限管理頁面**
4. **點擊添加使用者按鈕**
5. **檢查調試輸出**

應該會看到類似這樣的輸出：

```
開始獲取所有使用者...
從 RPC 函數獲取到 3 個使用者
```

## 🔍 調試方法

使用我之前設置的調試環境：

1. **在 VS Code 中設置斷點**：
   - `permission_service.dart` 第 337 行
   - `permission_management_page.dart` 第 377 行

2. **啟動調試模式**：
   - 按 F5
   - 選擇 "ctc (Chrome Web Debug)"

3. **檢查變數值**：
   - `rpcResponse` - 應該包含使用者清單
   - `_allUsers` - 應該有 3 個使用者
   - `_filteredUsers` - 應該也有 3 個使用者

## 📱 預期結果

修復後，您應該會看到：

- ✅ 搜尋框顯示 "搜尋使用者"
- ✅ 下方顯示可滾動的使用者清單
- ✅ 每個使用者顯示頭像、電子郵件和註冊時間
- ✅ 點擊使用者可以選擇

## 🆘 如果還是不行

如果執行 SQL 腳本後還是看不到使用者，請：

1. **檢查 Supabase 中的使用者**：
   - 在 Dashboard 中查看 Authentication > Users
   - 確認有 3 個註冊使用者

2. **檢查 RPC 函數**：

   ```sql
   SELECT * FROM get_all_users();
   ```

3. **檢查調試輸出**：
   - 開啟瀏覽器開發者工具
   - 查看 Console 輸出

請先執行 SQL 腳本，然後告訴我結果如何！
