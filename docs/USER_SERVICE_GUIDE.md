# UserService 使用指南

## 概述

`UserService` 是一個專門處理用戶 Profile 資料的服務類別，它透過 `auth.users.id` 來管理 `profiles` 表中的用戶資料。

## 主要功能

### 1. 獲取用戶資料

```dart
// 獲取當前登入用戶的 profile
final userProfile = await userService.getCurrentUserProfile();

// 透過特定用戶 ID 獲取 profile
final userProfile = await userService.getUserProfileById('user-id');
```

### 2. 創建和更新用戶資料

```dart
// 為當前用戶創建或更新 profile
final userProfile = await userService.upsertCurrentUserProfile(
  fullName: '用戶姓名',
  themePreference: 'dark',
);

// 更新當前用戶的 profile
final updatedProfile = await userService.updateCurrentUserProfile(
  fullName: '新姓名',
  themePreference: 'light',
);
```

### 3. 批量操作

```dart
// 批量獲取多個用戶的 profile
final userIds = ['id1', 'id2', 'id3'];
final profiles = await userService.getUserProfilesByIds(userIds);

// 搜尋用戶
final searchResults = await userService.searchUsers(
  email: 'example@email.com',
  limit: 10,
);
```

## 資料庫架構對應

UserService 直接對應到資料庫的 `profiles` 表：

```sql
CREATE TABLE public.profiles (
  id uuid NOT NULL,                    -- 對應 auth.users.id
  email text,                          -- 用戶 email
  full_name text,                      -- 用戶全名
  avatar_url text,                     -- 頭像 URL
  theme_preference text DEFAULT 'system', -- 主題偏好
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
```

## 使用範例

### 在 Widget 中使用

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final UserService _userService;
  UserProfile? _currentUser;

  @override
  void initState() {
    super.initState();
    _userService = UserService(Supabase.instance.client);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _userService.getCurrentUserProfile();
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUser?.fullName ?? '載入中...'),
      ),
      body: _currentUser != null
          ? Column(
              children: [
                Text('歡迎, ${_currentUser!.fullName ?? _currentUser!.email}'),
                Text('主題: ${_currentUser!.themePreference}'),
              ],
            )
          : const CircularProgressIndicator(),
    );
  }
}
```

### 與 UserPreferencesService 整合

新的 `UserPreferencesService` 已經整合了 `UserService`：

```dart
final preferencesService = UserPreferencesService(Supabase.instance.client);

// 獲取主題偏好
final theme = await preferencesService.getThemePreference();

// 更新主題偏好
await preferencesService.updateThemePreference('dark');
```

## 錯誤處理

所有方法都包含適當的錯誤處理：

```dart
try {
  final user = await userService.getCurrentUserProfile();
  if (user != null) {
    // 處理用戶資料
  } else {
    // 處理找不到用戶的情況
  }
} catch (e) {
  print('操作失敗: $e');
  // 處理錯誤
}
```

## 最佳實踐

1. **初始化時檢查 Profile**: 用戶首次登入時，確保創建 Profile

   ```dart
   final profile = await userService.getCurrentUserProfile();
   if (profile == null) {
     await userService.upsertCurrentUserProfile();
   }
   ```

2. **使用 upsert 方法**: 當不確定 Profile 是否存在時，使用 `upsertCurrentUserProfile()`

3. **批量操作**: 需要獲取多個用戶資料時，使用 `getUserProfilesByIds()` 而不是多次調用單個方法

4. **錯誤處理**: 總是檢查返回值是否為 null，並適當處理錯誤情況

## 遷移指南

如果您之前使用 `UserPreferencesService` 的方法：

- `getUserProfile()` → `userService.getCurrentUserProfile()`
- `createOrUpdateUserProfile()` → `userService.upsertCurrentUserProfile()`

這些舊方法已標記為 deprecated，但仍可使用。建議逐步遷移到新的 UserService API。
