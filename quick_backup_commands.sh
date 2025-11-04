#!/bin/bash

# ========================================
# CTC 快速備份指令合集
# ========================================

# 1. 智慧完整備份（推薦使用）- 只備份應用程式資料表，排除系統表
ctc_backup_smart() {
    docker exec supabase-db pg_dump -U postgres -d postgres \
        --schema=public \
        --exclude-table-data='auth.*' \
        --exclude-table-data='storage.*' \
        --exclude-table-data='realtime.*' \
        --exclude-table-data='_realtime.*' \
        --exclude-table-data='extensions.*' \
        --exclude-table-data='graphql*' \
        --exclude-table-data='pgbouncer.*' \
        --exclude-table-data='pg_*' \
        --exclude-table-data='information_schema.*' \
        --no-owner \
        --no-privileges \
        --verbose 2>/dev/null | gzip > "smart_backup_$(date +%Y%m%d_%H%M%S).sql.gz"
}

# 2. 只備份應用程式資料表（最安全的方式）
ctc_backup_app_only() {
    local backup_file="app_only_backup_$(date +%Y%m%d_%H%M%S).sql"
    local tables=(
        "attendance_leave_requests"
        "attendance_records" 
        "customers"
        "employee_skills"
        "employees"
        "floor_plan_permissions"
        "floor_plans"
        "holidays"
        "images"
        "job_vacancies"
        "leave_balances"
        "leave_requests"
        "photo_records"
        "profiles"
        "project_clients"
        "project_comments"
        "project_members"
        "project_tasks"
        "project_timeline"
        "projects"
        "system_settings"
        "user_profiles"
    )
    
    echo "-- CTC 應用程式專用備份 $(date)" > $backup_file
    echo "-- 只包含應用程式資料表，排除所有系統表" >> $backup_file
    echo "" >> $backup_file
    
    for table in "${tables[@]}"; do
        echo "正在備份資料表: $table"
        docker exec supabase-db pg_dump -U postgres -d postgres \
            --table=public.$table \
            --no-owner \
            --no-privileges \
            --verbose 2>/dev/null >> $backup_file
    done
    
    gzip $backup_file
    echo "✅ 備份完成: ${backup_file}.gz"
}

# 3. 超級精簡備份指令（一行指令）
alias ctc-backup='docker exec supabase-db pg_dump -U postgres -d postgres --schema=public --exclude-schema=auth --exclude-schema=storage --exclude-schema=realtime --exclude-schema=_realtime --exclude-schema=extensions --exclude-schema=graphql --exclude-schema=graphql_public --exclude-schema=pgbouncer --no-owner --no-privileges | gzip > "ctc_backup_$(date +%Y%m%d_%H%M%S).sql.gz" && echo "✅ CTC 備份完成"'

# 4. 還原備份指令
ctc_restore() {
    local backup_file=$1
    if [ -z "$backup_file" ]; then
        echo "使用方式: ctc_restore <備份檔案>"
        return 1
    fi
    
    if [[ $backup_file == *.gz ]]; then
        gunzip -c "$backup_file" | docker exec -i supabase-db psql -U postgres -d postgres
    else
        cat "$backup_file" | docker exec -i supabase-db psql -U postgres -d postgres
    fi
}

# 顯示使用說明
show_quick_commands() {
    cat << 'EOF'
🚀 CTC 快速備份指令說明

最推薦的備份指令（複製使用）：
┌─────────────────────────────────────────────────────────────────┐
│ docker exec supabase-db pg_dump -U postgres -d postgres \      │
│   --schema=public \                                             │
│   --exclude-schema=auth \                                       │
│   --exclude-schema=storage \                                    │
│   --exclude-schema=realtime \                                   │
│   --exclude-schema=_realtime \                                  │
│   --exclude-schema=extensions \                                 │
│   --exclude-schema=graphql \                                    │
│   --exclude-schema=graphql_public \                             │
│   --exclude-schema=pgbouncer \                                  │
│   --no-owner --no-privileges \                                  │
│   | gzip > "ctc_backup_$(date +%Y%m%d_%H%M%S).sql.gz"           │
└─────────────────────────────────────────────────────────────────┘

還原指令：
┌─────────────────────────────────────────────────────────────────┐
│ gunzip -c ctc_backup_20251104_143022.sql.gz | \                │
│   docker exec -i supabase-db psql -U postgres -d postgres      │
└─────────────────────────────────────────────────────────────────┘

其他快速指令：
  ./smart_backup.sh full     # 使用完整的智慧備份腳本
  ./smart_backup.sh list     # 列出所有備份檔案
  ./smart_backup.sh help     # 查看詳細說明

優點：
✅ 排除所有 Supabase 系統 schemas
✅ 只備份您的應用程式資料（public schema）
✅ 避免還原時的權限衝突
✅ 檔案更小，還原更快
✅ 不會包含系統預設表導致還原失敗

EOF
}

# 如果直接執行此腳本，顯示說明
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    show_quick_commands
fi