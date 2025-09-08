# 資料庫相關文檔

本目錄包含所有與資料庫相關的設計、設定和維護文檔。

## 📁 文檔列表

### 🏗️ 架構設計

- **[permission_system_database.md](permission_system_database.md)**
  - 權限管理系統的完整資料庫架構
  - 包含資料表設計、索引、RLS 策略
  - SQL 創建腳本和函數定義

### 🔧 維護修復

- **[database_fix_guide.md](database_fix_guide.md)**
  - 修復權限管理系統遞迴問題的詳細步驟
  - 包含問題診斷和解決方案
  - 完整的 SQL 修復腳本

- **[quick_fix.md](quick_fix.md)**
  - 臨時解決方案和快速修復命令
  - 適用於緊急情況的快速處理
  - 測試環境的簡化設定

## 🚀 使用順序

### 新系統設定

1. 先閱讀 `permission_system_database.md` 了解架構
2. 執行架構文檔中的 SQL 腳本創建資料表
3. 如遇問題，參考 `database_fix_guide.md`

### 問題修復

1. 如遇到權限遞迴錯誤，參考 `database_fix_guide.md`
2. 緊急情況下可使用 `quick_fix.md` 的臨時方案
3. 修復後參考架構文檔重新設定完整的安全策略

## ⚠️ 注意事項

- 所有 SQL 操作建議先在測試環境執行
- 執行 DROP 或 ALTER 操作前請備份資料庫
- RLS 策略的修改會影響應用程式的權限控制

## 🛠️ 常用 SQL 命令

```sql
-- 檢查 RLS 狀態
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'floor_plan_permissions';

-- 查看當前策略
SELECT * FROM pg_policies 
WHERE tablename = 'floor_plan_permissions';

-- 禁用 RLS（測試用）
ALTER TABLE floor_plan_permissions DISABLE ROW LEVEL SECURITY;
```
