-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.floor_plan_permissions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  floor_plan_id uuid NOT NULL,
  user_id uuid NOT NULL,
  permission_level integer NOT NULL CHECK (permission_level >= 1 AND permission_level <= 3),
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT floor_plan_permissions_pkey PRIMARY KEY (id),
  CONSTRAINT floor_plan_permissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT floor_plan_permissions_floor_plan_id_fkey FOREIGN KEY (floor_plan_id) REFERENCES public.floor_plans(id)
);
CREATE TABLE public.floor_plans (
  id uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  name text NOT NULL,
  image_url text NOT NULL UNIQUE,
  user_id uuid,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT floor_plans_pkey PRIMARY KEY (id),
  CONSTRAINT floor_plans_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.photo_records (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  floor_plan_id uuid NOT NULL,
  x_coordinate double precision NOT NULL,
  y_coordinate double precision NOT NULL,
  image_id uuid NOT NULL,
  description text,
  user_id uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT photo_records_pkey PRIMARY KEY (id),
  CONSTRAINT photo_records_floor_plan_id_fkey FOREIGN KEY (floor_plan_id) REFERENCES public.floor_plans(id),
  CONSTRAINT photo_records_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  email text,
  full_name text,
  avatar_url text,
  theme_preference text DEFAULT 'system'::text CHECK (theme_preference = ANY (ARRAY['light'::text, 'dark'::text, 'system'::text])),
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);