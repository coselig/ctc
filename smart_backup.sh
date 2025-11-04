#!/bin/bash

# =======================================================================
# CTC 智慧資料庫備份腳本
# 功能：只備份應用程式相關的資料表，排除系統預設表
# 作者：CTC 團隊
# 最後更新：2025-11-04
# =======================================================================

# 設定變數
CONTAINER_NAME="supabase-db"
DB_USER="postgres"
DB_NAME="postgres"
BACKUP_DIR="/home/coselig/ctc/backups"
DATE=$(date +%Y%m%d_%H%M%S)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日誌函數
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 檢查 Docker 容器是否運行
check_container() {
    if ! docker ps | grep -q ${CONTAINER_NAME}; then
        log_error "Docker 容器 ${CONTAINER_NAME} 未運行"
        log_info "請先啟動 Supabase 服務"
        exit 1
    fi
    log_success "Docker 容器 ${CONTAINER_NAME} 正在運行"
}

# 檢查資料庫連線
check_database() {
    if ! docker exec ${CONTAINER_NAME} psql -U ${DB_USER} -d ${DB_NAME} -c "SELECT 1;" > /dev/null 2>&1; then
        log_error "無法連接到資料庫"
        exit 1
    fi
    log_success "資料庫連線正常"
}

# 建立備份目錄
create_backup_dir() {
    mkdir -p ${BACKUP_DIR}
    if [ $? -eq 0 ]; then
        log_success "備份目錄已建立: ${BACKUP_DIR}"
    else
        log_error "無法建立備份目錄: ${BACKUP_DIR}"
        exit 1
    fi
}

# 應用程式資料表清單
get_app_tables() {
    cat << 'EOF'
attendance_leave_requests
attendance_records
customers
employee_skills
employees
floor_plan_permissions
floor_plans
holidays
images
job_vacancies
leave_balances
leave_requests
photo_records
profiles
project_clients
project_comments
project_members
project_tasks
project_timeline
projects
system_settings
user_profiles
EOF
}

# 應用程式函數清單
get_app_functions() {
    cat << 'EOF'
get_current_user_role()
get_employee_leave_balance(uuid,integer)
get_floor_plan_permissions(uuid)
get_project_statistics(uuid)
get_user_role()
handle_new_user()
has_floor_plan_access(uuid,uuid)
has_floor_plan_admin_access(uuid,uuid)
has_floor_plan_edit_access(uuid,uuid)
has_project_access(uuid,uuid)
has_project_admin_access(uuid,uuid)
initialize_leave_balance(uuid,text,integer,numeric)
is_boss()
is_boss_or_hr()
is_hr()
update_attendance_leave_requests_updated_at()
update_attendance_records_updated_at()
update_employee_updated_at()
update_leave_balance_on_request_change()
update_leave_balances_updated_at()
update_leave_requests_updated_at()
update_updated_at_column()
update_user_profiles_updated_at()
EOF
}

# 執行智慧備份（只備份應用程式相關的資料表和函數）
smart_backup() {
    local backup_type=$1
    local backup_file=""
    
    case $backup_type in
        "schema")
            backup_file="${BACKUP_DIR}/smart_schema_backup_${DATE}.sql"
            log_info "開始執行智慧 Schema 備份..."
            ;;
        "data")
            backup_file="${BACKUP_DIR}/smart_data_backup_${DATE}.sql"
            log_info "開始執行智慧資料備份..."
            ;;
        "full")
            backup_file="${BACKUP_DIR}/smart_full_backup_${DATE}.sql"
            log_info "開始執行智慧完整備份..."
            ;;
        *)
            log_error "無效的備份類型: $backup_type"
            return 1
            ;;
    esac

    # 建立臨時SQL檔案用於備份
    local temp_backup="/tmp/smart_backup_${DATE}.sql"
    
    # 開始產生備份檔案
    cat > ${temp_backup} << 'HEADER'
--
-- CTC 應用程式智慧備份
-- 只包含應用程式相關的資料表和函數
-- 排除 Supabase 系統預設的 schemas 和 tables
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- 僅備份 public schema 的應用程式資料
--

HEADER

    # 根據備份類型選擇不同的備份指令
    case $backup_type in
        "schema")
            # 備份資料表結構
            log_info "備份資料表結構..."
            for table in $(get_app_tables); do
                log_info "  - 備份資料表: $table"
                docker exec ${CONTAINER_NAME} pg_dump -U ${DB_USER} -d ${DB_NAME} \
                    --schema-only --table=public.${table} --no-owner --no-privileges >> ${temp_backup}
            done
            
            # 備份函數
            log_info "備份應用程式函數..."
            for func in $(get_app_functions); do
                log_info "  - 備份函數: $func"
                docker exec ${CONTAINER_NAME} pg_dump -U ${DB_USER} -d ${DB_NAME} \
                    --schema-only --function=public.${func} --no-owner --no-privileges >> ${temp_backup}
            done
            ;;
            
        "data")
            # 只備份資料（不含結構）
            log_info "備份資料表數據..."
            for table in $(get_app_tables); do
                log_info "  - 備份數據: $table"
                docker exec ${CONTAINER_NAME} pg_dump -U ${DB_USER} -d ${DB_NAME} \
                    --data-only --table=public.${table} --no-owner --no-privileges >> ${temp_backup}
            done
            ;;
            
        "full")
            # 完整備份（結構+數據）
            log_info "備份資料表結構和數據..."
            for table in $(get_app_tables); do
                log_info "  - 備份完整資料表: $table"
                docker exec ${CONTAINER_NAME} pg_dump -U ${DB_USER} -d ${DB_NAME} \
                    --table=public.${table} --no-owner --no-privileges >> ${temp_backup}
            done
            
            # 備份函數
            log_info "備份應用程式函數..."
            for func in $(get_app_functions); do
                log_info "  - 備份函數: $func"
                docker exec ${CONTAINER_NAME} pg_dump -U ${DB_USER} -d ${DB_NAME} \
                    --schema-only --function=public.${func} --no-owner --no-privileges >> ${temp_backup}
            done
            ;;
    esac

    # 壓縮並移動到最終位置
    log_info "壓縮備份檔案..."
    gzip -c ${temp_backup} > ${backup_file}.gz
    
    # 清理臨時檔案
    rm -f ${temp_backup}
    
    # 檢查備份是否成功
    if [ -f "${backup_file}.gz" ] && [ -s "${backup_file}.gz" ]; then
        log_success "✅ 智慧備份完成: ${backup_file}.gz"
        log_info "備份檔案大小: $(ls -lh ${backup_file}.gz | awk '{print $5}')"
        return 0
    else
        log_error "❌ 備份失敗"
        return 1
    fi
}

# 執行傳統完整備份（包含所有系統表，僅作對比）
traditional_backup() {
    local backup_file="${BACKUP_DIR}/traditional_full_backup_${DATE}.sql.gz"
    log_info "開始執行傳統完整備份（包含系統表）..."
    
    docker exec ${CONTAINER_NAME} pg_dump -U ${DB_USER} -d ${DB_NAME} --no-owner --no-privileges | gzip > ${backup_file}
    
    if [ $? -eq 0 ]; then
        log_success "✅ 傳統備份完成: ${backup_file}"
        log_info "備份檔案大小: $(ls -lh ${backup_file} | awk '{print $5}')"
    else
        log_error "❌ 傳統備份失敗"
        return 1
    fi
}

# 列出現有備份
list_backups() {
    log_info "現有備份檔案:"
    if [ -d "${BACKUP_DIR}" ] && [ "$(ls -A ${BACKUP_DIR})" ]; then
        ls -lht ${BACKUP_DIR}/*.gz 2>/dev/null | head -20
    else
        log_warning "沒有找到備份檔案"
    fi
}

# 還原智慧備份
restore_smart_backup() {
    local backup_file=$1
    
    if [ -z "$backup_file" ]; then
        log_error "請指定要還原的備份檔案"
        log_info "使用方式: $0 restore <備份檔案路徑>"
        return 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        log_error "備份檔案不存在: $backup_file"
        return 1
    fi
    
    log_warning "⚠️  注意: 此操作將還原應用程式資料表到備份時的狀態"
    log_info "備份檔案: $backup_file"
    read -p "確定要繼續嗎? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        log_info "已取消還原操作"
        return 0
    fi
    
    log_info "開始還原智慧備份..."
    
    if [[ $backup_file == *.gz ]]; then
        gunzip -c "$backup_file" | docker exec -i ${CONTAINER_NAME} psql -U ${DB_USER} -d ${DB_NAME}
    else
        cat "$backup_file" | docker exec -i ${CONTAINER_NAME} psql -U ${DB_USER} -d ${DB_NAME}
    fi
    
    if [ $? -eq 0 ]; then
        log_success "✅ 智慧備份還原成功"
    else
        log_error "❌ 智慧備份還原失敗"
        return 1
    fi
}

# 清理舊備份
cleanup_old_backups() {
    local days=${1:-7}
    log_info "清理 ${days} 天前的舊備份..."
    
    find ${BACKUP_DIR} -name "*.sql.gz" -type f -mtime +${days} -delete
    
    log_success "已清理 ${days} 天前的舊備份"
}

# 顯示幫助資訊
show_help() {
    cat << 'EOF'
CTC 智慧資料庫備份工具

使用方式:
    ./smart_backup.sh <命令> [選項]

命令:
    schema      - 只備份應用程式資料表結構和函數
    data        - 只備份應用程式資料（不含結構）  
    full        - 備份應用程式完整資料（結構+數據+函數）
    traditional - 執行傳統完整備份（包含系統表）
    restore     - 還原指定的備份檔案
    list        - 列出現有備份檔案
    cleanup     - 清理舊備份檔案
    help        - 顯示此幫助訊息

範例:
    ./smart_backup.sh full                           # 智慧完整備份
    ./smart_backup.sh schema                         # 只備份結構
    ./smart_backup.sh data                           # 只備份數據
    ./smart_backup.sh restore backups/backup.sql.gz # 還原備份
    ./smart_backup.sh list                           # 列出備份
    ./smart_backup.sh cleanup 30                     # 清理30天前的備份

智慧備份優勢:
    ✅ 只包含應用程式相關的資料表
    ✅ 排除 Supabase 系統預設的 schemas (auth, storage, realtime 等)
    ✅ 避免還原時的權限和系統表衝突
    ✅ 備份檔案更小，還原更快
    ✅ 減少還原失敗的風險

注意事項:
    - 智慧備份不包含 Supabase 的用戶認證資料（auth schema）
    - 如需完整系統備份，請使用 traditional 命令
    - 還原前建議先備份當前資料

EOF
}

# 主程式
main() {
    local command=${1:-help}
    
    echo "========================================"
    echo "CTC 智慧資料庫備份工具"
    echo "時間: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================"
    
    case $command in
        "schema")
            check_container
            check_database
            create_backup_dir
            smart_backup "schema"
            ;;
        "data")
            check_container
            check_database
            create_backup_dir
            smart_backup "data"
            ;;
        "full")
            check_container
            check_database
            create_backup_dir
            smart_backup "full"
            ;;
        "traditional")
            check_container
            check_database
            create_backup_dir
            traditional_backup
            ;;
        "restore")
            check_container
            check_database
            restore_smart_backup $2
            ;;
        "list")
            list_backups
            ;;
        "cleanup")
            cleanup_old_backups $2
            ;;
        "help")
            show_help
            ;;
        *)
            log_error "無效的命令: $command"
            show_help
            exit 1
            ;;
    esac
}

# 執行主程式
main "$@"