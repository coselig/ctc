# 🎯 解決設計圖新增問題

## ❌ 問題描述

```
新增設計圖失敗:PostgrestException(message: null value in column "id" of relation "floor_plans" violates not-null constraint, code: 23502, details: Bad Request, hint: null)
```

## ✅ 解決方案

### 1. 重新執行資料庫設置

在 Supabase SQL Editor 中執行 `complete_database_setup.sql`：

- 已修正 `floor_plans` 表格的 `id` 欄位為自動生成
- 所有表格、策略、函數都會先刪除再重新創建
- 可以安全重複執行

### 2. Flutter 程式碼已自動修正

- 修正了 `supabase_service.dart` 中的插入邏輯
- 現在會自動獲取生成的 `id` 來建立權限

## 🚀 執行步驟

1. **打開 Supabase 控制台** → SQL Editor
2. **複製整個 `complete_database_setup.sql` 內容**
3. **貼上並執行**
4. **重啟 Flutter 應用程式**

執行成功後就可以正常新增設計圖了！

---
**修正時間**: 2024-12-19  
**問題**: `floor_plans.id` 欄位缺少默認值  
**狀態**: ✅ 已修正
