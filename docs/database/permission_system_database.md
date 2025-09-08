# 工地紀錄照片系統權限管理 - 資料庫架構

## 新增資料表

### 1. floor_plan_permissions (設計圖權限表)

```sql
CREATE TABLE floor_plan_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    floor_plan_id TEXT NOT NULL,
    floor_plan_url TEXT NOT NULL,
    floor_plan_name TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_email TEXT NOT NULL,
    permission_level INTEGER NOT NULL DEFAULT 1 CHECK (permission_level BETWEEN 1 AND 3),
    is_owner BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(floor_plan_url, user_id)
);

-- 索引
CREATE INDEX idx_floor_plan_permissions_floor_plan_url ON floor_plan_permissions(floor_plan_url);
CREATE INDEX idx_floor_plan_permissions_user_id ON floor_plan_permissions(user_id);
CREATE INDEX idx_floor_plan_permissions_is_owner ON floor_plan_permissions(is_owner);

-- 註釋
COMMENT ON TABLE floor_plan_permissions IS '設計圖權限管理表';
COMMENT ON COLUMN floor_plan_permissions.permission_level IS '權限等級：1=一般用戶，2=進階用戶，3=管理員';
COMMENT ON COLUMN floor_plan_permissions.is_owner IS '是否為設計圖擁有者';
```

### 2. 存儲函數 - 轉移擁有者權限

```sql
CREATE OR REPLACE FUNCTION transfer_floor_plan_ownership(
    p_floor_plan_url TEXT,
    p_old_owner_id UUID,
    p_new_owner_id UUID
)
RETURNS VOID AS $$
BEGIN
    -- 更新舊擁有者權限
    UPDATE floor_plan_permissions 
    SET 
        is_owner = FALSE,
        permission_level = 3, -- 保持管理員權限
        updated_at = NOW()
    WHERE floor_plan_url = p_floor_plan_url 
      AND user_id = p_old_owner_id 
      AND is_owner = TRUE;
    
    -- 更新新擁有者權限
    UPDATE floor_plan_permissions 
    SET 
        is_owner = TRUE,
        permission_level = 3, -- 管理員權限
        updated_at = NOW()
    WHERE floor_plan_url = p_floor_plan_url 
      AND user_id = p_new_owner_id;
    
    -- 檢查是否成功
    IF NOT FOUND THEN
        RAISE EXCEPTION '轉移權限失敗：找不到目標用戶權限記錄';
    END IF;
END;
$$ LANGUAGE plpgsql;
```

### 3. 行級安全性 (RLS) 設定

```sql
-- 啟用 RLS
ALTER TABLE floor_plan_permissions ENABLE ROW LEVEL SECURITY;

-- 用戶只能查看自己有權限的設計圖
CREATE POLICY "Users can view their own permissions" ON floor_plan_permissions
    FOR SELECT USING (user_id = auth.uid());

-- 用戶可以插入自己為擁有者的權限記錄（上傳設計圖時）
CREATE POLICY "Users can create owner permissions" ON floor_plan_permissions
    FOR INSERT WITH CHECK (
        user_id = auth.uid() AND is_owner = TRUE
    );

-- 用戶可以插入其他用戶的權限記錄（如果自己是該設計圖的擁有者）
CREATE POLICY "Owners can add user permissions" ON floor_plan_permissions
    FOR INSERT WITH CHECK (
        -- 檢查當前用戶是否為該設計圖的擁有者（使用 RPC 函數避免遞迴）
        check_floor_plan_ownership(auth.uid(), floor_plan_url)
    );

-- 擁有者可以更新其他用戶的權限
CREATE POLICY "Owners can update permissions" ON floor_plan_permissions
    FOR UPDATE USING (
        check_floor_plan_ownership(auth.uid(), floor_plan_url)
    ) WITH CHECK (
        check_floor_plan_ownership(auth.uid(), floor_plan_url)
    );

-- 擁有者可以刪除其他用戶的權限
CREATE POLICY "Owners can delete permissions" ON floor_plan_permissions
    FOR DELETE USING (
        check_floor_plan_ownership(auth.uid(), floor_plan_url)
    );
```

### 4. 檢查擁有者權限的輔助函數（避免遞迴）

```sql
-- 創建檢查擁有者權限的函數
CREATE OR REPLACE FUNCTION check_floor_plan_ownership(
    user_id_param UUID,
    floor_plan_url_param TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
    -- 直接查詢是否存在擁有者記錄，不使用 RLS
    RETURN EXISTS (
        SELECT 1 
        FROM floor_plan_permissions 
        WHERE user_id = user_id_param 
          AND floor_plan_url = floor_plan_url_param 
          AND is_owner = TRUE
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## 權限等級說明

### 第一級 (Level 1) - 一般用戶

- **權限值**: 1
- **圖標**: 👤
- **描述**: 可以上傳圖片和刪除自己上傳的座標點
- **功能**:
  - ✅ 上傳照片記錄
  - ✅ 刪除自己的照片記錄
  - ❌ 刪除他人的照片記錄
  - ❌ 刪除設計圖

### 第二級 (Level 2) - 進階用戶

- **權限值**: 2
- **圖標**: ⭐
- **描述**: 有第一級的權限+刪除其他人座標點
- **功能**:
  - ✅ 上傳照片記錄
  - ✅ 刪除自己的照片記錄
  - ✅ 刪除他人的照片記錄
  - ❌ 刪除設計圖

### 第三級 (Level 3) - 管理員

- **權限值**: 3
- **圖標**: 👑
- **描述**: 有第二級權限+刪除設計圖
- **功能**:
  - ✅ 上傳照片記錄
  - ✅ 刪除自己的照片記錄
  - ✅ 刪除他人的照片記錄
  - ✅ 刪除設計圖

## 擁有者特權

擁有者 (is_owner = true) 額外擁有以下權限：

- 🔧 管理其他用戶的權限
- 👥 添加新用戶權限
- ✏️ 修改用戶權限等級
- 🗑️ 移除用戶權限
- 🔄 轉移擁有者權限

## 使用流程

### 1. 上傳設計圖時自動創建擁有者權限

```dart
// 上傳設計圖後
await permissionService.createOwnerPermission(
  floorPlanId: fileName.split('.').first,
  floorPlanUrl: publicUrl,
  floorPlanName: name,
);
```

### 2. 添加用戶權限

```dart
await permissionService.addUserPermission(
  floorPlanUrl: floorPlanUrl,
  floorPlanName: floorPlanName,
  userEmail: 'user@example.com',
  permissionLevel: PermissionLevel.level2,
);
```

### 3. 檢查權限

```dart
// 檢查是否可以刪除照片記錄
bool canDelete = await permissionService.canDeletePhotoRecord(
  floorPlanUrl: floorPlanUrl,
  photoRecordUserId: record.userId,
);

// 檢查是否可以刪除設計圖
bool canDeletePlan = await permissionService.canDeleteFloorPlan(floorPlanUrl);
```

### 4. 轉移擁有者權限

```dart
await permissionService.transferOwnership(
  floorPlanUrl: floorPlanUrl,
  newOwnerUserId: newOwnerId,
);
```

## 安全性考量

1. **行級安全性**: 使用 Supabase RLS 確保用戶只能訪問有權限的資源
2. **權限檢查**: 每個操作前都會檢查用戶權限
3. **審計記錄**: 所有權限變更都有時間戳記錄
4. **級聯刪除**: 刪除設計圖時自動清理相關權限記錄

## UI 組件

1. **PermissionManagementPage**: 權限管理主頁面
2. **AddUserPermissionDialog**: 添加用戶權限對話框
3. **設計圖選擇器**: 新增權限管理入口
4. **照片記錄**: 整合權限檢查邏輯
