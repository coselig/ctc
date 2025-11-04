# CTC 資料庫備份解決方案

## 📋 問題背景

之前的資料庫備份會連系統預設的table一起備份下來，造成還原失敗。這些系統表包括：
- Supabase 的 `auth` schema（用戶認證）
- `storage` schema（檔案存儲）  
- `realtime` schema（即時功能）
- `extensions` schema（擴展功能）
- `graphql` 相關的 schemas
- PostgreSQL 系統表

## 🚀 解決方案

我們提供了兩套備份工具來解決這個問題：

### 1. 快速備份指令（推薦）

**一行指令完成智慧備份：**
```bash
docker exec supabase-db pg_dump -U postgres -d postgres \
  --schema=public \
  --exclude-schema=auth \
  --exclude-schema=storage \
  --exclude-schema=realtime \
  --exclude-schema=_realtime \
  --exclude-schema=extensions \
  --exclude-schema=graphql \
  --exclude-schema=graphql_public \
  --exclude-schema=pgbouncer \
  --no-owner --no-privileges \
  | gzip > "ctc_backup_$(date +%Y%m%d_%H%M%S).sql.gz"
```

**一行指令還原備份：**
```bash
gunzip -c ctc_backup_20251104_143022.sql.gz | docker exec -i supabase-db psql -U postgres -d postgres
```

### 2. 完整智慧備份腳本

```bash
# 完整備份（結構 + 數據 + 函數）
./smart_backup.sh full

# 只備份結構
./smart_backup.sh schema

# 只備份數據  
./smart_backup.sh data

# 列出所有備份
./smart_backup.sh list

# 還原備份
./smart_backup.sh restore backups/backup_file.sql.gz

# 清理舊備份
./smart_backup.sh cleanup 7
```

## ✅ 智慧備份的優點

| 傳統備份 | 智慧備份 |
|---------|---------|
| ❌ 包含系統表 | ✅ 只包含應用程式資料表 |
| ❌ 還原時權限衝突 | ✅ 避免權限和系統表衝突 |
| ❌ 檔案較大 | ✅ 檔案更小，還原更快 |
| ❌ 容易還原失敗 | ✅ 減少還原失敗的風險 |
| ❌ 包含敏感系統資料 | ✅ 只備份必要的業務資料 |

## 📁 備份內容說明

### 包含的資料表（應用程式資料）：
- `attendance_leave_requests` - 補打卡申請
- `attendance_records` - 出勤記錄
- `customers` - 客戶資料
- `employees` - 員工資料
- `floor_plans` - 設計圖
- `projects` - 專案資料
- `leave_requests` - 請假申請
- 以及其他業務相關資料表...

### 排除的系統 Schemas：
- `auth.*` - Supabase 用戶認證系統
- `storage.*` - 檔案存儲系統
- `realtime.*` - 即時功能系統
- `extensions.*` - 資料庫擴展
- `graphql.*` - GraphQL 相關
- `pgbouncer.*` - 連線池管理
- PostgreSQL 內建系統表

## 🔧 快速開始

1. **執行智慧備份：**
   ```bash
   cd /home/coselig/dev/front/ctc
   ./smart_backup.sh full
   ```

2. **或使用一行指令：**
   ```bash
   ./quick_backup_commands.sh
   # 然後複製顯示的指令來使用
   ```

3. **查看備份檔案：**
   ```bash
   ./smart_backup.sh list
   ```

## 📝 注意事項

### ⚠️ 重要提醒：
- 智慧備份**不包含**用戶認證資料（auth schema）
- 如果需要完整的系統遷移，請使用 `./smart_backup.sh traditional`
- 還原前建議先備份當前資料
- 測試環境建議先測試還原流程

### 💡 建議的備份策略：
- **日常備份**：使用智慧備份（`./smart_backup.sh full`）
- **系統遷移**：使用傳統備份（`./smart_backup.sh traditional`）
- **開發測試**：使用結構備份（`./smart_backup.sh schema`）

## 🛠️ 故障排除

### 問題1：Docker 容器未運行
```bash
# 檢查容器狀態
docker ps | grep supabase-db

# 啟動 Supabase
supabase start
```

### 問題2：權限不足
```bash
# 確認腳本有執行權限
chmod +x smart_backup.sh
chmod +x quick_backup_commands.sh
```

### 問題3：備份檔案過大
```bash
# 使用更高壓縮率
./smart_backup.sh full  # 已包含 gzip 壓縮
```

## 📚 相關文件

- [完整備份文件](docs/database_backup_restore.md)
- [資料庫安裝說明](docs/database_install.md)
- [專案 README](README.md)

---

**最後更新**: 2025-11-04  
**維護者**: CTC 團隊