# 元件相關文檔

本目錄包含所有 UI 元件的設計、使用和維護文檔。

## 📁 文檔列表

### 🎨 元件整合

- **[unified_card_guide.md](unified_card_guide.md)**
  - UnifiedCard 元件的完整使用指南
  - 從 ProductCard 和 MissionCard 的整合過程
  - 元件 API 和使用範例

## 🎯 設計原則

### 一致性

- 統一的視覺風格和互動模式
- 可重用的元件架構
- 主題系統整合

### 靈活性

- 支援多種卡片類型
- 可自定義的內容和樣式
- 響應式設計適配

## 🧩 元件架構

```
lib/widgets/
├── unified_card.dart      # 統一卡片元件
└── card_variants/         # 卡片變體（如需要）
```

## 🚀 快速開始

### 1. 基本使用

```dart
UnifiedCard(
  cardType: CardType.product,
  title: '產品名稱',
  subtitle: '產品描述',
  onTap: () => print('點擊產品'),
)
```

### 2. 自定義樣式

```dart
UnifiedCard(
  cardType: CardType.mission,
  title: '任務標題',
  customIcon: Icons.assignment,
  backgroundColor: Colors.blue.shade50,
  onTap: () => navigateToMission(),
)
```

## 🛠️ 維護指南

### 新增卡片類型

1. 在 `CardType` enum 中新增類型
2. 在 `_buildCardContent` 方法中處理新類型
3. 更新文檔範例

### 樣式修改

- 修改 `_getCardDecoration` 方法調整外觀
- 使用主題系統確保一致性
- 測試各種螢幕尺寸的顯示效果

## 📱 響應式設計

元件支援以下螢幕適配：

- **手機直向**: 單欄顯示，完整資訊
- **手機橫向**: 雙欄顯示，簡化資訊
- **平板**: 多欄網格，卡片間距調整

## 🎨 主題整合

元件完全整合 Flutter 主題系統：

- `colorScheme`: 自動適配顏色
- `textTheme`: 文字樣式一致性
- `cardTheme`: 卡片預設樣式
