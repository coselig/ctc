# CTC 工地紀錄照片系統 - 文檔目錄

## 📚 文檔結構

本專案的文檔按功能分類整理，便於查找和維護。

### 🗄️ 資料庫相關 (`database/`)

資料庫架構、設定、修復和維護相關文檔。

- **[權限系統資料庫架構](database/permission_system_database.md)** - 完整的資料庫架構設計和 SQL 腳本
- **[資料庫修復指南](database/database_fix_guide.md)** - 修復權限管理系統的詳細步驟
- **[快速修復方案](database/quick_fix.md)** - 臨時解決方案和快速修復命令

### 🧩 Widget 組件 (`widgets/`)

UI 組件的使用指南和設計說明。

- **[UnifiedCard 統一卡片組件](widgets/unified_card_guide.md)** - 統一卡片組件的完整使用指南

### ⚙️ 功能模組 (`features/`)

系統功能的使用說明和技術總結。

- **[權限管理系統使用指南](features/permission_system_user_guide.md)** - 權限管理功能的詳細使用說明
- **[權限管理系統總結](features/permission_system_summary.md)** - 權限管理功能的完整技術總結

## 🚀 快速導航

### 新手入門

1. 先閱讀 [權限管理系統總結](features/permission_system_summary.md) 了解系統概況
2. 參考 [資料庫修復指南](database/database_fix_guide.md) 設定資料庫
3. 查看 [權限管理系統使用指南](features/permission_system_user_guide.md) 學習如何使用

### 開發者指南

1. [權限系統資料庫架構](database/permission_system_database.md) - 了解資料庫設計
2. [UnifiedCard 統一卡片組件](widgets/unified_card_guide.md) - UI 組件開發
3. [權限管理系統總結](features/permission_system_summary.md) - 系統架構

### 問題排除

1. [資料庫修復指南](database/database_fix_guide.md) - 解決資料庫相關問題
2. [快速修復方案](database/quick_fix.md) - 緊急修復方案

## 📋 文檔維護

### 更新頻率

- **資料庫文檔**: 當資料庫架構改變時更新
- **Widget 文檔**: 當組件 API 改變時更新
- **功能文檔**: 當功能特性改變時更新

### 文檔規範

- 使用 Markdown 格式
- 包含完整的代碼範例
- 提供清晰的步驟說明
- 包含常見問題和解決方案

## 🏗️ 系統架構概覽

```
CTC 工地紀錄照片系統
├── 資料庫層
│   ├── floor_plans (設計圖表)
│   ├── photo_records (照片記錄表)
│   └── floor_plan_permissions (權限管理表)
├── 服務層
│   ├── SupabaseService (數據服務)
│   └── PermissionService (權限服務)
├── UI 層
│   ├── UnifiedCard (統一卡片組件)
│   ├── PermissionManagementPage (權限管理頁面)
│   └── FloorPlanSelectorPage (設計圖選擇頁面)
└── 功能層
    ├── 三級權限制度
    ├── 擁有者管理
    └── 權限轉移
```

## 📞 技術支援

如有任何問題或建議，請：

1. 先查閱相關文檔
2. 檢查常見問題部分
3. 聯繫開發團隊

---

**最後更新**: 2025年9月8日
**版本**: v1.0.0
