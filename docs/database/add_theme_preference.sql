-- 新增使用者主題偏好欄位到 profiles 表
-- ================================================

-- 新增主題偏好欄位
ALTER TABLE public.profiles 
ADD COLUMN theme_preference text DEFAULT 'system' CHECK (theme_preference IN ('light', 'dark', 'system'));

-- 為現有用戶設定預設主題偏好
UPDATE public.profiles 
SET theme_preference = 'system' 
WHERE theme_preference IS NULL;

-- 創建或更新用戶資料的函數（包含主題偏好）
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, theme_preference)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name', 'system');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 如果觸發器不存在，則創建
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 創建更新用戶偏好的函數
CREATE OR REPLACE FUNCTION public.update_user_theme_preference(new_theme text)
RETURNS boolean AS $$
BEGIN
  UPDATE public.profiles 
  SET theme_preference = new_theme, updated_at = NOW()
  WHERE id = auth.uid();
  
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 創建獲取用戶偏好的函數
CREATE OR REPLACE FUNCTION public.get_user_theme_preference()
RETURNS text AS $$
DECLARE
  user_theme text;
BEGIN
  SELECT theme_preference INTO user_theme
  FROM public.profiles
  WHERE id = auth.uid();
  
  RETURN COALESCE(user_theme, 'system');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
