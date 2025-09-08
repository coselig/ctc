# UnifiedCard 組件使用指南

## 概述

`UnifiedCard` 是一個統一的卡片組件，整合了原本的 `ProductCard` 和 `MissionCard` 的功能。通過 `CardType` 枚舉來切換不同的顯示模式。

## 特點

- **統一設計**: 所有卡片使用相同的背景漸變、圓角和陰影效果
- **雙模式切換**: 支援產品卡片和價值理念卡片兩種模式
- **高度可定制**: 支援自訂按鈕文字、點擊事件等
- **響應式設計**: 自動適應不同螢幕尺寸
- **主題感知**: 完美支援亮色和暗色主題

## 使用方法

### 產品卡片模式 (CardType.product)

```dart
UnifiedCard(
  imageName: 'product_image.jpg',
  title: '產品標題',
  subtitle: '產品描述\n可以多行顯示',
  cardType: CardType.product,
  onTap: () {
    // 點擊事件處理
    Navigator.push(context, ...);
  },
  buttonText: '瞭解更多', // 可選，預設為 '瞭解更多'
)
```

### 價值理念卡片模式 (CardType.mission)

```dart
UnifiedCard(
  imageName: 'mission_icon.png',
  title: '價值標題',
  subtitle: 'Value Description',
  cardType: CardType.mission,
  invertColors: true, // 可選，適用於圖標著色
)
```

## 參數說明

| 參數 | 類型 | 必需 | 說明 |
|------|------|------|------|
| `imageName` | String | ✓ | 圖片檔案名稱 |
| `title` | String | ✓ | 卡片標題 |
| `subtitle` | String | ✓ | 卡片副標題/描述 |
| `cardType` | CardType | × | 卡片類型，預設為 `CardType.product` |
| `onTap` | VoidCallback? | × | 點擊事件回調 |
| `invertColors` | bool | × | 是否反轉顏色，預設為 `false` |
| `buttonText` | String? | × | 自訂按鈕文字，僅在 product 模式且有 onTap 時顯示 |

## 設計差異

### ProductCard 模式

- **布局比例**: 圖片 3:2 文字
- **圖片處理**: `BoxFit.cover`，填滿圖片區域
- **按鈕顯示**: 當有 `onTap` 時顯示 "瞭解更多" 按鈕
- **適用場景**: 產品展示、服務介紹

### MissionCard 模式

- **布局比例**: 正方形圖標 + 文字
- **圖片處理**: `BoxFit.contain`，圖標風格，可著色
- **按鈕顯示**: 無按鈕
- **適用場景**: 價值理念、特色說明

## 遷移指南

### 從 ProductCard 遷移

```diff
- ProductCard(
+ UnifiedCard(
    imageName: 'image.jpg',
    title: 'Title',
    subtitle: 'Subtitle',
+   cardType: CardType.product,
    onTap: () => {},
  )
```

### 從 MissionCard 遷移

```diff
- MissionCard(
+ UnifiedCard(
    imageName: 'icon.png',
    title: 'Title',
    subtitle: 'Subtitle',
+   cardType: CardType.mission,
    invertColors: true,
  )
```

## 優勢

1. **代碼重用**: 減少重複代碼，統一維護
2. **一致性**: 確保所有卡片的視覺風格保持一致
3. **擴展性**: 易於添加新的卡片類型
4. **維護性**: 只需要維護一個組件，降低維護成本
