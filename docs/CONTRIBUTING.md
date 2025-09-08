# 開發者貢獻指南

歡迎為 CTC 工地紀錄照片系統貢獻代碼！本指南將幫助您了解如何參與專案開發。

## 🚀 快速開始

### 環境需求

- **Flutter SDK**: >=3.0.0
- **Dart SDK**: >=3.0.0
- **Android Studio** 或 **VS Code** (推薦安裝 Flutter 擴展)
- **Git**: 版本控制

### 初始設定

1. **複製專案**

   ```bash
   git clone [repository-url]
   cd ctc
   ```

2. **安裝依賴**

   ```bash
   flutter pub get
   ```

3. **環境配置**

   ```bash
   # 複製環境配置範本
   cp .env.example .env
   # 編輯環境變數
   ```

4. **執行專案**

   ```bash
   flutter run
   ```

## 🏗️ 專案架構

### 目錄結構

```
lib/
├── main.dart              # 應用程式入口
├── app.dart               # 應用程式主要配置
├── config/                # 配置文件
├── models/                # 資料模型
│   ├── permission_level.dart
│   └── floor_plan_permission.dart
├── services/              # 業務邏輯服務
│   ├── permission_service.dart
│   └── supabase_service.dart
├── pages/                 # 頁面元件
│   ├── permission_management_page.dart
│   └── floor_plan_selector_page.dart
├── widgets/               # 可重用元件
│   └── unified_card.dart
└── theme/                 # 主題和樣式
```

### 程式碼風格

- 遵循 [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- 使用 `dart format .` 格式化程式碼
- 執行 `dart analyze` 檢查程式碼品質

## 🔄 開發流程

### 1. 功能開發

1. **創建分支**

   ```bash
   git checkout -b feature/功能名稱
   ```

2. **開發功能**
   - 編寫程式碼
   - 新增單元測試
   - 更新文檔

3. **測試驗證**

   ```bash
   # 執行測試
   flutter test
   
   # 檢查程式碼品質
   dart analyze
   
   # 格式化程式碼
   dart format .
   ```

4. **提交變更**

   ```bash
   git add .
   git commit -m "feat: 新增功能描述"
   git push origin feature/功能名稱
   ```

### 2. 提交訊息規範

使用 [Conventional Commits](https://www.conventionalcommits.org/) 格式：

- `feat:` 新功能
- `fix:` 錯誤修復
- `docs:` 文檔更新
- `style:` 程式碼格式調整
- `refactor:` 程式碼重構
- `test:` 測試相關
- `chore:` 維護任務

範例：

```
feat(permission): 新增權限管理系統
fix(database): 修復 RLS 遞迴問題
docs(readme): 更新安裝指南
```

## 🧪 測試指南

### 單元測試

```bash
# 執行所有測試
flutter test

# 執行特定測試文件
flutter test test/services/permission_service_test.dart

# 產生測試覆蓋率報告
flutter test --coverage
```

### 整合測試

```bash
# 執行整合測試
flutter test integration_test/
```

### 測試撰寫原則

- 每個公開方法都應有對應測試
- 測試邊界條件和錯誤情況
- 使用有意義的測試名稱
- 保持測試獨立性

## 📝 文檔貢獻

### 文檔結構

```
docs/
├── README.md              # 主要導航
├── database/              # 資料庫相關
├── widgets/               # 元件文檔
├── features/              # 功能說明
└── CONTRIBUTING.md        # 本文件
```

### 文檔撰寫原則

- 使用清晰的 Markdown 格式
- 提供程式碼範例
- 包含螢幕截圖（如適用）
- 保持文檔與程式碼同步

## 🐛 問題回報

### 回報前檢查

1. 搜尋現有 Issues 是否有相同問題
2. 確認使用的是最新版本
3. 準備重現步驟和環境資訊

### Issue 模板

```markdown
## 問題描述
[清楚描述遇到的問題]

## 重現步驟
1. 進入 [頁面/功能]
2. 點擊 [按鈕/元件]
3. 觀察到 [錯誤行為]

## 預期行為
[描述預期的正確行為]

## 環境資訊
- Flutter 版本：
- 作業系統：
- 裝置型號：

## 其他資訊
[其他相關資訊、錯誤訊息、螢幕截圖等]
```

## 🔐 安全性注意事項

### 敏感資訊

- 不要提交 API 金鑰或密碼
- 使用環境變數管理機密資訊
- 定期檢查提交歷史是否包含敏感資料

### 權限系統

- 所有權限檢查都要在伺服器端進行
- UI 權限控制僅為使用者體驗考量
- 測試各種權限層級的邊界情況

## 📚 學習資源

### Flutter 相關

- [Flutter 官方文檔](https://flutter.dev/docs)
- [Dart 語言指南](https://dart.dev/guides)
- [Flutter 程式碼實驗室](https://codelabs.developers.google.com/codelabs/flutter/)

### 資料庫相關

- [Supabase 文檔](https://supabase.com/docs)
- [PostgreSQL RLS 指南](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)

## 🤝 社群行為準則

- 保持友善和尊重的態度
- 歡迎新手提問和學習
- 提供建設性的意見和回饋
- 遵守開源專案的最佳實務

## 📞 聯絡方式

如有任何問題或建議，歡迎透過以下方式聯絡：

- 開啟 GitHub Issue
- 發送 Pull Request
- 參與專案討論

感謝您的貢獻！🎉
