# Coselig 智慧家居應用

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)

> 🏠 **光悅科技 (Coselig)** 智慧家居整合平台 - 讓智慧生活輕鬆入門

## 📖 專案簡介

Coselig 是一個現代化的智慧家居整合應用，提供完整的智慧家居解決方案。我們的使命是讓智慧家居技術變得**務實、穩定、實惠、耐用、永續、舒適**。

### 🌟 主要特色

- 🔐 **安全認證系統** - 支援 Email 和 Google OAuth 登入
- 📸 **工地照片記錄** - 專業的施工進度記錄系統
- 🏡 **智慧家居整合** - Home Assistant 開源平台整合
- 🛠️ **高規元件展示** - 台灣製造調光控制器
- 💡 **快時尚照明** - 輕量複合金屬板解決方案
- 🎨 **響應式設計** - 支援明暗主題切換
- 🌐 **跨平台支援** - Web、Android、iOS 全平台

## 🚀 技術棧

### 前端框架

- **Flutter 3.35.1** - 跨平台 UI 框架
- **Dart 3.9.0** - 程式語言
- **Material Design 3** - 現代化 UI 設計

### 後端服務

- **Supabase** - 後端即服務 (BaaS)
- **PostgreSQL** - 資料庫
- **Supabase Auth** - 身份驗證
- **Supabase Storage** - 檔案儲存

### 主要依賴套件

```yaml
dependencies:
  supabase_flutter: ^2.9.1      # Supabase 整合
  cached_network_image: ^3.3.1  # 圖片快取
  camera: ^0.10.5+9              # 相機功能
  image_picker: ^1.0.7           # 圖片選擇
  shared_preferences: ^2.2.2     # 本地儲存
  provider: ^6.1.1               # 狀態管理
```

## 📱 功能模組

### 🏠 主頁 (Welcome Page)

- 公司品牌展示
- 服務項目介紹
- 價值理念說明
- 動態輪播圖片

### 🔐 身份驗證 (Auth System)

- Email/密碼登入註冊
- Google OAuth 整合
- 即時認證狀態同步
- 安全的 JWT Token 管理

### 📸 照片記錄系統 (Photo Record)

- 工地施工進度記錄
- 相機拍攝整合
- 圖片上傳至雲端
- 歷史記錄查看

### 🏡 Home Assistant 整合

- 開源智慧家居平台
- 裝置管理介面
- 自動化規則設定

### 🛍️ 產品展示

- 高規元件介紹
- 照明解決方案
- 客製化服務

## 🛠️ 開發環境設置

### 系統需求

- **Flutter SDK**: 3.35.1 或更高版本
- **Dart SDK**: 3.9.0 或更高版本
- **Android Studio** 或 **VS Code**
- **Chrome** (用於 Web 開發)

### 安裝步驟

1. **克隆專案**

   ```bash
   git clone https://github.com/Yunitrish006006/ctc.git
   cd ctc
   ```

2. **安裝依賴**

   ```bash
   flutter pub get
   ```

3. **配置 Supabase**
   - 在 `lib/main.dart` 中更新您的 Supabase URL 和 API Key

   ```dart
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY',
   );
   ```

4. **運行應用**

   ```bash
   # Web 版本
   flutter run -d chrome
   
   # Android 版本  
   flutter run -d android
   
   # iOS 版本
   flutter run -d ios
   ```

## 🌐 Web 部署

### 標準 JavaScript 構建

```bash
flutter build web --release
```

### WebAssembly 構建 (推薦)

```bash
flutter build web --wasm --release
```

### 本地服務器測試

```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --release
```

## 📂 專案結構

```text
lib/
├── main.dart                 # 應用程式入口點
├── app.dart                 # 主應用程式設定
├── config/                  # 配置檔案
├── models/                  # 資料模型
├── pages/                   # 頁面組件
│   ├── welcome_page.dart    # 主頁
│   ├── auth_page.dart       # 登入註冊頁
│   ├── photo_record_page.dart # 照片記錄頁
│   ├── ha_page.dart         # Home Assistant 頁
│   └── ...
├── services/                # 服務層
│   ├── image_service.dart   # 圖片服務
│   └── ...
├── widgets/                 # 可複用組件
│   ├── product_card.dart    # 產品卡片
│   ├── mission_card.dart    # 使命卡片
│   └── ...
└── theme/                   # 主題設定
    └── app_theme.dart
```

## 🎨 UI/UX 特色

### 響應式設計

- 支援桌面、平板、手機多種尺寸
- 自適應網格佈局
- 動態字體大小調整

### 主題系統

- 🌞 明亮主題
- 🌙 暗黑主題  
- 🤖 系統自動切換

### 動畫效果

- 頁面轉場動畫
- 圖片輪播效果
- 載入狀態指示器

## 🔧 開發指南

### 代碼風格

- 遵循 [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- 使用 `flutter analyze` 進行靜態分析
- 通過 `dart format` 格式化代碼

### 狀態管理

- 使用 `Provider` 進行全域狀態管理
- `StatefulWidget` 處理本地狀態
- `StreamSubscription` 監聽 Supabase 認證狀態

### 測試策略

```bash
# 運行所有測試
flutter test

# 分析代碼品質
flutter analyze
```

## 🚢 部署指南

### GitHub Pages 部署

1. 構建 Web 版本
2. 推送到 `gh-pages` 分支
3. 在 GitHub Settings 中啟用 Pages

### Docker 部署

```dockerfile
FROM nginx:alpine
COPY build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## 🤝 貢獻指南

1. Fork 專案
2. 創建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 開啟 Pull Request

## 📄 授權條款

本專案採用 MIT 授權條款 - 詳情請參見 [LICENSE](LICENSE) 檔案

## 📞 聯絡資訊

- **公司**: 光悅科技 (Coselig)
- **網站**: <https://coselig.com>
- **Email**: <contact@coselig.com>

## 🙏 致謝

感謝以下開源專案的支持：

- [Flutter](https://flutter.dev) - 跨平台 UI 框架
- [Supabase](https://supabase.com) - 開源後端平台
- [Home Assistant](https://www.home-assistant.io) - 開源智慧家居平台

---

**讓智慧家居變得務實、穩定、實惠、耐用、永續、舒適**  
Made with ❤️ by 光悅科技團隊
