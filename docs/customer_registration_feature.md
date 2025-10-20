# 客戶註冊功能說明

## 概述
已成功為系統添加客戶註冊和管理功能。現在系統支援三種用戶類型：
1. **員工** - 內部工作人員，可訪問完整管理系統
2. **客戶** - 外部客戶，可查看授權的專案資料
3. **一般用戶** - 已註冊但尚未完善資料的用戶

## 新增檔案

### 1. 資料模型
- `lib/models/customer.dart` - 客戶資料模型

### 2. 服務層
- `lib/services/customer_service.dart` - 客戶 CRUD 操作服務

### 3. 頁面
- `lib/pages/customer/customer_registration_page.dart` - 客戶註冊表單
- `lib/pages/customer/customer_home_page.dart` - 客戶主頁面

### 4. 數據庫
- `docs/database/create_customers_table.sql` - 客戶表 SQL schema

## 修改的檔案

### 1. lib/services/user_permission_service.dart
- 新增 `UserType` 枚舉（employee, customer, guest）
- 新增 `getCurrentUserType()` 方法
- 新增 `isUserCustomer()` 方法
- 新增 `getCurrentCustomerInfo()` 方法

### 2. lib/app.dart
- 修改登入流程邏輯，根據用戶類型導向不同頁面
- 新增 `_buildGuestWelcome()` 方法，引導一般用戶選擇身份

### 3. lib/models/models.dart
- 新增 `export 'customer.dart';`

### 4. lib/services/services.dart
- 新增 `export 'customer_service.dart';`

## 使用流程

### 客戶註冊流程
1. 用戶在歡迎頁點擊「註冊」
2. 使用 Email/密碼註冊 Supabase 帳號
3. 登入後，系統檢測用戶類型為「一般用戶」
4. 顯示身份選擇頁面，提供「我是客戶」和「我是員工」選項
5. 用戶點擊「我是客戶」
6. 進入客戶資料填寫頁面，填寫：
   - 姓名 *（必填）
   - 公司名稱（選填）
   - 電子郵件 *（必填，預設為註冊郵箱）
   - 聯絡電話（選填）
   - 地址（選填）
   - 備註（選填）
7. 提交後創建客戶記錄
8. 自動跳轉到客戶主頁面

### 客戶主頁功能
- 顯示客戶個人資料卡片
- 顯示可訪問的專案列表（透過 project_clients 表關聯）
- 支援下拉刷新重新載入資料
- 提供登出功能

## 資料庫設置

### 1. 執行 SQL 腳本
在 Supabase SQL Editor 中執行：
```sql
-- 執行此檔案創建客戶表和 RLS 政策
docs/database/create_customers_table.sql
```

### 2. customers 表結構
```sql
CREATE TABLE customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  name text NOT NULL,
  company text,
  email text,
  phone text,
  address text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);
```

### 3. RLS 政策
- ✅ 客戶可查看/編輯自己的資料
- ✅ 客戶可創建自己的資料記錄
- ✅ 員工可查看所有客戶資料（用於管理）

## 權限邏輯

### 用戶類型判定順序
系統按以下順序判定用戶類型：
1. 先檢查是否在 `employees` 表中（且狀態為「在職」）→ 員工
2. 再檢查是否在 `customers` 表中 → 客戶
3. 都不是 → 一般用戶（引導選擇身份）

### 頁面導向邏輯
- **員工** → `SystemHomePage`（員工管理系統）
- **客戶** → `CustomerHomePage`（客戶中心）
- **一般用戶** → 身份選擇頁（引導註冊為客戶或等待員工邀請）
- **未登入** → `WelcomePage`（歡迎頁）

## 專案權限整合

### 如何授權客戶訪問專案
客戶訪問專案的權限透過 `project_clients` 表管理：

```sql
-- 範例：為客戶授予專案訪問權限
INSERT INTO project_clients (project_id, name, email, phone)
VALUES (
  '專案ID',
  '客戶姓名',
  'customer@example.com',  -- 匹配 customers.email
  '0912-345-678'           -- 匹配 customers.phone
);
```

系統會根據 email 或 phone 匹配 customers 表中的記錄，在客戶主頁顯示相關專案。

## 測試步驟

### 1. 測試客戶註冊流程
```
1. 開啟 App → 點擊「註冊」
2. 輸入 Email: test_customer@example.com, 密碼: Test1234!
3. 註冊成功後自動登入
4. 看到身份選擇頁面
5. 點擊「我是客戶」
6. 填寫客戶資料表單
7. 提交後看到客戶主頁
```

### 2. 測試員工流程
```
1. 用員工帳號登入
2. 應直接進入 SystemHomePage（員工管理系統）
```

### 3. 測試一般用戶流程
```
1. 註冊新帳號但不完善資料
2. 登入後看到身份選擇頁面
3. 點擊「我是員工」看到說明對話框
```

## 注意事項

1. **數據庫腳本必須執行**
   - 請確保在 Supabase 中執行 `create_customers_table.sql`
   - 檢查 RLS 政策是否正確啟用

2. **專案客戶關聯**
   - 目前透過 email/phone 匹配
   - 未來可考慮添加更直接的關聯表

3. **客戶權限範圍**
   - 客戶只能查看被授權的專案
   - 不能訪問員工管理功能
   - 不能編輯專案資料（僅查看）

4. **安全性**
   - 所有客戶資料受 RLS 保護
   - 客戶只能存取自己的資料
   - 員工可查看所有客戶（用於客服/管理）

## 未來改進建議

1. **客戶專案詳情頁**
   - 添加客戶查看專案詳情的功能
   - 顯示專案照片、進度等資訊

2. **客戶資料編輯**
   - 添加客戶修改個人資料的頁面

3. **通知系統**
   - 當專案有更新時通知客戶
   - 郵件或推播通知

4. **客戶專屬功能**
   - 客戶回饋表單
   - 客戶滿意度調查
   - 專案進度追蹤

5. **管理員功能**
   - 員工端的客戶管理頁面
   - 批量授權專案訪問權限
   - 客戶活躍度統計
