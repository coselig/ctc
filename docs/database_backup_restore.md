# 資料庫備份與還原指南

本文件說明如何備份和還原 Supabase PostgreSQL 資料庫。

## 📋 目錄

- [前置準備](#前置準備)
- [備份資料庫](#備份資料庫)
- [還原資料庫](#還原資料庫)
- [自動化備份](#自動化備份)
- [備份檔案管理](#備份檔案管理)
- [注意事項](#注意事項)

## 🔧 前置準備

### 確認環境

1. **確認 Docker 容器正在運行**:
```bash
docker ps | grep supabase-db
```

2. **確認資料庫連線**:
```bash
docker exec -it supabase-db psql -U postgres -d postgres -c "SELECT version();"
```

### 所需工具

- Docker
- PostgreSQL 客戶端工具 (pg_dump, psql)
- 足夠的磁碟空間

## 💾 備份資料庫

### 指令一: 完整備份資料庫

```bash
docker exec -t supabase-db pg_dump -U postgres -d postgres > backup.sql
```

#### 參數說明:
- `docker exec -t`: 在容器中執行命令
- `supabase-db`: Supabase 資料庫容器名稱
- `pg_dump`: PostgreSQL 備份工具
- `-U postgres`: 使用 postgres 使用者
- `-d postgres`: 備份 postgres 資料庫
- `> backup.sql`: 將輸出導向到檔案

### 帶時間戳記的備份

建議在備份檔案名稱中加入時間戳記:

```bash
# 使用當前日期時間
docker exec -t supabase-db pg_dump -U postgres -d postgres > backup_$(date +%Y%m%d_%H%M%S).sql
```

**範例輸出檔案名稱**: `backup_20251009_143022.sql`

### 壓縮備份 (節省空間)

```bash
# 備份並使用 gzip 壓縮
docker exec -t supabase-db pg_dump -U postgres -d postgres | gzip > backup_$(date +%Y%m%d_%H%M%S).sql.gz
```

### 僅備份特定資料表

```bash
# 備份單一資料表
docker exec -t supabase-db pg_dump -U postgres -d postgres -t employees > backup_employees.sql

# 備份多個資料表
docker exec -t supabase-db pg_dump -U postgres -d postgres -t employees -t attendance_records > backup_tables.sql
```

### 僅備份 Schema (不含資料)

```bash
# 只備份資料庫結構
docker exec -t supabase-db pg_dump -U postgres -d postgres --schema-only > backup_schema.sql
```

### 僅備份資料 (不含 Schema)

```bash
# 只備份資料
docker exec -t supabase-db pg_dump -U postgres -d postgres --data-only > backup_data.sql
```

## 🔄 還原資料庫

### 指令二: 透過備份檔案還原資料庫

```bash
cat backup.sql | docker exec -i supabase-db psql -U postgres -d postgres
```

#### 參數說明:
- `cat backup.sql`: 讀取備份檔案內容
- `|`: 透過管道傳送到下一個命令
- `docker exec -i`: 在容器中以互動模式執行命令
- `supabase-db`: Supabase 資料庫容器名稱
- `psql`: PostgreSQL 客戶端工具
- `-U postgres`: 使用 postgres 使用者
- `-d postgres`: 還原到 postgres 資料庫

### 還原壓縮備份

```bash
# 還原 gzip 壓縮的備份
gunzip -c backup_20251009_143022.sql.gz | docker exec -i supabase-db psql -U postgres -d postgres
```

### 還原前清空資料庫 (⚠️ 危險操作)

```bash
# 方法1: 刪除並重建資料庫
docker exec -it supabase-db psql -U postgres -c "DROP DATABASE IF EXISTS postgres;"
docker exec -it supabase-db psql -U postgres -c "CREATE DATABASE postgres;"
cat backup.sql | docker exec -i supabase-db psql -U postgres -d postgres

# 方法2: 使用 --clean 選項 (在備份時)
docker exec -t supabase-db pg_dump -U postgres -d postgres --clean > backup_clean.sql
cat backup_clean.sql | docker exec -i supabase-db psql -U postgres -d postgres
```

### 還原到新資料庫

```bash
# 建立新資料庫
docker exec -it supabase-db psql -U postgres -c "CREATE DATABASE postgres_restored;"

# 還原到新資料庫
cat backup.sql | docker exec -i supabase-db psql -U postgres -d postgres_restored
```

## 🤖 自動化備份

### 建立備份腳本

建立檔案 `backup_database.sh`:

```bash
#!/bin/bash

# 設定變數
CONTAINER_NAME="supabase-db"
DB_USER="postgres"
DB_NAME="postgres"
BACKUP_DIR="/home/coselig/ctc/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup_${DATE}.sql.gz"

# 建立備份目錄
mkdir -p ${BACKUP_DIR}

# 執行備份
echo "開始備份資料庫..."
docker exec -t ${CONTAINER_NAME} pg_dump -U ${DB_USER} -d ${DB_NAME} | gzip > ${BACKUP_FILE}

# 檢查備份是否成功
if [ $? -eq 0 ]; then
    echo "✅ 備份成功: ${BACKUP_FILE}"
    
    # 顯示備份檔案大小
    ls -lh ${BACKUP_FILE}
    
    # 刪除 7 天前的備份 (可選)
    find ${BACKUP_DIR} -name "backup_*.sql.gz" -type f -mtime +7 -delete
    echo "已刪除 7 天前的舊備份"
else
    echo "❌ 備份失敗"
    exit 1
fi
```

### 設定腳本權限

```bash
chmod +x backup_database.sh
```

### 執行備份腳本

```bash
./backup_database.sh
```

### 設定定期自動備份 (Cron)

```bash
# 編輯 crontab
crontab -e

# 新增以下內容 (每天凌晨 2:00 自動備份)
0 2 * * * /home/coselig/ctc/backup_database.sh >> /home/coselig/ctc/backup.log 2>&1

# 或每 6 小時備份一次
0 */6 * * * /home/coselig/ctc/backup_database.sh >> /home/coselig/ctc/backup.log 2>&1
```

### 建立還原腳本

建立檔案 `restore_database.sh`:

```bash
#!/bin/bash

# 設定變數
CONTAINER_NAME="supabase-db"
DB_USER="postgres"
DB_NAME="postgres"

# 檢查參數
if [ $# -eq 0 ]; then
    echo "使用方式: ./restore_database.sh <備份檔案路徑>"
    echo "範例: ./restore_database.sh backups/backup_20251009_143022.sql.gz"
    exit 1
fi

BACKUP_FILE=$1

# 檢查檔案是否存在
if [ ! -f "${BACKUP_FILE}" ]; then
    echo "❌ 錯誤: 備份檔案不存在: ${BACKUP_FILE}"
    exit 1
fi

# 確認還原操作
echo "⚠️  警告: 此操作將還原資料庫到備份時的狀態"
echo "備份檔案: ${BACKUP_FILE}"
read -p "確定要繼續嗎? (yes/no): " CONFIRM

if [ "${CONFIRM}" != "yes" ]; then
    echo "已取消還原操作"
    exit 0
fi

# 執行還原
echo "開始還原資料庫..."

if [[ ${BACKUP_FILE} == *.gz ]]; then
    # 還原壓縮檔案
    gunzip -c ${BACKUP_FILE} | docker exec -i ${CONTAINER_NAME} psql -U ${DB_USER} -d ${DB_NAME}
else
    # 還原未壓縮檔案
    cat ${BACKUP_FILE} | docker exec -i ${CONTAINER_NAME} psql -U ${DB_USER} -d ${DB_NAME}
fi

# 檢查還原是否成功
if [ $? -eq 0 ]; then
    echo "✅ 資料庫還原成功"
else
    echo "❌ 資料庫還原失敗"
    exit 1
fi
```

### 設定還原腳本權限

```bash
chmod +x restore_database.sh
```

### 執行還原腳本

```bash
./restore_database.sh backups/backup_20251009_143022.sql.gz
```

## 📂 備份檔案管理

### 建議的目錄結構

```
/home/coselig/ctc/
├── backups/
│   ├── daily/
│   │   ├── backup_20251009_020000.sql.gz
│   │   ├── backup_20251008_020000.sql.gz
│   │   └── ...
│   ├── weekly/
│   │   ├── backup_week_202540.sql.gz
│   │   └── ...
│   ├── monthly/
│   │   ├── backup_202510.sql.gz
│   │   └── ...
│   └── manual/
│       └── backup_before_migration_20251009.sql.gz
├── backup_database.sh
└── restore_database.sh
```

### 進階備份策略腳本

建立檔案 `backup_rotation.sh`:

```bash
#!/bin/bash

CONTAINER_NAME="supabase-db"
DB_USER="postgres"
DB_NAME="postgres"
BACKUP_ROOT="/home/coselig/ctc/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DAY_OF_WEEK=$(date +%u)  # 1=週一, 7=週日
DAY_OF_MONTH=$(date +%d)

# 每日備份
DAILY_DIR="${BACKUP_ROOT}/daily"
mkdir -p ${DAILY_DIR}
DAILY_BACKUP="${DAILY_DIR}/backup_${DATE}.sql.gz"

echo "執行每日備份..."
docker exec -t ${CONTAINER_NAME} pg_dump -U ${DB_USER} -d ${DB_NAME} | gzip > ${DAILY_BACKUP}

# 保留最近 7 天的每日備份
find ${DAILY_DIR} -name "backup_*.sql.gz" -type f -mtime +7 -delete

# 週日執行週備份
if [ ${DAY_OF_WEEK} -eq 7 ]; then
    WEEKLY_DIR="${BACKUP_ROOT}/weekly"
    mkdir -p ${WEEKLY_DIR}
    WEEK_NUM=$(date +%Y%U)
    WEEKLY_BACKUP="${WEEKLY_DIR}/backup_week_${WEEK_NUM}.sql.gz"
    
    echo "執行週備份..."
    cp ${DAILY_BACKUP} ${WEEKLY_BACKUP}
    
    # 保留最近 4 週的週備份
    find ${WEEKLY_DIR} -name "backup_week_*.sql.gz" -type f -mtime +28 -delete
fi

# 每月 1 號執行月備份
if [ ${DAY_OF_MONTH} -eq 01 ]; then
    MONTHLY_DIR="${BACKUP_ROOT}/monthly"
    mkdir -p ${MONTHLY_DIR}
    MONTH=$(date +%Y%m)
    MONTHLY_BACKUP="${MONTHLY_DIR}/backup_${MONTH}.sql.gz"
    
    echo "執行月備份..."
    cp ${DAILY_BACKUP} ${MONTHLY_BACKUP}
    
    # 保留最近 12 個月的月備份
    find ${MONTHLY_DIR} -name "backup_*.sql.gz" -type f -mtime +365 -delete
fi

echo "✅ 備份完成"
ls -lh ${DAILY_BACKUP}
```

### 查看備份檔案

```bash
# 列出所有備份
ls -lh backups/**/*.sql.gz

# 查看備份檔案資訊
ls -lh backups/daily/ | tail -10

# 計算總備份大小
du -sh backups/
```

## ⚠️ 注意事項

### 1. 備份前注意事項

- ✅ 確認有足夠的磁碟空間
- ✅ 確認資料庫連線正常
- ✅ 在低流量時段執行備份
- ✅ 備份前先測試備份腳本

### 2. 還原前注意事項

- ⚠️ **還原會覆蓋現有資料,請謹慎操作**
- ✅ 還原前先建立當前資料庫的備份
- ✅ 在測試環境先測試還原流程
- ✅ 確認備份檔案完整性
- ✅ 通知相關人員系統即將維護

### 3. 安全性建議

- 🔒 定期測試備份還原流程
- 🔒 將備份檔案儲存在不同的物理位置
- 🔒 加密備份檔案 (如含敏感資料)
- 🔒 設定適當的檔案權限:
  ```bash
  chmod 600 backup*.sql*
  ```
- 🔒 定期驗證備份檔案完整性

### 4. 效能考量

- 大型資料庫備份可能需要較長時間
- 備份期間資料庫效能可能下降
- 建議在非營業時間執行完整備份
- 考慮使用增量備份方案

### 5. 備份完整性檢查

```bash
# 檢查備份檔案是否可以解壓縮
gunzip -t backup_20251009_143022.sql.gz

# 檢查備份檔案內容
gunzip -c backup_20251009_143022.sql.gz | head -n 50

# 測試還原到臨時資料庫
docker exec -it supabase-db psql -U postgres -c "CREATE DATABASE test_restore;"
gunzip -c backup_20251009_143022.sql.gz | docker exec -i supabase-db psql -U postgres -d test_restore
docker exec -it supabase-db psql -U postgres -c "DROP DATABASE test_restore;"
```

## 🆘 故障排除

### 問題 1: 權限錯誤

```bash
# 確認 Docker 容器使用者權限
docker exec -it supabase-db whoami

# 如果需要使用 root
docker exec -u root -it supabase-db psql -U postgres
```

### 問題 2: 備份檔案過大

```bash
# 使用更高的壓縮率
docker exec -t supabase-db pg_dump -U postgres -d postgres | gzip -9 > backup.sql.gz

# 分割大檔案
docker exec -t supabase-db pg_dump -U postgres -d postgres | split -b 100M - backup_part_
```

### 問題 3: 還原時出現錯誤

```bash
# 忽略錯誤繼續還原
cat backup.sql | docker exec -i supabase-db psql -U postgres -d postgres -v ON_ERROR_STOP=0

# 查看詳細錯誤訊息
cat backup.sql | docker exec -i supabase-db psql -U postgres -d postgres 2>&1 | tee restore.log
```

### 問題 4: 容器名稱不正確

```bash
# 列出所有 Docker 容器
docker ps -a

# 找到正確的 Supabase 資料庫容器名稱
docker ps | grep postgres
```

## 📚 相關資源

- [PostgreSQL 官方文件 - pg_dump](https://www.postgresql.org/docs/current/app-pgdump.html)
- [PostgreSQL 官方文件 - psql](https://www.postgresql.org/docs/current/app-psql.html)
- [Docker 官方文件](https://docs.docker.com/)
- [Supabase 官方文件](https://supabase.com/docs)

## 📞 支援

如有問題,請參考:
- 專案 README: `/home/coselig/ctc/README.md`
- 資料庫 Schema: `/home/coselig/ctc/docs/database/`
- 系統整合文件: `/home/coselig/ctc/docs/`

---

**最後更新**: 2025-10-09  
**維護者**: CTC 團隊
