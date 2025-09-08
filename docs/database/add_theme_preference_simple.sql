-- 簡化版主題偏好設置（不依賴 RPC 函數）
-- 這個版本直接通過表操作來處理主題偏好
-- ================================================

-- 檢查 profiles 表是否存在 theme_preference 欄位
DO $$ 
BEGIN
    -- 檢查欄位是否存在
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name='profiles' 
        AND column_name='theme_preference'
    ) THEN
        -- 新增主題偏好欄位
        ALTER TABLE public.profiles 
        ADD COLUMN theme_preference text DEFAULT 'system' 
        CHECK (theme_preference IN ('light', 'dark', 'system'));
    END IF;
END $$;

-- 為現有用戶設定預設主題偏好
UPDATE public.profiles 
SET theme_preference = 'system' 
WHERE theme_preference IS NULL;

-- 確保所有登入用戶都有 profile 記錄的觸發器函數
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  -- 使用 INSERT ... ON CONFLICT DO NOTHING 來避免重複插入
  INSERT INTO public.profiles (id, email, full_name, theme_preference, created_at, updated_at)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''), 
    'system',
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 創建或替換觸發器
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 為當前所有已存在但沒有 profile 的用戶創建 profile
INSERT INTO public.profiles (id, email, full_name, theme_preference, created_at, updated_at)
SELECT 
  au.id,
  au.email,
  COALESCE(au.raw_user_meta_data->>'full_name', ''),
  'system',
  NOW(),
  NOW()
FROM auth.users au
LEFT JOIN public.profiles p ON au.id = p.id
WHERE p.id IS NULL
ON CONFLICT (id) DO NOTHING;
