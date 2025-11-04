## 補打卡申請顯示修復 - 測試指南

### 🔍 問題描述
用戶反映「補打卡申請沒辦法看到下班時間」，經分析發現顯示邏輯有問題。

### 🚫 原始問題

#### 1. 補下班打卡申請的時間顯示不正確
- **問題**：只顯示 `requestTime`，沒有考慮 `checkInTime`
- **影響**：無法看到修改的上班時間和下班時間的完整資訊

#### 2. HR 審核頁面顯示邏輯錯誤
- **問題**：總是顯示 `checkInTime` 作為上班時間
- **影響**：對於補下班打卡，應該顯示 `requestTime` 作為下班時間

### ✅ 修復內容

#### 1. 員工端：`attendance_request_page.dart`
```dart
// 修復前：所有類型都只顯示 requestTime
String _getRequestTimeText(AttendanceLeaveRequest request) {
  if (request.requestType == AttendanceRequestType.fullDay) {
    return '$checkIn - $checkOut';
  } else {
    return DateFormat('HH:mm').format(request.requestTime!);
  }
}

// 修復後：根據申請類型顯示正確資訊
String _getRequestTimeText(AttendanceLeaveRequest request) {
  switch (request.requestType) {
    case AttendanceRequestType.checkOut:
      if (request.checkInTime != null) {
        // 同時修改上班時間：顯示 "上班時間 - 下班時間"
        return '$checkIn - $checkOut';
      } else {
        // 只補下班：顯示 "下班: 時間"
        return '下班: $checkOut';
      }
    case AttendanceRequestType.checkIn:
      // 補上班：顯示 "上班: 時間"
      return '上班: $checkIn';
    // ...
  }
}
```

#### 2. 詳情對話框：新增 `_buildTimeDetailsRows` 方法
- 根據申請類型顯示對應的時間欄位
- 補下班打卡時，分別顯示「修改上班時間」和「補下班時間」

#### 3. HR 端：`hr_review_page.dart`
```dart
// 修復前：固定顯示邏輯
_buildInfoRow(Icons.login, '上班時間', request.checkInTime != null ? _formatDateTime(request.checkInTime!) : '未填寫'),
if (request.checkOutTime != null) [
  _buildInfoRow(Icons.logout, '下班時間', _formatDateTime(request.checkOutTime!)),
]

// 修復後：新增 _buildAttendanceTimeRows 方法
List<Widget> _buildAttendanceTimeRows(AttendanceLeaveRequest request) {
  switch (request.requestType) {
    case AttendanceRequestType.checkOut:
      if (request.checkInTime != null) {
        return [
          _buildInfoRow(Icons.edit, '修改上班時間', _formatDateTime(request.checkInTime!)),
          _buildInfoRow(Icons.logout, '補下班時間', _formatDateTime(request.requestTime!)),
        ];
      } else {
        return [
          _buildInfoRow(Icons.logout, '補下班時間', _formatDateTime(request.requestTime!)),
        ];
      }
    // ...
  }
}
```

#### 4. 管理端：`attendance_request_review_page.dart`
- 同樣修復了 `_getRequestTimeText` 方法的邏輯

### 🧪 測試案例

#### 測試案例 1：補上班打卡
- **申請內容**：只填寫上班時間 09:30
- **期待顯示**：「上班: 09:30」
- **資料結構**：`requestTime` 有值，`checkInTime` 和 `checkOutTime` 為 null

#### 測試案例 2：補下班打卡（不修改上班時間）
- **申請內容**：只填寫下班時間 18:30
- **期待顯示**：「下班: 18:30」
- **資料結構**：`requestTime` 有值，`checkInTime` 為 null，`checkOutTime` 為 null

#### 測試案例 3：補下班打卡（同時修改上班時間）
- **申請內容**：修改上班時間為 08:30，下班時間為 18:30
- **期待顯示**：「08:30 - 18:30」
- **資料結構**：`requestTime` 和 `checkInTime` 都有值，`checkOutTime` 為 null

#### 測試案例 4：補整天打卡
- **申請內容**：上班時間 08:30，下班時間 17:30
- **期待顯示**：「08:30 - 17:30」
- **資料結構**：`checkInTime` 和 `checkOutTime` 有值，`requestTime` 為 null

### 📋 驗收標準

#### 員工端檢查項目
- [ ] 申請列表中正確顯示時間資訊
- [ ] 點擊申請項目查看詳情時，顯示完整的時間資訊
- [ ] 不同申請類型的時間格式正確

#### HR 端檢查項目
- [ ] 審核頁面正確顯示申請的時間資訊
- [ ] 補下班打卡申請能看到修改的上班時間（如果有）
- [ ] 補下班打卡申請能看到申請的下班時間

#### 管理端檢查項目
- [ ] 管理頁面的申請列表正確顯示時間
- [ ] 審核功能不受影響

### 🔄 測試步驟

1. **創建測試資料**
   ```dart
   // 建議在開發環境中創建以下測試申請：
   // 1. 補上班打卡申請
   // 2. 補下班打卡申請（不修改上班時間）
   // 3. 補下班打卡申請（修改上班時間）
   // 4. 補整天打卡申請
   ```

2. **員工端測試**
   - 進入「我的補打卡申請」頁面
   - 檢查列表中的時間顯示
   - 點擊申請查看詳情

3. **HR 端測試**
   - 進入「HR 審核」頁面
   - 查看補打卡申請的時間資訊
   - 確認可以看到完整的時間資訊

4. **管理端測試**
   - 進入管理頁面的申請審核
   - 檢查時間顯示是否正確

### 🐛 已知問題與限制

1. **時區問題**：確保時間顯示使用正確的時區
2. **資料驗證**：確保 null 值的處理正確
3. **向下相容性**：舊資料的顯示是否正確

### 📝 後續優化建議

1. **統一時間顯示格式**：建立統一的時間格式化工具
2. **增加時間驗證**：申請時檢查時間邏輯是否合理
3. **優化使用者體驗**：提供更直觀的時間選擇界面
4. **增加提示資訊**：說明不同申請類型的用途