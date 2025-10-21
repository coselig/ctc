--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8
-- Dumped by pg_dump version 15.8

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
-- Name: _realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA _realtime;


ALTER SCHEMA _realtime OWNER TO supabase_admin;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql;


ALTER SCHEMA graphql OWNER TO supabase_admin;

--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql_public;


ALTER SCHEMA graphql_public OWNER TO supabase_admin;

--
-- Name: pg_net; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_net; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_net IS 'Async HTTP';


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA realtime;


ALTER SCHEMA realtime OWNER TO supabase_admin;

--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA storage;


ALTER SCHEMA storage OWNER TO supabase_admin;

--
-- Name: supabase_functions; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA supabase_functions;


ALTER SCHEMA supabase_functions OWNER TO supabase_admin;

--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA vault;


ALTER SCHEMA vault OWNER TO supabase_admin;

--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgjwt WITH SCHEMA extensions;


--
-- Name: EXTENSION pgjwt; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgjwt IS 'JSON Web Token API for Postgresql';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE auth.one_time_token_type OWNER TO supabase_auth_admin;

--
-- Name: action; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


ALTER TYPE realtime.action OWNER TO supabase_admin;

--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


ALTER TYPE realtime.equality_op OWNER TO supabase_admin;

--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


ALTER TYPE realtime.user_defined_filter OWNER TO supabase_admin;

--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


ALTER TYPE realtime.wal_column OWNER TO supabase_admin;

--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


ALTER TYPE realtime.wal_rls OWNER TO supabase_admin;

--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS'
);


ALTER TYPE storage.buckettype OWNER TO supabase_storage_admin;

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: postgres
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_cron_access() OWNER TO postgres;

--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: postgres
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


ALTER FUNCTION extensions.grant_pg_graphql_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: postgres
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_net_access() OWNER TO postgres;

--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: postgres
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_ddl_watch() OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_drop_watch() OWNER TO supabase_admin;

--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


ALTER FUNCTION extensions.set_graphql_placeholder() OWNER TO supabase_admin;

--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: supabase_admin
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    RAISE WARNING 'PgBouncer auth request: %', p_usename;

    RETURN QUERY
    SELECT usename::TEXT, passwd::TEXT FROM pg_catalog.pg_shadow
    WHERE usename = p_usename;
END;
$$;


ALTER FUNCTION pgbouncer.get_auth(p_usename text) OWNER TO supabase_admin;

--
-- Name: get_current_user_role(); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.get_current_user_role() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  user_role text;
BEGIN
  -- SECURITY DEFINER 會繞過 RLS 政策
  SELECT role INTO user_role
  FROM public.employees
  WHERE id = auth.uid();
  
  RETURN COALESCE(user_role, 'employee');
END;
$$;


ALTER FUNCTION public.get_current_user_role() OWNER TO supabase_admin;

--
-- Name: FUNCTION get_current_user_role(); Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON FUNCTION public.get_current_user_role() IS '安全地獲取當前用戶角色（繞過 RLS 避免遞迴）';


--
-- Name: get_employee_leave_balance(uuid, integer); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.get_employee_leave_balance(p_employee_id uuid, p_year integer DEFAULT NULL::integer) RETURNS TABLE(employee_id uuid, leave_type text, total_days numeric, used_days numeric, pending_days numeric, remaining_days numeric)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        lb.employee_id,
        lb.leave_type,
        lb.total_days,
        lb.used_days,
        lb.pending_days,
        (lb.total_days - lb.used_days - lb.pending_days) AS remaining_days
    FROM leave_balances lb
    WHERE lb.employee_id = p_employee_id
      AND (p_year IS NULL OR lb.year = p_year)
    ORDER BY lb.leave_type;
END;
$$;


ALTER FUNCTION public.get_employee_leave_balance(p_employee_id uuid, p_year integer) OWNER TO supabase_admin;

--
-- Name: get_floor_plan_permissions(uuid); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.get_floor_plan_permissions(p_floor_plan_id uuid) RETURNS TABLE(id uuid, floor_plan_id uuid, user_id uuid, permission_level integer, created_at timestamp with time zone, updated_at timestamp with time zone, user_email text, user_full_name text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT 
    fpp.id,
    fpp.floor_plan_id,
    fpp.user_id,
    fpp.permission_level,
    fpp.created_at,
    fpp.updated_at,
    p.email as user_email,
    p.full_name as user_full_name
  FROM public.floor_plan_permissions fpp
  LEFT JOIN public.profiles p ON fpp.user_id = p.id
  WHERE fpp.floor_plan_id = p_floor_plan_id
  ORDER BY fpp.created_at DESC;
END;
$$;


ALTER FUNCTION public.get_floor_plan_permissions(p_floor_plan_id uuid) OWNER TO supabase_admin;

--
-- Name: get_project_statistics(uuid); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.get_project_statistics(p_project_id uuid) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  result jsonb;
BEGIN
  SELECT jsonb_build_object(
    'total_members', (SELECT COUNT(*) FROM public.project_members WHERE project_id = p_project_id),
    'total_clients', (SELECT COUNT(*) FROM public.project_clients WHERE project_id = p_project_id),
    'total_timeline_items', (SELECT COUNT(*) FROM public.project_timeline WHERE project_id = p_project_id),
    'completed_timeline_items', (SELECT COUNT(*) FROM public.project_timeline WHERE project_id = p_project_id AND is_completed = true),
    'total_comments', (SELECT COUNT(*) FROM public.project_comments WHERE project_id = p_project_id),
    'total_tasks', (SELECT COUNT(*) FROM public.project_tasks WHERE project_id = p_project_id),
    'completed_tasks', (SELECT COUNT(*) FROM public.project_tasks WHERE project_id = p_project_id AND status = 'completed'),
    'in_progress_tasks', (SELECT COUNT(*) FROM public.project_tasks WHERE project_id = p_project_id AND status = 'in_progress'),
    'total_floor_plans', (SELECT COUNT(*) FROM public.floor_plans WHERE project_id = p_project_id)
  ) INTO result;
  
  RETURN result;
END;
$$;


ALTER FUNCTION public.get_project_statistics(p_project_id uuid) OWNER TO supabase_admin;

--
-- Name: get_user_role(); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.get_user_role() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  user_role text;
BEGIN
  SELECT role INTO user_role
  FROM public.employees
  WHERE id = auth.uid();
  
  RETURN COALESCE(user_role, 'employee');
END;
$$;


ALTER FUNCTION public.get_user_role() OWNER TO supabase_admin;

--
-- Name: FUNCTION get_user_role(); Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON FUNCTION public.get_user_role() IS '獲取當前用戶的角色';


--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO public.user_profiles (user_id, email, display_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.handle_new_user() OWNER TO supabase_admin;

--
-- Name: has_floor_plan_access(uuid, uuid); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.has_floor_plan_access(p_floor_plan_id uuid, p_user_id uuid DEFAULT auth.uid()) RETURNS boolean
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  -- 檢查是否為擁有者
  IF EXISTS (
    SELECT 1 FROM floor_plans
    WHERE id = p_floor_plan_id
    AND user_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  -- 檢查是否有任何等級的權限
  IF EXISTS (
    SELECT 1 FROM floor_plan_permissions
    WHERE floor_plan_id = p_floor_plan_id
    AND user_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  RETURN FALSE;
END;
$$;


ALTER FUNCTION public.has_floor_plan_access(p_floor_plan_id uuid, p_user_id uuid) OWNER TO supabase_admin;

--
-- Name: FUNCTION has_floor_plan_access(p_floor_plan_id uuid, p_user_id uuid); Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON FUNCTION public.has_floor_plan_access(p_floor_plan_id uuid, p_user_id uuid) IS '檢查用戶是否有設計圖的存取權限（任何等級）。使用 SECURITY DEFINER 繞過 RLS，避免遞迴。';


--
-- Name: has_floor_plan_admin_access(uuid, uuid); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.has_floor_plan_admin_access(p_floor_plan_id uuid, p_user_id uuid DEFAULT auth.uid()) RETURNS boolean
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  -- 檢查是否為擁有者
  IF EXISTS (
    SELECT 1 FROM floor_plans
    WHERE id = p_floor_plan_id
    AND user_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  -- 檢查是否有管理權限
  IF EXISTS (
    SELECT 1 FROM floor_plan_permissions
    WHERE floor_plan_id = p_floor_plan_id
    AND user_id = p_user_id
    AND permission_level = 3
  ) THEN
    RETURN TRUE;
  END IF;
  
  RETURN FALSE;
END;
$$;


ALTER FUNCTION public.has_floor_plan_admin_access(p_floor_plan_id uuid, p_user_id uuid) OWNER TO supabase_admin;

--
-- Name: FUNCTION has_floor_plan_admin_access(p_floor_plan_id uuid, p_user_id uuid); Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON FUNCTION public.has_floor_plan_admin_access(p_floor_plan_id uuid, p_user_id uuid) IS '檢查用戶是否有設計圖的管理權限（等級 = 3 或擁有者）。使用 SECURITY DEFINER 繞過 RLS，避免遞迴。';


--
-- Name: has_floor_plan_edit_access(uuid, uuid); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.has_floor_plan_edit_access(p_floor_plan_id uuid, p_user_id uuid DEFAULT auth.uid()) RETURNS boolean
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  -- 檢查是否為擁有者
  IF EXISTS (
    SELECT 1 FROM floor_plans
    WHERE id = p_floor_plan_id
    AND user_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  -- 檢查是否有編輯或管理權限
  IF EXISTS (
    SELECT 1 FROM floor_plan_permissions
    WHERE floor_plan_id = p_floor_plan_id
    AND user_id = p_user_id
    AND permission_level >= 2
  ) THEN
    RETURN TRUE;
  END IF;
  
  RETURN FALSE;
END;
$$;


ALTER FUNCTION public.has_floor_plan_edit_access(p_floor_plan_id uuid, p_user_id uuid) OWNER TO supabase_admin;

--
-- Name: FUNCTION has_floor_plan_edit_access(p_floor_plan_id uuid, p_user_id uuid); Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON FUNCTION public.has_floor_plan_edit_access(p_floor_plan_id uuid, p_user_id uuid) IS '檢查用戶是否有設計圖的編輯權限（等級 >= 2）。使用 SECURITY DEFINER 繞過 RLS，避免遞迴。';


--
-- Name: has_project_access(uuid, uuid); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.has_project_access(p_project_id uuid, p_user_id uuid DEFAULT auth.uid()) RETURNS boolean
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
BEGIN
  -- 檢查是否為擁有者
  IF EXISTS (
    SELECT 1 FROM public.projects
    WHERE id = p_project_id
    AND owner_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  -- 檢查是否為專案成員（任何角色）
  IF EXISTS (
    SELECT 1 FROM public.project_members
    WHERE project_id = p_project_id
    AND user_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  RETURN FALSE;
END;
$$;


ALTER FUNCTION public.has_project_access(p_project_id uuid, p_user_id uuid) OWNER TO supabase_admin;

--
-- Name: FUNCTION has_project_access(p_project_id uuid, p_user_id uuid); Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON FUNCTION public.has_project_access(p_project_id uuid, p_user_id uuid) IS '檢查用戶是否有專案的存取權限（擁有者或任何角色的成員）。使用 SECURITY DEFINER 繞過 RLS，避免遞迴。';


--
-- Name: has_project_admin_access(uuid, uuid); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.has_project_admin_access(p_project_id uuid, p_user_id uuid DEFAULT auth.uid()) RETURNS boolean
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
BEGIN
  -- 檢查是否為擁有者
  IF EXISTS (
    SELECT 1 FROM public.projects
    WHERE id = p_project_id
    AND owner_id = p_user_id
  ) THEN
    RETURN TRUE;
  END IF;
  
  -- 檢查是否為管理員
  IF EXISTS (
    SELECT 1 FROM public.project_members
    WHERE project_id = p_project_id
    AND user_id = p_user_id
    AND role = 'admin'
  ) THEN
    RETURN TRUE;
  END IF;
  
  RETURN FALSE;
END;
$$;


ALTER FUNCTION public.has_project_admin_access(p_project_id uuid, p_user_id uuid) OWNER TO supabase_admin;

--
-- Name: FUNCTION has_project_admin_access(p_project_id uuid, p_user_id uuid); Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON FUNCTION public.has_project_admin_access(p_project_id uuid, p_user_id uuid) IS '檢查用戶是否有專案的管理權限（擁有者或管理員）。使用 SECURITY DEFINER 繞過 RLS，避免遞迴。';


--
-- Name: initialize_leave_balance(uuid, text, integer, numeric); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.initialize_leave_balance(p_employee_id uuid, p_leave_type text, p_year integer, p_total_days numeric) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
    INSERT INTO leave_balances (
        employee_id,
        leave_type,
        year,
        total_days,
        used_days,
        pending_days
    )
    VALUES (
        p_employee_id,
        p_leave_type,
        p_year,
        p_total_days,
        0,
        0
    )
    ON CONFLICT (employee_id, leave_type, year)
    DO UPDATE SET
        total_days = EXCLUDED.total_days,
        updated_at = NOW();
END;
$$;


ALTER FUNCTION public.initialize_leave_balance(p_employee_id uuid, p_leave_type text, p_year integer, p_total_days numeric) OWNER TO supabase_admin;

--
-- Name: is_boss(); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.is_boss() RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.employees
    WHERE id = auth.uid() AND role = 'boss'
  );
END;
$$;


ALTER FUNCTION public.is_boss() OWNER TO supabase_admin;

--
-- Name: FUNCTION is_boss(); Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON FUNCTION public.is_boss() IS '檢查當前用戶是否為老闆';


--
-- Name: is_boss_or_hr(); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.is_boss_or_hr() RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.employees
    WHERE id = auth.uid() AND role IN ('boss', 'hr')
  );
END;
$$;


ALTER FUNCTION public.is_boss_or_hr() OWNER TO supabase_admin;

--
-- Name: FUNCTION is_boss_or_hr(); Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON FUNCTION public.is_boss_or_hr() IS '檢查當前用戶是否為老闆或人事';


--
-- Name: is_hr(); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.is_hr() RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.employees
    WHERE id = auth.uid() AND role = 'hr'
  );
END;
$$;


ALTER FUNCTION public.is_hr() OWNER TO supabase_admin;

--
-- Name: FUNCTION is_hr(); Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON FUNCTION public.is_hr() IS '檢查當前用戶是否為人事';


--
-- Name: update_attendance_leave_requests_updated_at(); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.update_attendance_leave_requests_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_attendance_leave_requests_updated_at() OWNER TO supabase_admin;

--
-- Name: update_attendance_records_updated_at(); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.update_attendance_records_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_attendance_records_updated_at() OWNER TO supabase_admin;

--
-- Name: update_employee_updated_at(); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.update_employee_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_employee_updated_at() OWNER TO supabase_admin;

--
-- Name: update_leave_balance_on_request_change(); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.update_leave_balance_on_request_change() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
    v_year INTEGER;
BEGIN
    v_year := EXTRACT(YEAR FROM NEW.start_date);
    
    -- 確保該員工該年度的假別額度記錄存在
    INSERT INTO leave_balances (employee_id, leave_type, year, total_days)
    VALUES (NEW.employee_id, NEW.leave_type, v_year, 0)
    ON CONFLICT (employee_id, leave_type, year) DO NOTHING;
    
    -- 如果是新增記錄
    IF TG_OP = 'INSERT' THEN
        IF NEW.status = 'pending' THEN
            -- 增加 pending_days
            UPDATE leave_balances
            SET pending_days = pending_days + NEW.total_days
            WHERE employee_id = NEW.employee_id
              AND leave_type = NEW.leave_type
              AND year = v_year;
        ELSIF NEW.status = 'approved' THEN
            -- 增加 used_days
            UPDATE leave_balances
            SET used_days = used_days + NEW.total_days
            WHERE employee_id = NEW.employee_id
              AND leave_type = NEW.leave_type
              AND year = v_year;
        END IF;
        
    -- 如果是更新記錄
    ELSIF TG_OP = 'UPDATE' THEN
        -- 先還原舊狀態
        IF OLD.status = 'pending' THEN
            UPDATE leave_balances
            SET pending_days = pending_days - OLD.total_days
            WHERE employee_id = OLD.employee_id
              AND leave_type = OLD.leave_type
              AND year = v_year;
        ELSIF OLD.status = 'approved' THEN
            UPDATE leave_balances
            SET used_days = used_days - OLD.total_days
            WHERE employee_id = OLD.employee_id
              AND leave_type = OLD.leave_type
              AND year = v_year;
        END IF;
        
        -- 套用新狀態
        IF NEW.status = 'pending' THEN
            UPDATE leave_balances
            SET pending_days = pending_days + NEW.total_days
            WHERE employee_id = NEW.employee_id
              AND leave_type = NEW.leave_type
              AND year = v_year;
        ELSIF NEW.status = 'approved' THEN
            UPDATE leave_balances
            SET used_days = used_days + NEW.total_days
            WHERE employee_id = NEW.employee_id
              AND leave_type = NEW.leave_type
              AND year = v_year;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_leave_balance_on_request_change() OWNER TO supabase_admin;

--
-- Name: update_leave_balances_updated_at(); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.update_leave_balances_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_leave_balances_updated_at() OWNER TO supabase_admin;

--
-- Name: update_leave_requests_updated_at(); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.update_leave_requests_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_leave_requests_updated_at() OWNER TO supabase_admin;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO supabase_admin;

--
-- Name: update_user_profiles_updated_at(); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.update_user_profiles_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_user_profiles_updated_at() OWNER TO supabase_admin;

--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


ALTER FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


ALTER FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) OWNER TO supabase_admin;

--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


ALTER FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) OWNER TO supabase_admin;

--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


ALTER FUNCTION realtime."cast"(val text, type_ regtype) OWNER TO supabase_admin;

--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


ALTER FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) OWNER TO supabase_admin;

--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


ALTER FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) OWNER TO supabase_admin;

--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


ALTER FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


ALTER FUNCTION realtime.quote_wal2json(entity regclass) OWNER TO supabase_admin;

--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  BEGIN
    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (payload, event, topic, private, extension)
    VALUES (payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      PERFORM pg_notify(
          'realtime:system',
          jsonb_build_object(
              'error', SQLERRM,
              'function', 'realtime.send',
              'event', event,
              'topic', topic,
              'private', private
          )::text
      );
  END;
END;
$$;


ALTER FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) OWNER TO supabase_admin;

--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


ALTER FUNCTION realtime.subscription_check_filters() OWNER TO supabase_admin;

--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION realtime.to_regrole(role_name text) OWNER TO supabase_admin;

--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


ALTER FUNCTION realtime.topic() OWNER TO supabase_realtime_admin;

--
-- Name: add_prefixes(text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.add_prefixes(_bucket_id text, _name text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    prefixes text[];
BEGIN
    prefixes := "storage"."get_prefixes"("_name");

    IF array_length(prefixes, 1) > 0 THEN
        INSERT INTO storage.prefixes (name, bucket_id)
        SELECT UNNEST(prefixes) as name, "_bucket_id" ON CONFLICT DO NOTHING;
    END IF;
END;
$$;


ALTER FUNCTION storage.add_prefixes(_bucket_id text, _name text) OWNER TO supabase_storage_admin;

--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) OWNER TO supabase_storage_admin;

--
-- Name: delete_prefix(text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_prefix(_bucket_id text, _name text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    -- Check if we can delete the prefix
    IF EXISTS(
        SELECT FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name") + 1
          AND "prefixes"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    )
    OR EXISTS(
        SELECT FROM "storage"."objects"
        WHERE "objects"."bucket_id" = "_bucket_id"
          AND "storage"."get_level"("objects"."name") = "storage"."get_level"("_name") + 1
          AND "objects"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    ) THEN
    -- There are sub-objects, skip deletion
    RETURN false;
    ELSE
        DELETE FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name")
          AND "prefixes"."name" = "_name";
        RETURN true;
    END IF;
END;
$$;


ALTER FUNCTION storage.delete_prefix(_bucket_id text, _name text) OWNER TO supabase_storage_admin;

--
-- Name: delete_prefix_hierarchy_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_prefix_hierarchy_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    prefix text;
BEGIN
    prefix := "storage"."get_prefix"(OLD."name");

    IF coalesce(prefix, '') != '' THEN
        PERFORM "storage"."delete_prefix"(OLD."bucket_id", prefix);
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION storage.delete_prefix_hierarchy_trigger() OWNER TO supabase_storage_admin;

--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


ALTER FUNCTION storage.enforce_bucket_name_length() OWNER TO supabase_storage_admin;

--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    SELECT _parts[array_length(_parts,1)] INTO _filename;
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


ALTER FUNCTION storage.extension(name text) OWNER TO supabase_storage_admin;

--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION storage.filename(name text) OWNER TO supabase_storage_admin;

--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


ALTER FUNCTION storage.foldername(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_level(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_level(name text) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


ALTER FUNCTION storage.get_level(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_prefix(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_prefix(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$_$;


ALTER FUNCTION storage.get_prefix(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_prefixes(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_prefixes(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE
    parts text[];
    prefixes text[];
    prefix text;
BEGIN
    -- Split the name into parts by '/'
    parts := string_to_array("name", '/');
    prefixes := '{}';

    -- Construct the prefixes, stopping one level below the last part
    FOR i IN 1..array_length(parts, 1) - 1 LOOP
            prefix := array_to_string(parts[1:i], '/');
            prefixes := array_append(prefixes, prefix);
    END LOOP;

    RETURN prefixes;
END;
$$;


ALTER FUNCTION storage.get_prefixes(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION storage.get_size_by_bucket() OWNER TO supabase_storage_admin;

--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


ALTER FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text) OWNER TO supabase_storage_admin;

--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


ALTER FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text) OWNER TO supabase_storage_admin;

--
-- Name: objects_insert_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_insert_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    NEW.level := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_insert_prefix_trigger() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    old_prefixes TEXT[];
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Retrieve old prefixes
        old_prefixes := "storage"."get_prefixes"(OLD."name");

        -- Remove old prefixes that are only used by this object
        WITH all_prefixes as (
            SELECT unnest(old_prefixes) as prefix
        ),
        can_delete_prefixes as (
             SELECT prefix
             FROM all_prefixes
             WHERE NOT EXISTS (
                 SELECT 1 FROM "storage"."objects"
                 WHERE "bucket_id" = OLD."bucket_id"
                   AND "name" <> OLD."name"
                   AND "name" LIKE (prefix || '%')
             )
         )
        DELETE FROM "storage"."prefixes" WHERE name IN (SELECT prefix FROM can_delete_prefixes);

        -- Add new prefixes
        PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    END IF;
    -- Set the new level
    NEW."level" := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_update_prefix_trigger() OWNER TO supabase_storage_admin;

--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


ALTER FUNCTION storage.operation() OWNER TO supabase_storage_admin;

--
-- Name: prefixes_insert_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.prefixes_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.prefixes_insert_trigger() OWNER TO supabase_storage_admin;

--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql
    AS $$
declare
    can_bypass_rls BOOLEAN;
begin
    SELECT rolbypassrls
    INTO can_bypass_rls
    FROM pg_roles
    WHERE rolname = coalesce(nullif(current_setting('role', true), 'none'), current_user);

    IF can_bypass_rls THEN
        RETURN QUERY SELECT * FROM storage.search_v1_optimised(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    ELSE
        RETURN QUERY SELECT * FROM storage.search_legacy_v1(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    END IF;
end;
$$;


ALTER FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_legacy_v1(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select path_tokens[$1] as folder
           from storage.objects
             where objects.name ilike $2 || $3 || ''%''
               and bucket_id = $4
               and array_length(objects.path_tokens, 1) <> $1
           group by folder
           order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_v1_optimised(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select (string_to_array(name, ''/''))[level] as name
           from storage.prefixes
             where lower(prefixes.name) like lower($2 || $3) || ''%''
               and bucket_id = $4
               and level = $1
           order by name ' || v_sort_order || '
     )
     (select name,
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[level] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where lower(objects.name) like lower($2 || $3) || ''%''
       and bucket_id = $4
       and level = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_v2(text, text, integer, integer, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
BEGIN
    RETURN query EXECUTE
        $sql$
        SELECT * FROM (
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name || '/' AS name,
                    NULL::uuid AS id,
                    NULL::timestamptz AS updated_at,
                    NULL::timestamptz AS created_at,
                    NULL::jsonb AS metadata
                FROM storage.prefixes
                WHERE name COLLATE "C" LIKE $1 || '%'
                AND bucket_id = $2
                AND level = $4
                AND name COLLATE "C" > $5
                ORDER BY prefixes.name COLLATE "C" LIMIT $3
            )
            UNION ALL
            (SELECT split_part(name, '/', $4) AS key,
                name,
                id,
                updated_at,
                created_at,
                metadata
            FROM storage.objects
            WHERE name COLLATE "C" LIKE $1 || '%'
                AND bucket_id = $2
                AND level = $4
                AND name COLLATE "C" > $5
            ORDER BY name COLLATE "C" LIMIT $3)
        ) obj
        ORDER BY name COLLATE "C" LIMIT $3;
        $sql$
        USING prefix, bucket_name, limits, levels, start_after;
END;
$_$;


ALTER FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer, levels integer, start_after text) OWNER TO supabase_storage_admin;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION storage.update_updated_at_column() OWNER TO supabase_storage_admin;

--
-- Name: http_request(); Type: FUNCTION; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE FUNCTION supabase_functions.http_request() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'supabase_functions'
    AS $$
    DECLARE
      request_id bigint;
      payload jsonb;
      url text := TG_ARGV[0]::text;
      method text := TG_ARGV[1]::text;
      headers jsonb DEFAULT '{}'::jsonb;
      params jsonb DEFAULT '{}'::jsonb;
      timeout_ms integer DEFAULT 1000;
    BEGIN
      IF url IS NULL OR url = 'null' THEN
        RAISE EXCEPTION 'url argument is missing';
      END IF;

      IF method IS NULL OR method = 'null' THEN
        RAISE EXCEPTION 'method argument is missing';
      END IF;

      IF TG_ARGV[2] IS NULL OR TG_ARGV[2] = 'null' THEN
        headers = '{"Content-Type": "application/json"}'::jsonb;
      ELSE
        headers = TG_ARGV[2]::jsonb;
      END IF;

      IF TG_ARGV[3] IS NULL OR TG_ARGV[3] = 'null' THEN
        params = '{}'::jsonb;
      ELSE
        params = TG_ARGV[3]::jsonb;
      END IF;

      IF TG_ARGV[4] IS NULL OR TG_ARGV[4] = 'null' THEN
        timeout_ms = 1000;
      ELSE
        timeout_ms = TG_ARGV[4]::integer;
      END IF;

      CASE
        WHEN method = 'GET' THEN
          SELECT http_get INTO request_id FROM net.http_get(
            url,
            params,
            headers,
            timeout_ms
          );
        WHEN method = 'POST' THEN
          payload = jsonb_build_object(
            'old_record', OLD,
            'record', NEW,
            'type', TG_OP,
            'table', TG_TABLE_NAME,
            'schema', TG_TABLE_SCHEMA
          );

          SELECT http_post INTO request_id FROM net.http_post(
            url,
            payload,
            params,
            headers,
            timeout_ms
          );
        ELSE
          RAISE EXCEPTION 'method argument % is invalid', method;
      END CASE;

      INSERT INTO supabase_functions.hooks
        (hook_table_id, hook_name, request_id)
      VALUES
        (TG_RELID, TG_NAME, request_id);

      RETURN NEW;
    END
  $$;


ALTER FUNCTION supabase_functions.http_request() OWNER TO supabase_functions_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: extensions; Type: TABLE; Schema: _realtime; Owner: supabase_admin
--

CREATE TABLE _realtime.extensions (
    id uuid NOT NULL,
    type text,
    settings jsonb,
    tenant_external_id text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE _realtime.extensions OWNER TO supabase_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: _realtime; Owner: supabase_admin
--

CREATE TABLE _realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE _realtime.schema_migrations OWNER TO supabase_admin;

--
-- Name: tenants; Type: TABLE; Schema: _realtime; Owner: supabase_admin
--

CREATE TABLE _realtime.tenants (
    id uuid NOT NULL,
    name text,
    external_id text,
    jwt_secret text,
    max_concurrent_users integer DEFAULT 200 NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    max_events_per_second integer DEFAULT 100 NOT NULL,
    postgres_cdc_default text DEFAULT 'postgres_cdc_rls'::text,
    max_bytes_per_second integer DEFAULT 100000 NOT NULL,
    max_channels_per_client integer DEFAULT 100 NOT NULL,
    max_joins_per_second integer DEFAULT 500 NOT NULL,
    suspend boolean DEFAULT false,
    jwt_jwks jsonb,
    notify_private_alpha boolean DEFAULT false,
    private_only boolean DEFAULT false NOT NULL
);


ALTER TABLE _realtime.tenants OWNER TO supabase_admin;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;

--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


ALTER TABLE auth.one_time_tokens OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: attendance_leave_requests; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.attendance_leave_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employee_id uuid NOT NULL,
    employee_name text NOT NULL,
    request_type text NOT NULL,
    request_date date NOT NULL,
    request_time timestamp with time zone,
    check_in_time timestamp with time zone,
    check_out_time timestamp with time zone,
    reason text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    reviewer_id uuid,
    reviewer_name text,
    review_comment text,
    reviewed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT attendance_leave_requests_request_type_check CHECK ((request_type = ANY (ARRAY['check_in'::text, 'check_out'::text, 'full_day'::text]))),
    CONSTRAINT attendance_leave_requests_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])))
);


ALTER TABLE public.attendance_leave_requests OWNER TO supabase_admin;

--
-- Name: TABLE attendance_leave_requests; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON TABLE public.attendance_leave_requests IS '補打卡申請記錄表';


--
-- Name: COLUMN attendance_leave_requests.id; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.attendance_leave_requests.id IS '申請ID (UUID)';


--
-- Name: COLUMN attendance_leave_requests.employee_id; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.attendance_leave_requests.employee_id IS '申請人ID';


--
-- Name: COLUMN attendance_leave_requests.employee_name; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.attendance_leave_requests.employee_name IS '申請人姓名';


--
-- Name: COLUMN attendance_leave_requests.request_type; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.attendance_leave_requests.request_type IS '申請類型 (check_in=補上班, check_out=補下班, full_day=補整天)';


--
-- Name: COLUMN attendance_leave_requests.request_date; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.attendance_leave_requests.request_date IS '申請補打卡的日期';


--
-- Name: COLUMN attendance_leave_requests.request_time; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.attendance_leave_requests.request_time IS '申請的打卡時間（單次打卡）';


--
-- Name: COLUMN attendance_leave_requests.check_in_time; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.attendance_leave_requests.check_in_time IS '補打卡的上班時間（整天）';


--
-- Name: COLUMN attendance_leave_requests.check_out_time; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.attendance_leave_requests.check_out_time IS '補打卡的下班時間（整天）';


--
-- Name: COLUMN attendance_leave_requests.reason; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.attendance_leave_requests.reason IS '申請原因';


--
-- Name: COLUMN attendance_leave_requests.status; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.attendance_leave_requests.status IS '狀態 (pending=待審核, approved=已核准, rejected=已拒絕)';


--
-- Name: COLUMN attendance_leave_requests.reviewer_id; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.attendance_leave_requests.reviewer_id IS '審核人ID';


--
-- Name: COLUMN attendance_leave_requests.reviewer_name; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.attendance_leave_requests.reviewer_name IS '審核人姓名';


--
-- Name: COLUMN attendance_leave_requests.review_comment; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.attendance_leave_requests.review_comment IS '審核意見';


--
-- Name: COLUMN attendance_leave_requests.reviewed_at; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.attendance_leave_requests.reviewed_at IS '審核時間';


--
-- Name: attendance_records; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.attendance_records (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employee_id uuid NOT NULL,
    employee_name text NOT NULL,
    employee_email text NOT NULL,
    check_in_time timestamp with time zone NOT NULL,
    check_out_time timestamp with time zone,
    work_hours numeric(5,2),
    location text,
    notes text,
    is_manual_entry boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE public.attendance_records OWNER TO supabase_admin;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.customers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name text NOT NULL,
    company text,
    email text,
    phone text,
    address text,
    notes text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE public.customers OWNER TO supabase_admin;

--
-- Name: TABLE customers; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON TABLE public.customers IS '客戶資料表 - 儲存註冊為客戶的用戶資料';


--
-- Name: COLUMN customers.user_id; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.customers.user_id IS '關聯到 auth.users.id 的用戶 ID';


--
-- Name: COLUMN customers.name; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.customers.name IS '客戶姓名';


--
-- Name: COLUMN customers.company; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.customers.company IS '客戶所屬公司名稱';


--
-- Name: employee_skills; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.employee_skills (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employee_id uuid NOT NULL,
    skill_name text NOT NULL,
    proficiency_level integer NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT employee_skills_proficiency_level_check CHECK (((proficiency_level >= 1) AND (proficiency_level <= 5)))
);


ALTER TABLE public.employee_skills OWNER TO supabase_admin;

--
-- Name: employees; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.employees (
    id uuid NOT NULL,
    employee_id text NOT NULL,
    name text NOT NULL,
    email text,
    phone text,
    department text NOT NULL,
    "position" text NOT NULL,
    hire_date date NOT NULL,
    salary numeric(10,2),
    status text DEFAULT '在職'::text,
    manager_id uuid,
    avatar_url text,
    address text,
    emergency_contact_name text,
    emergency_contact_phone text,
    notes text,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    role text DEFAULT 'employee'::text,
    CONSTRAINT employees_role_check CHECK ((role = ANY (ARRAY['boss'::text, 'hr'::text, 'employee'::text]))),
    CONSTRAINT employees_status_check CHECK ((status = ANY (ARRAY['在職'::text, '離職'::text, '留職停薪'::text, '解雇'::text])))
);


ALTER TABLE public.employees OWNER TO supabase_admin;

--
-- Name: COLUMN employees.role; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.employees.role IS '員工角色 (boss: 老闆, hr: 人事, employee: 一般員工)';


--
-- Name: floor_plan_permissions; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.floor_plan_permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    floor_plan_id uuid NOT NULL,
    user_id uuid NOT NULL,
    permission_level integer NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT floor_plan_permissions_permission_level_check CHECK (((permission_level >= 1) AND (permission_level <= 3)))
);


ALTER TABLE public.floor_plan_permissions OWNER TO supabase_admin;

--
-- Name: floor_plans; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.floor_plans (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    image_url text NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    project_id uuid
);


ALTER TABLE public.floor_plans OWNER TO supabase_admin;

--
-- Name: holidays; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.holidays (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    date date NOT NULL,
    name text NOT NULL,
    year integer NOT NULL,
    description text,
    is_workday boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.holidays OWNER TO supabase_admin;

--
-- Name: TABLE holidays; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON TABLE public.holidays IS '國定假日資料表';


--
-- Name: COLUMN holidays.date; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.holidays.date IS '假日日期';


--
-- Name: COLUMN holidays.name; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.holidays.name IS '假日名稱';


--
-- Name: COLUMN holidays.year; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.holidays.year IS '年份';


--
-- Name: COLUMN holidays.description; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.holidays.description IS '備註說明';


--
-- Name: COLUMN holidays.is_workday; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.holidays.is_workday IS '是否為調整上班日（補班日）';


--
-- Name: images; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.images (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    filename text NOT NULL,
    original_name text,
    file_path text NOT NULL,
    file_size integer,
    mime_type text,
    project_id uuid,
    uploaded_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE public.images OWNER TO supabase_admin;

--
-- Name: job_vacancies; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.job_vacancies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    department text NOT NULL,
    location text NOT NULL,
    type text DEFAULT '全職'::text,
    requirements text[] DEFAULT '{}'::text[],
    responsibilities text[] DEFAULT '{}'::text[],
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.job_vacancies OWNER TO supabase_admin;

--
-- Name: TABLE job_vacancies; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON TABLE public.job_vacancies IS '職位空缺資料表';


--
-- Name: COLUMN job_vacancies.id; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.job_vacancies.id IS '職位ID (UUID)';


--
-- Name: COLUMN job_vacancies.title; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.job_vacancies.title IS '職位名稱';


--
-- Name: COLUMN job_vacancies.department; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.job_vacancies.department IS '所屬部門';


--
-- Name: COLUMN job_vacancies.location; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.job_vacancies.location IS '工作地點';


--
-- Name: COLUMN job_vacancies.type; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.job_vacancies.type IS '職位類型 (全職/兼職/實習)';


--
-- Name: COLUMN job_vacancies.requirements; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.job_vacancies.requirements IS '應徵條件列表';


--
-- Name: COLUMN job_vacancies.responsibilities; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.job_vacancies.responsibilities IS '工作職責列表';


--
-- Name: COLUMN job_vacancies.description; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.job_vacancies.description IS '職位詳細描述';


--
-- Name: COLUMN job_vacancies.is_active; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.job_vacancies.is_active IS '是否為活躍職位';


--
-- Name: COLUMN job_vacancies.created_at; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.job_vacancies.created_at IS '建立時間';


--
-- Name: COLUMN job_vacancies.updated_at; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.job_vacancies.updated_at IS '更新時間';


--
-- Name: leave_balances; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.leave_balances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employee_id uuid NOT NULL,
    leave_type text NOT NULL,
    year integer NOT NULL,
    total_days numeric(5,1) DEFAULT 0 NOT NULL,
    used_days numeric(5,1) DEFAULT 0 NOT NULL,
    pending_days numeric(5,1) DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT leave_balances_leave_type_check CHECK ((leave_type = ANY (ARRAY['sick'::text, 'personal'::text, 'annual'::text, 'parental'::text, 'marriage'::text, 'bereavement'::text, 'official'::text, 'maternity'::text, 'paternity'::text, 'menstrual'::text]))),
    CONSTRAINT valid_days CHECK (((total_days >= (0)::numeric) AND (used_days >= (0)::numeric) AND (pending_days >= (0)::numeric) AND ((used_days + pending_days) <= total_days)))
);


ALTER TABLE public.leave_balances OWNER TO supabase_admin;

--
-- Name: leave_requests; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.leave_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employee_id uuid NOT NULL,
    employee_name text NOT NULL,
    leave_type text NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    start_period text DEFAULT 'full_day'::text NOT NULL,
    end_period text DEFAULT 'full_day'::text NOT NULL,
    total_days numeric(5,1) NOT NULL,
    reason text NOT NULL,
    attachment_url text,
    status text DEFAULT 'pending'::text NOT NULL,
    reviewer_id uuid,
    reviewer_name text,
    review_comment text,
    reviewed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT leave_requests_end_period_check CHECK ((end_period = ANY (ARRAY['full_day'::text, 'morning'::text, 'afternoon'::text]))),
    CONSTRAINT leave_requests_leave_type_check CHECK ((leave_type = ANY (ARRAY['sick'::text, 'personal'::text, 'annual'::text, 'parental'::text, 'marriage'::text, 'bereavement'::text, 'official'::text, 'maternity'::text, 'paternity'::text, 'menstrual'::text]))),
    CONSTRAINT leave_requests_start_period_check CHECK ((start_period = ANY (ARRAY['full_day'::text, 'morning'::text, 'afternoon'::text]))),
    CONSTRAINT leave_requests_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text, 'cancelled'::text]))),
    CONSTRAINT leave_requests_total_days_check CHECK ((total_days > (0)::numeric)),
    CONSTRAINT status_logic CHECK ((((status = 'pending'::text) AND (reviewed_at IS NULL)) OR ((status = ANY (ARRAY['approved'::text, 'rejected'::text])) AND (reviewed_at IS NOT NULL) AND (reviewer_id IS NOT NULL)))),
    CONSTRAINT valid_date_range CHECK ((end_date >= start_date))
);


ALTER TABLE public.leave_requests OWNER TO supabase_admin;

--
-- Name: photo_records; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.photo_records (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    floor_plan_id uuid NOT NULL,
    x_coordinate double precision NOT NULL,
    y_coordinate double precision NOT NULL,
    description text,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    image_url text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.photo_records OWNER TO supabase_admin;

--
-- Name: profiles; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    email text,
    full_name text,
    avatar_url text,
    theme_preference text DEFAULT 'system'::text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT profiles_theme_preference_check CHECK ((theme_preference = ANY (ARRAY['light'::text, 'dark'::text, 'system'::text])))
);


ALTER TABLE public.profiles OWNER TO supabase_admin;

--
-- Name: project_clients; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.project_clients (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    name text NOT NULL,
    company text,
    email text,
    phone text,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.project_clients OWNER TO supabase_admin;

--
-- Name: project_comments; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.project_comments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    user_id uuid NOT NULL,
    content text NOT NULL,
    parent_id uuid,
    attachments jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.project_comments OWNER TO supabase_admin;

--
-- Name: project_members; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.project_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role text DEFAULT 'member'::text NOT NULL,
    joined_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.project_members OWNER TO supabase_admin;

--
-- Name: project_tasks; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.project_tasks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    title text NOT NULL,
    description text,
    status text DEFAULT 'todo'::text NOT NULL,
    priority text DEFAULT 'medium'::text NOT NULL,
    assigned_to uuid,
    due_date date,
    completed_at timestamp with time zone,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    previous_task_id uuid,
    next_task_id uuid,
    display_order integer DEFAULT 0,
    tags text[]
);


ALTER TABLE public.project_tasks OWNER TO supabase_admin;

--
-- Name: project_timeline; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.project_timeline (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    title text NOT NULL,
    description text,
    milestone_date date NOT NULL,
    is_completed boolean DEFAULT false,
    completed_at timestamp with time zone,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.project_timeline OWNER TO supabase_admin;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.projects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    description text,
    status text DEFAULT 'active'::text NOT NULL,
    start_date date,
    end_date date,
    budget numeric(15,2),
    owner_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT projects_name_check CHECK ((char_length(name) >= 1))
);


ALTER TABLE public.projects OWNER TO supabase_admin;

--
-- Name: system_settings; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.system_settings (
    key text NOT NULL,
    value text,
    description text,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE public.system_settings OWNER TO supabase_admin;

--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.user_profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    email text NOT NULL,
    display_name text,
    avatar_url text,
    phone text,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE public.user_profiles OWNER TO supabase_admin;

--
-- Name: TABLE user_profiles; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON TABLE public.user_profiles IS '用戶檔案資料表';


--
-- Name: COLUMN user_profiles.id; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.user_profiles.id IS '檔案系統ID (UUID)';


--
-- Name: COLUMN user_profiles.user_id; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.user_profiles.user_id IS '關聯到認證系統的用戶ID';


--
-- Name: COLUMN user_profiles.email; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.user_profiles.email IS '用戶電子郵件';


--
-- Name: COLUMN user_profiles.display_name; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.user_profiles.display_name IS '顯示姓名';


--
-- Name: COLUMN user_profiles.avatar_url; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.user_profiles.avatar_url IS '頭像網址';


--
-- Name: COLUMN user_profiles.phone; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.user_profiles.phone IS '聯絡電話';


--
-- Name: COLUMN user_profiles.metadata; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.user_profiles.metadata IS '額外的用戶資料 (JSON 格式)';


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


ALTER TABLE realtime.messages OWNER TO supabase_realtime_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE realtime.schema_migrations OWNER TO supabase_admin;

--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE realtime.subscription OWNER TO supabase_admin;

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


ALTER TABLE storage.buckets OWNER TO supabase_storage_admin;

--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets_analytics (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.buckets_analytics OWNER TO supabase_storage_admin;

--
-- Name: iceberg_namespaces; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.iceberg_namespaces (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.iceberg_namespaces OWNER TO supabase_storage_admin;

--
-- Name: iceberg_tables; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.iceberg_tables (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    namespace_id uuid NOT NULL,
    bucket_id text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    location text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.iceberg_tables OWNER TO supabase_storage_admin;

--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE storage.migrations OWNER TO supabase_storage_admin;

--
-- Name: objects; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb,
    level integer
);


ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: prefixes; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.prefixes (
    bucket_id text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    level integer GENERATED ALWAYS AS (storage.get_level(name)) STORED NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE storage.prefixes OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


ALTER TABLE storage.s3_multipart_uploads OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.s3_multipart_uploads_parts OWNER TO supabase_storage_admin;

--
-- Name: hooks; Type: TABLE; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE TABLE supabase_functions.hooks (
    id bigint NOT NULL,
    hook_table_id integer NOT NULL,
    hook_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    request_id bigint
);


ALTER TABLE supabase_functions.hooks OWNER TO supabase_functions_admin;

--
-- Name: TABLE hooks; Type: COMMENT; Schema: supabase_functions; Owner: supabase_functions_admin
--

COMMENT ON TABLE supabase_functions.hooks IS 'Supabase Functions Hooks: Audit trail for triggered hooks.';


--
-- Name: hooks_id_seq; Type: SEQUENCE; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE SEQUENCE supabase_functions.hooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE supabase_functions.hooks_id_seq OWNER TO supabase_functions_admin;

--
-- Name: hooks_id_seq; Type: SEQUENCE OWNED BY; Schema: supabase_functions; Owner: supabase_functions_admin
--

ALTER SEQUENCE supabase_functions.hooks_id_seq OWNED BY supabase_functions.hooks.id;


--
-- Name: migrations; Type: TABLE; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE TABLE supabase_functions.migrations (
    version text NOT NULL,
    inserted_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE supabase_functions.migrations OWNER TO supabase_functions_admin;

--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: hooks id; Type: DEFAULT; Schema: supabase_functions; Owner: supabase_functions_admin
--

ALTER TABLE ONLY supabase_functions.hooks ALTER COLUMN id SET DEFAULT nextval('supabase_functions.hooks_id_seq'::regclass);


--
-- Data for Name: extensions; Type: TABLE DATA; Schema: _realtime; Owner: supabase_admin
--

COPY _realtime.extensions (id, type, settings, tenant_external_id, inserted_at, updated_at) FROM stdin;
3f3812e2-1f7d-49da-b1e2-2b1711ce1324	postgres_cdc_rls	{"region": "us-east-1", "db_host": "QhixI0o7PYIABziLUL4f0A==", "db_name": "sWBpZNdjggEPTQVlI52Zfw==", "db_port": "+enMDFi1J/3IrrquHHwUmA==", "db_user": "uxbEq/zz8DXVD53TOI1zmw==", "slot_name": "supabase_realtime_replication_slot", "db_password": "eGxa2ZKVreSn7eWieRQdp74vN25K+qFgdnxmDCKe4p20+C0410WXonzXTEj9CgYx", "publication": "supabase_realtime", "ssl_enforced": false, "poll_interval_ms": 100, "poll_max_changes": 100, "poll_max_record_bytes": 1048576}	realtime-dev	2025-10-21 01:10:43	2025-10-21 01:10:43
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: _realtime; Owner: supabase_admin
--

COPY _realtime.schema_migrations (version, inserted_at) FROM stdin;
20210706140551	2025-09-17 02:53:15
20220329161857	2025-09-17 02:53:15
20220410212326	2025-09-17 02:53:15
20220506102948	2025-09-17 02:53:15
20220527210857	2025-09-17 02:53:16
20220815211129	2025-09-17 02:53:16
20220815215024	2025-09-17 02:53:16
20220818141501	2025-09-17 02:53:16
20221018173709	2025-09-17 02:53:16
20221102172703	2025-09-17 02:53:16
20221223010058	2025-09-17 02:53:16
20230110180046	2025-09-17 02:53:16
20230810220907	2025-09-17 02:53:16
20230810220924	2025-09-17 02:53:16
20231024094642	2025-09-17 02:53:16
20240306114423	2025-09-17 02:53:16
20240418082835	2025-09-17 02:53:16
20240625211759	2025-09-17 02:53:16
20240704172020	2025-09-17 02:53:16
20240902173232	2025-09-17 02:53:16
20241106103258	2025-09-17 02:53:16
\.


--
-- Data for Name: tenants; Type: TABLE DATA; Schema: _realtime; Owner: supabase_admin
--

COPY _realtime.tenants (id, name, external_id, jwt_secret, max_concurrent_users, inserted_at, updated_at, max_events_per_second, postgres_cdc_default, max_bytes_per_second, max_channels_per_client, max_joins_per_second, suspend, jwt_jwks, notify_private_alpha, private_only) FROM stdin;
527152df-8513-4012-a744-bccda739d7c5	realtime-dev	realtime-dev	eGxa2ZKVreSn7eWieRQdp60i5H6KJLiST7splFU6MVHylMSAoQ2SjsTrTTQo/+bmYjQcO4hNnGTU+D1wtlXreA==	200	2025-10-21 01:10:43	2025-10-21 01:10:43	100	postgres_cdc_rls	100000	100	100	f	\N	f	f
\.


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
00000000-0000-0000-0000-000000000000	d84fa152-29e3-4508-92f3-ef9ac7789b6a	{"action":"user_signedup","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-01 05:36:28.014872+00	
00000000-0000-0000-0000-000000000000	25c5e426-a754-4894-ba74-1d230af0c4e2	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-01 05:36:28.025539+00	
00000000-0000-0000-0000-000000000000	918b9c99-79dd-43a2-b4be-0edf15d8a37b	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-01 05:39:55.653913+00	
00000000-0000-0000-0000-000000000000	923d542e-2745-4035-adf5-04ce62b9db2a	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-01 06:20:03.988068+00	
00000000-0000-0000-0000-000000000000	9ef733d0-e0b1-4875-9692-33ebcdf73d81	{"action":"user_signedup","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-01 06:30:30.766321+00	
00000000-0000-0000-0000-000000000000	a1667094-682f-46bb-87a1-49cc518361d3	{"action":"login","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-01 06:30:30.773836+00	
00000000-0000-0000-0000-000000000000	6a038e97-a74a-4ffa-9225-c23caab044c1	{"action":"login","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-01 06:30:33.485946+00	
00000000-0000-0000-0000-000000000000	13020e74-2cbf-4569-ae44-87744ffa1431	{"action":"login","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-01 06:32:57.574753+00	
00000000-0000-0000-0000-000000000000	a8511c3d-c1a7-42f5-9dd6-4a3c94968deb	{"action":"logout","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-01 06:34:59.64174+00	
00000000-0000-0000-0000-000000000000	207cac73-ccb6-4cce-aed6-6c4cbd04da25	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 06:36:26.958387+00	
00000000-0000-0000-0000-000000000000	a461f31b-c937-4cc9-8ff0-a8559f69cd4f	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 06:36:26.959592+00	
00000000-0000-0000-0000-000000000000	41389851-0537-4bf5-ba1e-f7fd2fc09ed5	{"action":"login","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-01 06:37:53.283521+00	
00000000-0000-0000-0000-000000000000	66778ea7-6993-4373-839c-e0f90699bb3a	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-01 07:35:32.480306+00	
00000000-0000-0000-0000-000000000000	71ddc19b-bac7-4229-ade5-4a67afda27c7	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 07:35:52.226543+00	
00000000-0000-0000-0000-000000000000	0aeb1569-adb2-4a01-82c8-ad17bfe02db2	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 07:35:52.227743+00	
00000000-0000-0000-0000-000000000000	51fa2014-13d8-4d56-a897-48fbc2d1eca9	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 08:35:21.263988+00	
00000000-0000-0000-0000-000000000000	ea7ea473-6d40-4b7e-a8c1-475f3015e299	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 08:35:21.266961+00	
00000000-0000-0000-0000-000000000000	8929d137-8de5-41d1-b5c0-a16d4447eefd	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 09:34:42.07353+00	
00000000-0000-0000-0000-000000000000	2620e6ee-5eac-4c7e-865d-43dd25efe367	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 09:34:42.074903+00	
00000000-0000-0000-0000-000000000000	b566f3cb-7848-4993-b03d-8248786a4a31	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 10:34:12.33697+00	
00000000-0000-0000-0000-000000000000	ded2874f-eb86-479a-a40c-27e6d90285f9	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 10:34:12.338239+00	
00000000-0000-0000-0000-000000000000	38d3205e-4cf5-406e-9a79-3f52fd0392d4	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 11:33:41.431052+00	
00000000-0000-0000-0000-000000000000	2e92dff3-45f8-4b73-b0bc-5d73a7469bb8	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 11:33:41.432303+00	
00000000-0000-0000-0000-000000000000	5265b93c-fc04-4d50-b4b0-f52885e72eb2	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 12:33:02.154009+00	
00000000-0000-0000-0000-000000000000	9849ecf3-13d7-475d-8e48-f05805f0eb79	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 12:33:02.155346+00	
00000000-0000-0000-0000-000000000000	2d3c8fdb-14f4-4434-9e41-d4c7ff6f6896	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 13:32:30.804086+00	
00000000-0000-0000-0000-000000000000	4fd494f0-e928-41e9-8a09-3f92d498c676	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 13:32:30.805173+00	
00000000-0000-0000-0000-000000000000	26a8b768-ece9-4d61-ac32-b90a38376aa9	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 14:31:50.873903+00	
00000000-0000-0000-0000-000000000000	22e7e764-bfc0-4290-b01f-853c11e3a36f	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 14:31:50.87542+00	
00000000-0000-0000-0000-000000000000	ce0b5bb3-0c75-4dd1-a74e-d06208ecaaf5	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 15:31:10.912298+00	
00000000-0000-0000-0000-000000000000	579bf886-0274-4857-908f-5b4fe5233308	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 15:31:10.913573+00	
00000000-0000-0000-0000-000000000000	8bdf57c9-4a0c-4e0a-9efc-64938cff7466	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 16:30:30.946095+00	
00000000-0000-0000-0000-000000000000	d8bb135c-4583-4d95-ae5c-477118e97646	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 16:30:30.947519+00	
00000000-0000-0000-0000-000000000000	3942b0dd-7fe3-469e-ada6-230684e1efb0	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 17:29:50.807466+00	
00000000-0000-0000-0000-000000000000	86380bd0-72a0-475a-b8f1-4c4b686b5156	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 17:29:50.808702+00	
00000000-0000-0000-0000-000000000000	df266b9e-5208-4053-af53-3bfc18d4142a	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 18:29:10.751806+00	
00000000-0000-0000-0000-000000000000	15d7f847-bb2e-414c-92d1-d9b2235859b2	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 18:29:10.752795+00	
00000000-0000-0000-0000-000000000000	db404128-fd36-4cf2-9930-3658d1b173ef	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 19:28:31.040468+00	
00000000-0000-0000-0000-000000000000	9bedc445-0890-4aa6-9930-c19d659daa0e	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 19:28:31.042793+00	
00000000-0000-0000-0000-000000000000	7426a2b7-0227-4bcb-a541-786fa8c29871	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 20:28:00.951304+00	
00000000-0000-0000-0000-000000000000	4aaa7abd-d37c-4b66-b141-4e5d35bd0e83	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 20:28:00.953611+00	
00000000-0000-0000-0000-000000000000	77c38598-e2e1-45a0-b76c-bb9e3dfcfdf5	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 21:27:20.629751+00	
00000000-0000-0000-0000-000000000000	e853e7de-6898-4aba-a19a-c523cb7957be	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 21:27:20.630839+00	
00000000-0000-0000-0000-000000000000	74d151b8-0a72-44ca-a856-56d1688c5ea5	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 22:26:40.470552+00	
00000000-0000-0000-0000-000000000000	cf51af23-bcce-4c8f-aa2c-c1e52809001d	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 22:26:40.472216+00	
00000000-0000-0000-0000-000000000000	6cb8c824-a0b4-4fbc-9d68-4b24fd06933b	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 23:26:00.591494+00	
00000000-0000-0000-0000-000000000000	b69ae1a1-d818-4aff-9888-0bfc9b10cb0b	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-01 23:26:00.593649+00	
00000000-0000-0000-0000-000000000000	a04b38e6-4a39-4b89-a783-f4cf05e89b10	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 00:25:21.264661+00	
00000000-0000-0000-0000-000000000000	0f4193d3-df42-44f0-a47b-9cd2cd2fed3b	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 00:25:21.266042+00	
00000000-0000-0000-0000-000000000000	1c93937b-b9ba-4b67-a7b2-0262593e2043	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 00:57:43.10389+00	
00000000-0000-0000-0000-000000000000	cda58fa6-8c3b-450e-bc6c-8ce0d081b266	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 01:25:19.323132+00	
00000000-0000-0000-0000-000000000000	94f22103-8394-4691-ab2e-3d242059bc1e	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 01:25:19.324257+00	
00000000-0000-0000-0000-000000000000	2205a66a-b183-4185-8946-12a544d2dc4d	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 01:48:50.803302+00	
00000000-0000-0000-0000-000000000000	671dd33f-55dd-4da8-9e21-d3cde96926e4	{"action":"logout","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-02 02:05:30.590844+00	
00000000-0000-0000-0000-000000000000	afb58391-6e13-470c-a40d-8a130d46ddcd	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 02:05:41.027018+00	
00000000-0000-0000-0000-000000000000	54dd38f1-1372-4e1b-bb67-ef5d9e01f077	{"action":"logout","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-02 02:23:45.830799+00	
00000000-0000-0000-0000-000000000000	04b24473-d07a-44ea-80b5-20204dc6229a	{"action":"user_signedup","actor_id":"3ab12806-3ba0-4073-a4da-346449ce5aec","actor_username":"test@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-02 02:24:01.895064+00	
00000000-0000-0000-0000-000000000000	2beed66b-be1e-499b-afec-fd722c963aa0	{"action":"login","actor_id":"3ab12806-3ba0-4073-a4da-346449ce5aec","actor_username":"test@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 02:24:01.904224+00	
00000000-0000-0000-0000-000000000000	e6395e07-bbc0-44cb-9d3e-3a97a23c3810	{"action":"login","actor_id":"3ab12806-3ba0-4073-a4da-346449ce5aec","actor_username":"test@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 02:24:07.039516+00	
00000000-0000-0000-0000-000000000000	1eba9928-6ff3-46a4-8047-23f9e093c3b0	{"action":"logout","actor_id":"3ab12806-3ba0-4073-a4da-346449ce5aec","actor_username":"test@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-02 02:24:10.995575+00	
00000000-0000-0000-0000-000000000000	7efec62b-6b92-496b-b658-b8fbc599b584	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 02:26:45.459414+00	
00000000-0000-0000-0000-000000000000	d4c53822-dd07-40ee-a739-06d709069783	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 03:26:06.474448+00	
00000000-0000-0000-0000-000000000000	1bcba61c-c980-4fb0-b50c-15ef3b407ae7	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 03:26:06.475377+00	
00000000-0000-0000-0000-000000000000	ca8f5c3a-043a-4701-ad86-30b8e42d66fe	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 03:55:52.098509+00	
00000000-0000-0000-0000-000000000000	5f56b207-d99f-4bc3-bcda-0553bebc38e3	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 04:43:19.165158+00	
00000000-0000-0000-0000-000000000000	bfd4f3a4-3040-483b-ac5e-64f154516e1a	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 05:08:47.591192+00	
00000000-0000-0000-0000-000000000000	ad534030-ebd6-4ddc-9324-6be6bcbe8707	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 05:14:17.947675+00	
00000000-0000-0000-0000-000000000000	c1bc5375-d1b8-4413-b0f3-76ed2adfa65b	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 05:17:03.860103+00	
00000000-0000-0000-0000-000000000000	1174e577-a14c-4c80-bb1d-bb4f6b0737ed	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 05:17:03.861656+00	
00000000-0000-0000-0000-000000000000	54aadd62-fe85-4fe8-85ce-f79ee49fa499	{"action":"logout","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-02 05:17:30.084585+00	
00000000-0000-0000-0000-000000000000	1fe16723-6898-4b7a-a85b-6c5882b54836	{"action":"login","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 05:17:42.934835+00	
00000000-0000-0000-0000-000000000000	fc1aac82-4f44-4121-91a6-5b0fc76f4493	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 05:23:09.832264+00	
00000000-0000-0000-0000-000000000000	c5c84f4e-ddd8-4d62-9258-4fae50f50b2e	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 05:23:09.836123+00	
00000000-0000-0000-0000-000000000000	802663a3-6361-41ed-a073-bda91760e43f	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 05:31:13.352848+00	
00000000-0000-0000-0000-000000000000	dc5397bd-7eff-4893-b8f1-8625769969b3	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 05:31:48.770729+00	
00000000-0000-0000-0000-000000000000	c5274549-c01e-4afd-b0be-913863947960	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 05:32:20.089624+00	
00000000-0000-0000-0000-000000000000	cbce39c7-5a49-4897-a237-c5aebf06d587	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 05:34:36.466941+00	
00000000-0000-0000-0000-000000000000	e56e4a78-3098-4ee9-b426-4fad996893ad	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 05:40:36.061531+00	
00000000-0000-0000-0000-000000000000	47b0e0f5-e0dd-46e8-98d0-a834199701ea	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 05:44:39.73214+00	
00000000-0000-0000-0000-000000000000	585478ad-5915-4058-9903-55786cc9fb5f	{"action":"logout","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-02 05:44:56.903143+00	
00000000-0000-0000-0000-000000000000	cd17a5bc-e1a6-4024-b106-35a6d1f384de	{"action":"user_signedup","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-02 05:45:11.711092+00	
00000000-0000-0000-0000-000000000000	8b3a0819-c1a5-47c0-b4d2-7977f13f8c9a	{"action":"login","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 05:45:11.717355+00	
00000000-0000-0000-0000-000000000000	bc690fa3-8fa1-44fd-ae94-fd8a27e3df67	{"action":"login","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 05:45:15.483689+00	
00000000-0000-0000-0000-000000000000	5e66f1e7-98e9-4aa9-b7d3-3ee9d93e9d07	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 06:17:57.444741+00	
00000000-0000-0000-0000-000000000000	557ad969-3a6d-4839-9a2f-f120f1de6865	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 06:17:57.446086+00	
00000000-0000-0000-0000-000000000000	38ee5c0d-0fd1-48db-bebc-610c7716ef85	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 07:55:14.110694+00	
00000000-0000-0000-0000-000000000000	803b7f70-581e-4828-8ba0-a1710d89b73a	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 07:55:14.117086+00	
00000000-0000-0000-0000-000000000000	870782ee-4399-4190-bb4f-e0b7b8d203d7	{"action":"logout","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-02 08:09:17.42548+00	
00000000-0000-0000-0000-000000000000	88957a5c-741c-465c-b7e1-ee05ae178dde	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 08:09:29.972581+00	
00000000-0000-0000-0000-000000000000	b9bc7dd0-c9b2-4122-9a2c-a1fa240ba2b3	{"action":"login","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 08:35:06.754705+00	
00000000-0000-0000-0000-000000000000	e246edbf-6398-4b45-9c3f-f0e04f59170c	{"action":"user_signedup","actor_id":"967e7680-75e4-4b14-a15d-8936c7e92bc7","actor_username":"a0987533182@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-02 08:37:38.920485+00	
00000000-0000-0000-0000-000000000000	daa5e67c-cd16-4584-96e2-8b559e51eed3	{"action":"login","actor_id":"967e7680-75e4-4b14-a15d-8936c7e92bc7","actor_username":"a0987533182@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-02 08:37:38.930424+00	
00000000-0000-0000-0000-000000000000	c4f576c6-01c5-4f03-8ef4-b4df94f5f847	{"action":"user_repeated_signup","actor_id":"967e7680-75e4-4b14-a15d-8936c7e92bc7","actor_username":"a0987533182@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-02 08:37:57.703317+00	
00000000-0000-0000-0000-000000000000	b0ce4579-af4c-497f-8f49-154d861c4ebd	{"action":"user_repeated_signup","actor_id":"967e7680-75e4-4b14-a15d-8936c7e92bc7","actor_username":"a0987533182@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-02 08:38:08.395633+00	
00000000-0000-0000-0000-000000000000	8637a35f-9f8d-4479-9990-70373efe4bd0	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 09:08:50.513069+00	
00000000-0000-0000-0000-000000000000	140a399c-3f05-4f7b-9ca4-3443315db873	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 09:08:50.514786+00	
00000000-0000-0000-0000-000000000000	01c08d30-7108-4c00-8802-fef985e07c65	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 10:08:19.412147+00	
00000000-0000-0000-0000-000000000000	a21b6011-8176-4210-a837-a9b71f3f690c	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 10:08:19.413352+00	
00000000-0000-0000-0000-000000000000	c013ae09-0e56-4c37-a894-b39334ac2cfa	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 11:07:40.028321+00	
00000000-0000-0000-0000-000000000000	d13a2729-15ed-4c22-b75e-986e802b8ebb	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 11:07:40.029805+00	
00000000-0000-0000-0000-000000000000	15d2466e-fc39-4476-ae98-a41943231944	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 12:07:09.819787+00	
00000000-0000-0000-0000-000000000000	d4f785fb-a101-4aca-94d5-98dbbeae1715	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 12:07:09.822068+00	
00000000-0000-0000-0000-000000000000	1ee15c71-0ba4-49fa-880b-dec1c98f3e61	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 13:06:28.815682+00	
00000000-0000-0000-0000-000000000000	6bb24f4d-f4e6-4122-87c1-3faf0d9df4c2	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 13:06:28.81712+00	
00000000-0000-0000-0000-000000000000	e7f602d8-0470-4d50-a912-ab80e1922877	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 14:05:48.687396+00	
00000000-0000-0000-0000-000000000000	bce3eef1-f688-4e82-891b-f87032a99391	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 14:05:48.689169+00	
00000000-0000-0000-0000-000000000000	54dc0f07-0ece-48a7-a667-11ac185fc7b9	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 15:05:08.722631+00	
00000000-0000-0000-0000-000000000000	baac316c-a466-4aa7-a275-51a905aab291	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 15:05:08.723829+00	
00000000-0000-0000-0000-000000000000	4c8df2cd-3d08-4449-a7c6-5007425cca59	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 16:04:28.69463+00	
00000000-0000-0000-0000-000000000000	5278517d-9ded-47ca-92f9-98004df1c1cc	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 16:04:28.69903+00	
00000000-0000-0000-0000-000000000000	264a5d53-fb26-4e3c-b819-3598604dd442	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 17:03:48.676534+00	
00000000-0000-0000-0000-000000000000	bd48be5e-1217-40f1-89c8-14ac9c96a11d	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 17:03:48.677567+00	
00000000-0000-0000-0000-000000000000	ac5a0e96-d573-4b4a-849a-00715ec83c02	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 18:03:08.695213+00	
00000000-0000-0000-0000-000000000000	7afa9cc5-f02c-42b6-963f-743dd4112a3c	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 18:03:08.696991+00	
00000000-0000-0000-0000-000000000000	5342cdc2-3205-489d-8723-585b4af981bc	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 19:02:28.7222+00	
00000000-0000-0000-0000-000000000000	2a5642c4-5c67-4c46-90a9-49f90953a8ed	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 19:02:28.723487+00	
00000000-0000-0000-0000-000000000000	22840b19-bd1e-4382-9b6e-7fac480442cc	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 20:01:48.737286+00	
00000000-0000-0000-0000-000000000000	bc845706-8313-4250-bf42-137b928799bb	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 20:01:48.738458+00	
00000000-0000-0000-0000-000000000000	c7f153a8-e7ee-406d-84a3-f61ece307db9	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 21:01:08.64343+00	
00000000-0000-0000-0000-000000000000	f3623439-3f0c-421f-888e-1b0261ec0ad1	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 21:01:08.644382+00	
00000000-0000-0000-0000-000000000000	160b3297-a050-4762-bb67-d80e4b234d9a	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 22:00:28.633456+00	
00000000-0000-0000-0000-000000000000	58c327af-5fcc-4b39-82e8-2758194f6913	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 22:00:28.636073+00	
00000000-0000-0000-0000-000000000000	98555da6-2b8b-4fb4-9d8f-840dc4dee961	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 22:59:48.488856+00	
00000000-0000-0000-0000-000000000000	fe18a06a-57c4-4bc2-95f0-5bdd6b3341e3	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 22:59:48.490174+00	
00000000-0000-0000-0000-000000000000	ceca2a8f-ed4c-4042-854d-d6d5711f74db	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 23:59:08.574972+00	
00000000-0000-0000-0000-000000000000	70e91824-e225-4b3d-ba3b-db4973207dd0	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-02 23:59:08.576038+00	
00000000-0000-0000-0000-000000000000	42d7b8f6-ae32-42a7-b149-83bafba3c622	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 00:58:29.098632+00	
00000000-0000-0000-0000-000000000000	d1b87af6-649b-4f71-91d5-8d21e753bdf5	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 00:58:29.099743+00	
00000000-0000-0000-0000-000000000000	9563474b-466f-4132-951f-ef2b0c600ecc	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 01:58:18.930782+00	
00000000-0000-0000-0000-000000000000	74d0c475-1f70-405b-9127-311cb1c43dd9	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 01:58:18.932377+00	
00000000-0000-0000-0000-000000000000	d96e8509-e3e2-4897-b338-2428a8015cca	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 02:58:18.573224+00	
00000000-0000-0000-0000-000000000000	26e71717-dd4a-4c75-a2bb-ca33d1abbb03	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 02:58:18.574696+00	
00000000-0000-0000-0000-000000000000	4f54ad24-fa83-46c7-9529-01c5ea69aa18	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 03:58:18.76169+00	
00000000-0000-0000-0000-000000000000	e3d42347-8cf7-46a0-a264-38f9c389f4f0	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 03:58:18.76321+00	
00000000-0000-0000-0000-000000000000	260c2b00-bb0b-4e5d-8fe1-a7b85fb07734	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 04:58:17.977933+00	
00000000-0000-0000-0000-000000000000	a9c22327-867b-464c-a44c-94c277e0d681	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 04:58:17.979119+00	
00000000-0000-0000-0000-000000000000	4c6b4761-38d8-49c4-bc16-1113e67c91e7	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 05:58:17.719251+00	
00000000-0000-0000-0000-000000000000	92f62d1c-05be-4da6-be56-9cda361018d8	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 05:58:17.720736+00	
00000000-0000-0000-0000-000000000000	e2b70b1d-a84a-49a7-9e85-2ac7902810bc	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 06:58:17.974645+00	
00000000-0000-0000-0000-000000000000	16eae5fa-7572-4833-a0ff-0b8e53e0c923	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 06:58:17.976035+00	
00000000-0000-0000-0000-000000000000	a215c921-27fe-442a-b9ef-616ab86ed5f5	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 07:58:18.700689+00	
00000000-0000-0000-0000-000000000000	2990a9df-1a38-4363-b570-142e83dbb392	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 07:58:18.702912+00	
00000000-0000-0000-0000-000000000000	5db214bb-8715-487e-89d8-30a0bea18eef	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 08:58:18.323603+00	
00000000-0000-0000-0000-000000000000	23e0efa1-22f9-49ec-81c4-81178cc1de3d	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 08:58:18.325543+00	
00000000-0000-0000-0000-000000000000	931840d2-2663-4ca7-9329-0b67949a6e50	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 09:58:18.618221+00	
00000000-0000-0000-0000-000000000000	c6e9cf77-52a2-45a9-b97f-a327dce5f18c	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 09:58:18.620212+00	
00000000-0000-0000-0000-000000000000	d921385e-5991-4d76-ac49-7fa7ea4c59d8	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 10:58:17.693418+00	
00000000-0000-0000-0000-000000000000	83efaf9c-c1fd-45e8-b8a0-bbb4b657742b	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 10:58:17.695018+00	
00000000-0000-0000-0000-000000000000	6a64c0ec-207c-44e1-9432-c8d875373c59	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 11:58:17.633488+00	
00000000-0000-0000-0000-000000000000	2ada4941-0a7b-49b9-842b-1dd8d2681975	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 11:58:17.634654+00	
00000000-0000-0000-0000-000000000000	1b2221f4-53f3-4eb7-89d8-d57e05b164eb	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 12:58:17.356114+00	
00000000-0000-0000-0000-000000000000	ecf8197a-6769-48b3-bc2a-b4293171406f	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 12:58:17.358133+00	
00000000-0000-0000-0000-000000000000	1660cf24-3141-4b8f-9ff0-4c36df7e6248	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 13:58:17.368225+00	
00000000-0000-0000-0000-000000000000	f1f20ba6-ed71-4111-a302-5f078f49dbad	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 13:58:17.369547+00	
00000000-0000-0000-0000-000000000000	02451daa-2663-4782-8080-366969db3ddb	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 14:58:17.297513+00	
00000000-0000-0000-0000-000000000000	42fa0bc9-f390-41f2-969e-461fac49ab8a	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 14:58:17.298883+00	
00000000-0000-0000-0000-000000000000	911f5aa8-8a9c-4534-ba12-16e0f8d88ad5	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 15:58:17.360818+00	
00000000-0000-0000-0000-000000000000	976b5c40-633b-4fed-989a-89680e651865	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 15:58:17.361926+00	
00000000-0000-0000-0000-000000000000	97efe662-74a4-4b15-9e92-767a23b519fc	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 16:58:17.361407+00	
00000000-0000-0000-0000-000000000000	0859e255-9ba4-4f70-aca5-e43daee8be2a	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 16:58:17.363679+00	
00000000-0000-0000-0000-000000000000	e84b4c42-02b0-472e-b2c4-1d5a1b840f18	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 17:58:17.310396+00	
00000000-0000-0000-0000-000000000000	2067e2e3-657e-4715-b714-158f77154a5d	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 17:58:17.317616+00	
00000000-0000-0000-0000-000000000000	da5ddd85-d570-4b44-aea2-e31d2a09a7e1	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 18:58:17.420954+00	
00000000-0000-0000-0000-000000000000	055e0252-17e6-462b-adde-b809615ff2b2	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 18:58:17.422123+00	
00000000-0000-0000-0000-000000000000	7f269212-79cb-43f2-91fe-cee890dc16d7	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 19:58:17.394216+00	
00000000-0000-0000-0000-000000000000	0bf6d053-78d9-40fb-9db1-33f81da32aa5	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 19:58:17.397577+00	
00000000-0000-0000-0000-000000000000	0bfe9561-7c27-4431-beb5-0167f4d9263d	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 20:58:17.04201+00	
00000000-0000-0000-0000-000000000000	9d441c00-b5a9-4fb5-ba06-dd05461bea03	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 20:58:17.043833+00	
00000000-0000-0000-0000-000000000000	d7f7f1c5-3c55-4466-8dba-572577979846	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 21:58:17.634101+00	
00000000-0000-0000-0000-000000000000	1ab63063-60b4-4b7c-8194-ecf7da296543	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 21:58:17.635698+00	
00000000-0000-0000-0000-000000000000	52074cf8-28a1-4c50-93dc-93aba383e446	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 22:58:17.1472+00	
00000000-0000-0000-0000-000000000000	01dbd8d4-3bd9-43ab-9535-7ab369baad95	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 22:58:17.148772+00	
00000000-0000-0000-0000-000000000000	a43d51f3-4cae-4503-88f5-1d08aaf50f2c	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 23:58:16.873628+00	
00000000-0000-0000-0000-000000000000	d9342c99-8186-4346-b4c6-2c7d681e8d7c	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-03 23:58:16.874971+00	
00000000-0000-0000-0000-000000000000	9d400b56-cc47-4d64-b102-821b2e0507c2	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 00:58:16.958205+00	
00000000-0000-0000-0000-000000000000	49ceea6a-fbce-49fa-a4ba-5bb6d52da793	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 00:58:16.959519+00	
00000000-0000-0000-0000-000000000000	e0d32315-f27e-4fbf-a84e-9f136166d1fd	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 01:58:17.592244+00	
00000000-0000-0000-0000-000000000000	aa3c0465-ee98-456d-b9e3-13ca8a3dab98	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 01:58:17.593449+00	
00000000-0000-0000-0000-000000000000	e4e4fb93-573a-4afa-a8c2-6c0ce4022e81	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 02:58:17.444585+00	
00000000-0000-0000-0000-000000000000	d20fcff8-86ab-41cd-86f8-0a2124be93f0	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 02:58:17.445815+00	
00000000-0000-0000-0000-000000000000	6673567c-b285-438c-9af5-7a75ef38ece2	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 03:58:17.744903+00	
00000000-0000-0000-0000-000000000000	468064a7-12e6-4d2d-a443-6f26d72ddb0b	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 03:58:17.745954+00	
00000000-0000-0000-0000-000000000000	dd0f7ed3-c8dd-497f-9157-dc4b65c94320	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 04:58:17.184409+00	
00000000-0000-0000-0000-000000000000	bb21fa81-89c5-4fe9-91f4-988aabf72062	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 04:58:17.185741+00	
00000000-0000-0000-0000-000000000000	32a9b8a5-1fed-46c5-b410-d262ad40e211	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 05:58:17.079512+00	
00000000-0000-0000-0000-000000000000	d9622bcf-0df0-484b-97b9-5dbee6279a99	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 05:58:17.080631+00	
00000000-0000-0000-0000-000000000000	f3ada60b-b08a-45db-8821-078acd209fb5	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 06:58:17.486044+00	
00000000-0000-0000-0000-000000000000	51850207-d9f7-4459-958d-782350724846	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 06:58:17.487208+00	
00000000-0000-0000-0000-000000000000	24f419eb-1cd2-481f-83d0-b5e42862dc64	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 07:58:16.988053+00	
00000000-0000-0000-0000-000000000000	d6347ff9-dece-44c5-b37a-f1a6f8dff2d8	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 07:58:16.99005+00	
00000000-0000-0000-0000-000000000000	e5e31c8c-e731-4a2c-9bf5-fb6333c39fab	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 08:58:16.900484+00	
00000000-0000-0000-0000-000000000000	9d3d3985-8c24-44f8-8594-3723f2a8b710	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 08:58:16.902715+00	
00000000-0000-0000-0000-000000000000	44217a9e-bd22-4f7d-8089-4075a0c04235	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 09:58:17.33712+00	
00000000-0000-0000-0000-000000000000	3a366c08-0e3f-4ba3-928a-e8ee27bc8664	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 09:58:17.338611+00	
00000000-0000-0000-0000-000000000000	0b7e7fa1-b685-43ac-9282-b199001631bd	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 10:58:16.702052+00	
00000000-0000-0000-0000-000000000000	29307735-f84f-4ec8-93dc-64df2dc2ce7f	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 10:58:16.704437+00	
00000000-0000-0000-0000-000000000000	33d97b1e-c8ff-4774-9649-7a8a985f03ae	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 11:58:16.397513+00	
00000000-0000-0000-0000-000000000000	cde21a76-032a-441e-938e-57b131896ba9	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 11:58:16.400187+00	
00000000-0000-0000-0000-000000000000	b43cd1ea-6923-482f-91df-ef3683727c4c	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 12:58:18.086318+00	
00000000-0000-0000-0000-000000000000	8e717548-efde-4a85-aa9c-46fac31c5b4a	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 12:58:18.088872+00	
00000000-0000-0000-0000-000000000000	962b99db-8a40-4c1b-815a-315c78ca7023	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 13:58:17.780781+00	
00000000-0000-0000-0000-000000000000	6891d92e-edbb-4af3-bdf9-6a6b441ab38a	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 13:58:17.782179+00	
00000000-0000-0000-0000-000000000000	0aafadd8-53b3-40d3-9524-e577ff3497fd	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 14:58:16.148609+00	
00000000-0000-0000-0000-000000000000	6712a2b6-fd18-4501-89f3-06fcd804a4ad	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 14:58:16.149926+00	
00000000-0000-0000-0000-000000000000	5d59bb3f-2d88-4585-ad23-f7a08bcdf914	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 15:58:16.195184+00	
00000000-0000-0000-0000-000000000000	f536b5e3-7e09-4792-ba79-54e1d8b9a769	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 15:58:16.196603+00	
00000000-0000-0000-0000-000000000000	52fa6e16-c147-4d98-82e4-7aa9289e80a5	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 16:58:16.259768+00	
00000000-0000-0000-0000-000000000000	d90861bf-7035-4eb8-b363-e1106b3d72c9	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 16:58:16.26206+00	
00000000-0000-0000-0000-000000000000	73258d9c-5daf-43c2-8fc8-c4afb7e6fb8c	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 17:58:16.123381+00	
00000000-0000-0000-0000-000000000000	33f1f182-1001-469b-b449-36774f43a7be	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 17:58:16.124247+00	
00000000-0000-0000-0000-000000000000	0a620f2a-ce20-41b0-9b59-53f358130c87	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 18:58:16.20494+00	
00000000-0000-0000-0000-000000000000	9b0a5256-b6db-4d1b-800c-06db9ace7d1b	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 18:58:16.206014+00	
00000000-0000-0000-0000-000000000000	1a54f8a7-868e-48be-bd49-e73e3a9d2670	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 19:58:16.273572+00	
00000000-0000-0000-0000-000000000000	aaa0e2e0-f491-4dcb-9640-c07d491ee156	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 19:58:16.275722+00	
00000000-0000-0000-0000-000000000000	bb8cdceb-bf8f-4d97-b16d-c5d349a0e6e7	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 20:58:16.098726+00	
00000000-0000-0000-0000-000000000000	ac246c59-8d13-4500-890f-4c070d865c7f	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 20:58:16.100588+00	
00000000-0000-0000-0000-000000000000	a245cc0c-9a5e-4f40-916e-1b137e09e9ab	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 21:58:16.317747+00	
00000000-0000-0000-0000-000000000000	5d077e06-3c40-40af-9275-81008fbba422	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 21:58:16.319958+00	
00000000-0000-0000-0000-000000000000	5457d03c-a075-41d1-8e64-33d54b99051a	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 22:58:16.258026+00	
00000000-0000-0000-0000-000000000000	e6381c0f-49af-488a-b4c5-7106b5e92495	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 22:58:16.259996+00	
00000000-0000-0000-0000-000000000000	e2d05f47-71be-4464-aaf0-72dac53a65ce	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 23:58:16.508205+00	
00000000-0000-0000-0000-000000000000	ed2cd2e5-82f3-4747-97e3-f5f7eb65e609	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-04 23:58:16.510129+00	
00000000-0000-0000-0000-000000000000	c584cb9e-9712-47e8-8a1f-aef8a4b155e3	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 00:58:16.19059+00	
00000000-0000-0000-0000-000000000000	0e48777e-bc3f-4c12-8215-46bf8fc908df	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 00:58:16.191877+00	
00000000-0000-0000-0000-000000000000	6ed1bf44-6135-44fe-ab76-7df634ba3cfb	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 01:58:15.99471+00	
00000000-0000-0000-0000-000000000000	c8ec029c-aed5-4578-8fe2-84bb88f3f8b6	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 01:58:15.996809+00	
00000000-0000-0000-0000-000000000000	6a67c10a-5fd1-4f0f-b9ea-d289632a7e14	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 02:58:16.433778+00	
00000000-0000-0000-0000-000000000000	57fe0fbb-e85d-412a-bfed-b1c457445eb5	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 02:58:16.435162+00	
00000000-0000-0000-0000-000000000000	ac4f7334-47c8-44fb-8a45-0f62ce15e5c1	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 03:58:16.015986+00	
00000000-0000-0000-0000-000000000000	43603d92-93f0-49e6-aaff-31aebc01759a	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 03:58:16.01734+00	
00000000-0000-0000-0000-000000000000	13f236ba-98e7-4a69-9c4a-1f031d03f6d6	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 04:58:15.806003+00	
00000000-0000-0000-0000-000000000000	173ba15b-81a3-410d-9d5f-530b2d92bc06	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 04:58:15.806906+00	
00000000-0000-0000-0000-000000000000	14bec530-0756-4dec-9604-3baedf324a19	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 05:58:16.091662+00	
00000000-0000-0000-0000-000000000000	4f391b07-38cc-4eb1-b542-fd7bc2016328	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 05:58:16.09295+00	
00000000-0000-0000-0000-000000000000	c55a9bbd-dbca-4b4d-a987-75f3fc3f6929	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 06:58:15.55629+00	
00000000-0000-0000-0000-000000000000	2e3a38f7-9712-4509-8ea8-e2baeaa4e7f8	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 06:58:15.557258+00	
00000000-0000-0000-0000-000000000000	903aef36-876c-4116-8e87-d3eea3702ed6	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 07:58:16.231824+00	
00000000-0000-0000-0000-000000000000	19629b88-ee5d-4a90-b667-204f08a798d4	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 07:58:16.234142+00	
00000000-0000-0000-0000-000000000000	7c5ff57c-167b-4b58-ae8d-f405f5bdb908	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 08:58:15.821141+00	
00000000-0000-0000-0000-000000000000	e9e8fd5a-6ac7-474f-ad0e-bcc10dff947d	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-05 08:58:15.824255+00	
00000000-0000-0000-0000-000000000000	3810de24-73ab-4d74-b48f-5645b8e762e4	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 00:29:21.255214+00	
00000000-0000-0000-0000-000000000000	cc6caee1-c889-4ddf-81ee-f7466a720893	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 00:29:21.274814+00	
00000000-0000-0000-0000-000000000000	ac776931-30b1-49c9-904c-f901fa37961c	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 01:28:51.019956+00	
00000000-0000-0000-0000-000000000000	c0f05424-7074-4dbd-9a2b-d5156bc27a62	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 01:28:51.022855+00	
00000000-0000-0000-0000-000000000000	bfd2bf41-85fe-42d0-a04a-825dc33639ec	{"action":"logout","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-07 02:13:50.096486+00	
00000000-0000-0000-0000-000000000000	d7b1f328-3d68-4cd7-95bf-11e93391f148	{"action":"login","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-07 02:14:01.012439+00	
00000000-0000-0000-0000-000000000000	90000bec-d7e4-497d-9c47-c60c2725b6ae	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 03:14:08.206806+00	
00000000-0000-0000-0000-000000000000	e62e4980-86f0-4c14-83a7-a7ef6e94c769	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 03:14:08.209128+00	
00000000-0000-0000-0000-000000000000	80f308ed-c71d-4bf7-bcd2-a702b9783201	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 04:14:07.554594+00	
00000000-0000-0000-0000-000000000000	b9fa9901-c05e-4542-9e51-d95deb7775fd	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 04:14:07.556806+00	
00000000-0000-0000-0000-000000000000	aef4a50a-8a36-48b3-be74-d163f8422abd	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 05:13:30.896479+00	
00000000-0000-0000-0000-000000000000	1208155b-3f94-42d8-9ee8-c9d70d72e3c1	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 05:13:30.898157+00	
00000000-0000-0000-0000-000000000000	e9a153bc-836e-4047-9c2f-ecf811ac9078	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 06:12:50.235478+00	
00000000-0000-0000-0000-000000000000	24a7ade5-7295-460c-a9bd-5c76ff63bc3d	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 06:12:50.278168+00	
00000000-0000-0000-0000-000000000000	14e2bc40-2a09-41c9-849f-e92be2477059	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 07:13:07.80504+00	
00000000-0000-0000-0000-000000000000	231b908c-bc02-4f33-98fc-337343d1531e	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 07:13:07.809802+00	
00000000-0000-0000-0000-000000000000	5f17c482-462a-46d8-9268-4262502b8da3	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 07:32:45.433459+00	
00000000-0000-0000-0000-000000000000	5836113d-6794-415e-9915-cfecf5710938	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 07:32:45.436434+00	
00000000-0000-0000-0000-000000000000	dde1dba5-f6df-475d-8f80-68ef6cb79d1b	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 07:33:30.987874+00	
00000000-0000-0000-0000-000000000000	c71b38f8-07f5-4ff0-9563-145cd1f41dcf	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 07:33:30.988945+00	
00000000-0000-0000-0000-000000000000	2a1f1df2-51c7-43c0-8aa0-e32300444755	{"action":"logout","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-07 07:36:00.188438+00	
00000000-0000-0000-0000-000000000000	acab6fcf-8a40-484f-9e08-0e925b8667c8	{"action":"login","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-07 07:36:13.264949+00	
00000000-0000-0000-0000-000000000000	f46f530b-5d5b-4f1c-a3c2-7b939bbaa93c	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 07:57:48.577812+00	
00000000-0000-0000-0000-000000000000	3271d963-b79d-4585-a414-3f090c230ef9	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 07:57:48.579453+00	
00000000-0000-0000-0000-000000000000	2bb516cd-7dbf-478a-8980-0072a97f2045	{"action":"logout","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-07 07:58:25.871485+00	
00000000-0000-0000-0000-000000000000	df2c69ab-b83c-4dbe-9ca0-91c18c3b24a0	{"action":"login","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-07 07:58:39.750145+00	
00000000-0000-0000-0000-000000000000	eab74ed6-5702-4d88-8060-e315efcf7f6b	{"action":"login","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-07 09:03:05.521399+00	
00000000-0000-0000-0000-000000000000	3d7f0df8-9e97-4cb1-8f52-474993441141	{"action":"user_signedup","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-07 09:08:34.216644+00	
00000000-0000-0000-0000-000000000000	71f35bd0-aeb8-47bd-907e-2fcfee94cbc8	{"action":"login","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-07 09:08:34.22726+00	
00000000-0000-0000-0000-000000000000	29b272d8-d110-455f-87eb-6493bada39fc	{"action":"login","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-07 09:08:41.398048+00	
00000000-0000-0000-0000-000000000000	3066e7f8-cd0c-4887-b224-aef8195203b8	{"action":"login","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-07 09:16:47.535515+00	
00000000-0000-0000-0000-000000000000	17663134-fc4e-4763-a84f-0a278bdf5802	{"action":"logout","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-07 09:29:35.579859+00	
00000000-0000-0000-0000-000000000000	b04037a4-582f-4a91-ba0c-041a6c12d775	{"action":"login","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-07 09:29:56.385745+00	
00000000-0000-0000-0000-000000000000	68b3ab74-8fa8-45d7-b130-e7a4190384b0	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 00:30:05.638907+00	
00000000-0000-0000-0000-000000000000	cd7182bf-2b77-44f1-859a-84b789e541bb	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 10:19:18.092206+00	
00000000-0000-0000-0000-000000000000	6d278fbe-0034-4d75-b95d-8685aca29a22	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 10:19:18.095138+00	
00000000-0000-0000-0000-000000000000	d91203ff-4b2a-40f8-9877-49f2d152ba96	{"action":"token_refreshed","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 10:19:23.012033+00	
00000000-0000-0000-0000-000000000000	ad1687cd-e8fd-4ae5-a0dc-29ff7944aa94	{"action":"token_revoked","actor_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","actor_username":"yunthomas006@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 10:19:23.015863+00	
00000000-0000-0000-0000-000000000000	3e7a6acf-6246-46e9-bc42-4233b7904887	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 10:30:06.096641+00	
00000000-0000-0000-0000-000000000000	5c7bf9ca-99cb-4015-92f3-08882df3fa46	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 10:30:06.097991+00	
00000000-0000-0000-0000-000000000000	81e8dd98-31ea-4034-bf9d-30a30e1cb2e7	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 11:30:06.35491+00	
00000000-0000-0000-0000-000000000000	a6b42292-2197-40db-bd3a-df6bcf1712d3	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 11:30:06.356463+00	
00000000-0000-0000-0000-000000000000	90989f4b-dc18-43c1-8bb3-cce71a2d3679	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 12:30:08.133519+00	
00000000-0000-0000-0000-000000000000	12d3641c-8b43-404c-8736-a054c1ab1c84	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 12:30:08.134742+00	
00000000-0000-0000-0000-000000000000	0805aa14-f1d2-4a5b-8001-ff50ea91916c	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 13:30:06.001256+00	
00000000-0000-0000-0000-000000000000	396ed964-e6c3-4ae9-b7e7-e27df6594aba	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 13:30:06.002532+00	
00000000-0000-0000-0000-000000000000	4b7dd2a8-a702-43a4-bfc8-d165bcf8f9c9	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 14:30:05.909009+00	
00000000-0000-0000-0000-000000000000	76e9e867-a08d-4246-9d2f-04535bfe21c2	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 14:30:05.910763+00	
00000000-0000-0000-0000-000000000000	845ccba8-737c-4010-a718-1750673abd4a	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 15:30:05.900122+00	
00000000-0000-0000-0000-000000000000	a848f65a-508b-481f-bca1-36dbc1f006b3	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 15:30:05.902011+00	
00000000-0000-0000-0000-000000000000	482eaf84-8286-4e5c-abb7-eb777e939af8	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 16:30:05.881247+00	
00000000-0000-0000-0000-000000000000	4f96d8dc-1c72-4362-b1bc-5d6a8687b3ce	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 16:30:05.882214+00	
00000000-0000-0000-0000-000000000000	dedc0817-bc15-454a-8a0a-4e9de73ffd42	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 17:30:05.887322+00	
00000000-0000-0000-0000-000000000000	dcfd72b8-3378-4a96-86a3-9a687ddccc22	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 17:30:05.888458+00	
00000000-0000-0000-0000-000000000000	b51387e3-4ce7-4c62-9ad1-5cf8cf072f5a	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 18:30:05.989554+00	
00000000-0000-0000-0000-000000000000	03a831ef-c98f-48d5-9e35-3797a64530b0	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 18:30:05.990726+00	
00000000-0000-0000-0000-000000000000	4ee22f7d-ff2f-4490-80bd-0ac095f25014	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 19:30:05.871075+00	
00000000-0000-0000-0000-000000000000	fff1e4d1-f36a-42d7-ba54-778d97767226	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 19:30:05.872946+00	
00000000-0000-0000-0000-000000000000	ff054c58-9e70-4b9a-9a2e-6803f3373ca7	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 20:30:06.094228+00	
00000000-0000-0000-0000-000000000000	cd096f09-cc67-4456-8dd5-10fac4653ed7	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 20:30:06.095746+00	
00000000-0000-0000-0000-000000000000	35a3023f-90b8-49e5-9583-44d095fe6dd6	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 21:30:05.873368+00	
00000000-0000-0000-0000-000000000000	bc1ac527-c3fe-4277-aea2-df8793ce4483	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 21:30:05.877172+00	
00000000-0000-0000-0000-000000000000	91d1856f-4e6a-4beb-9b2e-a6c4e2b3360b	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 22:30:06.121293+00	
00000000-0000-0000-0000-000000000000	d3b02f3e-76a4-4102-b390-8a2773a83b17	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 22:30:06.122444+00	
00000000-0000-0000-0000-000000000000	463b2a5d-501b-4455-90a6-9a3171f4cb80	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 23:30:05.992669+00	
00000000-0000-0000-0000-000000000000	d9a6e23e-a216-4359-b904-12ce6693bd36	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-07 23:30:05.993944+00	
00000000-0000-0000-0000-000000000000	f4f483c8-c64b-47f9-b2ac-fc3f2d45f853	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 00:30:05.641971+00	
00000000-0000-0000-0000-000000000000	db12ec4e-5c52-4dec-ac80-fe6dd12b9bdc	{"action":"token_refreshed","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 00:58:06.063741+00	
00000000-0000-0000-0000-000000000000	2c33e324-52b6-4219-86bb-703955f21168	{"action":"token_revoked","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 00:58:06.065041+00	
00000000-0000-0000-0000-000000000000	33fe1c78-8af4-42d9-842e-784d667ddcf0	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 01:30:05.501678+00	
00000000-0000-0000-0000-000000000000	f1b0ee86-e78c-432e-acd8-520f19ee4d3d	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 01:30:05.50299+00	
00000000-0000-0000-0000-000000000000	85f9d4be-57fb-43b3-9c6b-734eeda8ee20	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 01:46:41.460232+00	
00000000-0000-0000-0000-000000000000	df76093f-1cad-4769-ae89-ff65a8b95fb8	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 01:46:41.461577+00	
00000000-0000-0000-0000-000000000000	568d7c91-4481-46ad-9387-c6c75a43050a	{"action":"token_refreshed","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 01:57:40.284464+00	
00000000-0000-0000-0000-000000000000	9c1cfce5-bb0e-44af-9f89-7d2b8cc7aa20	{"action":"token_revoked","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 01:57:40.286283+00	
00000000-0000-0000-0000-000000000000	dfa172ff-3cc4-48cf-9100-8733dd7e6fed	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"test@gmail.com","user_id":"3ab12806-3ba0-4073-a4da-346449ce5aec","user_phone":""}}	2025-10-08 02:38:06.065555+00	
00000000-0000-0000-0000-000000000000	d1c2973f-a445-4f97-993f-add6e9ea16c2	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 02:55:29.140553+00	
00000000-0000-0000-0000-000000000000	dd20da92-9fd1-4678-93a5-99632e97278e	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 02:55:29.145304+00	
00000000-0000-0000-0000-000000000000	aade55e6-74fc-4c22-816e-0eff97abb847	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 03:05:13.711123+00	
00000000-0000-0000-0000-000000000000	55cc04d3-3f63-46b1-bcc0-82647e9f7d16	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 03:05:13.714429+00	
00000000-0000-0000-0000-000000000000	3bea48c6-6719-4050-adf9-95b5262bcafc	{"action":"user_signedup","actor_id":"8b37894d-57e6-4c75-aa1c-82329839a080","actor_username":"my@coselig.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-08 03:21:09.338354+00	
00000000-0000-0000-0000-000000000000	a1931950-d15f-4ef8-95ff-782cc5e03884	{"action":"login","actor_id":"8b37894d-57e6-4c75-aa1c-82329839a080","actor_username":"my@coselig.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-08 03:21:09.346202+00	
00000000-0000-0000-0000-000000000000	3885890e-7af0-41c9-a794-8a58849c73f8	{"action":"user_repeated_signup","actor_id":"8b37894d-57e6-4c75-aa1c-82329839a080","actor_username":"my@coselig.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-10-08 03:21:12.714464+00	
00000000-0000-0000-0000-000000000000	603d587c-43c4-4abb-9fb1-18012aadfaa7	{"action":"login","actor_id":"8b37894d-57e6-4c75-aa1c-82329839a080","actor_username":"my@coselig.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-08 03:21:24.534488+00	
00000000-0000-0000-0000-000000000000	3b0653c4-8f6b-488d-9a64-02604e925fd6	{"action":"logout","actor_id":"8b37894d-57e6-4c75-aa1c-82329839a080","actor_username":"my@coselig.com","actor_via_sso":false,"log_type":"account"}	2025-10-08 03:23:22.417531+00	
00000000-0000-0000-0000-000000000000	94348907-d2c6-411c-b12f-371355005dde	{"action":"user_signedup","actor_id":"4176723e-66cd-4654-915d-d9ed009be926","actor_username":"cyunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-08 03:23:26.221135+00	
00000000-0000-0000-0000-000000000000	cfe7e8cc-e674-4a0b-ad56-6f3cdf7f05a2	{"action":"login","actor_id":"4176723e-66cd-4654-915d-d9ed009be926","actor_username":"cyunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-08 03:23:26.227415+00	
00000000-0000-0000-0000-000000000000	95f4e398-94ca-49a9-a8c4-442ec318866f	{"action":"login","actor_id":"8b37894d-57e6-4c75-aa1c-82329839a080","actor_username":"my@coselig.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-08 03:23:53.762744+00	
00000000-0000-0000-0000-000000000000	f89fac27-3e96-4cae-8f3f-4b84f15c3f00	{"action":"login","actor_id":"4176723e-66cd-4654-915d-d9ed009be926","actor_username":"cyunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-08 03:23:57.684369+00	
00000000-0000-0000-0000-000000000000	4ca79d0b-5059-430d-8e72-31a9e3e802a6	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 03:55:05.493138+00	
00000000-0000-0000-0000-000000000000	a0bb578b-faf6-4ff2-8e1c-263ceaa3d889	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 03:55:05.494741+00	
00000000-0000-0000-0000-000000000000	810c5d58-af3b-496a-b23d-5e86033f9e7b	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"yunthomas006@gmail.com","user_id":"98568fd9-dd57-4f17-9a61-76a6951f1fac","user_phone":""}}	2025-10-08 04:43:51.473449+00	
00000000-0000-0000-0000-000000000000	14510b9a-19a1-4a22-9161-d8aa904ad66f	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 04:45:11.181012+00	
00000000-0000-0000-0000-000000000000	ed0f5fbe-1b46-4b92-927d-5dbe199ffc6c	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 04:45:11.184094+00	
00000000-0000-0000-0000-000000000000	92bceffc-8671-4c3c-94f3-c87b310e71d6	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 04:45:13.485041+00	
00000000-0000-0000-0000-000000000000	977e3b60-2d2c-4b81-bc64-cc3f52b75aaa	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 04:54:28.440086+00	
00000000-0000-0000-0000-000000000000	d00fe33a-84fc-4bf3-920f-e9cd78b49f7e	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 04:54:28.44258+00	
00000000-0000-0000-0000-000000000000	05388823-6134-4d42-8ac6-cd34412b248d	{"action":"token_refreshed","actor_id":"4176723e-66cd-4654-915d-d9ed009be926","actor_username":"cyunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 04:57:10.040402+00	
00000000-0000-0000-0000-000000000000	5c98ecc4-9d6a-4f13-a25b-b7a3d97cd15a	{"action":"token_revoked","actor_id":"4176723e-66cd-4654-915d-d9ed009be926","actor_username":"cyunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 04:57:10.041638+00	
00000000-0000-0000-0000-000000000000	3f3eae3b-9c59-424f-b585-d2184e95998b	{"action":"logout","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-08 05:03:27.279379+00	
00000000-0000-0000-0000-000000000000	925d8bbc-14de-44fe-91c5-5f7634b5587d	{"action":"login","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-08 05:03:35.446104+00	
00000000-0000-0000-0000-000000000000	e22dc1bd-ec0d-434b-9fa4-2c9f0ce2391e	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 06:03:00.543217+00	
00000000-0000-0000-0000-000000000000	3bd4fe8e-f0f9-478c-a57d-dc8bb0e32e81	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 06:03:00.55114+00	
00000000-0000-0000-0000-000000000000	9f777c18-af06-456c-822e-97045037a148	{"action":"token_refreshed","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 06:06:42.654183+00	
00000000-0000-0000-0000-000000000000	031906e1-acd7-4552-ac44-cbc2af8ef78e	{"action":"token_revoked","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 06:06:42.655732+00	
00000000-0000-0000-0000-000000000000	b4d487cd-e2f7-42f5-8c44-55861a1d30c4	{"action":"user_signedup","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-08 06:31:54.254974+00	
00000000-0000-0000-0000-000000000000	f745b73f-ed68-4fb0-ade8-b2992939d6ca	{"action":"login","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-08 06:31:54.262132+00	
00000000-0000-0000-0000-000000000000	ab31f788-b77e-4ab6-b2b8-70a4adf5577f	{"action":"login","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-08 06:31:58.402955+00	
00000000-0000-0000-0000-000000000000	7f8fcd9e-0672-4146-930f-20cdc9962c2b	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 07:02:24.918766+00	
00000000-0000-0000-0000-000000000000	669a6942-f397-4e91-a5ce-28ea6dcd7741	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 07:02:24.920848+00	
00000000-0000-0000-0000-000000000000	4b3069d4-e81c-4d7c-abb4-2649d7a3a029	{"action":"token_refreshed","actor_id":"4176723e-66cd-4654-915d-d9ed009be926","actor_username":"cyunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 07:02:46.819336+00	
00000000-0000-0000-0000-000000000000	03dba868-3399-4468-bbcf-782b54a6ed0a	{"action":"token_revoked","actor_id":"4176723e-66cd-4654-915d-d9ed009be926","actor_username":"cyunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 07:02:46.820976+00	
00000000-0000-0000-0000-000000000000	d746b5a1-01e5-4cd6-8a7e-6e759fe97341	{"action":"logout","actor_id":"4176723e-66cd-4654-915d-d9ed009be926","actor_username":"cyunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-08 07:03:14.085767+00	
00000000-0000-0000-0000-000000000000	1f094604-c243-4ed7-aa65-111f7594d220	{"action":"login","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-08 07:04:15.362004+00	
00000000-0000-0000-0000-000000000000	9f2fb7b3-85d1-4e09-aa3a-4f8e3bfdc89b	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"cyunyunyam108010@gmail.com","user_id":"4176723e-66cd-4654-915d-d9ed009be926","user_phone":""}}	2025-10-08 07:04:35.263067+00	
00000000-0000-0000-0000-000000000000	bcdc364b-0f95-430a-be15-207d6496e7eb	{"action":"logout","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-08 07:04:44.389918+00	
00000000-0000-0000-0000-000000000000	8f96052a-4345-4d97-98f3-9ae1c94dda6e	{"action":"token_refreshed","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 07:06:31.756046+00	
00000000-0000-0000-0000-000000000000	ab15f9ba-d291-43ea-9aab-89f640fc156f	{"action":"token_revoked","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 07:06:31.757311+00	
00000000-0000-0000-0000-000000000000	6ef184b5-9b1e-4d79-914e-b3c172becd5d	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 07:32:06.130509+00	
00000000-0000-0000-0000-000000000000	a2c961c3-8951-4ba4-8d27-a02befdbe1b2	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 07:32:06.173603+00	
00000000-0000-0000-0000-000000000000	20a9eb02-f37f-40e9-906a-21c72145d3b3	{"action":"logout","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-08 07:49:24.281667+00	
00000000-0000-0000-0000-000000000000	7a609aab-96ba-436c-8cc3-abe12c825a99	{"action":"login","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-08 07:49:32.580513+00	
00000000-0000-0000-0000-000000000000	e5f0e734-9c45-4a94-8753-51ffd1d55a13	{"action":"logout","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-08 08:09:47.9337+00	
00000000-0000-0000-0000-000000000000	3697b812-8220-435b-936e-e285fa9bd03f	{"action":"login","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-08 08:10:02.033408+00	
00000000-0000-0000-0000-000000000000	c41f3e27-22d6-4613-88d8-ffcc0678c19c	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 08:50:55.724615+00	
00000000-0000-0000-0000-000000000000	119b5c08-dd48-4328-b20e-4108c19ddafa	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 08:50:55.727521+00	
00000000-0000-0000-0000-000000000000	fb6d96cf-00ac-4fd7-9063-77e999b5f383	{"action":"token_refreshed","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 09:00:46.796597+00	
00000000-0000-0000-0000-000000000000	e116416f-f442-4758-a546-2baa7491c4dd	{"action":"token_revoked","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 09:00:46.799805+00	
00000000-0000-0000-0000-000000000000	e3c087a5-7eb7-460e-bebf-f61f4427a972	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 09:09:33.819211+00	
00000000-0000-0000-0000-000000000000	6b3a8e24-fb34-4bce-a5fc-a3138c8c6d11	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 09:09:33.821113+00	
00000000-0000-0000-0000-000000000000	5f511b8d-780f-4a49-8e16-6cacb2076dc0	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 10:09:06.359401+00	
00000000-0000-0000-0000-000000000000	12de1464-230c-4edf-9373-67647f9b668a	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 10:09:06.361079+00	
00000000-0000-0000-0000-000000000000	5186e2d2-5873-4e09-adfa-c43d266eb72f	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 11:09:06.322878+00	
00000000-0000-0000-0000-000000000000	59a0fdde-1a84-4755-80ea-3864fe5acab8	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 11:09:06.324824+00	
00000000-0000-0000-0000-000000000000	928a5cc4-a6ad-4c27-8503-0bf772510168	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 11:26:36.997821+00	
00000000-0000-0000-0000-000000000000	7e72b2a2-6f27-4ced-8db2-c767e1513f95	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 11:26:37.000836+00	
00000000-0000-0000-0000-000000000000	841baf99-347c-42fb-bf14-b6f001abeebf	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 12:09:05.680917+00	
00000000-0000-0000-0000-000000000000	5f5515e3-cd57-43e7-8437-760e8653160f	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 12:09:05.683684+00	
00000000-0000-0000-0000-000000000000	204ba22b-9598-493b-92af-5904c3394d73	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 13:09:05.419239+00	
00000000-0000-0000-0000-000000000000	687eba24-8f2c-4d62-8a9b-3f59c551dad1	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 13:09:05.420649+00	
00000000-0000-0000-0000-000000000000	55fd5524-9f39-4213-bf35-0738463f2be7	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 14:09:04.811702+00	
00000000-0000-0000-0000-000000000000	d0152fcf-a8d4-4877-bf3d-0a3cca03ac37	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 14:09:04.812799+00	
00000000-0000-0000-0000-000000000000	74fa3328-159b-42ba-b6f6-cbd0aba618b8	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 14:11:28.010955+00	
00000000-0000-0000-0000-000000000000	970a274c-b3e7-4142-b401-842d102459c1	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 14:11:28.012074+00	
00000000-0000-0000-0000-000000000000	82c22bb3-cecf-43ba-846a-dd244b6f3b67	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 15:09:04.803668+00	
00000000-0000-0000-0000-000000000000	f3d0af45-49e2-4cfa-b27a-8907cd0b075a	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 15:09:04.804903+00	
00000000-0000-0000-0000-000000000000	e164b4c9-a53c-4a5c-92f3-4a9a630e4dcf	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 16:09:04.907189+00	
00000000-0000-0000-0000-000000000000	a1c0b106-4158-4ce4-b6de-63d020a903e2	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 16:09:04.908532+00	
00000000-0000-0000-0000-000000000000	9655fa0c-a5e3-45b7-a826-9c5b4d03c66e	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 17:09:04.762478+00	
00000000-0000-0000-0000-000000000000	0ca601c9-e91d-4b99-b475-ebde64a30df6	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 17:09:04.763856+00	
00000000-0000-0000-0000-000000000000	a0d9de08-6d23-4e05-b02a-610c3ac5eac0	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 18:09:04.872381+00	
00000000-0000-0000-0000-000000000000	49390247-d560-4fc0-a250-ffbdd2df130d	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 18:09:04.874472+00	
00000000-0000-0000-0000-000000000000	d150779d-7d2d-472d-80fc-4c3caacb4677	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 19:09:04.996191+00	
00000000-0000-0000-0000-000000000000	bbab3c98-54cc-4a70-9cf1-f854a37d3d27	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 19:09:04.998515+00	
00000000-0000-0000-0000-000000000000	382915c6-b90c-4bef-b37c-9c8937c6b59d	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 20:09:04.729164+00	
00000000-0000-0000-0000-000000000000	3b807abd-382f-4ef2-a4ae-f8398469be2d	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 20:09:04.730318+00	
00000000-0000-0000-0000-000000000000	d5c8b312-c8b2-41fa-8ea4-0fed56b98c8d	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 21:09:04.870579+00	
00000000-0000-0000-0000-000000000000	5892cbb3-96f4-450f-b47b-539b0bc50a71	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 21:09:04.873249+00	
00000000-0000-0000-0000-000000000000	dc73e53c-dceb-4f71-a0ea-6f5a3e028649	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 22:09:04.726644+00	
00000000-0000-0000-0000-000000000000	8b2387fb-50c0-41b7-9621-8a4d335c2b39	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 22:09:04.733302+00	
00000000-0000-0000-0000-000000000000	d7efe67e-fb2e-4cdb-8898-0ff4f80474ac	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 23:09:04.87771+00	
00000000-0000-0000-0000-000000000000	379ea222-bd2a-45ed-9a34-8a3951d42f6f	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-08 23:09:04.879311+00	
00000000-0000-0000-0000-000000000000	b680aa2c-b5e8-4199-935c-210fc9e911ba	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 00:09:04.517963+00	
00000000-0000-0000-0000-000000000000	9f0c2825-dd13-40be-b578-234088692943	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 00:09:04.519401+00	
00000000-0000-0000-0000-000000000000	6b2b4b10-6df5-473b-b6fa-cf7f6a580181	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 00:30:54.78897+00	
00000000-0000-0000-0000-000000000000	ea3f0c67-5820-42b3-8cea-d5754b42a381	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 00:30:54.790335+00	
00000000-0000-0000-0000-000000000000	3b7098d5-37b8-428e-ac0c-2ae0bed4df01	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 00:31:18.928796+00	
00000000-0000-0000-0000-000000000000	14df1bd9-265f-4144-bd90-c2ff867786cd	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 00:31:18.929977+00	
00000000-0000-0000-0000-000000000000	919cc86c-79c9-412a-9d97-b7aad040993a	{"action":"token_refreshed","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 00:35:02.602637+00	
00000000-0000-0000-0000-000000000000	9f7d044e-99ee-46a8-b82e-d5e4c2aa1000	{"action":"token_revoked","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 00:35:02.603827+00	
00000000-0000-0000-0000-000000000000	9bd152d9-0d60-43c2-af81-e2c60d9ead95	{"action":"token_refreshed","actor_id":"8b37894d-57e6-4c75-aa1c-82329839a080","actor_username":"my@coselig.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 00:36:01.052691+00	
00000000-0000-0000-0000-000000000000	de9dab24-1b13-4e57-8e6e-2616d48132b9	{"action":"token_revoked","actor_id":"8b37894d-57e6-4c75-aa1c-82329839a080","actor_username":"my@coselig.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 00:36:01.056542+00	
00000000-0000-0000-0000-000000000000	bc5f2c74-9835-42dc-a80e-b298122fd91a	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 01:09:05.220789+00	
00000000-0000-0000-0000-000000000000	c4172a5e-9f47-412e-b142-aa0d8d474e8d	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 01:09:05.221794+00	
00000000-0000-0000-0000-000000000000	b12c0464-3792-4d2f-8f83-d63cee069355	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 01:30:20.712095+00	
00000000-0000-0000-0000-000000000000	b44339ff-e1be-4f05-8337-ac67b48a3d09	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 01:30:20.713421+00	
00000000-0000-0000-0000-000000000000	494b71a8-4665-4d57-b3e1-66a1602fce2e	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 02:08:33.763941+00	
00000000-0000-0000-0000-000000000000	d6dcd6bb-1a3f-4c49-bf44-2d54273d6b74	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 02:08:33.765133+00	
00000000-0000-0000-0000-000000000000	e2c14499-7d7e-4ad3-a264-f4c8522cf930	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 02:30:21.466715+00	
00000000-0000-0000-0000-000000000000	a33d12ff-4980-4b8f-b866-9f0aee4e23e9	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 02:30:21.467912+00	
00000000-0000-0000-0000-000000000000	7165eb1d-8247-4b4f-a02a-49451a858479	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 03:07:55.173686+00	
00000000-0000-0000-0000-000000000000	7ebcb77a-4dd1-4c6a-acc1-6567e3056de8	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 03:07:55.17518+00	
00000000-0000-0000-0000-000000000000	3ead97ec-dc2e-49b1-be6a-5b0af1d06e60	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 03:30:21.321793+00	
00000000-0000-0000-0000-000000000000	750c2012-ba8e-4661-9d4a-a6fe7fa101ba	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 03:30:21.323018+00	
00000000-0000-0000-0000-000000000000	6d28979b-8433-49c9-b383-fa7830f61afb	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 04:08:04.793763+00	
00000000-0000-0000-0000-000000000000	1b3e0933-6e4e-4816-915a-da57b32a8672	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 04:08:04.796454+00	
00000000-0000-0000-0000-000000000000	7032957d-d98e-4d9c-ac05-4b11e873c34b	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 04:30:22.091367+00	
00000000-0000-0000-0000-000000000000	9c5fcbb7-5c75-4c89-b6ef-d447a0add751	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 04:30:22.094116+00	
00000000-0000-0000-0000-000000000000	4f978df3-6557-43ca-8ce0-5f42ae539dc6	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 05:08:05.336784+00	
00000000-0000-0000-0000-000000000000	5b74ab68-e637-40a9-bf33-95b0f9ae3c4e	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 05:08:05.338093+00	
00000000-0000-0000-0000-000000000000	59c298b2-b5b4-4250-bb8f-830d6d4416a3	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 05:30:20.488974+00	
00000000-0000-0000-0000-000000000000	9596b850-a862-4a14-bff4-da71b7e8a51f	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 05:30:20.491204+00	
00000000-0000-0000-0000-000000000000	2fcb5846-115f-4d56-bb7f-27580a62394c	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 06:07:31.528417+00	
00000000-0000-0000-0000-000000000000	886fd873-d03c-4e65-8111-3a3c976c62c5	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 06:07:31.531698+00	
00000000-0000-0000-0000-000000000000	47e1c1f0-5324-4d61-936e-54f7ea8141dd	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 06:30:21.236387+00	
00000000-0000-0000-0000-000000000000	77f553fd-2ccf-4321-bb1e-73c9d35c4e38	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 06:30:21.238491+00	
00000000-0000-0000-0000-000000000000	7e7c017c-8cf6-4237-906a-d902aa7c06ff	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 07:07:04.353834+00	
00000000-0000-0000-0000-000000000000	b84d2e34-4673-47e3-83f0-4b80f5d8cbfe	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 07:07:04.359974+00	
00000000-0000-0000-0000-000000000000	0ca1b120-c1b7-48b7-b444-593398d6acb0	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 07:30:21.739004+00	
00000000-0000-0000-0000-000000000000	f08c1e00-2841-48f3-ba78-ae488aa8d990	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 07:30:21.740691+00	
00000000-0000-0000-0000-000000000000	c7d74c67-7cef-470b-b129-69cc2ec73291	{"action":"logout","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-09 07:53:57.525297+00	
00000000-0000-0000-0000-000000000000	a7279184-7b33-47aa-8b25-c4b9c5fe56ed	{"action":"login","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-09 07:54:07.744891+00	
00000000-0000-0000-0000-000000000000	3361d48e-e589-41a2-862b-9d6af1a6c50b	{"action":"logout","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-09 07:56:37.792491+00	
00000000-0000-0000-0000-000000000000	b73b49e1-f943-40c7-a156-e96f619ba0bd	{"action":"login","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-09 07:56:46.303001+00	
00000000-0000-0000-0000-000000000000	3c817575-8017-4364-adee-1285d21350d6	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 08:30:21.818957+00	
00000000-0000-0000-0000-000000000000	edd51a6d-42e4-4e19-8f34-5e645f334063	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 08:30:21.821291+00	
00000000-0000-0000-0000-000000000000	735dd623-bc86-40d0-9fa4-c2c0efa4ee8e	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 08:56:13.953677+00	
00000000-0000-0000-0000-000000000000	4d105369-7b96-4db0-9bbe-4ed6f9397f67	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 08:56:13.95542+00	
00000000-0000-0000-0000-000000000000	c7f226de-b9f5-4b34-b4c4-340fa447c9ea	{"action":"token_refreshed","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 09:00:20.232313+00	
00000000-0000-0000-0000-000000000000	42738f0e-61d2-428e-901c-848752d74065	{"action":"token_revoked","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 09:00:20.233577+00	
00000000-0000-0000-0000-000000000000	efbbcb2f-f8a9-442e-b605-4c89c681dfe1	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 09:30:21.327736+00	
00000000-0000-0000-0000-000000000000	1d522d28-80dc-49e1-b0ab-24e7bf6326fd	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 09:30:21.329164+00	
00000000-0000-0000-0000-000000000000	54418ec1-f588-40f0-8a44-f14436e52b8a	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 09:56:04.859197+00	
00000000-0000-0000-0000-000000000000	a65a1a7e-788d-486e-99ea-52218b9e5e57	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 09:56:04.860519+00	
00000000-0000-0000-0000-000000000000	893d5e0b-6e86-4f10-b1b1-ac136f2b908c	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 10:56:04.277348+00	
00000000-0000-0000-0000-000000000000	60818e3c-b852-4269-9c54-c49b9f8674c3	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 10:56:04.279901+00	
00000000-0000-0000-0000-000000000000	b8fb41f6-e4ed-4d66-85e0-59f4ec2efb8d	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 11:56:05.48929+00	
00000000-0000-0000-0000-000000000000	387ca876-36bf-4c6b-a995-9c311722a37e	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 11:56:05.49086+00	
00000000-0000-0000-0000-000000000000	ceca7fbf-a568-4d11-82c7-cc04263f7cc1	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 12:56:07.196251+00	
00000000-0000-0000-0000-000000000000	ef7b2ece-5e0e-45ad-b4a8-3ba205363867	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 12:56:07.197267+00	
00000000-0000-0000-0000-000000000000	3a4591e8-297d-49e1-a79e-610dca433ccc	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 13:56:03.710108+00	
00000000-0000-0000-0000-000000000000	8b1feed8-97d8-4e40-bede-276e9b50de3a	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 13:56:03.711223+00	
00000000-0000-0000-0000-000000000000	c5cd18fc-e6fd-44d2-a486-2ee1ea0d2f5f	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 14:56:03.699973+00	
00000000-0000-0000-0000-000000000000	c4f2843f-baf1-4d7a-8b70-ccd74d730bbe	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 14:56:03.70124+00	
00000000-0000-0000-0000-000000000000	60d94a8a-c8d6-4f29-8fd2-151c04a4401b	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 15:56:03.834476+00	
00000000-0000-0000-0000-000000000000	5a8f0dce-4959-48ba-b80b-e051ad41c599	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 15:56:03.836219+00	
00000000-0000-0000-0000-000000000000	9b9d3c56-9810-4d59-a38c-a60389a809ec	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 16:56:03.709763+00	
00000000-0000-0000-0000-000000000000	cb217b63-a185-47bf-801d-997eb9029f8d	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 16:56:03.711061+00	
00000000-0000-0000-0000-000000000000	4a07ea71-d3bd-4806-8459-5ca87c55bfd6	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 17:56:03.722988+00	
00000000-0000-0000-0000-000000000000	92f7ceb2-72d4-40fa-8895-a758e618f8ca	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 17:56:03.724646+00	
00000000-0000-0000-0000-000000000000	a8be403a-897e-4276-8b29-2f8e46bea96d	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 18:56:03.704938+00	
00000000-0000-0000-0000-000000000000	e408c67c-9918-4e46-9baf-9e636f83f1a8	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 18:56:03.706797+00	
00000000-0000-0000-0000-000000000000	61c0cc6c-8d2d-467d-877e-acb532693807	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 19:56:03.831617+00	
00000000-0000-0000-0000-000000000000	7b993093-9e1f-49fe-9416-5a0d6fa39d58	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 19:56:03.832671+00	
00000000-0000-0000-0000-000000000000	18a546d0-47c5-44a8-8af0-930d4c414e31	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 20:56:03.644132+00	
00000000-0000-0000-0000-000000000000	d307eb3f-3eef-4b0f-8a37-a542611c58be	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 20:56:03.646605+00	
00000000-0000-0000-0000-000000000000	5e1ddb11-9f51-456c-a47d-c013ac33fc3c	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 21:56:03.712676+00	
00000000-0000-0000-0000-000000000000	bed506be-c924-47f5-8345-b83eb2e8d43c	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 21:56:03.71497+00	
00000000-0000-0000-0000-000000000000	581a4b97-a545-48fd-8b01-76e631d38606	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 22:56:03.479678+00	
00000000-0000-0000-0000-000000000000	7257ba30-5497-499c-a5fc-061fb472a3fa	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 22:56:03.481204+00	
00000000-0000-0000-0000-000000000000	badb277a-c97c-4acd-8773-f9c631cbc6e2	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 23:56:03.988062+00	
00000000-0000-0000-0000-000000000000	ab98d7bc-4343-45f3-8a27-dde5d03e47f0	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-09 23:56:03.989802+00	
00000000-0000-0000-0000-000000000000	1d615db6-6c4d-4ae2-84cc-23516881486f	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 00:56:04.00777+00	
00000000-0000-0000-0000-000000000000	8c7ed147-caca-4ac5-855c-d17d508cc1b7	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 00:56:04.010039+00	
00000000-0000-0000-0000-000000000000	85ff16af-89da-4eed-a3b4-f2121286b8dc	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 01:56:03.218048+00	
00000000-0000-0000-0000-000000000000	ecc1a68b-eeab-4b25-beab-bddd939c6916	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 01:56:03.219613+00	
00000000-0000-0000-0000-000000000000	876e4cf2-aaeb-4dc0-8424-33e58e17b50c	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 02:56:04.055376+00	
00000000-0000-0000-0000-000000000000	1b087329-9892-4376-8095-89bd167d6679	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 02:56:04.05673+00	
00000000-0000-0000-0000-000000000000	d843d7e5-5b84-4b69-8e98-bb62696412ab	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 03:56:03.748907+00	
00000000-0000-0000-0000-000000000000	2ca96e99-5354-4590-8201-8e83a1f4c7fd	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 03:56:03.752096+00	
00000000-0000-0000-0000-000000000000	a40dbce1-baaf-49b6-b4ef-61557edbd27e	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 04:56:04.316969+00	
00000000-0000-0000-0000-000000000000	03214c48-6ec6-40cd-9bb0-aa426d7b2844	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 04:56:04.318108+00	
00000000-0000-0000-0000-000000000000	619a7479-7b87-4f2b-a05a-ff0ecfd3b410	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 05:56:04.156389+00	
00000000-0000-0000-0000-000000000000	ecd211e5-0a3e-4877-9fd7-6944f1cfafb9	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 05:56:04.158275+00	
00000000-0000-0000-0000-000000000000	22f1f50b-0658-4394-aa6c-1ce6554fa824	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 06:56:04.298656+00	
00000000-0000-0000-0000-000000000000	57ea2f16-efe2-42ff-9d1c-4e8aa997b7bc	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 06:56:04.300132+00	
00000000-0000-0000-0000-000000000000	6601f8af-3072-4ba6-b399-b99108a1fad1	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 07:56:03.494866+00	
00000000-0000-0000-0000-000000000000	a5f3d808-3b2a-419f-a029-cd0f653c0d86	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 07:56:03.497702+00	
00000000-0000-0000-0000-000000000000	7df6e553-b2fd-47b0-bba9-463a7150b3ef	{"action":"login","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-10 08:31:58.601385+00	
00000000-0000-0000-0000-000000000000	2a6e4a8b-8642-4eb9-a384-305ff04ead1f	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 08:56:03.323838+00	
00000000-0000-0000-0000-000000000000	2d9443fd-0fc0-4b3c-9c49-defbffd6f77d	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 08:56:03.325054+00	
00000000-0000-0000-0000-000000000000	e4861f02-184b-4d83-8fda-43723f42c1bc	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 09:56:03.635972+00	
00000000-0000-0000-0000-000000000000	56897d0e-f699-430f-96cc-d108db5ac7a1	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 09:56:03.636907+00	
00000000-0000-0000-0000-000000000000	795292fb-5870-4489-992f-8ec1b6074049	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 10:56:03.780922+00	
00000000-0000-0000-0000-000000000000	2ca24e9e-992c-45ca-9cd4-437beb0833c7	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 10:56:03.781977+00	
00000000-0000-0000-0000-000000000000	3d0fefd3-cd9d-42ef-a260-381e77bbfdc1	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 11:56:03.325837+00	
00000000-0000-0000-0000-000000000000	a88e573d-0998-4c6c-8177-d1562934f7d5	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 11:56:03.328564+00	
00000000-0000-0000-0000-000000000000	2b5b13d4-41cc-4c66-9e88-73e6f1b6a965	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 12:56:03.85358+00	
00000000-0000-0000-0000-000000000000	873140dd-378a-4ad4-8677-34c78bcf9d03	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 12:56:03.854811+00	
00000000-0000-0000-0000-000000000000	545d4162-6039-46d9-bb2d-05bfbccec40b	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 13:56:03.629402+00	
00000000-0000-0000-0000-000000000000	544e9ed6-f6fd-42c9-ba3f-18dad00d923d	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 13:56:03.630596+00	
00000000-0000-0000-0000-000000000000	1e7d497f-7221-4253-a68a-c1f6efe225c5	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 14:56:02.686882+00	
00000000-0000-0000-0000-000000000000	c7bc0e44-172b-4c82-a768-eb974dae43f0	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 14:56:02.687951+00	
00000000-0000-0000-0000-000000000000	6347b6d6-8828-4ff0-9fa8-b24a9b0fe199	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 15:56:02.773653+00	
00000000-0000-0000-0000-000000000000	32540c7a-8d20-4499-ad75-ac7a6594b691	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 15:56:02.77498+00	
00000000-0000-0000-0000-000000000000	59fe35a6-d273-40e9-ab54-46e16d39c33c	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 16:56:02.718209+00	
00000000-0000-0000-0000-000000000000	30512297-2263-4a0e-baf5-3a15ba040d6e	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 16:56:02.719148+00	
00000000-0000-0000-0000-000000000000	9ca530fb-fd2a-4a4f-9ba3-d5bd96861bc4	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 17:56:02.975823+00	
00000000-0000-0000-0000-000000000000	15f52d8d-a4e0-4c73-8ca5-de4d7dc2b8ec	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 17:56:02.976623+00	
00000000-0000-0000-0000-000000000000	98fd2d34-440a-423c-a3ba-ff4b8bd82b01	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 18:56:02.548551+00	
00000000-0000-0000-0000-000000000000	52beb18e-fc1a-4b6d-9ac2-670d0b98938c	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 18:56:02.54967+00	
00000000-0000-0000-0000-000000000000	2b719689-a082-488a-8317-21f3bd9b9f03	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 19:56:02.637764+00	
00000000-0000-0000-0000-000000000000	aade8deb-64ee-4b1b-a5fe-3a0539f67c72	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 19:56:02.638847+00	
00000000-0000-0000-0000-000000000000	5115d9bb-7987-4725-82fb-b1f284534af7	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 20:56:06.878604+00	
00000000-0000-0000-0000-000000000000	b24bc20e-7a2a-4a46-8fae-1b029b6af3cd	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 20:56:06.879322+00	
00000000-0000-0000-0000-000000000000	aeceadb0-0067-4039-9424-696212ab28b5	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 21:56:02.754015+00	
00000000-0000-0000-0000-000000000000	69824232-66a3-49dc-9ccc-c747b937f50b	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 21:56:02.755532+00	
00000000-0000-0000-0000-000000000000	0f96aa55-a611-485b-bf13-741584b3f8f7	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 22:56:02.171619+00	
00000000-0000-0000-0000-000000000000	fc9c3e57-e660-419e-9c04-ba71f22a5117	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 22:56:02.172663+00	
00000000-0000-0000-0000-000000000000	1a7c23ba-319c-450b-b8d1-def7f1959f92	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 23:56:02.164725+00	
00000000-0000-0000-0000-000000000000	6f189231-0187-4809-b5f0-cbf73ecad54d	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-10 23:56:02.166847+00	
00000000-0000-0000-0000-000000000000	d3960be6-d767-4c1b-b682-ca74eebf1062	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 00:56:03.018442+00	
00000000-0000-0000-0000-000000000000	e9336910-fb05-45d2-a4aa-f9c3b4428713	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 00:56:03.019503+00	
00000000-0000-0000-0000-000000000000	8769b83f-3123-44f3-bc1f-64445891c521	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 01:56:02.763335+00	
00000000-0000-0000-0000-000000000000	628472be-89dc-4660-890e-0d95f971096b	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 01:56:02.766588+00	
00000000-0000-0000-0000-000000000000	8c1c1a15-a656-4f29-9c34-79fda6c0f665	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 02:56:02.269062+00	
00000000-0000-0000-0000-000000000000	c366c7ed-3508-4bf6-b7b3-6f3b00452b78	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 02:56:02.271593+00	
00000000-0000-0000-0000-000000000000	dd450f0c-cdb3-4264-88d7-cedc81544ad1	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 03:56:01.942884+00	
00000000-0000-0000-0000-000000000000	67308d41-cb78-4e74-b0d7-fe7d90edeed8	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 03:56:01.943739+00	
00000000-0000-0000-0000-000000000000	e8f4844e-a38d-48e6-b0b6-f55489c1b703	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 04:56:02.555223+00	
00000000-0000-0000-0000-000000000000	b03b1d48-fa1b-4f08-8391-d2d0147e18aa	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 04:56:02.55639+00	
00000000-0000-0000-0000-000000000000	a0265d0a-92b3-4e1c-a2bc-06f500d0cd0d	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 05:05:04.052313+00	
00000000-0000-0000-0000-000000000000	7ea581b4-064d-42e6-824d-87f436b52c12	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 05:05:04.05431+00	
00000000-0000-0000-0000-000000000000	65805ae6-1d2a-4651-ab09-f82ec814553d	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 05:56:01.921141+00	
00000000-0000-0000-0000-000000000000	653eff95-9b53-45bb-8028-52eb61640480	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 05:56:01.922274+00	
00000000-0000-0000-0000-000000000000	a72d1f1a-4674-4a7e-a1a1-ff1b6990c6a3	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 06:56:02.272022+00	
00000000-0000-0000-0000-000000000000	e675cc7a-325b-4e08-bc07-1e7090415d0b	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 06:56:02.273239+00	
00000000-0000-0000-0000-000000000000	67c7dd2f-cea4-4b03-b49b-70aa49ee0ea7	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 07:56:01.8325+00	
00000000-0000-0000-0000-000000000000	836f7679-0631-49dd-b72d-5ed4271bf020	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 07:56:01.834351+00	
00000000-0000-0000-0000-000000000000	45451349-a931-4cff-b6be-8ed20194ae30	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 08:56:02.943289+00	
00000000-0000-0000-0000-000000000000	beb2b205-1361-4891-8ae8-51ceb3a162a9	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 08:56:02.945069+00	
00000000-0000-0000-0000-000000000000	a4a93765-ad45-475d-9e43-559b84f08cb5	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 09:56:03.349218+00	
00000000-0000-0000-0000-000000000000	734d8525-757d-4942-9211-1303e514af09	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 09:56:03.350784+00	
00000000-0000-0000-0000-000000000000	d47a6c12-a189-45d2-ac38-89595a903122	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 10:56:02.007012+00	
00000000-0000-0000-0000-000000000000	4b594f64-49a5-4c14-be52-ac4c01380e74	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 10:56:02.010272+00	
00000000-0000-0000-0000-000000000000	0eefafb7-bf8e-4bf4-8e35-11d41373d913	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 11:56:01.632103+00	
00000000-0000-0000-0000-000000000000	1aa2872c-3d3e-4355-bbf1-b39116eca957	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 11:56:01.633807+00	
00000000-0000-0000-0000-000000000000	02c6ebed-8f06-4ad4-81c2-55e8aa2d4169	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 12:56:01.557897+00	
00000000-0000-0000-0000-000000000000	0673c3ba-446f-4189-b630-7ca0c2857afe	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 12:56:01.559074+00	
00000000-0000-0000-0000-000000000000	d2c77239-2efc-4e10-8cc9-264ad04e38f6	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 13:56:01.549328+00	
00000000-0000-0000-0000-000000000000	f4dd0e07-1d90-405f-bf5d-b5e076f451ce	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 13:56:01.551737+00	
00000000-0000-0000-0000-000000000000	7af0ccb6-b996-44d1-add5-09399731c716	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 14:56:05.531108+00	
00000000-0000-0000-0000-000000000000	d92410cf-bcdd-4a14-9f4a-91d0a39210de	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 14:56:05.532225+00	
00000000-0000-0000-0000-000000000000	09757751-7d7c-4f6d-9bfd-e2a7c7518c58	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 15:56:01.644024+00	
00000000-0000-0000-0000-000000000000	d2974963-166d-450b-b847-9063fae69fc3	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 15:56:01.645437+00	
00000000-0000-0000-0000-000000000000	f47f94be-3253-4678-a089-cfdd47d29f35	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 16:56:01.680436+00	
00000000-0000-0000-0000-000000000000	910f4616-be50-4279-a4e0-b5f7aefdb622	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 16:56:01.683168+00	
00000000-0000-0000-0000-000000000000	f7ef489d-a710-42a1-a620-9510f4241410	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 17:56:01.708818+00	
00000000-0000-0000-0000-000000000000	72a0a411-152a-425c-914a-9a3bc623f2da	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 17:56:01.710053+00	
00000000-0000-0000-0000-000000000000	67460b55-1a2f-4870-aecf-b682f2ae7717	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 18:56:01.498949+00	
00000000-0000-0000-0000-000000000000	cc49ed4c-29e4-44c0-829d-3dc55f196d44	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 18:56:01.501725+00	
00000000-0000-0000-0000-000000000000	6738a0de-c36f-40e3-92ce-f6f565cc13b5	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 19:56:06.501487+00	
00000000-0000-0000-0000-000000000000	1dfcfde0-debb-47ef-a026-671af9fc4677	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 19:56:06.502638+00	
00000000-0000-0000-0000-000000000000	198792cf-993f-447b-9be1-daee5fc9f28f	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 20:56:01.310283+00	
00000000-0000-0000-0000-000000000000	dbe9f097-9a75-4632-a588-12c731c8cc18	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 20:56:01.312319+00	
00000000-0000-0000-0000-000000000000	b8ffa073-fda2-4dab-bb68-4ffdb88db7fa	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 21:56:01.971073+00	
00000000-0000-0000-0000-000000000000	273e3c85-c558-4c83-abff-6292b9314073	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 21:56:01.974547+00	
00000000-0000-0000-0000-000000000000	43143d90-d2f3-4acf-9adf-b4c5e383d696	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 22:56:01.923528+00	
00000000-0000-0000-0000-000000000000	0cc7ec40-1fc0-4b93-aaa2-5226d76081f5	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 22:56:01.925503+00	
00000000-0000-0000-0000-000000000000	ab896201-568a-43c0-85af-4e66682c8466	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 23:56:01.591596+00	
00000000-0000-0000-0000-000000000000	1103e877-730d-48b1-b976-73fb574e15e6	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-11 23:56:01.594185+00	
00000000-0000-0000-0000-000000000000	08d846aa-c73d-4250-980d-5e96444abed5	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 00:56:01.706671+00	
00000000-0000-0000-0000-000000000000	a77f276d-c8ed-4b63-b09e-e610c6c37049	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 00:56:01.707984+00	
00000000-0000-0000-0000-000000000000	b4583c83-f8cf-4ebc-a686-a9e1d23454f4	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 01:56:01.254487+00	
00000000-0000-0000-0000-000000000000	854fc9c3-60cb-4fe4-9aff-0788bc3d4f1f	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 01:56:01.258322+00	
00000000-0000-0000-0000-000000000000	301358a3-78c5-4548-bc7d-5722bf3f683d	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 02:56:01.056292+00	
00000000-0000-0000-0000-000000000000	eed281ee-92d9-4098-90e8-0d9d2521a582	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 02:56:01.057868+00	
00000000-0000-0000-0000-000000000000	144125fe-f7f5-4f0c-9c2d-8ab23b30828f	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 03:56:01.331162+00	
00000000-0000-0000-0000-000000000000	a2efefe9-2bd6-4591-85c6-2d094c8f1d9d	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 03:56:01.335994+00	
00000000-0000-0000-0000-000000000000	693fe1b5-4e11-43c1-bba9-54dc312e36bc	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 04:56:02.153533+00	
00000000-0000-0000-0000-000000000000	7a17abaf-9885-4831-8b79-2ce92d7267a7	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 04:56:02.156337+00	
00000000-0000-0000-0000-000000000000	41cff139-cdf2-453c-8183-c558ff6b9f3d	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 05:56:02.226715+00	
00000000-0000-0000-0000-000000000000	a49794ca-5e49-420d-8749-babe2ee094b3	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 05:56:02.229757+00	
00000000-0000-0000-0000-000000000000	77a29525-6957-4746-b0e9-5ce3bcb44e78	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 06:56:01.171798+00	
00000000-0000-0000-0000-000000000000	8ef17165-cbb6-4eb6-8620-60ca200b644b	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 06:56:01.173234+00	
00000000-0000-0000-0000-000000000000	f908aa7a-a6fa-4940-9c79-a5a9b8a8856a	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 07:56:01.883597+00	
00000000-0000-0000-0000-000000000000	e8eacb5f-189d-4e89-86c2-a4e52de6b22a	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 07:56:01.886264+00	
00000000-0000-0000-0000-000000000000	0faf13e0-6fbe-485c-bafb-c6bc952da1c1	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 08:56:01.162044+00	
00000000-0000-0000-0000-000000000000	3e01ae50-25d2-4ac1-9533-02a1506bf1f2	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 08:56:01.165965+00	
00000000-0000-0000-0000-000000000000	a888a4aa-be1f-418c-93ef-5aa42b874d4e	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 09:56:01.929173+00	
00000000-0000-0000-0000-000000000000	e2b827bf-af0e-4766-98dc-56118720403f	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 09:56:01.934945+00	
00000000-0000-0000-0000-000000000000	f0f96859-a8e7-48f3-9e37-ffb644dc0d16	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 10:56:01.113797+00	
00000000-0000-0000-0000-000000000000	bce1a5b9-8732-4258-9405-3a24295f5689	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 10:56:01.116385+00	
00000000-0000-0000-0000-000000000000	c25aa486-cfd4-477e-8686-096c2e50ef7f	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 11:56:03.386504+00	
00000000-0000-0000-0000-000000000000	2efd4427-530d-47b1-a117-3c875e158de5	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 11:56:03.393312+00	
00000000-0000-0000-0000-000000000000	d5f7d8a9-fd0b-41ea-9c89-3415042433e4	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 12:56:02.100984+00	
00000000-0000-0000-0000-000000000000	079babe0-f00e-4822-9178-28ad53e42648	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 12:56:02.103823+00	
00000000-0000-0000-0000-000000000000	d42bb0b5-f350-44b3-aa5e-12d3c8da1ef2	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 13:56:01.952953+00	
00000000-0000-0000-0000-000000000000	3052106c-5f1f-4598-92fe-1606cc22dbff	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 13:56:01.955809+00	
00000000-0000-0000-0000-000000000000	6f374dd3-cd24-49b4-b275-40431eaaf080	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 14:56:00.591431+00	
00000000-0000-0000-0000-000000000000	c7f642dd-71f6-40b4-81a0-966781d8d7b9	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 14:56:00.595622+00	
00000000-0000-0000-0000-000000000000	97f222ca-2afa-4200-82e1-87c5aa69190b	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 15:56:00.555069+00	
00000000-0000-0000-0000-000000000000	7cf04bcc-4538-4ed4-8fa0-bb79b07408a4	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 15:56:00.557583+00	
00000000-0000-0000-0000-000000000000	c370db36-3874-41ae-bfe3-7a6e93b2b75e	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 16:56:00.550272+00	
00000000-0000-0000-0000-000000000000	064d5f64-2b40-457f-a0cc-6732633ba7c6	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 16:56:00.552984+00	
00000000-0000-0000-0000-000000000000	907b58ba-852d-443e-82e5-e68c369f3639	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 17:56:00.5491+00	
00000000-0000-0000-0000-000000000000	ce56fa3e-484b-488f-bfa5-353c574623eb	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 17:56:00.552372+00	
00000000-0000-0000-0000-000000000000	6b714881-5989-4723-8631-9bbf1215a8d6	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 18:56:00.547006+00	
00000000-0000-0000-0000-000000000000	25da1e95-1407-40af-801d-68d022952789	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 18:56:00.549657+00	
00000000-0000-0000-0000-000000000000	abfb01c2-fd64-45f3-b610-571803b8d4c5	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 19:56:00.609384+00	
00000000-0000-0000-0000-000000000000	e5bc7180-5caa-4271-8589-1b0d95630d96	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 19:56:00.612742+00	
00000000-0000-0000-0000-000000000000	f5bd32df-fdfc-4245-99af-533e22c99163	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 20:56:00.747402+00	
00000000-0000-0000-0000-000000000000	f41cc8e3-24ac-4ef9-8cae-3c7156546403	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 20:56:00.751309+00	
00000000-0000-0000-0000-000000000000	9e0e936f-cc0e-4b27-9b46-c4a177cbbbd1	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 21:56:00.723323+00	
00000000-0000-0000-0000-000000000000	0d5c34c7-d12b-4419-8295-2f04067019ab	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-12 21:56:00.728257+00	
00000000-0000-0000-0000-000000000000	8764a3d4-e32e-4511-9f53-9de6c5e86fe8	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 00:31:45.211365+00	
00000000-0000-0000-0000-000000000000	2cf8f5bc-8c9c-40cd-9f3e-4cd09f4c7eb9	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 00:31:45.226157+00	
00000000-0000-0000-0000-000000000000	7c03ec1e-52c9-469e-bebe-b416a5b65adc	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 00:31:45.299483+00	
00000000-0000-0000-0000-000000000000	13f82a2b-04f8-4cca-aa76-6b9b3b38caac	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 00:31:45.3028+00	
00000000-0000-0000-0000-000000000000	90aa41d8-7278-4ab8-8ff8-c248cacc4757	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 01:32:00.326905+00	
00000000-0000-0000-0000-000000000000	0ff110da-dd47-4700-a271-75d6b4af8757	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 01:32:00.332503+00	
00000000-0000-0000-0000-000000000000	b6cc4894-fbf6-439b-9a72-4d6bcce3af72	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 01:32:00.370157+00	
00000000-0000-0000-0000-000000000000	b571e12b-cbd5-4ca6-8d93-133ab4104731	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 01:32:00.373115+00	
00000000-0000-0000-0000-000000000000	35cb1955-6caa-43b3-b2b2-fe49a907aefe	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 02:32:00.605838+00	
00000000-0000-0000-0000-000000000000	cde8e89b-a65c-442e-b846-a24f5de3a3f3	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 02:32:00.607999+00	
00000000-0000-0000-0000-000000000000	2a45019f-55ae-415b-a1c4-876311e1cdf3	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 02:32:00.757541+00	
00000000-0000-0000-0000-000000000000	c6c5723d-41fd-428d-8916-7b0724e9d428	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 02:32:00.758414+00	
00000000-0000-0000-0000-000000000000	a1dfe2c3-493b-48fd-a983-bf4e3fe77721	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 03:32:00.551193+00	
00000000-0000-0000-0000-000000000000	63863c98-f299-468a-bf23-7f5fa95289a3	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 03:32:00.555338+00	
00000000-0000-0000-0000-000000000000	5eb0b1cc-87d4-4298-8c9f-4acd5e53a7bf	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 03:32:00.746241+00	
00000000-0000-0000-0000-000000000000	811bd157-c10d-4164-adec-81b95c1d4695	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 03:32:00.747403+00	
00000000-0000-0000-0000-000000000000	65e0265d-e8b7-4a0c-9343-a484e5f593a5	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 04:32:00.66441+00	
00000000-0000-0000-0000-000000000000	eb8636f3-be95-4e3b-801e-cbd4a2c36ccc	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 04:32:00.669219+00	
00000000-0000-0000-0000-000000000000	85d8e7b9-4949-4af3-b088-1dcb25a53597	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 04:32:00.871671+00	
00000000-0000-0000-0000-000000000000	bd237701-6443-4fc0-9bca-00c6b8f821d5	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 04:32:00.872811+00	
00000000-0000-0000-0000-000000000000	9aeb66cf-9f08-4ff8-abd5-1ed9b9714c64	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 05:32:00.844524+00	
00000000-0000-0000-0000-000000000000	21bce3a1-c15f-43ee-aeb1-0c5bb029f4a1	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 05:32:00.84683+00	
00000000-0000-0000-0000-000000000000	8f2a3469-25a8-4f75-a2de-dc0743d245c0	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 05:32:02.452851+00	
00000000-0000-0000-0000-000000000000	c530b3b5-1c81-4136-b7c7-73877949dd35	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 05:32:02.454282+00	
00000000-0000-0000-0000-000000000000	22b60726-164a-47ec-ba6d-567669224c5a	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 06:32:00.631571+00	
00000000-0000-0000-0000-000000000000	7a06ee08-4415-47ca-af0d-cc9e4b9ae035	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 06:32:00.635276+00	
00000000-0000-0000-0000-000000000000	f60006bc-63c6-4798-bbe3-b1bc793aa93e	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 06:32:00.96024+00	
00000000-0000-0000-0000-000000000000	9b95d189-8107-43bd-adf8-0b38cbc187fb	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 06:32:00.961699+00	
00000000-0000-0000-0000-000000000000	f6d49bf7-f28b-4eb0-a146-2c17b9dc416c	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 07:32:01.181345+00	
00000000-0000-0000-0000-000000000000	b8b003ef-e997-467c-8b10-d7f0a7a73e33	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 07:32:01.185135+00	
00000000-0000-0000-0000-000000000000	c4f18adc-8318-4622-8056-77a42f74cc05	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 07:32:01.659633+00	
00000000-0000-0000-0000-000000000000	11885824-0932-47b5-97bd-44518b01353e	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 07:32:01.660895+00	
00000000-0000-0000-0000-000000000000	dae93b59-0d8d-4815-9041-18c4812ec247	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 08:31:22.74443+00	
00000000-0000-0000-0000-000000000000	59f3b79b-0f88-4b45-80b8-c4b1b12ab53e	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 08:31:22.747144+00	
00000000-0000-0000-0000-000000000000	7f04b737-551a-4402-a79b-969043d34bd8	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 08:32:00.789227+00	
00000000-0000-0000-0000-000000000000	4b1bec93-db75-4130-98e9-188a5a5467b9	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 08:32:00.790507+00	
00000000-0000-0000-0000-000000000000	31c418fc-d0d5-4490-a2ae-eaa2ea77725f	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 09:31:00.011319+00	
00000000-0000-0000-0000-000000000000	903d3ff0-7061-41e3-bcf3-55a0599ee49b	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 09:31:00.016602+00	
00000000-0000-0000-0000-000000000000	3877a417-7343-40f9-9ccd-e38e7db2d805	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 09:31:23.024835+00	
00000000-0000-0000-0000-000000000000	0c843a9e-284e-476c-aa70-1c6b715a35c0	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-13 09:31:23.025963+00	
00000000-0000-0000-0000-000000000000	b9781444-91d0-45a9-8648-8494c9138c6a	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 00:39:34.47502+00	
00000000-0000-0000-0000-000000000000	ca13dbc7-89fc-4142-bf7d-124757223c6f	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 00:39:34.478807+00	
00000000-0000-0000-0000-000000000000	5d60d716-e5ed-47db-9d8a-19da0224b5ad	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 01:38:59.764175+00	
00000000-0000-0000-0000-000000000000	26639c1b-29c7-4a28-9a1f-bcc908081e48	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 01:38:59.768098+00	
00000000-0000-0000-0000-000000000000	14cfeaa6-fcbb-4553-bc4d-6a1908b124a6	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 02:38:59.24557+00	
00000000-0000-0000-0000-000000000000	43cf53ec-94c7-4c36-8162-6d7d667bdfc3	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 02:38:59.247426+00	
00000000-0000-0000-0000-000000000000	b9f25ba7-43bc-4531-8fb3-fd26460ba18e	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 03:38:59.229425+00	
00000000-0000-0000-0000-000000000000	f4edf4ad-53ff-4230-8433-d426152f145e	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 03:38:59.230832+00	
00000000-0000-0000-0000-000000000000	2203087b-8a70-464b-9dc7-6238cea1ffa4	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 04:38:59.195744+00	
00000000-0000-0000-0000-000000000000	999602e6-f6a6-40cb-915e-210782e7fe47	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 04:38:59.197142+00	
00000000-0000-0000-0000-000000000000	73894843-181f-4a15-a702-03bd564e8b70	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 05:38:59.950455+00	
00000000-0000-0000-0000-000000000000	e4c7d2d3-59fb-442e-9419-e3a10711fd62	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 05:38:59.952253+00	
00000000-0000-0000-0000-000000000000	4a51e357-b1a8-44d4-bf72-bb11dd260893	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 06:38:59.471036+00	
00000000-0000-0000-0000-000000000000	20107fb4-9a2a-4105-b6d3-937803bca711	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 06:38:59.476289+00	
00000000-0000-0000-0000-000000000000	73d7eacf-6521-42bb-a0e5-89664be4e7ee	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 07:38:22.969436+00	
00000000-0000-0000-0000-000000000000	9d729913-600d-4d85-bc5c-e5d1a0700e99	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 07:38:22.973699+00	
00000000-0000-0000-0000-000000000000	e195b373-c46c-49d8-92f5-8722a32a9594	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 07:43:33.489708+00	
00000000-0000-0000-0000-000000000000	aa7530ff-056a-4a96-b70d-9ebb0b63ea5c	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 07:43:33.491734+00	
00000000-0000-0000-0000-000000000000	cd182298-a1b7-4e47-a150-c17c34ccd6b1	{"action":"token_refreshed","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 07:52:59.052647+00	
00000000-0000-0000-0000-000000000000	7b0114bf-64ea-46ce-b56f-8e4fa75f0605	{"action":"token_revoked","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 07:52:59.055492+00	
00000000-0000-0000-0000-000000000000	f4d00fc3-11d1-4326-9896-90e81a45a722	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 08:39:21.510581+00	
00000000-0000-0000-0000-000000000000	b85b6162-af62-47f6-a356-c1f6c7c54876	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 08:39:21.520585+00	
00000000-0000-0000-0000-000000000000	afe50b53-77fb-4e81-aa12-32fb5f985fc4	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 08:43:24.330214+00	
00000000-0000-0000-0000-000000000000	d5bdc58c-148d-411a-bdef-935c18ab5c99	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 08:43:24.332016+00	
00000000-0000-0000-0000-000000000000	bf0f0546-2b17-47b4-a030-0d33669cc706	{"action":"token_refreshed","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 09:13:02.111368+00	
00000000-0000-0000-0000-000000000000	497d586f-0d2e-405d-8dee-917fc68196be	{"action":"token_revoked","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 09:13:02.117173+00	
00000000-0000-0000-0000-000000000000	c67c7dfc-f8b3-4823-91b7-5e8c3da03b74	{"action":"user_updated_password","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-14 09:26:27.710539+00	
00000000-0000-0000-0000-000000000000	253c634d-fabe-4a6d-9ace-d04255541e79	{"action":"user_modified","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-14 09:26:27.711452+00	
00000000-0000-0000-0000-000000000000	58bf59af-4739-49fc-a7ec-5ac010ebde26	{"action":"user_updated_password","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-14 09:26:38.75299+00	
00000000-0000-0000-0000-000000000000	ec98ca3d-96cb-4b95-8cfb-853062a028fe	{"action":"user_modified","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-14 09:26:38.753855+00	
00000000-0000-0000-0000-000000000000	cc91a26e-6eef-4870-9fec-26c1e6d732a4	{"action":"user_updated_password","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-14 09:27:15.385964+00	
00000000-0000-0000-0000-000000000000	6d58b36b-dbf2-461a-af19-fac1b995d805	{"action":"user_modified","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-14 09:27:15.387208+00	
00000000-0000-0000-0000-000000000000	cb6fdbf3-7a4e-4290-a9bc-5004a0284f3b	{"action":"login","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-14 09:28:56.743577+00	
00000000-0000-0000-0000-000000000000	a4d76fc2-a009-4fb7-bcc5-b3c8de31d67e	{"action":"user_updated_password","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-14 09:29:43.626383+00	
00000000-0000-0000-0000-000000000000	e7a98804-7c99-477e-9e7d-b788065c8a58	{"action":"user_modified","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-14 09:29:43.627832+00	
00000000-0000-0000-0000-000000000000	a40f1ce2-960a-40ba-b8b3-bea6cfced31e	{"action":"user_updated_password","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-14 09:30:22.285403+00	
00000000-0000-0000-0000-000000000000	669cc276-6afc-4d1b-85fb-0797c6511357	{"action":"user_modified","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-14 09:30:22.286527+00	
00000000-0000-0000-0000-000000000000	585f1248-7557-49fd-bed5-8f9945167168	{"action":"login","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-14 09:33:23.209839+00	
00000000-0000-0000-0000-000000000000	a994ab27-e38b-4047-b475-f0eaefea2762	{"action":"user_updated_password","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-14 09:33:59.086418+00	
00000000-0000-0000-0000-000000000000	bcc4b033-84ad-4be9-816f-2ab204d5fbe5	{"action":"user_modified","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"user"}	2025-10-14 09:33:59.087462+00	
00000000-0000-0000-0000-000000000000	de37b0bf-bf25-4dff-96c4-9805a0c5be8f	{"action":"login","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-14 09:35:12.515601+00	
00000000-0000-0000-0000-000000000000	a612021e-ab76-4cf5-8488-ee866a15c2b6	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 09:38:48.609406+00	
00000000-0000-0000-0000-000000000000	5ae6072b-bda8-49be-a833-79360802b6cc	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 09:38:48.610505+00	
00000000-0000-0000-0000-000000000000	cace94ba-3486-4bbd-9c7d-7f21b405f201	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 10:38:08.699865+00	
00000000-0000-0000-0000-000000000000	60090795-1df8-40f0-8f30-36790d62a4ce	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 10:38:08.701185+00	
00000000-0000-0000-0000-000000000000	e36738c5-5c89-4bbe-934c-7beb55a6aeac	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 11:37:28.680335+00	
00000000-0000-0000-0000-000000000000	0b014346-12ae-433a-a09b-5fa0a7a82a3a	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 11:37:28.681955+00	
00000000-0000-0000-0000-000000000000	50d1f10d-177f-4758-be2d-54f5e778c32a	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 12:36:48.70469+00	
00000000-0000-0000-0000-000000000000	2cb8dd27-b13a-4248-b6ca-0023c14638bc	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 12:36:48.706902+00	
00000000-0000-0000-0000-000000000000	81efae8b-80b3-4c57-9484-add347328587	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 13:36:08.686399+00	
00000000-0000-0000-0000-000000000000	fa04e34d-9583-4b89-82c8-afbf09a3d963	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 13:36:08.687842+00	
00000000-0000-0000-0000-000000000000	83ad9c0f-dfa4-4877-8aff-e319bd7aaae5	{"action":"token_refreshed","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 14:10:47.3954+00	
00000000-0000-0000-0000-000000000000	304ba26c-230b-4fcf-b9b5-25b666d4458c	{"action":"token_revoked","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 14:10:47.399516+00	
00000000-0000-0000-0000-000000000000	f3be0c38-936d-48e4-a8be-a8ae8aac78ee	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 14:35:28.678603+00	
00000000-0000-0000-0000-000000000000	ead9e393-f81f-450c-9a00-179bf386e4fe	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 14:35:28.680714+00	
00000000-0000-0000-0000-000000000000	ab6fd628-4672-42f7-81d6-8d1abce62057	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 15:34:48.677223+00	
00000000-0000-0000-0000-000000000000	512c4022-6d40-4de6-b7ad-a9ba74ecd68a	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 15:34:48.679717+00	
00000000-0000-0000-0000-000000000000	e9510dee-c0e7-4b89-aab1-21aac434d458	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 16:34:08.77913+00	
00000000-0000-0000-0000-000000000000	11fa983a-040e-4cc9-befe-6d4a299c88c8	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 16:34:08.781065+00	
00000000-0000-0000-0000-000000000000	5b44fe90-fc8c-48c5-abfa-241ee6a4faf3	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 17:33:28.824813+00	
00000000-0000-0000-0000-000000000000	f4796507-af09-449c-aea7-de4ca68762d2	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 17:33:28.826389+00	
00000000-0000-0000-0000-000000000000	dcd13446-f798-430d-9c4c-a9c4f5721667	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 18:32:48.628292+00	
00000000-0000-0000-0000-000000000000	72dc3d03-5635-48d8-bf5a-f5fe88316889	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 18:32:48.630664+00	
00000000-0000-0000-0000-000000000000	1757d9fa-f011-4e86-a332-3f5ad3a2051f	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 19:32:08.783774+00	
00000000-0000-0000-0000-000000000000	f0523d8b-96ee-4007-a4dd-c8c3af7d8a88	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 19:32:08.785055+00	
00000000-0000-0000-0000-000000000000	bb965fa5-0257-45c2-9cb1-437a1d70aec3	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 20:31:28.788222+00	
00000000-0000-0000-0000-000000000000	3f189ba8-af7f-4a5a-a7a6-615250abb5d5	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 20:31:28.789369+00	
00000000-0000-0000-0000-000000000000	a01bbfac-9fd0-4461-9053-80d61e03b58f	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 21:30:48.338741+00	
00000000-0000-0000-0000-000000000000	20c2a647-c4fb-4f4a-8e75-ab4f295b837c	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 21:30:48.33987+00	
00000000-0000-0000-0000-000000000000	3badb842-4f97-465b-b5b7-972d15bfed77	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 22:30:08.247946+00	
00000000-0000-0000-0000-000000000000	66e594b6-80aa-429e-8a93-736ce4869f76	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 22:30:08.249542+00	
00000000-0000-0000-0000-000000000000	7c89e40b-150f-4370-a58e-4f052bbb7856	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 23:29:28.95515+00	
00000000-0000-0000-0000-000000000000	22fdfb80-90c0-400c-b931-2d810b8c337c	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-14 23:29:28.956807+00	
00000000-0000-0000-0000-000000000000	b390426d-573a-43aa-b119-15975599d5a4	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 00:28:48.556751+00	
00000000-0000-0000-0000-000000000000	ccae64c5-4616-4b39-bf90-c201fdad965f	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 00:28:48.559877+00	
00000000-0000-0000-0000-000000000000	2fe89682-3b3b-4484-9b59-4e21a02995d6	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 00:32:01.07637+00	
00000000-0000-0000-0000-000000000000	97e67622-0a00-43e2-a68a-cee1a99c576c	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 00:32:01.078123+00	
00000000-0000-0000-0000-000000000000	cffcfb71-f094-4357-a68c-da92944d152e	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 01:28:47.792819+00	
00000000-0000-0000-0000-000000000000	6de52055-2cab-4d58-88f4-9c8b5c1be675	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 01:28:47.794168+00	
00000000-0000-0000-0000-000000000000	1f6cf592-15fb-4764-b8c9-634b796d7404	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 02:28:47.757582+00	
00000000-0000-0000-0000-000000000000	f1b7cc49-dc27-4b29-9a6a-0ee44fea32ae	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 02:28:47.759478+00	
00000000-0000-0000-0000-000000000000	65c808d3-22ac-4860-bc39-6097a0578962	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 03:27:35.272136+00	
00000000-0000-0000-0000-000000000000	23de7191-f7d2-4c49-a11f-5d550f689c40	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 03:27:35.273555+00	
00000000-0000-0000-0000-000000000000	e6ca9b8d-82eb-4408-b96f-730da6237934	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 03:28:47.733829+00	
00000000-0000-0000-0000-000000000000	3acaad39-97f7-4c38-a569-b60811526110	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 03:28:47.734803+00	
00000000-0000-0000-0000-000000000000	fed642e0-4a15-45d2-ada0-e2ed8c38c5c1	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 04:28:48.808447+00	
00000000-0000-0000-0000-000000000000	3bf83045-feae-40a7-9b2e-ab64d191e0ea	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 04:28:48.809496+00	
00000000-0000-0000-0000-000000000000	adcf280c-4075-4eff-aee1-6cf8626ab823	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 05:28:48.479779+00	
00000000-0000-0000-0000-000000000000	f146737e-bfe8-4e1e-86d3-9432634b84e0	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 05:28:48.480719+00	
00000000-0000-0000-0000-000000000000	4eab8330-38e8-405f-9c91-9d0c4f86fc56	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 06:28:49.001805+00	
00000000-0000-0000-0000-000000000000	a1d25f3d-d15f-44cc-b725-f58830b37500	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 06:28:49.002619+00	
00000000-0000-0000-0000-000000000000	58e921ef-d280-4f0f-adbc-0a98d0a22bf2	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 07:28:48.726596+00	
00000000-0000-0000-0000-000000000000	7447c316-8405-490f-89ba-7f68b0ebc8f4	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 07:28:48.72909+00	
00000000-0000-0000-0000-000000000000	01193c7c-169d-4856-9e10-03c6f860ed19	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 08:28:48.669442+00	
00000000-0000-0000-0000-000000000000	631bdc7e-1d01-471f-a15f-de25a5712cde	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 08:28:48.67053+00	
00000000-0000-0000-0000-000000000000	c083fdad-fc39-417a-b863-e1563c0c8f7e	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 09:28:48.896308+00	
00000000-0000-0000-0000-000000000000	def05df7-a94e-4817-a62a-fad953d09c29	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 09:28:48.897912+00	
00000000-0000-0000-0000-000000000000	7231c57d-b0ce-461d-b5d2-49c763108d82	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 10:28:48.458596+00	
00000000-0000-0000-0000-000000000000	6c25e4ae-673f-4eb7-9824-782ca786502e	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 10:28:48.46035+00	
00000000-0000-0000-0000-000000000000	19900978-b95f-4b80-bc50-dbf864f5483a	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 11:28:48.104036+00	
00000000-0000-0000-0000-000000000000	54c0dd76-f256-4ae5-b5ce-58d0f393e1ea	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 11:28:48.10552+00	
00000000-0000-0000-0000-000000000000	c7d776d5-7744-486c-a609-742b0d89a38b	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 12:28:48.054608+00	
00000000-0000-0000-0000-000000000000	39bd3386-d6ef-4bc2-b35c-40268a05e730	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 12:28:48.056253+00	
00000000-0000-0000-0000-000000000000	62ed5984-cd05-4d81-9ce0-3dc723f7bb9d	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 13:28:47.888161+00	
00000000-0000-0000-0000-000000000000	d4de99bf-c1fb-4b5a-8834-df17ea517ef2	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 13:28:47.889421+00	
00000000-0000-0000-0000-000000000000	3a6e2e74-f12a-4ebd-bb69-68c7f3438511	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 14:28:47.084043+00	
00000000-0000-0000-0000-000000000000	3ab43a18-6f38-422d-a3f5-49a01c44d6e2	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 14:28:47.085697+00	
00000000-0000-0000-0000-000000000000	3db85aed-fcd9-4478-ad17-d1f17a5d2891	{"action":"token_refreshed","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 14:48:52.827809+00	
00000000-0000-0000-0000-000000000000	f2035270-dee0-4344-9b1b-91d101078f88	{"action":"token_revoked","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 14:48:52.828701+00	
00000000-0000-0000-0000-000000000000	4803c37d-915b-4b43-91e6-ff05a7ed86f5	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 15:29:56.223848+00	
00000000-0000-0000-0000-000000000000	970dc5f6-d01f-4ed4-9bf2-a309c2c11f1b	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 15:29:56.224883+00	
00000000-0000-0000-0000-000000000000	140333a3-4acc-4510-b868-551989e96ba9	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 16:29:47.058428+00	
00000000-0000-0000-0000-000000000000	aceb197e-795d-465e-ad29-b76f7e38c72e	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 16:29:47.060031+00	
00000000-0000-0000-0000-000000000000	be5b1563-2e31-4b65-8c4c-a0dcd4a572f5	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 17:29:47.054775+00	
00000000-0000-0000-0000-000000000000	a5a1a28e-0443-4ccf-91d8-33989e618115	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 17:29:47.05619+00	
00000000-0000-0000-0000-000000000000	66341dd9-d698-4e68-a369-ed91f7885e19	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 18:29:47.147667+00	
00000000-0000-0000-0000-000000000000	e6c2ce72-0770-4492-a581-6a2dbf107887	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 18:29:47.148608+00	
00000000-0000-0000-0000-000000000000	b2dffc47-8e6a-4deb-b420-cac8003c3cfd	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 19:29:47.114382+00	
00000000-0000-0000-0000-000000000000	af0b1540-beb3-4c10-b9fc-a00689a6bf35	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 19:29:47.11681+00	
00000000-0000-0000-0000-000000000000	5473d325-e835-4d5b-a01b-10003fb0844f	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 20:29:47.051266+00	
00000000-0000-0000-0000-000000000000	617ae140-0e67-4a67-9948-c467a0b0790c	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 20:29:47.053561+00	
00000000-0000-0000-0000-000000000000	e52391db-3bca-47e7-a85b-f74c109dd8a7	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 21:29:47.230572+00	
00000000-0000-0000-0000-000000000000	5f665adb-9240-4bfb-b1d3-e5706f9eb8ab	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 21:29:47.23148+00	
00000000-0000-0000-0000-000000000000	d04e0fd2-11fb-4ba7-9ef9-4b2ec2f3943d	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 22:29:47.006381+00	
00000000-0000-0000-0000-000000000000	825712fd-ebae-4867-b0a3-733950297650	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 22:29:47.007793+00	
00000000-0000-0000-0000-000000000000	4b4256e8-d479-470a-9e03-6b4443d75878	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 23:29:47.234848+00	
00000000-0000-0000-0000-000000000000	e899ec66-4ed6-4a27-ac01-9b1b08826fb1	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-15 23:29:47.23572+00	
00000000-0000-0000-0000-000000000000	e57c4c36-a147-4d63-a209-2de1cc1997d4	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 00:22:18.672677+00	
00000000-0000-0000-0000-000000000000	bb4c2fc3-98c8-498d-9d83-ad9b426e97a9	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 00:22:18.675542+00	
00000000-0000-0000-0000-000000000000	8eb14fd9-0f8f-4707-8e69-8788e3d37f1e	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 00:29:47.025168+00	
00000000-0000-0000-0000-000000000000	6aad4516-2127-40f3-8374-803eabd328a8	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 00:29:47.026611+00	
00000000-0000-0000-0000-000000000000	150a0b68-c582-4bca-9638-74f731a4be53	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 01:29:46.972195+00	
00000000-0000-0000-0000-000000000000	f4eafcbc-b344-46be-9ee4-59edb5f29509	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 01:29:46.976299+00	
00000000-0000-0000-0000-000000000000	cccf3f44-4e4d-4181-8e01-785042ad7daf	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 02:29:46.680375+00	
00000000-0000-0000-0000-000000000000	c6aac5df-fdd0-4755-b215-7b6587981356	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 02:29:46.684419+00	
00000000-0000-0000-0000-000000000000	44cbe256-19ca-425e-a8fa-8fce9406e29b	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 03:29:46.636119+00	
00000000-0000-0000-0000-000000000000	83885b77-7ebf-4e7d-9980-ee1d53a8e3f1	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 03:29:46.640043+00	
00000000-0000-0000-0000-000000000000	5cb52181-ff6d-4fdf-81da-7bd7af89b176	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 03:41:08.143208+00	
00000000-0000-0000-0000-000000000000	f884870f-ed26-4db1-aba2-8819b4d2d6df	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 03:41:08.145966+00	
00000000-0000-0000-0000-000000000000	50e3e33d-14eb-4698-bca8-905b62fa3765	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 04:29:47.221368+00	
00000000-0000-0000-0000-000000000000	3c4564c6-7ee6-4324-b216-040d46f4f591	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 04:29:47.223585+00	
00000000-0000-0000-0000-000000000000	a1ae18c5-7e8c-46a2-b4eb-b950f6e4bcf8	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 05:29:46.992707+00	
00000000-0000-0000-0000-000000000000	7111dbf4-5bbd-4b53-9f80-0470bfe03c59	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 05:29:46.9954+00	
00000000-0000-0000-0000-000000000000	11bcc28e-2124-4de6-bf9b-42a8fd70bdfa	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 06:29:47.423935+00	
00000000-0000-0000-0000-000000000000	da469755-07c7-4093-bd10-8a57bca76de1	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 06:29:47.427518+00	
00000000-0000-0000-0000-000000000000	2c35a553-b6fd-44a6-adb1-41fc4edeccad	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 07:29:46.778166+00	
00000000-0000-0000-0000-000000000000	52c330ea-35a1-49a5-ae1a-dca1ac148d4a	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 07:29:46.782994+00	
00000000-0000-0000-0000-000000000000	97da4315-8bb2-48ad-a725-88479779025a	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 08:16:27.34528+00	
00000000-0000-0000-0000-000000000000	6416f7f7-bb8f-46ed-a722-4708725c2669	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 08:16:27.348036+00	
00000000-0000-0000-0000-000000000000	a00068a2-494d-46dc-bcd4-5f687aa57893	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 08:29:46.465853+00	
00000000-0000-0000-0000-000000000000	99350871-970d-40b8-9b22-8e407c565bac	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 08:29:46.467387+00	
00000000-0000-0000-0000-000000000000	1dc24912-2380-4808-99f5-9b99c506f524	{"action":"logout","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-16 09:05:04.238587+00	
00000000-0000-0000-0000-000000000000	602f25a0-ed67-434b-9705-d5d4a66575e8	{"action":"login","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-16 09:05:14.737002+00	
00000000-0000-0000-0000-000000000000	56024e4c-75e6-47e7-8734-372f0ae1deb7	{"action":"logout","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-10-16 09:08:17.606907+00	
00000000-0000-0000-0000-000000000000	848943c1-622e-4e8a-94f6-190cd595805a	{"action":"login","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-16 09:08:26.430815+00	
00000000-0000-0000-0000-000000000000	bc234ff3-aa60-4302-98d2-1d395cdeb610	{"action":"login","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-16 09:08:45.269242+00	
00000000-0000-0000-0000-000000000000	5fe95ac0-5e5a-4c6d-8e1c-6a88a66123fb	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 09:16:37.300054+00	
00000000-0000-0000-0000-000000000000	034790fd-7f86-4c0a-b587-ede979816c19	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 09:16:37.302267+00	
00000000-0000-0000-0000-000000000000	ea35ccde-1518-4109-bf5e-e23b675ab9ba	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 10:07:51.421884+00	
00000000-0000-0000-0000-000000000000	986768a5-3382-4503-b912-bb6b62cef3c9	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 10:07:51.425221+00	
00000000-0000-0000-0000-000000000000	39f731fb-6559-4b73-846d-fce50bf51a55	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 10:08:10.918413+00	
00000000-0000-0000-0000-000000000000	fe903b6f-c87c-43c2-bff3-41b7f8a743da	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 10:08:10.919719+00	
00000000-0000-0000-0000-000000000000	44e6c302-c957-41bb-bffe-aaf36c53c65b	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 11:07:20.850139+00	
00000000-0000-0000-0000-000000000000	17f74e47-bbbd-4af3-bf55-b2be77e3569e	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 11:07:20.852603+00	
00000000-0000-0000-0000-000000000000	d366a05d-b8b0-4ff0-bd9b-779f9283c0d4	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 11:07:31.543992+00	
00000000-0000-0000-0000-000000000000	a0f62a52-0f76-4a56-a43d-cdf471501f44	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 11:07:31.548312+00	
00000000-0000-0000-0000-000000000000	f58d3e22-368f-4e52-8825-81776f016da3	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 12:06:41.352842+00	
00000000-0000-0000-0000-000000000000	61367b12-7ff7-45c6-9636-6c833fb507b7	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 12:06:41.354221+00	
00000000-0000-0000-0000-000000000000	95c3f91f-c0a3-4d14-8f3d-06e840834977	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 12:07:00.854731+00	
00000000-0000-0000-0000-000000000000	59caf03a-d17f-4ea6-871f-a42c1373d97b	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 12:07:00.856757+00	
00000000-0000-0000-0000-000000000000	e426a7e0-29d2-4de0-b3a0-7b83d1b3ce90	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 13:06:10.524927+00	
00000000-0000-0000-0000-000000000000	f24cc3b2-e8b1-4d88-8a22-38fb5c5ea6b7	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 13:06:10.526813+00	
00000000-0000-0000-0000-000000000000	1cd832e9-277c-4022-8da5-8caafc80f393	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 13:06:29.675171+00	
00000000-0000-0000-0000-000000000000	9d18f629-cc65-4be9-a736-9cd71662bc66	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 13:06:29.676176+00	
00000000-0000-0000-0000-000000000000	805b77d2-ba0e-4666-9ee4-06c4111bd7fc	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 14:05:39.844745+00	
00000000-0000-0000-0000-000000000000	d3196a52-d746-4fbc-9e94-8e0f670f0888	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 14:05:39.848318+00	
00000000-0000-0000-0000-000000000000	b88cc233-649b-4905-8bea-bee38626681e	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 14:05:50.470795+00	
00000000-0000-0000-0000-000000000000	97edd52b-8b51-44c1-a190-2ae01a5c1db6	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 14:05:50.471653+00	
00000000-0000-0000-0000-000000000000	35d4d01f-455f-4852-9132-6962662f1e62	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 15:05:06.05709+00	
00000000-0000-0000-0000-000000000000	d0ede52f-d8ad-4580-81a0-0122d7ea5a45	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 15:05:06.058807+00	
00000000-0000-0000-0000-000000000000	1f5f38fe-5a79-4e81-84c3-6b11356441ad	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 15:05:21.279132+00	
00000000-0000-0000-0000-000000000000	714b827a-393d-4afc-bbdb-6c99b7c0c513	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 15:05:21.280021+00	
00000000-0000-0000-0000-000000000000	7226a820-0d3a-4c46-8234-ceff49ae3256	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 16:04:29.997175+00	
00000000-0000-0000-0000-000000000000	9b9d8f73-1a77-4add-887e-0e18f537fe6e	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 16:04:29.998712+00	
00000000-0000-0000-0000-000000000000	3f9538fb-341f-48d4-83a2-cca182863740	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 16:04:49.916167+00	
00000000-0000-0000-0000-000000000000	4c25e105-1a0b-48fa-87ee-bdfc3a304c4d	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 16:04:49.918114+00	
00000000-0000-0000-0000-000000000000	1a2d7db5-7e99-4c45-86b4-4f43e18c7b7c	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 17:03:59.821671+00	
00000000-0000-0000-0000-000000000000	8afce51c-a204-4839-a97a-65dc4a57c538	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 17:03:59.822992+00	
00000000-0000-0000-0000-000000000000	98bb2676-74de-4d48-9aa6-63cddd98288f	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 17:04:10.754237+00	
00000000-0000-0000-0000-000000000000	1b033f6d-7312-4ee6-91ee-a937442423f7	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 17:04:10.755188+00	
00000000-0000-0000-0000-000000000000	4facbc39-6525-4ab9-8a10-f3c0c9c35cfc	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 18:03:19.967033+00	
00000000-0000-0000-0000-000000000000	80b4cfa4-fd9b-4c4a-b401-5afa709d8dd3	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 18:03:19.968838+00	
00000000-0000-0000-0000-000000000000	cab38c63-d3a6-435a-9a76-59f8508bc774	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 18:03:39.796874+00	
00000000-0000-0000-0000-000000000000	7e243811-4af8-44b3-8659-7e75f36d7aaf	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 18:03:39.797909+00	
00000000-0000-0000-0000-000000000000	af38207d-bd47-4660-9a61-0fe521ea36fb	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 19:02:39.815719+00	
00000000-0000-0000-0000-000000000000	2ba81c48-418b-4273-9673-ca505c5d4ed9	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 19:02:39.816659+00	
00000000-0000-0000-0000-000000000000	22e9ab58-6993-4bba-8fe2-27a34070f86e	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 19:02:59.752467+00	
00000000-0000-0000-0000-000000000000	5cb5b022-73b1-4e99-852b-b8d289137092	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 19:02:59.753346+00	
00000000-0000-0000-0000-000000000000	1f166fc3-5bae-4a25-a0ba-31dc2d06f542	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 20:01:59.827931+00	
00000000-0000-0000-0000-000000000000	758c9719-023f-4a84-b1eb-547ed2698416	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 20:01:59.82925+00	
00000000-0000-0000-0000-000000000000	1edbd687-7603-4cfe-a705-8adb40f86197	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 20:02:19.808931+00	
00000000-0000-0000-0000-000000000000	1140823d-6535-4d48-9d19-4096fce8d375	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 20:02:19.809713+00	
00000000-0000-0000-0000-000000000000	5f09c1d9-50f4-4232-91b4-923f2c895ea5	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 21:01:19.823315+00	
00000000-0000-0000-0000-000000000000	c0094efa-0bd0-42d8-be03-cd12daf1f675	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 21:01:19.82465+00	
00000000-0000-0000-0000-000000000000	be96cb8a-25be-4b0c-9a73-c887c4b90b50	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 21:01:39.800573+00	
00000000-0000-0000-0000-000000000000	0109aba9-56a3-4bb2-b139-012c1e626b84	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 21:01:39.801746+00	
00000000-0000-0000-0000-000000000000	a523f6cc-2bc1-4569-b9d7-eddd0db87538	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 22:00:40.88143+00	
00000000-0000-0000-0000-000000000000	377850b5-1c59-4ac4-86da-4e470e4adb9d	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 22:00:40.882552+00	
00000000-0000-0000-0000-000000000000	b1d8efa5-8cb9-44f7-a3cd-89bfaa775eeb	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 22:00:59.849086+00	
00000000-0000-0000-0000-000000000000	9bfa17da-7a22-4735-a2b7-c156d4be95da	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 22:00:59.851584+00	
00000000-0000-0000-0000-000000000000	f0d87366-4cac-40ad-a17a-a2b589be962d	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 23:00:10.197467+00	
00000000-0000-0000-0000-000000000000	f0251960-73c0-47a5-ac35-998828160852	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 23:00:10.199229+00	
00000000-0000-0000-0000-000000000000	54c96e8d-9f3f-4b29-918f-be7a850b770b	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 23:00:19.469246+00	
00000000-0000-0000-0000-000000000000	3b9b0a34-ee67-42e1-8d2e-e98d40bc8b0d	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 23:00:19.470548+00	
00000000-0000-0000-0000-000000000000	dc0afa2f-167f-431f-a156-6a1299603e0c	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 23:59:40.006827+00	
00000000-0000-0000-0000-000000000000	b7d0bc3a-2228-49d8-b86a-6bad6f29ef5c	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 23:59:40.008168+00	
00000000-0000-0000-0000-000000000000	babce701-f1d2-47e5-b5a4-4c59d83b83fd	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 23:59:52.169985+00	
00000000-0000-0000-0000-000000000000	03a4f34d-d85f-43fe-ba0f-2e9c7b5429e8	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-16 23:59:52.172449+00	
00000000-0000-0000-0000-000000000000	8c6b1b06-4d5c-44cb-9c77-fdc8ce793023	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 00:59:10.240443+00	
00000000-0000-0000-0000-000000000000	150770ac-facb-49a4-95df-0b12553d0e29	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 00:59:10.246434+00	
00000000-0000-0000-0000-000000000000	c0d84423-4252-4b71-913b-75121b629edc	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 00:59:19.424353+00	
00000000-0000-0000-0000-000000000000	1c5e18e2-8daa-4438-a1c6-707eac2c6b9f	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 00:59:19.426631+00	
00000000-0000-0000-0000-000000000000	29f87d5c-8983-4b69-8643-b22753d1dccf	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 01:58:46.512852+00	
00000000-0000-0000-0000-000000000000	0e684d1d-cea9-40a7-b126-d7d6b5abfc0d	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 01:58:46.518083+00	
00000000-0000-0000-0000-000000000000	a8a70445-4fe4-4cca-b881-a04d3a1817c5	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 01:58:46.588166+00	
00000000-0000-0000-0000-000000000000	0878bd06-d415-4c73-ab39-359099c8f772	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 01:58:46.589874+00	
00000000-0000-0000-0000-000000000000	29e480b8-6bb0-4401-ad0b-52dddecd232e	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 02:58:46.347785+00	
00000000-0000-0000-0000-000000000000	9f64e618-075c-4e61-8de8-a64100bed864	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 02:58:46.348569+00	
00000000-0000-0000-0000-000000000000	c95776c6-9a3c-4a8c-be4a-41ad84a6e03c	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 02:58:46.34914+00	
00000000-0000-0000-0000-000000000000	00e0c691-9560-4099-80fd-8cc413335a93	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 02:58:46.34949+00	
00000000-0000-0000-0000-000000000000	477aeff5-04da-4caf-9425-af6069fd70f3	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 03:58:46.134231+00	
00000000-0000-0000-0000-000000000000	a06562ea-fa8f-4f9e-8e21-89a85f03a4a8	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 03:58:46.140038+00	
00000000-0000-0000-0000-000000000000	aff61f93-c515-46da-8d46-23b9e747cb79	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 04:58:45.858548+00	
00000000-0000-0000-0000-000000000000	026fd54d-aae5-415f-badc-a4fafa987efb	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 04:58:45.85968+00	
00000000-0000-0000-0000-000000000000	d9bf1350-47a2-4cc5-84cf-a6af08489046	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 05:58:46.313456+00	
00000000-0000-0000-0000-000000000000	76a0979e-63a4-4405-be4e-f446463f36cf	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 05:58:46.314518+00	
00000000-0000-0000-0000-000000000000	448827a6-af72-4156-804a-59d37dc2e582	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 06:55:22.222637+00	
00000000-0000-0000-0000-000000000000	1f91d1da-90ba-4e26-858f-20d0e5470153	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 06:55:22.229349+00	
00000000-0000-0000-0000-000000000000	49eda095-6273-4d94-aed1-9e235bbd2d00	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 06:58:46.757441+00	
00000000-0000-0000-0000-000000000000	22b8ea7b-6425-44e4-afc3-c981070e89ba	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 06:58:46.76216+00	
00000000-0000-0000-0000-000000000000	58a17a00-a453-411b-a423-d6507ba47730	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 07:58:45.435625+00	
00000000-0000-0000-0000-000000000000	0adbf65e-c6c3-4f07-a22b-1847cbd2508d	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 07:58:45.440334+00	
00000000-0000-0000-0000-000000000000	b266cb05-c884-4500-bed4-4edf07f4219b	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 08:58:45.790509+00	
00000000-0000-0000-0000-000000000000	0b5899a6-f1e3-4897-aea7-06fe10dc611c	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 08:58:45.796501+00	
00000000-0000-0000-0000-000000000000	ecd23083-95c1-4265-a2a8-a983597bb200	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 09:59:45.753678+00	
00000000-0000-0000-0000-000000000000	67c4c603-f5eb-4ff6-aa13-d27d2d50b1ff	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 09:59:45.755268+00	
00000000-0000-0000-0000-000000000000	ba059fd1-0ebe-4ba9-9a23-03c87ce2a833	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 10:59:45.067784+00	
00000000-0000-0000-0000-000000000000	92e3ecf0-7634-4311-95c7-567ea32bed14	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 10:59:45.069076+00	
00000000-0000-0000-0000-000000000000	a49bdfee-a221-4b54-84c5-5b2bc16309e7	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 10:59:45.09968+00	
00000000-0000-0000-0000-000000000000	47cf5d16-08b6-4485-9c22-5c216ecd7ee8	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 10:59:45.100949+00	
00000000-0000-0000-0000-000000000000	0487f29d-23b1-4ab0-9c59-30c71955e664	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 11:59:58.972575+00	
00000000-0000-0000-0000-000000000000	7a799d7e-00d1-4881-ac7c-75f307d6d326	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 11:59:58.97438+00	
00000000-0000-0000-0000-000000000000	a2652000-ecea-4af6-b624-ad8a1f0e79e7	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 12:59:59.956873+00	
00000000-0000-0000-0000-000000000000	df7f7b3b-f610-4c14-a655-69ca7010a501	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 12:59:59.95789+00	
00000000-0000-0000-0000-000000000000	13a8cfb5-11e0-4e7a-b024-1fe9c7822fc9	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 13:00:44.914764+00	
00000000-0000-0000-0000-000000000000	8b14b40d-f72f-4f40-b9c9-657a4f4eef9d	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 13:00:44.915953+00	
00000000-0000-0000-0000-000000000000	3d0853f4-7889-4c49-9acc-e6127d311a3f	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 00:58:19.430475+00	
00000000-0000-0000-0000-000000000000	f68003ff-14fa-42ee-8dfc-878a9b23890b	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 00:58:19.436044+00	
00000000-0000-0000-0000-000000000000	865aece7-d33b-4353-ad18-ad627b2e0bb3	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 01:00:36.397276+00	
00000000-0000-0000-0000-000000000000	d6f211f5-7b30-41ea-9b77-dae65eddfad8	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 01:00:36.398465+00	
00000000-0000-0000-0000-000000000000	695477fb-cdf6-4e82-a0a8-f6d751079e41	{"action":"user_signedup","actor_id":"11f94728-d012-4413-819b-79fe1a30fe6c","actor_username":"testcustomer@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-10-20 01:33:15.380187+00	
00000000-0000-0000-0000-000000000000	e28b93d4-a165-46cd-9a32-cb543aa35420	{"action":"login","actor_id":"11f94728-d012-4413-819b-79fe1a30fe6c","actor_username":"testcustomer@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-20 01:33:15.39017+00	
00000000-0000-0000-0000-000000000000	33ba880e-b36b-40d6-91d4-ea28ec6341bb	{"action":"login","actor_id":"11f94728-d012-4413-819b-79fe1a30fe6c","actor_username":"testcustomer@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-20 01:33:17.511691+00	
00000000-0000-0000-0000-000000000000	71a20d6e-65e1-408c-95ab-ce1214c066be	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 01:57:39.244716+00	
00000000-0000-0000-0000-000000000000	ad8b71c4-4608-4a1a-b3b7-6387bab9e317	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 01:57:39.247115+00	
00000000-0000-0000-0000-000000000000	92817f1c-ffb9-4a6c-a7f5-a31408c4885d	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 02:00:26.419138+00	
00000000-0000-0000-0000-000000000000	98f72a99-d256-4f7e-8a95-7c36635cb829	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 02:00:26.420122+00	
00000000-0000-0000-0000-000000000000	86631a6f-0124-4b44-812f-005ffa1eb577	{"action":"token_refreshed","actor_id":"11f94728-d012-4413-819b-79fe1a30fe6c","actor_username":"testcustomer@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 02:33:11.276759+00	
00000000-0000-0000-0000-000000000000	025501d2-5f26-4727-accf-eb8ebc887324	{"action":"token_revoked","actor_id":"11f94728-d012-4413-819b-79fe1a30fe6c","actor_username":"testcustomer@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 02:33:11.279074+00	
00000000-0000-0000-0000-000000000000	c00e5c28-4b77-44a3-aac2-584cfbb4d762	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 02:57:39.384733+00	
00000000-0000-0000-0000-000000000000	3ea93fb3-45af-46cb-8507-2697a925f7dc	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 02:57:39.386703+00	
00000000-0000-0000-0000-000000000000	287d807a-4205-4363-b831-11c89cb3e3a5	{"action":"token_refreshed","actor_id":"11f94728-d012-4413-819b-79fe1a30fe6c","actor_username":"testcustomer@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 03:32:35.272344+00	
00000000-0000-0000-0000-000000000000	d104c45f-6965-44e1-b4d9-e3d091d4e0f2	{"action":"token_revoked","actor_id":"11f94728-d012-4413-819b-79fe1a30fe6c","actor_username":"testcustomer@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 03:32:35.276129+00	
00000000-0000-0000-0000-000000000000	b5d2d0e2-fa30-43a2-8980-d460af22398e	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 03:57:39.552367+00	
00000000-0000-0000-0000-000000000000	6fe22231-48e5-4d20-b53c-f1371ffb7984	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 03:57:39.554279+00	
00000000-0000-0000-0000-000000000000	df308aad-abf6-4988-91f7-2e4eb0a94c85	{"action":"token_refreshed","actor_id":"11f94728-d012-4413-819b-79fe1a30fe6c","actor_username":"testcustomer@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 04:32:26.353249+00	
00000000-0000-0000-0000-000000000000	afe230f6-7cc1-4961-af1d-02b77ab7c59b	{"action":"token_revoked","actor_id":"11f94728-d012-4413-819b-79fe1a30fe6c","actor_username":"testcustomer@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 04:32:26.355622+00	
00000000-0000-0000-0000-000000000000	dceaff48-5bef-47be-8114-1a089ce62108	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 04:45:37.292215+00	
00000000-0000-0000-0000-000000000000	438da71f-a52d-4235-b256-16cd3eeff4df	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 04:45:37.293695+00	
00000000-0000-0000-0000-000000000000	ae57db4e-5252-4979-9996-7d72c9ab2dce	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 04:57:39.419366+00	
00000000-0000-0000-0000-000000000000	3c766869-e333-4cdf-a5e2-10e02393c9d4	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 04:57:39.420749+00	
00000000-0000-0000-0000-000000000000	2dfa2c5c-90be-4d4f-aa8f-c088bcf6ede0	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 05:03:56.852132+00	
00000000-0000-0000-0000-000000000000	1bd6d939-e3f6-4d2d-9a8c-997725bb98d7	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 05:03:56.853663+00	
00000000-0000-0000-0000-000000000000	99dbf398-e547-4bb0-83f6-f1229610b8ac	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 11:59:58.972573+00	
00000000-0000-0000-0000-000000000000	60e0bb07-22fe-45e0-8163-22898e55b5ee	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 11:59:58.974676+00	
00000000-0000-0000-0000-000000000000	c4d60f8e-4a1e-4da8-be6b-1ed97c721288	{"action":"token_refreshed","actor_id":"11f94728-d012-4413-819b-79fe1a30fe6c","actor_username":"testcustomer@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 05:31:54.2304+00	
00000000-0000-0000-0000-000000000000	62428ed8-6fb5-4ebc-a14d-6ea039792073	{"action":"token_revoked","actor_id":"11f94728-d012-4413-819b-79fe1a30fe6c","actor_username":"testcustomer@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 05:31:54.232856+00	
00000000-0000-0000-0000-000000000000	846fc6fd-f1aa-474b-9ecc-d58b7c5034b4	{"action":"token_refreshed","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 05:45:46.009006+00	
00000000-0000-0000-0000-000000000000	1715fcc5-2ed5-45cf-a9a9-3dd941236729	{"action":"token_revoked","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 05:45:46.011228+00	
00000000-0000-0000-0000-000000000000	882898a3-99af-46a9-b832-7f01d681e79e	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 05:57:39.508501+00	
00000000-0000-0000-0000-000000000000	cc031127-d79d-4f40-9d68-72ec1464ada6	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 05:57:39.509822+00	
00000000-0000-0000-0000-000000000000	c2eeeb03-f516-4618-9320-1f459c4ff9e6	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 06:03:26.225024+00	
00000000-0000-0000-0000-000000000000	e1a1e68a-e9cf-472b-a88b-0f8751b5a5d9	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 06:03:26.226429+00	
00000000-0000-0000-0000-000000000000	61bc1628-d6b7-4125-86e4-ea34f469ec56	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 06:03:26.270557+00	
00000000-0000-0000-0000-000000000000	5b1186fb-5622-4729-a832-2dfe9b81a7a6	{"action":"token_refreshed","actor_id":"11f94728-d012-4413-819b-79fe1a30fe6c","actor_username":"testcustomer@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 06:31:26.431818+00	
00000000-0000-0000-0000-000000000000	18819176-ec87-4e67-b3c1-b2dac0262e71	{"action":"token_revoked","actor_id":"11f94728-d012-4413-819b-79fe1a30fe6c","actor_username":"testcustomer@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 06:31:26.433619+00	
00000000-0000-0000-0000-000000000000	4e2eac6f-5a5c-43c7-9333-42353e881668	{"action":"token_refreshed","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 06:54:47.678457+00	
00000000-0000-0000-0000-000000000000	ff31df9d-8b2b-44ee-bea7-34d81d2318a7	{"action":"token_revoked","actor_id":"581142f6-a7dd-41dc-8e01-cb0f2eeb54cb","actor_username":"pointer091489@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 06:54:47.680121+00	
00000000-0000-0000-0000-000000000000	8a3e5fb6-83c7-459f-bdfc-dbadafd6cb1b	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 06:57:39.532354+00	
00000000-0000-0000-0000-000000000000	04374bed-5f09-41c7-8cdb-1d453f5a9b76	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 06:57:39.534611+00	
00000000-0000-0000-0000-000000000000	8056530e-d50c-4c2a-b4ee-4753b5f778d6	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 07:03:26.277864+00	
00000000-0000-0000-0000-000000000000	ee02fdb4-f9d9-4a11-a292-244178c0055c	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 07:03:26.279153+00	
00000000-0000-0000-0000-000000000000	0b0b25a1-59c3-4409-a16e-6b3dec320488	{"action":"token_refreshed","actor_id":"11f94728-d012-4413-819b-79fe1a30fe6c","actor_username":"testcustomer@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 07:31:26.25693+00	
00000000-0000-0000-0000-000000000000	dee26a4a-1fd3-40c5-8fe8-be5b9daf9901	{"action":"token_revoked","actor_id":"11f94728-d012-4413-819b-79fe1a30fe6c","actor_username":"testcustomer@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 07:31:26.258733+00	
00000000-0000-0000-0000-000000000000	bcc0167f-5779-4eb7-9183-d2fc09d3fd26	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 07:57:39.728587+00	
00000000-0000-0000-0000-000000000000	87fe6b1a-508c-415f-b044-97fd2f42e829	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 07:57:39.730036+00	
00000000-0000-0000-0000-000000000000	f94a91f2-9858-47b4-9944-008901c680fd	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 08:03:26.363905+00	
00000000-0000-0000-0000-000000000000	b13c88be-1f36-451d-92d2-cba50dfb737f	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 08:03:26.365949+00	
00000000-0000-0000-0000-000000000000	1322e9c1-c479-45b4-a92d-5868d0c2572e	{"action":"token_refreshed","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 08:57:39.731231+00	
00000000-0000-0000-0000-000000000000	e2cdbfa5-8b35-40e6-b270-346809f1f0a4	{"action":"token_revoked","actor_id":"afb7e323-2304-42f0-84ba-c43d09380d0d","actor_username":"chunyunyam108010@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 08:57:39.737682+00	
00000000-0000-0000-0000-000000000000	075f42e9-e9c8-471f-a485-1a43f748de23	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 09:03:27.377537+00	
00000000-0000-0000-0000-000000000000	b0ff0b91-db94-4815-af18-32287ee68274	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-20 09:03:27.399634+00	
00000000-0000-0000-0000-000000000000	035f6246-837f-494e-b707-94abe4925f4a	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 03:58:46.13423+00	
00000000-0000-0000-0000-000000000000	176ac10f-1135-4e96-99be-bc079f7c5fb2	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 03:58:46.141831+00	
00000000-0000-0000-0000-000000000000	9d9b6edf-3b17-4a78-ad37-b23784ed193a	{"action":"token_refreshed","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 04:58:45.856356+00	
00000000-0000-0000-0000-000000000000	1148604d-1829-473a-a5f0-16e011533975	{"action":"token_revoked","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 04:58:45.859097+00	
00000000-0000-0000-0000-000000000000	e710f48f-e2c3-44d5-b542-484f84a9a9b3	{"action":"login","actor_id":"b48d15d8-c7cb-4782-a8fb-b43055c49a1e","actor_username":"yunitrish0419@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-10-17 05:55:32.801646+00	
00000000-0000-0000-0000-000000000000	82c1e99a-2057-404d-904e-14c520c658bb	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 05:58:46.313737+00	
00000000-0000-0000-0000-000000000000	1eb5f6e0-fba3-44ec-bf1e-617ac05bf6b7	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 05:58:46.314559+00	
00000000-0000-0000-0000-000000000000	d08a91fd-0493-4dd3-8675-583132d36b89	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 06:58:46.757414+00	
00000000-0000-0000-0000-000000000000	0e15641c-a120-4f2e-9ba4-2dc5a9f0a08e	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 06:58:46.762156+00	
00000000-0000-0000-0000-000000000000	56bd65e2-2580-44f6-b899-c0a8deeb9616	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 07:58:45.436169+00	
00000000-0000-0000-0000-000000000000	780e9569-0f76-480a-be98-9adb1675dd45	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 07:58:45.440337+00	
00000000-0000-0000-0000-000000000000	dd4bc0ab-59d2-4760-8864-9577979086d0	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 08:58:45.790507+00	
00000000-0000-0000-0000-000000000000	e46f620b-41d9-437e-aa76-28b3e66dea1b	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 08:58:45.796464+00	
00000000-0000-0000-0000-000000000000	bf07b6f4-5e3d-4ff5-8390-56f1ca52bf53	{"action":"token_refreshed","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 09:59:45.753296+00	
00000000-0000-0000-0000-000000000000	a0eeb41a-ec91-4535-8e90-2f0fdd57a220	{"action":"token_revoked","actor_id":"a939945b-b080-4575-871b-91e222484828","actor_username":"coseligtest@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-10-17 09:59:45.755253+00	
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
a939945b-b080-4575-871b-91e222484828	a939945b-b080-4575-871b-91e222484828	{"sub": "a939945b-b080-4575-871b-91e222484828", "email": "coseligtest@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-10-01 06:30:30.75808+00	2025-10-01 06:30:30.758181+00	2025-10-01 06:30:30.758181+00	dbdc35a5-666f-4e4d-ad0e-879ce122e769
b48d15d8-c7cb-4782-a8fb-b43055c49a1e	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	{"sub": "b48d15d8-c7cb-4782-a8fb-b43055c49a1e", "email": "yunitrish0419@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-10-02 05:45:11.70139+00	2025-10-02 05:45:11.701519+00	2025-10-02 05:45:11.701519+00	34cd9711-ae51-45f6-abc0-8613036eb665
967e7680-75e4-4b14-a15d-8936c7e92bc7	967e7680-75e4-4b14-a15d-8936c7e92bc7	{"sub": "967e7680-75e4-4b14-a15d-8936c7e92bc7", "email": "a0987533182@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-10-02 08:37:38.914318+00	2025-10-02 08:37:38.914381+00	2025-10-02 08:37:38.914381+00	2c488279-8a86-4c8e-919b-893b7aa9df04
581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	{"sub": "581142f6-a7dd-41dc-8e01-cb0f2eeb54cb", "email": "pointer091489@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-10-07 09:08:34.211067+00	2025-10-07 09:08:34.211279+00	2025-10-07 09:08:34.211279+00	1734efdc-291e-487c-9d4d-212453db2229
8b37894d-57e6-4c75-aa1c-82329839a080	8b37894d-57e6-4c75-aa1c-82329839a080	{"sub": "8b37894d-57e6-4c75-aa1c-82329839a080", "email": "my@coselig.com", "email_verified": false, "phone_verified": false}	email	2025-10-08 03:21:09.332216+00	2025-10-08 03:21:09.332289+00	2025-10-08 03:21:09.332289+00	23fbe231-f351-46e0-a9e8-29075ef5633f
afb7e323-2304-42f0-84ba-c43d09380d0d	afb7e323-2304-42f0-84ba-c43d09380d0d	{"sub": "afb7e323-2304-42f0-84ba-c43d09380d0d", "email": "chunyunyam108010@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-10-08 06:31:54.249296+00	2025-10-08 06:31:54.249421+00	2025-10-08 06:31:54.249421+00	130f35a7-f3e6-4dbb-9e84-10d27c70ee50
11f94728-d012-4413-819b-79fe1a30fe6c	11f94728-d012-4413-819b-79fe1a30fe6c	{"sub": "11f94728-d012-4413-819b-79fe1a30fe6c", "email": "testcustomer@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-10-20 01:33:15.372505+00	2025-10-20 01:33:15.37255+00	2025-10-20 01:33:15.37255+00	4866667a-6a95-47b9-82d8-a7049623d484
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
0a93cf2e-7ed2-4b75-b932-57321f2ae6ae	2025-10-01 06:30:30.779697+00	2025-10-01 06:30:30.779697+00	password	d2553bdf-456f-468c-b890-1417808e1d30
dd47842e-d6a0-4c9b-9056-835916865833	2025-10-01 06:32:57.581807+00	2025-10-01 06:32:57.581807+00	password	c9686030-0663-4eb7-b986-502b7c25362b
ec07d3d0-561c-4f2d-a4d1-ebaedbacdec0	2025-10-02 05:17:42.946062+00	2025-10-02 05:17:42.946062+00	password	7094eef3-3c30-43cf-b21c-a1fba40d2a91
cfef587a-5e6f-4dc4-9c8e-50ac99d096d9	2025-10-02 08:37:38.936009+00	2025-10-02 08:37:38.936009+00	password	a41212d9-2feb-4785-808b-516fe577dc7f
b53c57e2-006f-49d8-b171-7e95211dd839	2025-10-07 02:14:01.023644+00	2025-10-07 02:14:01.023644+00	password	211159c3-733d-4603-9c3f-4ce823769fbe
0e759360-1482-442c-98f9-49b927ca9766	2025-10-07 07:36:13.271614+00	2025-10-07 07:36:13.271614+00	password	33bfbf6e-cea7-456a-b702-e92e407fa917
25ff321c-9561-46c3-872a-78c1661edb5f	2025-10-08 03:21:09.35935+00	2025-10-08 03:21:09.35935+00	password	37fe246c-8c20-4054-8ba0-e5ee78959853
5254186f-6f1b-4be5-bbe7-db6612669d28	2025-10-08 03:23:53.766604+00	2025-10-08 03:23:53.766604+00	password	33af02f7-a7bc-4fa9-a239-24cdbeaf8084
0a9434f8-ee7f-43cf-b309-2e75c3a35d64	2025-10-08 06:31:54.271985+00	2025-10-08 06:31:54.271985+00	password	30527f47-887b-4cb4-afc5-c9aea06bd7f0
09f23050-fffa-4263-8df8-8e5cd3a6363e	2025-10-08 06:31:58.407633+00	2025-10-08 06:31:58.407633+00	password	f7cc986d-14fc-46da-be6f-8f2e377c92d8
8e3ec9d1-0c71-490a-8dac-96ccefad86ea	2025-10-14 09:28:56.749505+00	2025-10-14 09:28:56.749505+00	password	e481fb8e-50e7-4336-981b-528cebc0d06b
a2aaee5d-0b51-4045-9fdd-7e96c92040bd	2025-10-14 09:33:23.214949+00	2025-10-14 09:33:23.214949+00	password	17bbd749-1218-41c6-836b-b0b675f6db64
5e782e6d-265d-4c69-96d3-3d81d738af20	2025-10-14 09:35:12.520035+00	2025-10-14 09:35:12.520035+00	password	58c7dd9d-e13b-4395-a9b8-ca890e76ed75
8ea7dab2-47e9-4036-add7-0c1bce519c52	2025-10-16 09:08:26.436055+00	2025-10-16 09:08:26.436055+00	password	9dc011ac-4df2-4f73-973f-242178b75647
53b02269-832f-4631-805d-b5fbd24d1526	2025-10-16 09:08:45.275419+00	2025-10-16 09:08:45.275419+00	password	478379ea-9429-4a96-bde2-8b26857fc1be
7dd2415f-1d3d-43ca-8795-1c4e9bbc418f	2025-10-17 05:55:32.815041+00	2025-10-17 05:55:32.815041+00	password	bb66412d-b7c4-43e1-9bf9-d7d16a1f2287
84307570-6750-4110-a514-7d76d07adcc1	2025-10-20 01:33:15.403452+00	2025-10-20 01:33:15.403452+00	password	e0294d64-4517-4a81-a677-7616ad9edc1a
83cabd19-38d0-4a1c-bfd0-49677b16759c	2025-10-20 01:33:17.517687+00	2025-10-20 01:33:17.517687+00	password	ea518ddb-7533-4f7d-b0db-e90cc3dd6760
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
00000000-0000-0000-0000-000000000000	4	uubs75wstfgm	a939945b-b080-4575-871b-91e222484828	f	2025-10-01 06:30:30.777314+00	2025-10-01 06:30:30.777314+00	\N	0a93cf2e-7ed2-4b75-b932-57321f2ae6ae
00000000-0000-0000-0000-000000000000	132	eoissgg36lpt	a939945b-b080-4575-871b-91e222484828	t	2025-10-07 03:14:08.211887+00	2025-10-07 04:14:07.558734+00	nqw6oxwmfyuq	b53c57e2-006f-49d8-b171-7e95211dd839
00000000-0000-0000-0000-000000000000	6	wpze3ww3r5mo	a939945b-b080-4575-871b-91e222484828	f	2025-10-01 06:32:57.578747+00	2025-10-01 06:32:57.578747+00	\N	dd47842e-d6a0-4c9b-9056-835916865833
00000000-0000-0000-0000-000000000000	322	5liqbry5yxp3	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-13 00:31:45.257951+00	2025-10-13 01:32:00.375991+00	3u7e3t6bwuhd	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	214	4k76p4sk6ynz	8b37894d-57e6-4c75-aa1c-82329839a080	f	2025-10-09 00:36:01.061039+00	2025-10-09 00:36:01.061039+00	5ssz3nqosvu5	5254186f-6f1b-4be5-bbe7-db6612669d28
00000000-0000-0000-0000-000000000000	133	3ds5j2yb7abb	a939945b-b080-4575-871b-91e222484828	t	2025-10-07 04:14:07.559864+00	2025-10-07 05:13:30.901185+00	eoissgg36lpt	b53c57e2-006f-49d8-b171-7e95211dd839
00000000-0000-0000-0000-000000000000	414	zuutq4uz2f2s	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-16 09:08:26.433617+00	2025-10-16 10:07:51.426647+00	\N	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	182	hlqtbidfstm4	afb7e323-2304-42f0-84ba-c43d09380d0d	f	2025-10-08 06:31:54.269134+00	2025-10-08 06:31:54.269134+00	\N	0a9434f8-ee7f-43cf-b309-2e75c3a35d64
00000000-0000-0000-0000-000000000000	211	25pibik7nz7a	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-09 00:30:54.792316+00	2025-10-09 01:30:20.716816+00	7k73omenns4y	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	134	w3gbojpxkpx3	a939945b-b080-4575-871b-91e222484828	t	2025-10-07 05:13:30.901887+00	2025-10-07 06:12:50.279651+00	3ds5j2yb7abb	b53c57e2-006f-49d8-b171-7e95211dd839
00000000-0000-0000-0000-000000000000	415	mky6ecsiqrer	a939945b-b080-4575-871b-91e222484828	t	2025-10-16 09:08:45.271945+00	2025-10-16 10:08:10.920819+00	\N	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	417	mncjksmm2ziz	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-16 10:07:51.429907+00	2025-10-16 11:07:20.854603+00	zuutq4uz2f2s	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	135	giiv4oqirwt7	a939945b-b080-4575-871b-91e222484828	t	2025-10-07 06:12:50.282537+00	2025-10-07 07:13:07.811214+00	w3gbojpxkpx3	b53c57e2-006f-49d8-b171-7e95211dd839
00000000-0000-0000-0000-000000000000	216	lnkjt2mkkafq	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-09 01:30:20.717353+00	2025-10-09 02:30:21.468914+00	25pibik7nz7a	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	136	fbbi6hftornt	a939945b-b080-4575-871b-91e222484828	f	2025-10-07 07:13:07.816296+00	2025-10-07 07:13:07.816296+00	giiv4oqirwt7	b53c57e2-006f-49d8-b171-7e95211dd839
00000000-0000-0000-0000-000000000000	325	64b5gzaesrge	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-13 01:32:00.379481+00	2025-10-13 02:32:00.759318+00	5liqbry5yxp3	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	418	xb2dltuvj7vm	a939945b-b080-4575-871b-91e222484828	t	2025-10-16 10:08:10.921255+00	2025-10-16 11:07:31.551139+00	mky6ecsiqrer	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	183	u7l2rlcjgpeg	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-08 06:31:58.405593+00	2025-10-08 07:32:06.176527+00	\N	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	419	an5slnco67in	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-16 11:07:20.855569+00	2025-10-16 12:06:41.355416+00	mncjksmm2ziz	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	218	uckegvnyvm5x	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-09 02:30:21.469417+00	2025-10-09 03:30:21.324099+00	lnkjt2mkkafq	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	420	duwol5s7iqu3	a939945b-b080-4575-871b-91e222484828	t	2025-10-16 11:07:31.552116+00	2025-10-16 12:07:00.858959+00	xb2dltuvj7vm	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	421	czhmheu4ab3d	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-16 12:06:41.355918+00	2025-10-16 13:06:10.528194+00	an5slnco67in	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	422	theuoo6vrx3u	a939945b-b080-4575-871b-91e222484828	t	2025-10-16 12:07:00.859965+00	2025-10-16 13:06:29.677208+00	duwol5s7iqu3	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	327	5sk4h6ag5jqx	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-13 02:32:00.759789+00	2025-10-13 03:32:00.748464+00	64b5gzaesrge	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	423	urnjwkgfctvd	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-16 13:06:10.528972+00	2025-10-16 14:05:39.849898+00	czhmheu4ab3d	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	424	56majun5crln	a939945b-b080-4575-871b-91e222484828	t	2025-10-16 13:06:29.677655+00	2025-10-16 14:05:50.472498+00	theuoo6vrx3u	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	425	75ptln4xbaxh	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-16 14:05:39.850847+00	2025-10-16 15:05:06.059806+00	urnjwkgfctvd	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	329	eiqemb7vmsjh	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-13 03:32:00.748944+00	2025-10-13 04:32:00.874059+00	5sk4h6ag5jqx	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	426	wfcvivrpy5v6	a939945b-b080-4575-871b-91e222484828	t	2025-10-16 14:05:50.472966+00	2025-10-16 15:05:21.281484+00	56majun5crln	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	331	n7dcomgpr3ue	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-13 04:32:00.874553+00	2025-10-13 05:32:00.84785+00	eiqemb7vmsjh	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	427	5zqu7g32t3ge	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-16 15:05:06.060393+00	2025-10-16 16:04:29.999408+00	75ptln4xbaxh	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	428	rhmkdd6p2u4q	a939945b-b080-4575-871b-91e222484828	t	2025-10-16 15:05:21.281832+00	2025-10-16 16:04:49.919884+00	wfcvivrpy5v6	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	429	ca244r5k6vzg	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-16 16:04:29.999832+00	2025-10-16 17:03:59.824214+00	5zqu7g32t3ge	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	430	zixpxtdybz2t	a939945b-b080-4575-871b-91e222484828	t	2025-10-16 16:04:49.920663+00	2025-10-16 17:04:10.773281+00	rhmkdd6p2u4q	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	431	z4cx2zr2pekl	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-16 17:03:59.824746+00	2025-10-16 18:03:19.970402+00	ca244r5k6vzg	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	332	fys3dwgmdfv7	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-13 05:32:00.849627+00	2025-10-13 06:32:00.962901+00	n7dcomgpr3ue	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	432	knh5qu7xenok	a939945b-b080-4575-871b-91e222484828	t	2025-10-16 17:04:10.773878+00	2025-10-16 18:03:39.798632+00	zixpxtdybz2t	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	433	d7anydmcueso	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-16 18:03:19.971201+00	2025-10-16 19:02:39.817459+00	z4cx2zr2pekl	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	434	ip7hlfpb3ij5	a939945b-b080-4575-871b-91e222484828	t	2025-10-16 18:03:39.798947+00	2025-10-16 19:02:59.75505+00	knh5qu7xenok	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	435	eittm2qaifyv	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-16 19:02:39.817878+00	2025-10-16 20:01:59.830285+00	d7anydmcueso	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	436	wd36fzlnpady	a939945b-b080-4575-871b-91e222484828	t	2025-10-16 19:02:59.755609+00	2025-10-16 20:02:19.810384+00	ip7hlfpb3ij5	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	437	qjduhddbceig	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-16 20:01:59.830899+00	2025-10-16 21:01:19.825587+00	eittm2qaifyv	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	438	hpgzo2en3ojt	a939945b-b080-4575-871b-91e222484828	t	2025-10-16 20:02:19.810718+00	2025-10-16 21:01:39.802821+00	wd36fzlnpady	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	439	d7grz66yswht	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-16 21:01:19.826159+00	2025-10-16 22:00:40.88334+00	qjduhddbceig	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	41	ix6nrg5fefon	a939945b-b080-4575-871b-91e222484828	t	2025-10-02 05:17:42.938448+00	2025-10-02 06:17:57.448992+00	\N	ec07d3d0-561c-4f2d-a4d1-ebaedbacdec0
00000000-0000-0000-0000-000000000000	51	t7geeoexcztq	a939945b-b080-4575-871b-91e222484828	f	2025-10-02 06:17:57.451801+00	2025-10-02 06:17:57.451801+00	ix6nrg5fefon	ec07d3d0-561c-4f2d-a4d1-ebaedbacdec0
00000000-0000-0000-0000-000000000000	440	yjtthqzqogvh	a939945b-b080-4575-871b-91e222484828	t	2025-10-16 21:01:39.803347+00	2025-10-16 22:00:59.853934+00	hpgzo2en3ojt	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	441	ldzfd25j2olr	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-16 22:00:40.883738+00	2025-10-16 23:00:10.200231+00	d7grz66yswht	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	416	atqvnlwnl7wa	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-16 09:16:37.307764+00	2025-10-20 00:58:19.437215+00	acxzlns4u7w3	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	391	lbdrtww2qgzc	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	t	2025-10-15 14:48:52.829956+00	2025-10-20 05:45:46.012984+00	7aveu5zl4rxh	5e782e6d-265d-4c69-96d3-3d81d738af20
00000000-0000-0000-0000-000000000000	55	3i77tpsltkvh	967e7680-75e4-4b14-a15d-8936c7e92bc7	f	2025-10-02 08:37:38.933697+00	2025-10-02 08:37:38.933697+00	\N	cfef587a-5e6f-4dc4-9c8e-50ac99d096d9
00000000-0000-0000-0000-000000000000	191	7k73omenns4y	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-08 08:50:55.732828+00	2025-10-09 00:30:54.791543+00	2w65zatscxef	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	139	i67vrxe2tksa	a939945b-b080-4575-871b-91e222484828	f	2025-10-07 07:36:13.268584+00	2025-10-07 07:36:13.268584+00	\N	0e759360-1482-442c-98f9-49b927ca9766
00000000-0000-0000-0000-000000000000	234	3u7e3t6bwuhd	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-09 09:30:21.330877+00	2025-10-13 00:31:45.227431+00	w2omjwst3uar	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	442	iwuliefsikeo	a939945b-b080-4575-871b-91e222484828	t	2025-10-16 22:00:59.854888+00	2025-10-16 23:00:19.471514+00	yjtthqzqogvh	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	188	2w65zatscxef	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-08 07:32:06.18194+00	2025-10-08 08:50:55.728919+00	u7l2rlcjgpeg	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	220	ay54nxa6vqsl	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-09 03:30:21.32486+00	2025-10-09 04:30:22.096649+00	uckegvnyvm5x	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	222	fqntvqpmt2b7	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-09 04:30:22.097858+00	2025-10-09 05:30:20.492784+00	ay54nxa6vqsl	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	224	pk62rofezgsd	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-09 05:30:20.494096+00	2025-10-09 06:30:21.239838+00	fqntvqpmt2b7	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	226	yuiw6ku2nc5s	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-09 06:30:21.241014+00	2025-10-09 07:30:21.742958+00	pk62rofezgsd	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	228	oubvhptchrfx	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-09 07:30:21.744326+00	2025-10-09 08:30:21.822465+00	yuiw6ku2nc5s	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	231	w2omjwst3uar	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-09 08:30:21.825969+00	2025-10-09 09:30:21.33014+00	oubvhptchrfx	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	131	nqw6oxwmfyuq	a939945b-b080-4575-871b-91e222484828	t	2025-10-07 02:14:01.018037+00	2025-10-07 03:14:08.210419+00	\N	b53c57e2-006f-49d8-b171-7e95211dd839
00000000-0000-0000-0000-000000000000	443	b5xgfxodw4od	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-16 23:00:10.203725+00	2025-10-16 23:59:40.00898+00	ldzfd25j2olr	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	173	5ssz3nqosvu5	8b37894d-57e6-4c75-aa1c-82329839a080	t	2025-10-08 03:23:53.764975+00	2025-10-09 00:36:01.059905+00	\N	5254186f-6f1b-4be5-bbe7-db6612669d28
00000000-0000-0000-0000-000000000000	444	6ok2fkuvnqij	a939945b-b080-4575-871b-91e222484828	t	2025-10-16 23:00:19.471894+00	2025-10-16 23:59:52.174756+00	iwuliefsikeo	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	445	us4osa5uqebn	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-16 23:59:40.011298+00	2025-10-17 00:59:10.247823+00	b5xgfxodw4od	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	446	4drgcye3toim	a939945b-b080-4575-871b-91e222484828	t	2025-10-16 23:59:52.175754+00	2025-10-17 00:59:19.428788+00	6ok2fkuvnqij	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	448	pqx3zyuzig57	a939945b-b080-4575-871b-91e222484828	t	2025-10-17 00:59:19.429673+00	2025-10-17 01:58:46.519346+00	4drgcye3toim	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	447	vmbpabo7dj2j	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-17 00:59:10.252728+00	2025-10-17 01:58:46.590804+00	us4osa5uqebn	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	449	lzcnrqq2bwu6	a939945b-b080-4575-871b-91e222484828	t	2025-10-17 01:58:46.524836+00	2025-10-17 02:58:46.350091+00	pqx3zyuzig57	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	170	2lwl5q7zjh4r	8b37894d-57e6-4c75-aa1c-82329839a080	f	2025-10-08 03:21:09.355196+00	2025-10-08 03:21:09.355196+00	\N	25ff321c-9561-46c3-872a-78c1661edb5f
00000000-0000-0000-0000-000000000000	451	nkl2xm7lz4jg	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-17 02:58:46.354094+00	2025-10-17 03:58:46.141233+00	qss5ohmfwu64	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	453	pep4qtr7gdv2	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-17 03:58:46.145287+00	2025-10-17 04:58:45.860063+00	nkl2xm7lz4jg	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	455	pcbbqpokxbk3	a939945b-b080-4575-871b-91e222484828	t	2025-10-17 04:58:45.862819+00	2025-10-17 05:58:46.31529+00	ou72hp3hmkkk	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	460	imeccdg23ixn	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	f	2025-10-17 06:55:22.234748+00	2025-10-17 06:55:22.234748+00	ccqlebmcytjm	7dd2415f-1d3d-43ca-8795-1c4e9bbc418f
00000000-0000-0000-0000-000000000000	458	76aqbeunc3yf	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-17 05:58:46.316824+00	2025-10-17 06:58:46.763429+00	7exxbfvqyauf	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	461	vqux4lfabqht	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-17 06:58:46.76748+00	2025-10-17 07:58:45.441258+00	76aqbeunc3yf	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	463	ncwo26ewbb3u	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-17 07:58:45.443919+00	2025-10-17 08:58:45.797933+00	vqux4lfabqht	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	466	e2pqd6sqiuvu	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-17 08:58:45.803353+00	2025-10-17 09:59:45.756403+00	ncwo26ewbb3u	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	468	72bojsewy4ub	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-17 09:59:45.760358+00	2025-10-17 10:59:45.10205+00	e2pqd6sqiuvu	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	470	2zhppatwgoea	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-17 10:59:45.102526+00	2025-10-17 11:59:58.975341+00	72bojsewy4ub	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	469	vw6zvlysvr6a	a939945b-b080-4575-871b-91e222484828	t	2025-10-17 10:59:45.070785+00	2025-10-17 11:59:58.975469+00	m4bbrzooxsbp	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	401	ki5otzbtr2zd	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-16 00:22:18.67831+00	2025-10-16 08:16:27.349383+00	sslyvxpfzmz4	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	471	asjmp7avcfma	a939945b-b080-4575-871b-91e222484828	t	2025-10-17 11:59:58.976169+00	2025-10-17 13:00:44.91714+00	vw6zvlysvr6a	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	477	4ghizpwm5g7e	11f94728-d012-4413-819b-79fe1a30fe6c	f	2025-10-20 01:33:15.39927+00	2025-10-20 01:33:15.39927+00	\N	84307570-6750-4110-a514-7d76d07adcc1
00000000-0000-0000-0000-000000000000	475	wb4rkpbp5bn6	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-20 00:58:19.438648+00	2025-10-20 01:57:39.24903+00	atqvnlwnl7wa	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	476	3stnlsbytp5t	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-20 01:00:36.400396+00	2025-10-20 02:00:26.420831+00	pnxb3ztcutpm	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	478	gbgp2toknrwf	11f94728-d012-4413-819b-79fe1a30fe6c	t	2025-10-20 01:33:17.51541+00	2025-10-20 02:33:11.280252+00	\N	83cabd19-38d0-4a1c-bfd0-49677b16759c
00000000-0000-0000-0000-000000000000	479	rxwevyyfzelc	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-20 01:57:39.254395+00	2025-10-20 02:57:39.38836+00	wb4rkpbp5bn6	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	481	jnvuxou6imuf	11f94728-d012-4413-819b-79fe1a30fe6c	t	2025-10-20 02:33:11.281909+00	2025-10-20 03:32:35.27706+00	gbgp2toknrwf	83cabd19-38d0-4a1c-bfd0-49677b16759c
00000000-0000-0000-0000-000000000000	482	ypw2ews6ommd	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-20 02:57:39.389553+00	2025-10-20 03:57:39.555827+00	rxwevyyfzelc	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	483	rw3t4xzz34na	11f94728-d012-4413-819b-79fe1a30fe6c	t	2025-10-20 03:32:35.280381+00	2025-10-20 04:32:26.357603+00	jnvuxou6imuf	83cabd19-38d0-4a1c-bfd0-49677b16759c
00000000-0000-0000-0000-000000000000	406	ipnbnnvg5jrp	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-16 03:41:08.149274+00	2025-10-20 04:45:37.295083+00	nds57swqutbv	8e3ec9d1-0c71-490a-8dac-96ccefad86ea
00000000-0000-0000-0000-000000000000	486	ckqpohge4s7p	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	f	2025-10-20 04:45:37.295955+00	2025-10-20 04:45:37.295955+00	ipnbnnvg5jrp	8e3ec9d1-0c71-490a-8dac-96ccefad86ea
00000000-0000-0000-0000-000000000000	484	sdk2by3p7o5x	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-20 03:57:39.556781+00	2025-10-20 04:57:39.422034+00	ypw2ews6ommd	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	480	qjsf57mvoq7r	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-20 02:00:26.421208+00	2025-10-20 05:03:56.854608+00	3stnlsbytp5t	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	485	wmxxjcsfegeu	11f94728-d012-4413-819b-79fe1a30fe6c	t	2025-10-20 04:32:26.359051+00	2025-10-20 05:31:54.234244+00	rw3t4xzz34na	83cabd19-38d0-4a1c-bfd0-49677b16759c
00000000-0000-0000-0000-000000000000	487	46iflys2htp3	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-20 04:57:39.422784+00	2025-10-20 05:57:39.510955+00	sdk2by3p7o5x	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	488	ka5gkwtzj2jn	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-20 05:03:56.855296+00	2025-10-20 06:03:26.227514+00	qjsf57mvoq7r	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	489	fumsh4xocc4x	11f94728-d012-4413-819b-79fe1a30fe6c	t	2025-10-20 05:31:54.235129+00	2025-10-20 06:31:26.436896+00	wmxxjcsfegeu	83cabd19-38d0-4a1c-bfd0-49677b16759c
00000000-0000-0000-0000-000000000000	490	j4iweo4mpbtl	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	t	2025-10-20 05:45:46.01514+00	2025-10-20 06:54:47.681566+00	lbdrtww2qgzc	5e782e6d-265d-4c69-96d3-3d81d738af20
00000000-0000-0000-0000-000000000000	491	o4mw7vnslmv6	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-20 05:57:39.51207+00	2025-10-20 06:57:39.536311+00	46iflys2htp3	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	492	57d2xvpuj5jk	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-20 06:03:26.228227+00	2025-10-20 07:03:26.281177+00	ka5gkwtzj2jn	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	335	uvbz3jbrkomb	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-13 06:32:00.963433+00	2025-10-13 07:32:01.662189+00	fys3dwgmdfv7	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	363	7aveu5zl4rxh	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	t	2025-10-14 14:10:47.406556+00	2025-10-15 14:48:52.829489+00	cowbg3dtyn7e	5e782e6d-265d-4c69-96d3-3d81d738af20
00000000-0000-0000-0000-000000000000	337	3atztklnu7k2	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-13 07:32:01.663969+00	2025-10-13 08:32:00.791537+00	uvbz3jbrkomb	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	353	sslyvxpfzmz4	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-14 08:43:24.335824+00	2025-10-16 00:22:18.67762+00	lxl4yr6jotde	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	450	qss5ohmfwu64	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-17 01:58:46.591632+00	2025-10-17 02:58:46.350311+00	vmbpabo7dj2j	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	378	nds57swqutbv	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-15 03:27:35.275334+00	2025-10-16 03:41:08.147663+00	cda5qyn6f2fe	8e3ec9d1-0c71-490a-8dac-96ccefad86ea
00000000-0000-0000-0000-000000000000	339	iwrqp3encx2a	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-13 08:32:00.792039+00	2025-10-13 09:31:23.026939+00	3atztklnu7k2	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	452	owo5robjg6yn	a939945b-b080-4575-871b-91e222484828	t	2025-10-17 02:58:46.354059+00	2025-10-17 03:58:46.14313+00	lzcnrqq2bwu6	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	454	ou72hp3hmkkk	a939945b-b080-4575-871b-91e222484828	t	2025-10-17 03:58:46.145294+00	2025-10-17 04:58:45.860567+00	owo5robjg6yn	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	456	7exxbfvqyauf	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-17 04:58:45.86278+00	2025-10-17 05:58:46.315297+00	pep4qtr7gdv2	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	457	ccqlebmcytjm	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-17 05:55:32.812072+00	2025-10-17 06:55:22.23091+00	\N	7dd2415f-1d3d-43ca-8795-1c4e9bbc418f
00000000-0000-0000-0000-000000000000	459	gb26bbasx4tl	a939945b-b080-4575-871b-91e222484828	t	2025-10-17 05:58:46.316786+00	2025-10-17 06:58:46.763426+00	pcbbqpokxbk3	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	462	uxguzrtovjt4	a939945b-b080-4575-871b-91e222484828	t	2025-10-17 06:58:46.767463+00	2025-10-17 07:58:45.44145+00	gb26bbasx4tl	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	464	2utkffslz7ro	a939945b-b080-4575-871b-91e222484828	t	2025-10-17 07:58:45.44395+00	2025-10-17 08:58:45.797917+00	uxguzrtovjt4	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	465	7q2sjjmajtdg	a939945b-b080-4575-871b-91e222484828	t	2025-10-17 08:58:45.803367+00	2025-10-17 09:59:45.756353+00	2utkffslz7ro	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	341	7q2susx7ywjt	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-13 09:31:23.027478+00	2025-10-14 07:43:33.493154+00	iwrqp3encx2a	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	467	m4bbrzooxsbp	a939945b-b080-4575-871b-91e222484828	t	2025-10-17 09:59:45.760367+00	2025-10-17 10:59:45.070155+00	7q2sjjmajtdg	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	472	mhgxqinzl7yl	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-17 11:59:58.976172+00	2025-10-17 12:59:59.958711+00	2zhppatwgoea	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	350	lxl4yr6jotde	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-14 07:43:33.495043+00	2025-10-14 08:43:24.333337+00	7q2susx7ywjt	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	494	nmopqt656ob4	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	f	2025-10-20 06:54:47.683046+00	2025-10-20 06:54:47.683046+00	j4iweo4mpbtl	5e782e6d-265d-4c69-96d3-3d81d738af20
00000000-0000-0000-0000-000000000000	493	qjwzerfecrwz	11f94728-d012-4413-819b-79fe1a30fe6c	t	2025-10-20 06:31:26.438792+00	2025-10-20 07:31:26.260174+00	fumsh4xocc4x	83cabd19-38d0-4a1c-bfd0-49677b16759c
00000000-0000-0000-0000-000000000000	356	ghaaiijblpr2	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	f	2025-10-14 09:33:23.213089+00	2025-10-14 09:33:23.213089+00	\N	a2aaee5d-0b51-4045-9fdd-7e96c92040bd
00000000-0000-0000-0000-000000000000	497	n4h7a23xdbaq	11f94728-d012-4413-819b-79fe1a30fe6c	f	2025-10-20 07:31:26.261386+00	2025-10-20 07:31:26.261386+00	qjwzerfecrwz	83cabd19-38d0-4a1c-bfd0-49677b16759c
00000000-0000-0000-0000-000000000000	495	fgor76hysrit	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-20 06:57:39.537309+00	2025-10-20 07:57:39.731313+00	o4mw7vnslmv6	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	496	p3pcpzfwtjv4	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-20 07:03:26.282649+00	2025-10-20 08:03:26.367617+00	57d2xvpuj5jk	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	498	on4gm6q3pm6m	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-20 07:57:39.732288+00	2025-10-20 08:57:39.738885+00	fgor76hysrit	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	500	jmh7nleo54gg	afb7e323-2304-42f0-84ba-c43d09380d0d	f	2025-10-20 08:57:39.741393+00	2025-10-20 08:57:39.741393+00	on4gm6q3pm6m	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	499	obm6nsde57hh	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-20 08:03:26.368915+00	2025-10-20 09:03:27.404222+00	p3pcpzfwtjv4	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	501	7pgyekh7jbup	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	f	2025-10-20 09:03:27.459089+00	2025-10-20 09:03:27.459089+00	obm6nsde57hh	8ea7dab2-47e9-4036-add7-0c1bce519c52
00000000-0000-0000-0000-000000000000	357	cowbg3dtyn7e	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	t	2025-10-14 09:35:12.518047+00	2025-10-14 14:10:47.403668+00	\N	5e782e6d-265d-4c69-96d3-3d81d738af20
00000000-0000-0000-0000-000000000000	355	lyoqpn2nbqif	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-14 09:28:56.747622+00	2025-10-15 00:32:01.079672+00	\N	8e3ec9d1-0c71-490a-8dac-96ccefad86ea
00000000-0000-0000-0000-000000000000	375	cda5qyn6f2fe	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-15 00:32:01.080448+00	2025-10-15 03:27:35.274693+00	lyoqpn2nbqif	8e3ec9d1-0c71-490a-8dac-96ccefad86ea
00000000-0000-0000-0000-000000000000	411	acxzlns4u7w3	afb7e323-2304-42f0-84ba-c43d09380d0d	t	2025-10-16 08:16:27.354254+00	2025-10-16 09:16:37.303498+00	ki5otzbtr2zd	09f23050-fffa-4263-8df8-8e5cd3a6363e
00000000-0000-0000-0000-000000000000	474	h33dochtl5b7	a939945b-b080-4575-871b-91e222484828	f	2025-10-17 13:00:44.917712+00	2025-10-17 13:00:44.917712+00	asjmp7avcfma	53b02269-832f-4631-805d-b5fbd24d1526
00000000-0000-0000-0000-000000000000	473	pnxb3ztcutpm	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	t	2025-10-17 12:59:59.959382+00	2025-10-20 01:00:36.399672+00	mhgxqinzl7yl	8ea7dab2-47e9-4036-add7-0c1bce519c52
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag) FROM stdin;
83cabd19-38d0-4a1c-bfd0-49677b16759c	11f94728-d012-4413-819b-79fe1a30fe6c	2025-10-20 01:33:17.514018+00	2025-10-20 07:31:26.265524+00	\N	aal1	\N	2025-10-20 07:31:26.265436	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	192.168.144.1	\N
0a93cf2e-7ed2-4b75-b932-57321f2ae6ae	a939945b-b080-4575-871b-91e222484828	2025-10-01 06:30:30.77539+00	2025-10-01 06:30:30.77539+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	172.18.0.1	\N
dd47842e-d6a0-4c9b-9056-835916865833	a939945b-b080-4575-871b-91e222484828	2025-10-01 06:32:57.57644+00	2025-10-01 06:32:57.57644+00	\N	aal1	\N	\N	Mozilla/5.0 (iPad; CPU OS 18_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/140.0.7339.101 Mobile/15E148 Safari/604.1	172.18.0.1	\N
8e3ec9d1-0c71-490a-8dac-96ccefad86ea	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	2025-10-14 09:28:56.745336+00	2025-10-20 04:45:37.299329+00	\N	aal1	\N	2025-10-20 04:45:37.299261	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Mobile Safari/537.36	192.168.144.1	\N
09f23050-fffa-4263-8df8-8e5cd3a6363e	afb7e323-2304-42f0-84ba-c43d09380d0d	2025-10-08 06:31:58.404047+00	2025-10-20 08:57:39.747988+00	\N	aal1	\N	2025-10-20 08:57:39.74794	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	192.168.144.1	\N
8ea7dab2-47e9-4036-add7-0c1bce519c52	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	2025-10-16 09:08:26.432153+00	2025-10-20 09:03:27.474982+00	\N	aal1	\N	2025-10-20 09:03:27.474852	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	192.168.144.1	\N
b53c57e2-006f-49d8-b171-7e95211dd839	a939945b-b080-4575-871b-91e222484828	2025-10-07 02:14:01.014025+00	2025-10-07 07:13:07.828348+00	\N	aal1	\N	2025-10-07 07:13:07.828199	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	172.18.0.1	\N
53b02269-832f-4631-805d-b5fbd24d1526	a939945b-b080-4575-871b-91e222484828	2025-10-16 09:08:45.270385+00	2025-10-17 13:00:44.921247+00	\N	aal1	\N	2025-10-17 13:00:44.92116	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	192.168.144.1	\N
84307570-6750-4110-a514-7d76d07adcc1	11f94728-d012-4413-819b-79fe1a30fe6c	2025-10-20 01:33:15.391327+00	2025-10-20 01:33:15.391327+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	192.168.144.1	\N
7dd2415f-1d3d-43ca-8795-1c4e9bbc418f	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	2025-10-17 05:55:32.803781+00	2025-10-17 06:55:22.244476+00	\N	aal1	\N	2025-10-17 06:55:22.244353	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	192.168.144.1	\N
ec07d3d0-561c-4f2d-a4d1-ebaedbacdec0	a939945b-b080-4575-871b-91e222484828	2025-10-02 05:17:42.936571+00	2025-10-02 06:17:57.456082+00	\N	aal1	\N	2025-10-02 06:17:57.455887	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	172.18.0.1	\N
5254186f-6f1b-4be5-bbe7-db6612669d28	8b37894d-57e6-4c75-aa1c-82329839a080	2025-10-08 03:23:53.763746+00	2025-10-09 00:36:01.06773+00	\N	aal1	\N	2025-10-09 00:36:01.067597	Mozilla/5.0 (iPhone; CPU iPhone OS 18_6_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Mobile/15E148 Safari/604.1	192.168.144.1	\N
5e782e6d-265d-4c69-96d3-3d81d738af20	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-14 09:35:12.516808+00	2025-10-20 06:54:47.686748+00	\N	aal1	\N	2025-10-20 06:54:47.686677	Mozilla/5.0 (iPhone; CPU iPhone OS 18_6_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Mobile/15E148 Safari/604.1	192.168.144.1	\N
cfef587a-5e6f-4dc4-9c8e-50ac99d096d9	967e7680-75e4-4b14-a15d-8936c7e92bc7	2025-10-02 08:37:38.93191+00	2025-10-02 08:37:38.93191+00	\N	aal1	\N	\N	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36	172.18.0.1	\N
0e759360-1482-442c-98f9-49b927ca9766	a939945b-b080-4575-871b-91e222484828	2025-10-07 07:36:13.26636+00	2025-10-07 07:36:13.26636+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	172.18.0.1	\N
0a9434f8-ee7f-43cf-b309-2e75c3a35d64	afb7e323-2304-42f0-84ba-c43d09380d0d	2025-10-08 06:31:54.266534+00	2025-10-08 06:31:54.266534+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36	192.168.144.1	\N
25ff321c-9561-46c3-872a-78c1661edb5f	8b37894d-57e6-4c75-aa1c-82329839a080	2025-10-08 03:21:09.34823+00	2025-10-08 03:21:09.34823+00	\N	aal1	\N	\N	Mozilla/5.0 (iPhone; CPU iPhone OS 18_6_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Mobile/15E148 Safari/604.1	192.168.144.1	\N
a2aaee5d-0b51-4045-9fdd-7e96c92040bd	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-14 09:33:23.211612+00	2025-10-14 09:33:23.211612+00	\N	aal1	\N	\N	Mozilla/5.0 (iPhone; CPU iPhone OS 18_6_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Mobile/15E148 Safari/604.1	192.168.144.1	\N
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	authenticated	authenticated	pointer091489@gmail.com	$2a$10$sn5vUcV7MRJtM6vRCcdipOgjqoc05H/oKrUs4sNxDqFQx4.agVyHe	2025-10-07 09:08:34.217964+00	\N		\N		\N			\N	2025-10-14 09:35:12.516746+00	{"provider": "email", "providers": ["email"]}	{"sub": "581142f6-a7dd-41dc-8e01-cb0f2eeb54cb", "email": "pointer091489@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-10-07 09:08:34.164373+00	2025-10-20 06:54:47.684831+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	11f94728-d012-4413-819b-79fe1a30fe6c	authenticated	authenticated	testcustomer@gmail.com	$2a$10$Rt49Waof540/q239.4orb.Ei8OjyoSUc24G0FCVgNl5hphakN/91e	2025-10-20 01:33:15.381698+00	\N		\N		\N			\N	2025-10-20 01:33:17.513913+00	{"provider": "email", "providers": ["email"]}	{"sub": "11f94728-d012-4413-819b-79fe1a30fe6c", "email": "testcustomer@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-10-20 01:33:15.348752+00	2025-10-20 07:31:26.263454+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	8b37894d-57e6-4c75-aa1c-82329839a080	authenticated	authenticated	my@coselig.com	$2a$10$RHl.jp6J.IExbF/w5MKQIengElXjQHavuLheBHlB7F2ZAahYxWASe	2025-10-08 03:21:09.34004+00	\N		\N		\N			\N	2025-10-08 03:23:53.763657+00	{"provider": "email", "providers": ["email"]}	{"sub": "8b37894d-57e6-4c75-aa1c-82329839a080", "email": "my@coselig.com", "email_verified": true, "phone_verified": false}	\N	2025-10-08 03:21:09.312099+00	2025-10-09 00:36:01.064439+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	a939945b-b080-4575-871b-91e222484828	authenticated	authenticated	coseligtest@gmail.com	$2a$10$jTsnkPNnpU9KcyaDd57vee403br6KbhQH6IB7B903sXf4D31VD5Cq	2025-10-01 06:30:30.767385+00	\N		\N		\N			\N	2025-10-16 09:08:45.270306+00	{"provider": "email", "providers": ["email"]}	{"sub": "a939945b-b080-4575-871b-91e222484828", "email": "coseligtest@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-10-01 06:30:30.748721+00	2025-10-17 13:00:44.919538+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	967e7680-75e4-4b14-a15d-8936c7e92bc7	authenticated	authenticated	a0987533182@gmail.com	$2a$10$rVkpEMsmD3qZgE7RobA1WO4/UaAClLHZY2wNYHNsEWhBWYOD5OgFa	2025-10-02 08:37:38.921768+00	\N		\N		\N			\N	2025-10-02 08:37:38.931823+00	{"provider": "email", "providers": ["email"]}	{"sub": "967e7680-75e4-4b14-a15d-8936c7e92bc7", "email": "a0987533182@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-10-02 08:37:38.89802+00	2025-10-02 08:37:38.935404+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	afb7e323-2304-42f0-84ba-c43d09380d0d	authenticated	authenticated	chunyunyam108010@gmail.com	$2a$10$kEdhwp41QjsoZ/wQgxz6ruaMfr97AlNEtA/aZC37tb/CuEcbfDtPe	2025-10-08 06:31:54.256143+00	\N		\N		\N			\N	2025-10-08 07:04:15.363291+00	{"provider": "email", "providers": ["email"]}	{"sub": "afb7e323-2304-42f0-84ba-c43d09380d0d", "email": "chunyunyam108010@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-10-08 06:31:54.227082+00	2025-10-20 08:57:39.744854+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	authenticated	authenticated	yunitrish0419@gmail.com	$2a$10$6L6XDZbo.yJ5MRn7tKgQ.uE.GItlfk.zTfOgNmBCyKtQOslWFTXje	2025-10-02 05:45:11.712259+00	\N		\N		\N			\N	2025-10-17 05:55:32.803698+00	{"provider": "email", "providers": ["email"]}	{"sub": "b48d15d8-c7cb-4782-a8fb-b43055c49a1e", "email": "yunitrish0419@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-10-02 05:45:11.673474+00	2025-10-20 09:03:27.465683+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: attendance_leave_requests; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.attendance_leave_requests (id, employee_id, employee_name, request_type, request_date, request_time, check_in_time, check_out_time, reason, status, reviewer_id, reviewer_name, review_comment, reviewed_at, created_at, updated_at) FROM stdin;
ec423160-2b0e-4403-a365-d248db345eed	afb7e323-2304-42f0-84ba-c43d09380d0d	嚴沅希	check_out	2025-10-08	2025-10-08 16:51:00+00	\N	\N	我想下班，但申請原因至少需要十個字	approved	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	林昀佑	ok	2025-10-08 16:52:10.652+00	2025-10-08 08:51:46.042516+00	2025-10-08 08:52:10.090004+00
83591375-0fdc-4beb-9069-a1fe61eee54e	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	楊子徵	full_day	2025-10-08	\N	2025-10-08 08:30:00+00	2025-10-08 17:30:00+00	今天不爽上班，超級無敵不爽	approved	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	林昀佑	ok	2025-10-08 17:01:53.636+00	2025-10-08 09:01:32.814571+00	2025-10-08 09:01:53.980446+00
b7b0d51b-ea13-41ea-9309-e812b5a74f74	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	林昀佑	check_out	2025-10-08	2025-10-08 17:30:00+00	\N	\N		approved	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	林昀佑	ok	2025-10-08 17:14:56.277+00	2025-10-08 09:14:37.632142+00	2025-10-08 09:14:55.923799+00
\.


--
-- Data for Name: attendance_records; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.attendance_records (id, employee_id, employee_name, employee_email, check_in_time, check_out_time, work_hours, location, notes, is_manual_entry, created_at, updated_at) FROM stdin;
b1a0ee73-1047-4882-88e3-99bc03f491a2	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	楊子徵	pointer091489@gmail.com	2025-10-08 08:30:00+00	2025-10-08 17:30:00+00	9.00	公司	【補打卡】測試測試測試	f	2025-10-08 06:07:09.37193+00	2025-10-08 06:16:56.412124+00
2fb6a76c-5cab-46eb-b867-05136fc1647d	afb7e323-2304-42f0-84ba-c43d09380d0d	嚴沅希	chunyunyam108010@gmail.com	2025-10-08 08:15:00+00	\N	\N	\N	【補打卡】TEST...	t	2025-10-08 07:06:26.373242+00	2025-10-08 07:06:26.373242+00
ac5075c2-3288-43f3-bee4-5cdbdef3956d	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	林昀佑	yunitrish0419@gmail.com	2025-10-08 08:30:00+00	2025-10-08 17:30:00+00	9.00	補打卡申請	補打卡申請已核准\n原因：	t	2025-10-08 06:04:13.683852+00	2025-10-08 09:14:55.987357+00
f3841d83-2eed-4c28-8c13-033d2a9339d1	afb7e323-2304-42f0-84ba-c43d09380d0d	嚴沅希	chunyunyam108010@gmail.com	2025-10-09 08:31:02.062+00	\N	\N	光悅科技股份有限公司	\N	f	2025-10-09 00:31:02.304863+00	2025-10-09 00:31:02.304863+00
c26d612d-ef1d-44a1-a42c-fcc1fe87bba6	8b37894d-57e6-4c75-aa1c-82329839a080	楊茂常	my@coselig.com	2025-10-09 08:36:15.62+00	\N	\N	光悅科技股份有限公司	\N	f	2025-10-09 00:36:16.208672+00	2025-10-09 00:36:16.208672+00
eff4e6e3-e966-4f50-acf1-a444f30306cb	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	楊子徵	pointer091489@gmail.com	2025-10-09 08:35:17.267+00	2025-10-09 17:36:17.088+00	1.00	光悅科技股份有限公司	\N	f	2025-10-09 00:35:17.900588+00	2025-10-09 09:36:17.350138+00
a1b69102-94f7-494f-8d52-948fc0d65ebf	afb7e323-2304-42f0-84ba-c43d09380d0d	嚴沅希	chunyunyam108010@gmail.com	2025-10-13 08:31:56.896+00	\N	\N	光悅科技股份有限公司	\N	f	2025-10-13 00:32:04.592083+00	2025-10-13 00:32:04.592083+00
ffdf1c98-602d-4d55-b443-10e6bec0f216	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	林昀佑	yunitrish0419@gmail.com	2025-10-09 08:30:00+00	2025-10-09 17:35:00+00	9.08	\N	【補打卡】忘記打卡了	f	2025-10-09 00:31:31.250832+00	2025-10-13 00:43:29.388117+00
1c0a6cc1-ab17-46d8-bf28-755539fe0cd1	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	林昀佑	yunitrish0419@gmail.com	2025-10-13 08:26:00+00	2025-10-13 17:31:42.005+00	1.08	\N	【補打卡】系統重開所以延遲打卡	f	2025-10-13 00:33:36.919232+00	2025-10-13 09:31:42.328722+00
2d7c7ab7-ad66-4520-8232-f728e4fe3e88	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	林昀佑	yunitrish0419@gmail.com	2025-10-14 08:39:49.01+00	2025-10-14 17:31:11.468+00	0.85	\N	\N	f	2025-10-14 00:39:48.93035+00	2025-10-14 09:31:11.565259+00
5b665a88-2da2-4797-9aef-7865b891ad75	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	林昀佑	yunitrish0419@gmail.com	2025-10-15 08:32:08.253+00	\N	\N	\N	\N	f	2025-10-15 00:32:06.762575+00	2025-10-15 00:32:06.762575+00
6525a91f-a6f8-401f-848f-14c32b8f87bc	afb7e323-2304-42f0-84ba-c43d09380d0d	嚴沅希	chunyunyam108010@gmail.com	2025-10-16 08:22:26.469+00	\N	\N	光悅科技股份有限公司	\N	f	2025-10-16 00:22:25.299955+00	2025-10-16 00:22:25.299955+00
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.customers (id, user_id, name, company, email, phone, address, notes, created_at, updated_at) FROM stdin;
f3c46be1-3138-455a-b809-17da5a4e3782	11f94728-d012-4413-819b-79fe1a30fe6c	客戶1	公司1	testcustomer@gmail.com	0912345678	\N	\N	2025-10-20 10:04:14.814+00	2025-10-20 10:04:14.814+00
\.


--
-- Data for Name: employee_skills; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.employee_skills (id, employee_id, skill_name, proficiency_level, created_at) FROM stdin;
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.employees (id, employee_id, name, email, phone, department, "position", hire_date, salary, status, manager_id, avatar_url, address, emergency_contact_name, emergency_contact_phone, notes, created_by, created_at, updated_at, role) FROM stdin;
a939945b-b080-4575-871b-91e222484828	TEST001	測試用戶	coseligtest@gmail.com	\N	測試部門	測試職位	2025-10-07	\N	在職	\N	\N	\N	\N	\N	\N	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	2025-10-07 02:21:45.008972+00	2025-10-13 04:52:20.869802+00	boss
8b37894d-57e6-4c75-aa1c-82329839a080	EMP001	楊茂常	my@coselig.com	\N	總部	老闆	2011-01-11	\N	在職	\N	\N	\N	\N	\N	\N	a939945b-b080-4575-871b-91e222484828	2025-10-08 11:22:49.913+00	2025-10-13 04:52:27.308125+00	boss
afb7e323-2304-42f0-84ba-c43d09380d0d	EMP006	嚴沅希	chunyunyam108010@gmail.com	\N	設計部	設計師	2025-10-08	10.00	在職	\N	\N	冥王星	\N	\N	\N	afb7e323-2304-42f0-84ba-c43d09380d0d	2025-10-08 15:05:08.102+00	2025-10-13 04:52:55.670473+00	employee
b48d15d8-c7cb-4782-a8fb-b43055c49a1e	EMP005	林昀佑	yunitrish0419@gmail.com	0937565253	技術部	開發人員	2025-10-07	\N	在職	\N	\N	\N	\N	\N	\N	a939945b-b080-4575-871b-91e222484828	2025-10-07 10:31:38.911+00	2025-10-13 04:52:58.730599+00	hr
967e7680-75e4-4b14-a15d-8936c7e92bc7	EMP004	陳偉丞	a0987533182@gmail.com	\N	外勤部	施作師傅	2023-10-07	\N	在職	\N	\N	\N	\N	\N	\N	a939945b-b080-4575-871b-91e222484828	2025-10-07 13:11:57.468+00	2025-10-13 04:53:12.858119+00	employee
581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	EMP003	楊子徵	pointer091489@gmail.com	\N	人事部	放飯的	2025-10-07	\N	在職	\N	\N	\N	\N	\N	\N	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-07 17:09:25.402+00	2025-10-13 04:53:15.614055+00	hr
\.


--
-- Data for Name: floor_plan_permissions; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.floor_plan_permissions (id, floor_plan_id, user_id, permission_level, created_at, updated_at) FROM stdin;
c3793ab3-920e-49df-a1e8-6f338b95201c	bc957de5-17a0-4000-a27c-01750078b516	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	2	2025-10-16 08:17:26.305495+00	2025-10-16 08:17:26.305495+00
44cc146b-a5d8-4a57-ac97-c5af22a840bc	e05a879d-6136-417b-94e2-3e4b4059bc96	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	3	2025-10-16 09:06:46.152806+00	2025-10-16 09:06:46.152806+00
9abf266c-9a02-4b1c-80cf-e202927f955e	d924ed25-1bc8-41a9-9890-e994a2432ce5	afb7e323-2304-42f0-84ba-c43d09380d0d	3	2025-10-16 09:18:32.274847+00	2025-10-16 17:19:51.861+00
cc7ea118-e01c-4fe1-b4ff-7dc5afb492ab	d924ed25-1bc8-41a9-9890-e994a2432ce5	a939945b-b080-4575-871b-91e222484828	1	2025-10-16 08:15:58.251307+00	2025-10-16 17:26:37.334+00
\.


--
-- Data for Name: floor_plans; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.floor_plans (id, name, image_url, user_id, created_at, updated_at, project_id) FROM stdin;
e05a879d-6136-417b-94e2-3e4b4059bc96	民雄一樓	https://coselig.com/api/storage/v1/object/public/assets/floor_plans/1759892315894_scaled_S_5046274.jpg	a939945b-b080-4575-871b-91e222484828	2025-10-08 02:58:49.687132+00	2025-10-08 02:58:49.687132+00	\N
bc957de5-17a0-4000-a27c-01750078b516	羅斯福-單線圖(by 豪哥)	https://coselig.com/api/storage/v1/object/public/assets/floor_plans/1759999918415_scaled_2025_10_09_165139.png	afb7e323-2304-42f0-84ba-c43d09380d0d	2025-10-09 08:52:23.810076+00	2025-10-09 08:52:23.810076+00	\N
25a40fa3-e78d-4d70-a704-0bda19c7a154	羅斯福-燈具迴路圖	https://coselig.com/api/storage/v1/object/public/assets/floor_plans/1759999990539_scaled_2025_10_09_165258.png	afb7e323-2304-42f0-84ba-c43d09380d0d	2025-10-09 08:54:06.790527+00	2025-10-09 08:54:06.790527+00	\N
d924ed25-1bc8-41a9-9890-e994a2432ce5	3F	https://coselig.com/api/storage/v1/object/public/assets/floor_plans/1760425447720_scaled_S_5046274.jpg	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	2025-10-14 07:04:19.733585+00	2025-10-14 07:04:19.733585+00	\N
94f256b3-257a-454a-b325-b255d45d0279	北捷B2燈光	https://coselig.com/api/storage/v1/object/public/assets/floor_plans/1760428597968_scaled_2025_10_14_3.56.24.png	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-14 07:56:49.756092+00	2025-10-14 07:56:49.756092+00	\N
43bfffc1-c324-4a78-b657-186515285196	北捷B3燈光	https://coselig.com/api/storage/v1/object/public/assets/floor_plans/1760428824692_scaled_2025_10_14_3.58.14.png	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-14 08:00:27.115101+00	2025-10-14 08:00:27.115101+00	\N
5d5b68b6-4255-4d5a-a3df-ca7772a78e22	3f	https://coselig.com/api/storage/v1/object/public/assets/floor_plans/1760605655718_scaled_floorplan_1756191726259.jpg	a939945b-b080-4575-871b-91e222484828	2025-10-16 09:07:37.57352+00	2025-10-16 09:07:37.57352+00	\N
\.


--
-- Data for Name: holidays; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.holidays (id, date, name, year, description, is_workday, created_at, updated_at) FROM stdin;
51b5ab66-3746-4c73-9748-ac92af708935	2025-01-01	中華民國開國紀念日	2025	依規定放假一日	f	2025-10-09 07:11:57.614488+00	2025-10-09 07:11:57.614488+00
eb7bb20d-c734-4a95-a8d2-de46b19567e5	2025-01-27	農曆除夕	2025	春節假期	f	2025-10-09 07:11:57.614488+00	2025-10-09 07:11:57.614488+00
381df67b-1bb6-4c22-9fc7-9be1f6fcccba	2025-01-28	春節	2025	春節假期	f	2025-10-09 07:11:57.614488+00	2025-10-09 07:11:57.614488+00
137ba499-1c84-448a-8b06-cf55c4b3e7df	2025-01-29	春節	2025	春節假期	f	2025-10-09 07:11:57.614488+00	2025-10-09 07:11:57.614488+00
655b9fbf-9024-4fae-aa81-ba310c82c428	2025-01-30	春節	2025	春節假期	f	2025-10-09 07:11:57.614488+00	2025-10-09 07:11:57.614488+00
dca8c05d-49dc-47eb-882f-b54700ac4072	2025-01-31	春節	2025	春節假期	f	2025-10-09 07:11:57.614488+00	2025-10-09 07:11:57.614488+00
9235504f-9118-423a-8ce8-7194a3e19c16	2025-02-28	和平紀念日	2025	依規定放假一日	f	2025-10-09 07:11:57.614488+00	2025-10-09 07:11:57.614488+00
9b5e3216-dd7b-4efa-8023-e2afb9e17ffc	2025-04-04	兒童節及民族掃墓節	2025	依規定放假一日	f	2025-10-09 07:11:57.614488+00	2025-10-09 07:11:57.614488+00
09980c1f-a338-461c-a332-3dafc4fe55af	2025-04-05	民族掃墓節補假	2025	補假一日	f	2025-10-09 07:11:57.614488+00	2025-10-09 07:11:57.614488+00
25b47df6-465a-4f86-9348-5f985fdd4d2c	2025-05-01	勞動節	2025	依規定放假一日	f	2025-10-09 07:11:57.614488+00	2025-10-09 07:11:57.614488+00
f98e7733-1d22-4e4c-b688-634236565042	2025-05-31	端午節	2025	依規定放假一日	f	2025-10-09 07:11:57.614488+00	2025-10-09 07:11:57.614488+00
3f9b6725-d360-4202-9d8e-7d098b9dc466	2025-10-06	中秋節	2025	依規定放假一日	f	2025-10-09 07:11:57.614488+00	2025-10-09 07:11:57.614488+00
49f97a35-c8c4-4da1-8c7f-ceec6f3c351e	2025-10-10	國慶日	2025	依規定放假一日	f	2025-10-09 07:11:57.614488+00	2025-10-09 07:11:57.614488+00
\.


--
-- Data for Name: images; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.images (id, filename, original_name, file_path, file_size, mime_type, project_id, uploaded_by, created_at) FROM stdin;
\.


--
-- Data for Name: job_vacancies; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.job_vacancies (id, title, department, location, type, requirements, responsibilities, description, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: leave_balances; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.leave_balances (id, employee_id, leave_type, year, total_days, used_days, pending_days, created_at, updated_at) FROM stdin;
33ddae30-5392-4974-98d3-2ad91f401d91	967e7680-75e4-4b14-a15d-8936c7e92bc7	sick	2025	30.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
93fb14b9-3a93-41a3-85ab-922f673dc61f	967e7680-75e4-4b14-a15d-8936c7e92bc7	personal	2025	14.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
9d0be650-abb2-42a3-ba1f-970b043e163b	967e7680-75e4-4b14-a15d-8936c7e92bc7	annual	2025	14.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
91fd1b38-a3b8-4741-8e9e-218f2b6bdc0e	967e7680-75e4-4b14-a15d-8936c7e92bc7	parental	2025	730.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
55efed80-e6f5-4cf0-a021-3cf8c7f51ed8	967e7680-75e4-4b14-a15d-8936c7e92bc7	marriage	2025	8.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
62d85c97-370a-4f77-93a9-e510bfa0f281	967e7680-75e4-4b14-a15d-8936c7e92bc7	bereavement	2025	8.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
7f7588eb-9183-49f1-9b65-12604a94d344	967e7680-75e4-4b14-a15d-8936c7e92bc7	official	2025	365.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
cf46b905-a35d-45d4-b89d-8d3f123ef605	967e7680-75e4-4b14-a15d-8936c7e92bc7	maternity	2025	56.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
cf847624-df33-4648-b225-af238979a23c	967e7680-75e4-4b14-a15d-8936c7e92bc7	paternity	2025	7.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
6f35ceca-a07a-424a-ac77-2ba4684ddbe1	967e7680-75e4-4b14-a15d-8936c7e92bc7	menstrual	2025	12.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
fa6ae085-f88d-4b50-8bf4-1825cfd728d7	a939945b-b080-4575-871b-91e222484828	sick	2025	30.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
2616fc50-f156-4e80-bfc1-25d63f1d049e	a939945b-b080-4575-871b-91e222484828	personal	2025	14.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
f5b82e1e-9bed-43c0-893c-af0e95b02b09	a939945b-b080-4575-871b-91e222484828	annual	2025	14.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
be3cce0c-a3cd-4cc5-988f-5c6ba59b808e	a939945b-b080-4575-871b-91e222484828	parental	2025	730.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
78f63329-0a07-45b4-828e-e0d92e6d66ef	a939945b-b080-4575-871b-91e222484828	marriage	2025	8.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
9fae0c4f-2cf9-4f91-9d02-fb09c0aed166	a939945b-b080-4575-871b-91e222484828	bereavement	2025	8.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
450ffd24-7d90-42f5-8146-6939cc0c4b8b	a939945b-b080-4575-871b-91e222484828	official	2025	365.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
addbd0e2-bb74-4936-b68c-ac873eb47cb6	a939945b-b080-4575-871b-91e222484828	maternity	2025	56.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
e7a3e37e-7e93-4650-8eed-27cbbefb44a8	a939945b-b080-4575-871b-91e222484828	paternity	2025	7.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
93ecea7e-b4d3-479b-9b79-c3443da8d37b	a939945b-b080-4575-871b-91e222484828	menstrual	2025	12.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
fcbc15c1-4dfc-4082-80e9-429885ce4237	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	sick	2025	30.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
93f610ad-f7cc-46be-b6e9-96faa50b6c73	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	personal	2025	14.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
2c4d5ff6-d485-432d-9f2e-5721e4ae9ce3	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	annual	2025	14.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
98656ea0-fb62-4b80-8eb1-76291a51f325	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	parental	2025	730.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
d668df88-6f7a-41b4-a70f-f82e7285c684	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	marriage	2025	8.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
8380645c-dc2d-42d0-b7ab-5fb1498f6759	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	bereavement	2025	8.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
336d06dd-2345-4416-bf2f-01bd353579cf	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	official	2025	365.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
7f27eff0-06db-4cc6-8c21-dee8ba254b58	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	maternity	2025	56.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
e4f2c4a2-1132-4d01-b2e4-72186444161f	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	paternity	2025	7.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
8c877fb1-1606-4d0a-b337-e336462a337e	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	menstrual	2025	12.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
cbb416ee-fda9-488a-9420-b44cff592f08	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	sick	2025	30.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
632e10cc-1eb4-4d3b-ac49-dbcae0e54d2c	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	annual	2025	14.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
c9f541f2-e037-4aa5-a124-4f879a47c82f	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	parental	2025	730.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
d4b2352d-9362-425c-b402-f23cd205550f	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	marriage	2025	8.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
3040459d-ac70-4846-907a-8aada512bb6a	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	bereavement	2025	8.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
55ec0fb2-a8b2-49ff-908c-02e8857c8992	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	official	2025	365.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
9e1a0f7f-ac4f-49d4-a958-2e3304aaa2a3	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	maternity	2025	56.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
b15a07b2-c4a8-43c6-9d3f-55aabc0026bd	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	paternity	2025	7.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
a6ccaad5-90ce-4c8a-b27b-13a68ef0cdc8	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	menstrual	2025	12.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
c2713a64-9a52-48eb-984d-20438eaec7ba	8b37894d-57e6-4c75-aa1c-82329839a080	sick	2025	30.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
9e5413ae-4e9a-41e0-9536-ef752880a8d6	8b37894d-57e6-4c75-aa1c-82329839a080	personal	2025	14.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
f44f4022-a3ef-4456-81d1-dbbd9218347f	8b37894d-57e6-4c75-aa1c-82329839a080	annual	2025	14.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
e475a821-216d-47f7-b23b-fd13fe587993	8b37894d-57e6-4c75-aa1c-82329839a080	parental	2025	730.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
c58b44f7-5391-446e-be3f-2618eb93506a	8b37894d-57e6-4c75-aa1c-82329839a080	marriage	2025	8.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
3c17560b-b435-4ec2-acee-05b5b0e85588	8b37894d-57e6-4c75-aa1c-82329839a080	bereavement	2025	8.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
944d41c7-e19d-4999-8f5e-c86dab997bde	8b37894d-57e6-4c75-aa1c-82329839a080	official	2025	365.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
493b41c9-abff-4196-917b-34c67029b517	8b37894d-57e6-4c75-aa1c-82329839a080	maternity	2025	56.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
3a6acd62-b347-432d-a7e2-c518394a4122	8b37894d-57e6-4c75-aa1c-82329839a080	paternity	2025	7.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
ec2daeca-b5e8-4b8d-b91f-3b4dd3c0616e	8b37894d-57e6-4c75-aa1c-82329839a080	menstrual	2025	12.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
a2c5b7c7-c4bd-4f73-9a59-42e2428ee033	afb7e323-2304-42f0-84ba-c43d09380d0d	sick	2025	30.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
9592fdc6-e7c8-4b1e-a8bd-68b694618c83	afb7e323-2304-42f0-84ba-c43d09380d0d	personal	2025	14.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
3baac7bb-f301-4f34-90c8-21c6fc2a475a	afb7e323-2304-42f0-84ba-c43d09380d0d	annual	2025	14.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
dfaa77a5-bca4-4fb3-b7dd-d8acd0ca301f	afb7e323-2304-42f0-84ba-c43d09380d0d	parental	2025	730.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
12bca3e7-b30d-4d14-b3d9-6c67f563f67c	afb7e323-2304-42f0-84ba-c43d09380d0d	marriage	2025	8.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
2aeb90e9-7453-4be8-8bcb-7f6e56e7a311	afb7e323-2304-42f0-84ba-c43d09380d0d	bereavement	2025	8.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
9fdf87a4-8001-4ea1-8923-03f959ad8338	afb7e323-2304-42f0-84ba-c43d09380d0d	official	2025	365.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
e130fc28-1610-46b7-bd2d-f26974181423	afb7e323-2304-42f0-84ba-c43d09380d0d	maternity	2025	56.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
dfaf6ef1-f5f6-4c7a-8924-01a31b5c9495	afb7e323-2304-42f0-84ba-c43d09380d0d	paternity	2025	7.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
96a04776-a58e-4360-9042-0524e868c4a9	afb7e323-2304-42f0-84ba-c43d09380d0d	menstrual	2025	12.0	0.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 06:14:48.964826+00
70300530-557e-45b7-ba45-db75bfa23b7a	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	personal	2025	14.0	2.0	0.0	2025-10-09 06:14:48.964826+00	2025-10-09 08:22:24.176505+00
\.


--
-- Data for Name: leave_requests; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.leave_requests (id, employee_id, employee_name, leave_type, start_date, end_date, start_period, end_period, total_days, reason, attachment_url, status, reviewer_id, reviewer_name, review_comment, reviewed_at, created_at, updated_at) FROM stdin;
fcedcb80-e5b8-4488-92fa-2bb3a99c2d98	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	林昀佑	personal	2025-10-10	2025-10-10	full_day	full_day	1.0	ewfafawfa	\N	approved	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	林昀佑	awdaw	2025-10-09 16:22:23.655+00	2025-10-09 08:22:18.569677+00	2025-10-09 08:22:24.176505+00
\.


--
-- Data for Name: photo_records; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.photo_records (id, floor_plan_id, x_coordinate, y_coordinate, description, user_id, created_at, updated_at, image_url) FROM stdin;
e75f1e09-e293-46cf-a41b-cdf9ea09391f	25a40fa3-e78d-4d70-a704-0bda19c7a154	496.91157688700144	497.06891386471864	廚房的櫃體燈都不用計算	afb7e323-2304-42f0-84ba-c43d09380d0d	2025-10-09 16:54:48.699+00	2025-10-09 16:54:48.699+00	
fe442cb7-5d9e-4d31-92bb-1ed85ec5644b	25a40fa3-e78d-4d70-a704-0bda19c7a154	1040.6324304804227	255.04678640566055	1. 要問一下老闆當初拿給對方的樣品是哪種\n2. 9.5cm的燈不考慮,我們應該只有開孔8.5cm的嵌燈	afb7e323-2304-42f0-84ba-c43d09380d0d	2025-10-09 16:56:13.444+00	2025-10-09 16:56:13.444+00	
55e252c2-a3ab-4622-a9dc-a3d8a1135e1b	25a40fa3-e78d-4d70-a704-0bda19c7a154	734.1974450192872	337.45744719411914	客廳最大圈的那個矽膠燈條有四個迴路是因為是雙色溫(除了那邊以外都是單色溫)	afb7e323-2304-42f0-84ba-c43d09380d0d	2025-10-09 16:58:45.931+00	2025-10-09 16:58:45.931+00	
9a468e03-831c-4b9e-b900-766bc04d49df	bc957de5-17a0-4000-a27c-01750078b516	1106.430032369966	1076.11519587313	H1~H9的編號如何對應?	afb7e323-2304-42f0-84ba-c43d09380d0d	2025-10-09 16:59:19.715+00	2025-10-09 16:59:19.715+00	
4d48baf8-62f3-4131-a872-b0f85a47ec6e	d924ed25-1bc8-41a9-9890-e994a2432ce5	75.99164926931107	132.0417536534447	照片記錄於 2025-10-14 15:04:45	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	2025-10-14 15:04:45.146+00	2025-10-14 15:04:45.147+00	https://coselig.com/api/storage/v1/object/public/assets/photos/1760427732349_scaled_2025_08_19_182306.png
cb416dc6-89f1-4ba8-a591-5a05eb0d08f3	d924ed25-1bc8-41a9-9890-e994a2432ce5	72.95198329853862	176.1169102296451	rawerawr	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	2025-10-14 15:51:01.357+00	2025-10-14 15:51:01.357+00	
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.profiles (id, email, full_name, avatar_url, theme_preference, created_at, updated_at) FROM stdin;
967e7680-75e4-4b14-a15d-8936c7e92bc7	a0987533182@gmail.com	\N	\N	system	2025-10-02 08:37:39.162634+00	2025-10-02 16:37:38.014+00
581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	pointer091489@gmail.com	\N	\N	system	2025-10-07 09:08:34.286124+00	2025-10-14 17:35:58.327+00
a939945b-b080-4575-871b-91e222484828	coseligtest@gmail.com	\N	\N	system	2025-10-01 06:30:30.831448+00	2025-10-16 17:08:45.968+00
11f94728-d012-4413-819b-79fe1a30fe6c	testcustomer@gmail.com	\N	\N	system	2025-10-20 01:33:15.464482+00	2025-10-20 09:33:17.678+00
8b37894d-57e6-4c75-aa1c-82329839a080	my@coselig.com	\N	\N	system	2025-10-08 03:21:09.461052+00	2025-10-08 11:23:53.617+00
b48d15d8-c7cb-4782-a8fb-b43055c49a1e	yunitrish0419@gmail.com	\N	\N	system	2025-10-02 05:45:11.78427+00	2025-10-20 16:39:44.861+00
afb7e323-2304-42f0-84ba-c43d09380d0d	chunyunyam108010@gmail.com	\N	\N	dark	2025-10-08 06:31:54.297604+00	2025-10-08 17:04:43.208+00
\.


--
-- Data for Name: project_clients; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.project_clients (id, project_id, name, company, email, phone, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: project_comments; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.project_comments (id, project_id, user_id, content, parent_id, attachments, created_at, updated_at) FROM stdin;
38e1462e-9bd8-41ed-ac04-db06f13cb4b4	73faecc9-6889-410f-97ce-ee05a52b51aa	afb7e323-2304-42f0-84ba-c43d09380d0d	哇我第一個留言欸！！！！	\N	\N	2025-10-16 08:25:07.385463+00	2025-10-16 08:25:07.385463+00
c69c70ec-ba82-4341-a7b4-96008cc67d05	73faecc9-6889-410f-97ce-ee05a52b51aa	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	awdawr	38e1462e-9bd8-41ed-ac04-db06f13cb4b4	\N	2025-10-16 09:01:00.077964+00	2025-10-16 09:01:00.077964+00
\.


--
-- Data for Name: project_members; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.project_members (id, project_id, user_id, role, joined_at) FROM stdin;
37b4746a-ffe5-4e66-838e-ac41146c3634	519888d3-34d8-4b9d-9331-6c309eb03604	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	admin	2025-10-16 08:04:02.668502+00
e62b73aa-f73f-42f4-bfd6-178876b8ba31	519888d3-34d8-4b9d-9331-6c309eb03604	afb7e323-2304-42f0-84ba-c43d09380d0d	admin	2025-10-16 08:16:15.105918+00
b92ed555-c650-4973-91bb-05634b8f5301	73faecc9-6889-410f-97ce-ee05a52b51aa	afb7e323-2304-42f0-84ba-c43d09380d0d	admin	2025-10-16 08:20:39.95271+00
b54e7444-d0ca-4021-b226-102f4ed6c178	73faecc9-6889-410f-97ce-ee05a52b51aa	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	member	2025-10-16 08:20:49.666777+00
7d3c4ae5-2cf5-40db-951a-353e4e925e8a	ae250ed1-fdd7-4fcb-be48-5767aa02ec3b	a939945b-b080-4575-871b-91e222484828	member	2025-10-20 05:50:34.416429+00
\.


--
-- Data for Name: project_tasks; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.project_tasks (id, project_id, title, description, status, priority, assigned_to, due_date, completed_at, created_by, created_at, updated_at, previous_task_id, next_task_id, display_order, tags) FROM stdin;
962f9af4-2d83-47a7-ba69-5386a3e42ae5	73faecc9-6889-410f-97ce-ee05a52b51aa	車道燈案-盤體圖	繪製盤體圖、上傳到雲端、在DC報備	blocked	urgent	\N	2025-10-17	\N	afb7e323-2304-42f0-84ba-c43d09380d0d	2025-10-16 08:24:08.862516+00	2025-10-16 08:26:09.58523+00	\N	\N	0	\N
0ec5af34-e202-4b86-96b2-2141177c5de2	519888d3-34d8-4b9d-9331-6c309eb03604	測試任務	測試用的任務	in_progress	urgent	\N	2025-10-31	\N	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	2025-10-20 02:15:46.292759+00	2025-10-20 09:26:37.7911+00	\N	\N	0	\N
\.


--
-- Data for Name: project_timeline; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.project_timeline (id, project_id, title, description, milestone_date, is_completed, completed_at, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.projects (id, name, description, status, start_date, end_date, budget, owner_id, created_at, updated_at) FROM stdin;
73faecc9-6889-410f-97ce-ee05a52b51aa	求生指南手冊	一起活下去	active	2025-10-16	2026-02-25	\N	afb7e323-2304-42f0-84ba-c43d09380d0d	2025-10-16 08:19:48.026404+00	2025-10-16 08:19:48.026404+00
ae250ed1-fdd7-4fcb-be48-5767aa02ec3b	10/20	測試	active	2025-10-20	2025-11-30	\N	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-20 05:49:16.951836+00	2025-10-20 05:49:16.951836+00
519888d3-34d8-4b9d-9331-6c309eb03604	測試專案	一個拿來測試的專案	active	2025-03-03	2025-12-26	\N	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	2025-10-16 07:22:19.510811+00	2025-10-20 08:53:45.443531+00
\.


--
-- Data for Name: system_settings; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.system_settings (key, value, description, updated_at) FROM stdin;
recruitment_email	hr@guangyue.tech	人資聯絡信箱	2025-10-02 01:29:26.100871+00
company_name	光悅科技	公司名稱	2025-10-02 01:46:51.710699+00
company_address	台北市信義區	公司地址	2025-10-02 01:46:51.710699+00
hr_email	hr@guangyue.tech	人資聯絡信箱	2025-10-02 01:46:51.710699+00
company_phone	02-1234-5678	公司電話	2025-10-02 01:46:51.710699+00
employee_id_prefix	EMP	員工編號前綴	2025-10-02 01:46:51.710699+00
default_work_hours	8	預設工作時數	2025-10-02 01:46:51.710699+00
\.


--
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public.user_profiles (id, user_id, email, display_name, avatar_url, phone, metadata, created_at, updated_at) FROM stdin;
60a894fd-53de-42dc-a9e5-347e74a685eb	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	yunitrish0419@gmail.com	yunitrish0419	\N	\N	{}	2025-10-02 05:45:11.672926+00	2025-10-02 05:45:11.672926+00
a26937c4-5642-4806-aa4f-6ef753ac4bf2	967e7680-75e4-4b14-a15d-8936c7e92bc7	a0987533182@gmail.com	a0987533182	\N	\N	{}	2025-10-02 08:37:38.896712+00	2025-10-02 08:37:38.896712+00
6bc0dab0-098d-46bc-95e2-7fcbec47a892	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	pointer091489@gmail.com	pointer091489	\N	\N	{}	2025-10-07 09:08:34.163889+00	2025-10-07 09:08:34.163889+00
3586913b-86f9-4ade-9109-e5b18d9d2bd0	8b37894d-57e6-4c75-aa1c-82329839a080	my@coselig.com	my	\N	\N	{}	2025-10-08 03:21:09.306652+00	2025-10-08 03:21:09.306652+00
959abfce-616f-461f-8fa7-3f9c509caecc	afb7e323-2304-42f0-84ba-c43d09380d0d	chunyunyam108010@gmail.com	chunyunyam108010	\N	\N	{}	2025-10-08 06:31:54.225855+00	2025-10-08 06:31:54.225855+00
750f2f0d-5da1-44b9-b72a-e8c2895648c5	11f94728-d012-4413-819b-79fe1a30fe6c	testcustomer@gmail.com	testcustomer	\N	\N	{}	2025-10-20 01:33:15.347458+00	2025-10-20 01:33:15.347458+00
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2025-09-17 02:53:23
20211116045059	2025-09-17 02:53:23
20211116050929	2025-09-17 02:53:23
20211116051442	2025-09-17 02:53:23
20211116212300	2025-09-17 02:53:23
20211116213355	2025-09-17 02:53:23
20211116213934	2025-09-17 02:53:23
20211116214523	2025-09-17 02:53:23
20211122062447	2025-09-17 02:53:23
20211124070109	2025-09-17 02:53:23
20211202204204	2025-09-17 02:53:23
20211202204605	2025-09-17 02:53:23
20211210212804	2025-09-17 02:53:23
20211228014915	2025-09-17 02:53:23
20220107221237	2025-09-17 02:53:23
20220228202821	2025-09-17 02:53:23
20220312004840	2025-09-17 02:53:23
20220603231003	2025-09-17 02:53:23
20220603232444	2025-09-17 02:53:23
20220615214548	2025-09-17 02:53:23
20220712093339	2025-09-17 02:53:23
20220908172859	2025-09-17 02:53:23
20220916233421	2025-09-17 02:53:23
20230119133233	2025-09-17 02:53:23
20230128025114	2025-09-17 02:53:23
20230128025212	2025-09-17 02:53:23
20230227211149	2025-09-17 02:53:23
20230228184745	2025-09-17 02:53:23
20230308225145	2025-09-17 02:53:23
20230328144023	2025-09-17 02:53:23
20231018144023	2025-09-17 02:53:23
20231204144023	2025-09-17 02:53:23
20231204144024	2025-09-17 02:53:23
20231204144025	2025-09-17 02:53:23
20240108234812	2025-09-17 02:53:23
20240109165339	2025-09-17 02:53:23
20240227174441	2025-09-17 02:53:23
20240311171622	2025-09-17 02:53:23
20240321100241	2025-09-17 02:53:23
20240401105812	2025-09-17 02:53:23
20240418121054	2025-09-17 02:53:23
20240523004032	2025-09-17 02:53:23
20240618124746	2025-09-17 02:53:23
20240801235015	2025-09-17 02:53:23
20240805133720	2025-09-17 02:53:23
20240827160934	2025-09-17 02:53:23
20240919163303	2025-09-17 02:53:23
20240919163305	2025-09-17 02:53:23
20241019105805	2025-09-17 02:53:23
20241030150047	2025-09-17 02:53:23
20241108114728	2025-09-17 02:53:23
20241121104152	2025-09-17 02:53:23
20241130184212	2025-09-17 02:53:23
20241220035512	2025-09-17 02:53:23
20241220123912	2025-09-17 02:53:23
20241224161212	2025-09-17 02:53:23
20250107150512	2025-09-17 02:53:23
20250110162412	2025-09-17 02:53:23
20250123174212	2025-09-17 02:53:23
20250128220012	2025-09-17 02:53:23
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type) FROM stdin;
assets	assets	\N	2025-09-25 03:43:55.512182+00	2025-09-25 03:43:55.512182+00	t	f	\N	\N	\N	STANDARD
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets_analytics (id, type, format, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: iceberg_namespaces; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.iceberg_namespaces (id, bucket_id, name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: iceberg_tables; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.iceberg_tables (id, namespace_id, bucket_id, name, location, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2025-09-17 02:53:18.233847
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2025-09-17 02:53:18.239937
2	storage-schema	5c7968fd083fcea04050c1b7f6253c9771b99011	2025-09-17 02:53:18.243594
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2025-09-17 02:53:18.261213
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2025-09-17 02:53:18.296507
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2025-09-17 02:53:18.300752
6	change-column-name-in-get-size	f93f62afdf6613ee5e7e815b30d02dc990201044	2025-09-17 02:53:18.3086
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2025-09-17 02:53:18.314358
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2025-09-17 02:53:18.319019
9	fix-search-function	3a0af29f42e35a4d101c259ed955b67e1bee6825	2025-09-17 02:53:18.323758
10	search-files-search-function	68dc14822daad0ffac3746a502234f486182ef6e	2025-09-17 02:53:18.32936
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2025-09-17 02:53:18.335589
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2025-09-17 02:53:18.343774
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2025-09-17 02:53:18.350687
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2025-09-17 02:53:18.359257
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2025-09-17 02:53:18.404759
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2025-09-17 02:53:18.410708
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2025-09-17 02:53:18.417163
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2025-09-17 02:53:18.425254
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2025-09-17 02:53:18.433538
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2025-09-17 02:53:18.440766
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2025-09-17 02:53:18.456368
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2025-09-17 02:53:18.502261
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2025-09-17 02:53:18.534291
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2025-09-17 02:53:18.53973
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2025-09-17 02:53:18.545858
26	objects-prefixes	ef3f7871121cdc47a65308e6702519e853422ae2	2025-09-17 02:53:18.550758
27	search-v2	33b8f2a7ae53105f028e13e9fcda9dc4f356b4a2	2025-09-17 02:53:18.57861
28	object-bucket-name-sorting	ba85ec41b62c6a30a3f136788227ee47f311c436	2025-09-17 02:53:18.596988
29	create-prefixes	a7b1a22c0dc3ab630e3055bfec7ce7d2045c5b7b	2025-09-17 02:53:18.602588
30	update-object-levels	6c6f6cc9430d570f26284a24cf7b210599032db7	2025-09-17 02:53:18.607569
31	objects-level-index	33f1fef7ec7fea08bb892222f4f0f5d79bab5eb8	2025-09-17 02:53:18.621558
32	backward-compatible-index-on-objects	2d51eeb437a96868b36fcdfb1ddefdf13bef1647	2025-09-17 02:53:18.634854
33	backward-compatible-index-on-prefixes	fe473390e1b8c407434c0e470655945b110507bf	2025-09-17 02:53:18.646355
34	optimize-search-function-v1	82b0e469a00e8ebce495e29bfa70a0797f7ebd2c	2025-09-17 02:53:18.648754
35	add-insert-trigger-prefixes	63bb9fd05deb3dc5e9fa66c83e82b152f0caf589	2025-09-17 02:53:18.659225
36	optimise-existing-functions	81cf92eb0c36612865a18016a38496c530443899	2025-09-17 02:53:18.669121
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2025-09-17 02:53:18.68144
38	iceberg-catalog-flag-on-buckets	19a8bd89d5dfa69af7f222a46c726b7c41e462c5	2025-09-17 02:53:18.687794
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata, level) FROM stdin;
ccd2fa46-71cb-49e3-b5eb-74e202d2359d	assets	customize_service.jpg	\N	2025-09-25 05:36:40.3766+00	2025-09-25 05:36:40.3766+00	2025-09-25 05:36:40.3766+00	{"eTag": "\\"52f00f8c2f6f729f6fc156a3aa796565\\"", "size": 18755, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:40.142Z", "contentLength": 18755, "httpStatusCode": 200}	d7c95057-e89f-4fe8-bbe1-41a9076e3783	\N	\N	1
681b4a40-2720-48ca-b1ea-187dd592efa8	assets	handshake.jpg	\N	2025-09-25 05:36:42.531863+00	2025-09-25 05:36:42.531863+00	2025-09-25 05:36:42.531863+00	{"eTag": "\\"c7cff19670f2be0d263e51ce99dd0566\\"", "size": 144003, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:41.847Z", "contentLength": 144003, "httpStatusCode": 200}	a98b3436-8c36-4e5b-9e6d-4dc793633abb	\N	\N	1
b738b00f-1e23-4f68-aba3-5097be7a22a3	assets	ha.png	\N	2025-09-25 05:36:42.883374+00	2025-09-25 05:36:42.883374+00	2025-09-25 05:36:42.883374+00	{"eTag": "\\"ce824a6c4dca153f32cbffec7c993e18\\"", "size": 369096, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:42.130Z", "contentLength": 369096, "httpStatusCode": 200}	1a96d317-db93-4c27-8e18-017daa8e4d62	\N	\N	1
23ca0540-9aea-4d4a-b9bc-3de7f9326dd3	assets	affordable.png	\N	2025-09-25 05:36:40.363697+00	2025-09-25 05:36:40.363697+00	2025-09-25 05:36:40.363697+00	{"eTag": "\\"4bb7794e1ca1f0869d1a1b06b87dc896\\"", "size": 3184, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:40.142Z", "contentLength": 3184, "httpStatusCode": 200}	8197bc89-c00e-4bbd-a8b9-145cb3eb1a1a	\N	\N	1
51d5f473-46bd-4baf-ac88-b60ec40734e8	assets	feasible.png	\N	2025-09-25 05:36:41.331465+00	2025-09-25 05:36:41.331465+00	2025-09-25 05:36:41.331465+00	{"eTag": "\\"fd32aefe90668017dae691bcd2c0c3f5\\"", "size": 2614, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:40.737Z", "contentLength": 2614, "httpStatusCode": 200}	23441e38-eb31-4927-90ba-8fc8c8bca3a8	\N	\N	1
0cc3837e-2920-4d78-8722-5307e372801a	assets	stable.png	\N	2025-09-25 05:36:42.960522+00	2025-09-25 05:36:42.960522+00	2025-09-25 05:36:42.960522+00	{"eTag": "\\"882d4cde4ce78cb74dba9dfe81ced86c\\"", "size": 4391, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:42.906Z", "contentLength": 4391, "httpStatusCode": 200}	ddf1c28d-11b2-4d5e-a7bd-5b0f9185e565	\N	\N	1
ff4166ad-4f2a-410d-a4aa-29ef3e771bb2	assets	customize_button.jpg	\N	2025-09-25 05:36:40.363332+00	2025-09-25 05:36:40.363332+00	2025-09-25 05:36:40.363332+00	{"eTag": "\\"cebcd383da9d2fece0fc7102fe68932f\\"", "size": 9911, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:40.142Z", "contentLength": 9911, "httpStatusCode": 200}	cb811055-2524-4458-9aa1-dca43a9dfb41	\N	\N	1
1a313183-a7c5-42f1-bbd3-b8db50719df6	assets	bedroom.jpg	\N	2025-09-25 05:36:40.544459+00	2025-09-25 05:36:40.544459+00	2025-09-25 05:36:40.544459+00	{"eTag": "\\"fd8f07333303a25179a6ffb47f387bf9\\"", "size": 294691, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:40.202Z", "contentLength": 294691, "httpStatusCode": 200}	e678adaa-c0c5-440b-8301-273cb653af9d	\N	\N	1
909208da-f553-4636-a797-ff22a6fdc258	assets	comfortable.png	\N	2025-09-25 05:36:40.347075+00	2025-09-25 05:36:40.347075+00	2025-09-25 05:36:40.347075+00	{"eTag": "\\"33063bf4a317efa9ead121593902e3fb\\"", "size": 2695, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:40.130Z", "contentLength": 2695, "httpStatusCode": 200}	d0d415be-5bff-4648-a08c-27ea6936eda4	\N	\N	1
03c5cea3-1fb7-4c7b-911e-74023d615442	assets	CTC_icon.png	\N	2025-09-25 05:36:40.395662+00	2025-09-25 05:36:40.395662+00	2025-09-25 05:36:40.395662+00	{"eTag": "\\"696347c31618923c72d30502689e3d15\\"", "size": 24663, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:40.164Z", "contentLength": 24663, "httpStatusCode": 200}	d26e5d6e-9782-46ce-bb13-728fa75d4d1a	\N	\N	1
30dc8b7f-4d6b-4b7b-95b5-66aad56a5875	assets	DI.jpg	\N	2025-09-25 05:36:41.371626+00	2025-09-25 05:36:41.371626+00	2025-09-25 05:36:41.371626+00	{"eTag": "\\"6af25f7135621212ad650a2abab69416\\"", "size": 8833, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:40.746Z", "contentLength": 8833, "httpStatusCode": 200}	95638f29-fb95-4fbc-b650-f1088cc042f3	\N	\N	1
a0a955e5-f325-4a86-8dce-96c7dce49ae3	assets	sqare_ctc_icon.png	\N	2025-09-25 05:36:42.973918+00	2025-09-25 05:36:42.973918+00	2025-09-25 05:36:42.973918+00	{"eTag": "\\"6e394d877a527b30c9cacac971fefe78\\"", "size": 74466, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:42.906Z", "contentLength": 74466, "httpStatusCode": 200}	7a7b5250-da78-4578-85e7-7c7dd193f60c	\N	\N	1
37fbd915-e1b3-4486-99f9-9bf111c6b45c	assets	HA.jpg	\N	2025-09-25 05:36:41.342588+00	2025-09-25 05:36:41.342588+00	2025-09-25 05:36:41.342588+00	{"eTag": "\\"85a84a83a10c547a2b730e8553bd3e3b\\"", "size": 10989, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:40.742Z", "contentLength": 10989, "httpStatusCode": 200}	6d6d8287-d3e7-4058-8511-60de5212ad61	\N	\N	1
36aa8ffc-7634-46c3-97e2-4027f0b2c32a	assets	homeassistant_logo.png	\N	2025-09-25 05:36:41.53261+00	2025-09-25 05:36:41.53261+00	2025-09-25 05:36:41.53261+00	{"eTag": "\\"762d73e78e8344561390ca97c89fa6a0\\"", "size": 62744, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:41.501Z", "contentLength": 62744, "httpStatusCode": 200}	9fbc64eb-7535-4274-a9a1-625bc08b8027	\N	\N	1
91bd014f-e2a5-4568-9167-d8b3e0a80309	assets	living-room.jpg	\N	2025-09-25 05:36:42.981173+00	2025-09-25 05:36:42.981173+00	2025-09-25 05:36:42.981173+00	{"eTag": "\\"a3260fd94e3d230d41d22c092c9c1ec4\\"", "size": 396006, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:42.868Z", "contentLength": 396006, "httpStatusCode": 200}	8caa6ec4-9daf-4ca4-bd36-122ee6495da6	\N	\N	1
8c78e1b4-ff3b-411d-838c-c6705ee8a28e	assets	smart_interface.jpg	\N	2025-09-25 05:36:42.951136+00	2025-09-25 05:36:42.951136+00	2025-09-25 05:36:42.951136+00	{"eTag": "\\"33b66e0043ff97d3a187067c1b8f4583\\"", "size": 15927, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:42.885Z", "contentLength": 15927, "httpStatusCode": 200}	24eafeeb-1514-4c84-9a1e-a343e7a9b739	\N	\N	1
81ba7389-807d-4507-8009-dd98760ef9c8	assets	sustainable.png	\N	2025-09-25 05:36:43.000996+00	2025-09-25 05:36:43.000996+00	2025-09-25 05:36:43.000996+00	{"eTag": "\\"d9ff67954db6abb94a1c285e8ac4dc1a\\"", "size": 3137, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:42.940Z", "contentLength": 3137, "httpStatusCode": 200}	98524e4a-c0ba-4ca2-bbb6-cf2e06c0bb61	\N	\N	1
60adcd56-29b4-4430-9b13-9ee03799a086	assets	floor_plans/1759297726696_scaled_2025_08_20_095939.png	98568fd9-dd57-4f17-9a61-76a6951f1fac	2025-10-01 05:48:46.152946+00	2025-10-01 05:48:46.152946+00	2025-10-01 05:48:46.152946+00	{"eTag": "\\"a4855451033aae5c63dc9c4eb351c152\\"", "size": 616314, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T05:48:46.132Z", "contentLength": 616314, "httpStatusCode": 200}	3e70ebbb-5f71-4457-96b9-efbc1383b42b	98568fd9-dd57-4f17-9a61-76a6951f1fac	{}	2
c730ca0b-1b64-42db-9693-8bd4072566fd	assets	floor_plans/1759297753860_scaled_2025_08_20_095939.png	98568fd9-dd57-4f17-9a61-76a6951f1fac	2025-10-01 05:49:14.59223+00	2025-10-01 05:49:14.59223+00	2025-10-01 05:49:14.59223+00	{"eTag": "\\"a4855451033aae5c63dc9c4eb351c152\\"", "size": 616314, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T05:49:14.580Z", "contentLength": 616314, "httpStatusCode": 200}	0105ae79-e748-4dac-8f40-9461472c2223	98568fd9-dd57-4f17-9a61-76a6951f1fac	{}	2
cf4132c4-1021-4a65-bdcb-2b0daac74858	assets	floor_plans/1759394864392_scaled_17593948440824051527099455416145.jpg	967e7680-75e4-4b14-a15d-8936c7e92bc7	2025-10-02 08:47:48.008266+00	2025-10-02 08:47:48.008266+00	2025-10-02 08:47:48.008266+00	{"eTag": "\\"5e5147e52abeab46ea9a2eec79a306ab\\"", "size": 215395, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T08:47:47.996Z", "contentLength": 215395, "httpStatusCode": 200}	60467797-bb62-46e1-afef-2ad698e767a9	967e7680-75e4-4b14-a15d-8936c7e92bc7	{}	2
619767e1-5ba1-46cd-b0f7-9cec0823e39b	assets	floor_plans/1759394927567_scaled_17593949195145610732692331816620.jpg	967e7680-75e4-4b14-a15d-8936c7e92bc7	2025-10-02 08:48:50.885047+00	2025-10-02 08:48:50.885047+00	2025-10-02 08:48:50.885047+00	{"eTag": "\\"11acdb60e691ea92c688d3b4bbfc8c0a\\"", "size": 172197, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T08:48:50.874Z", "contentLength": 172197, "httpStatusCode": 200}	8376e248-2794-48c5-921e-84013e36f369	967e7680-75e4-4b14-a15d-8936c7e92bc7	{}	2
784b4860-f012-41af-a23d-039eadae74d9	assets	floor_plans/1759394950892_scaled_1000000871.jpg	967e7680-75e4-4b14-a15d-8936c7e92bc7	2025-10-02 08:49:14.394406+00	2025-10-02 08:49:14.394406+00	2025-10-02 08:49:14.394406+00	{"eTag": "\\"3db16c5374d9e5c6dedc5e56ae26eba8\\"", "size": 269464, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T08:49:14.379Z", "contentLength": 269464, "httpStatusCode": 200}	0d5c2045-bdd5-4818-bde6-cf76ea5264b0	967e7680-75e4-4b14-a15d-8936c7e92bc7	{}	2
059946c8-451c-42cd-8017-435895a4e47d	assets	floor_plans/1759892315894_scaled_S_5046274.jpg	a939945b-b080-4575-871b-91e222484828	2025-10-08 02:58:36.861033+00	2025-10-08 02:58:36.861033+00	2025-10-08 02:58:36.861033+00	{"eTag": "\\"365573b3f129bc4a8e764ce11489a5f7\\"", "size": 38933, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-08T02:58:36.832Z", "contentLength": 38933, "httpStatusCode": 200}	286842bd-e7b0-4e4a-8a57-5e73b699ff9e	a939945b-b080-4575-871b-91e222484828	{}	2
dc18321d-bc0e-4229-89c7-787e9450a19f	assets	floor_plans/1759999360397_scaled_2025_10_09_102126.png	afb7e323-2304-42f0-84ba-c43d09380d0d	2025-10-09 08:42:42.103131+00	2025-10-09 08:42:42.103131+00	2025-10-09 08:42:42.103131+00	{"eTag": "\\"180dbf47abedd98d8e0cfe6071023557\\"", "size": 116044, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-09T08:42:42.065Z", "contentLength": 116044, "httpStatusCode": 200}	0dcc0f31-1c0b-4de6-b839-e1d748e08cd7	afb7e323-2304-42f0-84ba-c43d09380d0d	{}	2
a0ef39be-b474-460e-a7de-561aeee5a6d5	assets	photos/1760434598672_scaled_image.jpg	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-14 09:36:38.850938+00	2025-10-14 09:36:38.850938+00	2025-10-14 09:36:38.850938+00	{"eTag": "\\"1f145cb34543224691a208d36d345c77\\"", "size": 586834, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-14T09:36:38.835Z", "contentLength": 586834, "httpStatusCode": 200}	f80d4a92-8951-4b86-8d55-b171fb1003be	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	{}	2
12e24e51-3a05-44a3-9554-a8a462781b5a	assets	floor_plans/1759297744144_scaled_2025_08_20_095939.png	98568fd9-dd57-4f17-9a61-76a6951f1fac	2025-10-01 05:49:04.435774+00	2025-10-01 05:49:04.435774+00	2025-10-01 05:49:04.435774+00	{"eTag": "\\"a4855451033aae5c63dc9c4eb351c152\\"", "size": 616314, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T05:49:04.420Z", "contentLength": 616314, "httpStatusCode": 200}	fb2fdb9f-098e-4f3e-8ea9-100e72c98d41	98568fd9-dd57-4f17-9a61-76a6951f1fac	{}	2
52a4b258-e2b3-450c-9ee0-6201dcccd03c	assets	floor_plans/1759297802100_scaled_1F.png	98568fd9-dd57-4f17-9a61-76a6951f1fac	2025-10-01 05:50:02.296072+00	2025-10-01 05:50:02.296072+00	2025-10-01 05:50:02.296072+00	{"eTag": "\\"99dfea6748c2a7adf6f962a9c07aa39a\\"", "size": 33493, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T05:50:02.286Z", "contentLength": 33493, "httpStatusCode": 200}	85b1d5e1-ff7c-47de-98ca-9d0e79006d93	98568fd9-dd57-4f17-9a61-76a6951f1fac	{}	2
7085e231-8ac5-4ea3-b9fe-03642a97f798	assets	floor_plans/1759297838613_scaled_2025_08_19_182306.png	98568fd9-dd57-4f17-9a61-76a6951f1fac	2025-10-01 05:50:39.304621+00	2025-10-01 05:50:39.304621+00	2025-10-01 05:50:39.304621+00	{"eTag": "\\"079d6c569f535d39779cb145bbba2dd1\\"", "size": 763135, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T05:50:39.279Z", "contentLength": 763135, "httpStatusCode": 200}	c8c59fe7-0b4a-4330-8360-de5a556308ab	98568fd9-dd57-4f17-9a61-76a6951f1fac	{}	2
6654e93c-a5d9-433b-ba50-909c3b0834ad	assets	floor_plans/1759394883830_scaled_1000000869.jpg	967e7680-75e4-4b14-a15d-8936c7e92bc7	2025-10-02 08:48:06.288915+00	2025-10-02 08:48:06.288915+00	2025-10-02 08:48:06.288915+00	{"eTag": "\\"eea0335763b57402258caf69f4f4fdba\\"", "size": 107820, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T08:48:06.273Z", "contentLength": 107820, "httpStatusCode": 200}	e6adb017-872a-4ff9-810e-a40c0db9447a	967e7680-75e4-4b14-a15d-8936c7e92bc7	{}	2
8a3f252e-3190-4878-a7a8-105a99f2fe41	assets	floor_plans/1759394937558_scaled_1000000871.jpg	967e7680-75e4-4b14-a15d-8936c7e92bc7	2025-10-02 08:49:00.298926+00	2025-10-02 08:49:00.298926+00	2025-10-02 08:49:00.298926+00	{"eTag": "\\"3db16c5374d9e5c6dedc5e56ae26eba8\\"", "size": 269464, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T08:49:00.279Z", "contentLength": 269464, "httpStatusCode": 200}	0a07188a-2a7c-40e6-a52c-a198bb4057cc	967e7680-75e4-4b14-a15d-8936c7e92bc7	{}	2
aa3deeb8-fd40-4124-8978-94bade110645	assets	photos/1759394992938_scaled_17593949880424910763990775728596.jpg	967e7680-75e4-4b14-a15d-8936c7e92bc7	2025-10-02 08:49:57.852068+00	2025-10-02 08:49:57.852068+00	2025-10-02 08:49:57.852068+00	{"eTag": "\\"0be9d1e9aa52467ec097c516ecdd29a8\\"", "size": 200573, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-02T08:49:57.842Z", "contentLength": 200573, "httpStatusCode": 200}	65cb6be1-07f9-4215-a5ec-1d599fae7984	967e7680-75e4-4b14-a15d-8936c7e92bc7	{}	2
5e5bb80b-f5d2-4552-beca-a43efe198812	assets	floor_plans/1759999368145_scaled_2025_10_09_164229.png	afb7e323-2304-42f0-84ba-c43d09380d0d	2025-10-09 08:42:50.172001+00	2025-10-09 08:42:50.172001+00	2025-10-09 08:42:50.172001+00	{"eTag": "\\"e5c07ef75350de288e5ec478b086ceeb\\"", "size": 655720, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-09T08:42:50.153Z", "contentLength": 655720, "httpStatusCode": 200}	25c5a5c1-1a61-44b1-9fe4-2ee9c59cb8ab	afb7e323-2304-42f0-84ba-c43d09380d0d	{}	2
dc524c37-d42a-4fb8-96af-1207b21f7672	assets	photos/1760434639965_scaled_image.jpg	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-14 09:37:20.835674+00	2025-10-14 09:37:20.835674+00	2025-10-14 09:37:20.835674+00	{"eTag": "\\"42f22790ae8d0656d327cae924360ea7\\"", "size": 694990, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-14T09:37:20.818Z", "contentLength": 694990, "httpStatusCode": 200}	66049d61-05e8-4e13-954c-56132b96568d	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	{}	2
9c3d3f0c-2278-4491-b926-cba1183def88	assets	floor_plans/1759298374165_scaled_2025_08_19_182306.png	98568fd9-dd57-4f17-9a61-76a6951f1fac	2025-10-01 05:59:34.561514+00	2025-10-01 05:59:34.561514+00	2025-10-01 05:59:34.561514+00	{"eTag": "\\"079d6c569f535d39779cb145bbba2dd1\\"", "size": 763135, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T05:59:34.537Z", "contentLength": 763135, "httpStatusCode": 200}	0f64b24b-05bb-4092-a75f-dcb81c8f864e	98568fd9-dd57-4f17-9a61-76a6951f1fac	{}	2
bd8448f8-f7a7-4626-a24d-63b5106981f3	assets	floor_plans/1759999918415_scaled_2025_10_09_165139.png	afb7e323-2304-42f0-84ba-c43d09380d0d	2025-10-09 08:51:59.400482+00	2025-10-09 08:51:59.400482+00	2025-10-09 08:51:59.400482+00	{"eTag": "\\"39ef32ca38575c6c0eac167b9c614857\\"", "size": 285578, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-09T08:51:59.387Z", "contentLength": 285578, "httpStatusCode": 200}	d605391f-b73c-4598-b884-479aadad4ad8	afb7e323-2304-42f0-84ba-c43d09380d0d	{}	2
feebbf85-3cea-485c-a429-a8a3ebdc9131	assets	floor_plans/1760605655718_scaled_floorplan_1756191726259.jpg	a939945b-b080-4575-871b-91e222484828	2025-10-16 09:07:36.336511+00	2025-10-16 09:07:36.336511+00	2025-10-16 09:07:36.336511+00	{"eTag": "\\"271b03da0b5de8040b29c1a4b312a8ca\\"", "size": 19408, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-16T09:07:36.305Z", "contentLength": 19408, "httpStatusCode": 200}	2b891d91-9be7-445b-9417-e0fb6476a0ca	a939945b-b080-4575-871b-91e222484828	{}	2
d964f022-1191-46d8-a4d2-91493ad20e4a	assets	photos/1759299378969_scaled_2025_08_19_182644.png	98568fd9-dd57-4f17-9a61-76a6951f1fac	2025-10-01 06:16:19.360508+00	2025-10-01 06:16:19.360508+00	2025-10-01 06:16:19.360508+00	{"eTag": "\\"c7ae8c02121878f02c26b96b80df1f36\\"", "size": 533605, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T06:16:19.348Z", "contentLength": 533605, "httpStatusCode": 200}	98e55853-99d7-456c-a269-39bb4b7bf3e7	98568fd9-dd57-4f17-9a61-76a6951f1fac	{}	2
8245b4ce-1811-467b-8977-fc41cef5ea82	assets	floor_plans/1759999990539_scaled_2025_10_09_165258.png	afb7e323-2304-42f0-84ba-c43d09380d0d	2025-10-09 08:53:12.587613+00	2025-10-09 08:53:12.587613+00	2025-10-09 08:53:12.587613+00	{"eTag": "\\"5eff8beec4b67bb512d3715b53719fe5\\"", "size": 567383, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-09T08:53:12.576Z", "contentLength": 567383, "httpStatusCode": 200}	98e08543-da6d-4a52-9a1c-30f17e76bb77	afb7e323-2304-42f0-84ba-c43d09380d0d	{}	2
7d660cd9-1a84-4a24-9c14-4fc5542666d1	assets	photos/1760607434830_scaled_2025_09_02_172153.png	a939945b-b080-4575-871b-91e222484828	2025-10-16 09:37:14.277966+00	2025-10-16 09:37:14.277966+00	2025-10-16 09:37:14.277966+00	{"eTag": "\\"39ce3dd4b240963472b37f215fee72f2\\"", "size": 30817, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-16T09:37:14.265Z", "contentLength": 30817, "httpStatusCode": 200}	6cb19618-40dd-4711-9495-cf300a2dd2dc	a939945b-b080-4575-871b-91e222484828	{}	2
387daaf9-471d-4064-9a21-5b1d24388c2f	assets	floor_plans/1759299778112_scaled_S_5046274.jpg	98568fd9-dd57-4f17-9a61-76a6951f1fac	2025-10-01 06:22:58.381348+00	2025-10-01 06:22:58.381348+00	2025-10-01 06:22:58.381348+00	{"eTag": "\\"8d3743e1cd83b7dc036c446331fce23e\\"", "size": 100331, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T06:22:58.369Z", "contentLength": 100331, "httpStatusCode": 200}	b208d0a9-045d-4828-884b-2c20694db6fa	98568fd9-dd57-4f17-9a61-76a6951f1fac	{}	2
fb9edcf6-a285-4112-8faa-cd94310579f6	assets	floor_plans/1760425447720_scaled_S_5046274.jpg	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	2025-10-14 07:04:07.91019+00	2025-10-14 07:04:07.91019+00	2025-10-14 07:04:07.91019+00	{"eTag": "\\"365573b3f129bc4a8e764ce11489a5f7\\"", "size": 38933, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-14T07:04:07.879Z", "contentLength": 38933, "httpStatusCode": 200}	2fbd4b6a-a709-431f-a24d-c4e3cfb8f827	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	{}	2
91f1f88c-1df3-4da8-b29b-241c6b1d7cf7	assets	photos/1759299812538_scaled_2025_08_20_100239.png	98568fd9-dd57-4f17-9a61-76a6951f1fac	2025-10-01 06:23:33.157521+00	2025-10-01 06:23:33.157521+00	2025-10-01 06:23:33.157521+00	{"eTag": "\\"d6daae98bf358789dd7efd0a6ea8d967\\"", "size": 633694, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T06:23:33.136Z", "contentLength": 633694, "httpStatusCode": 200}	84141fcd-fc99-45a0-9d71-57a5c686948b	98568fd9-dd57-4f17-9a61-76a6951f1fac	{}	2
7da6b2f9-aa03-49cd-a833-e837f4af3f59	assets	photos/1760425485077_scaled_1F.png	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	2025-10-14 07:04:44.348849+00	2025-10-14 07:04:44.348849+00	2025-10-14 07:04:44.348849+00	{"eTag": "\\"99dfea6748c2a7adf6f962a9c07aa39a\\"", "size": 33493, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-14T07:04:44.336Z", "contentLength": 33493, "httpStatusCode": 200}	313b8110-ca82-4ca4-9c35-4ed3b942f153	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	{}	2
b942f2c0-8075-49d3-bb3f-e80c0d957e3e	assets	floor_plans/1759300256389_scaled_S_5046274.jpg	a939945b-b080-4575-871b-91e222484828	2025-10-01 06:30:56.745535+00	2025-10-01 06:30:56.745535+00	2025-10-01 06:30:56.745535+00	{"eTag": "\\"8d3743e1cd83b7dc036c446331fce23e\\"", "size": 100331, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T06:30:56.738Z", "contentLength": 100331, "httpStatusCode": 200}	6fa6c0ed-cb16-42a6-ae67-897de1862d65	a939945b-b080-4575-871b-91e222484828	{}	2
e146c3fe-088d-4120-99c9-af6eb42a7687	assets	photos/1760427732349_scaled_2025_08_19_182306.png	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	2025-10-14 07:42:12.366379+00	2025-10-14 07:42:12.366379+00	2025-10-14 07:42:12.366379+00	{"eTag": "\\"079d6c569f535d39779cb145bbba2dd1\\"", "size": 763135, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-14T07:42:12.342Z", "contentLength": 763135, "httpStatusCode": 200}	84db2453-8121-43a3-b292-787440b09408	b48d15d8-c7cb-4782-a8fb-b43055c49a1e	{}	2
da7efcf0-d4e1-43e2-9120-48dd58d1d649	assets	photos/1759300295189_scaled_1F.png	a939945b-b080-4575-871b-91e222484828	2025-10-01 06:31:36.058039+00	2025-10-01 06:31:36.058039+00	2025-10-01 06:31:36.058039+00	{"eTag": "\\"99dfea6748c2a7adf6f962a9c07aa39a\\"", "size": 33493, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T06:31:36.046Z", "contentLength": 33493, "httpStatusCode": 200}	4917d6dc-d3c2-42e5-9ac9-12d20deaa2b7	a939945b-b080-4575-871b-91e222484828	{}	2
c22dfacd-0ac0-4e8e-9dc4-dfc5a7c77b19	assets	floor_plans/1760428426484_scaled_IMG_3103.jpeg	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-14 07:53:47.745213+00	2025-10-14 07:53:47.745213+00	2025-10-14 07:53:47.745213+00	{"eTag": "\\"71aeee70b46581ec892cced0210abba1\\"", "size": 334666, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-14T07:53:47.732Z", "contentLength": 334666, "httpStatusCode": 200}	0c1305c1-4f5e-4fe6-8f91-1ddba285490e	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	{}	2
7dd0f7eb-d828-4010-a1a2-303c5a0071f2	assets	photos/1760428489990_scaled_IMG_3105.jpeg	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-14 07:54:51.588684+00	2025-10-14 07:54:51.588684+00	2025-10-14 07:54:51.588684+00	{"eTag": "\\"b04d404453d7cb2dafaa5b61383c8a19\\"", "size": 307683, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-14T07:54:51.576Z", "contentLength": 307683, "httpStatusCode": 200}	8ab4faf4-b019-49a2-adf3-2744af552551	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	{}	2
85a9aa51-a02f-4939-bbe2-fcea18c9bd97	assets	photos/1760428510494_scaled_IMG_3106.jpeg	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-14 07:55:11.639001+00	2025-10-14 07:55:11.639001+00	2025-10-14 07:55:11.639001+00	{"eTag": "\\"d6b23052607c6f50d22f2999d8ae0ad2\\"", "size": 196436, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-14T07:55:11.628Z", "contentLength": 196436, "httpStatusCode": 200}	144bc1ea-a722-4ba4-93c4-e5283fae3dc4	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	{}	2
d8ef9012-e6c5-498c-9cd4-504e1313ec71	assets	photos/1759301492975_scaled_CTC_icon.png	98568fd9-dd57-4f17-9a61-76a6951f1fac	2025-10-01 06:51:33.347421+00	2025-10-01 06:51:33.347421+00	2025-10-01 06:51:33.347421+00	{"eTag": "\\"6a2f6c2c24067b558671a998209e9edc\\"", "size": 34384, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T06:51:33.339Z", "contentLength": 34384, "httpStatusCode": 200}	f173ec8a-9324-45e0-800e-dd8837a5cd12	98568fd9-dd57-4f17-9a61-76a6951f1fac	{}	2
1d0c1b44-c6c6-43b3-950d-5ba274cd500c	assets	floor_plans/1760428454045_scaled_IMG_3103.jpeg	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-14 07:54:15.341482+00	2025-10-14 07:54:15.341482+00	2025-10-14 07:54:15.341482+00	{"eTag": "\\"71aeee70b46581ec892cced0210abba1\\"", "size": 334666, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-14T07:54:15.332Z", "contentLength": 334666, "httpStatusCode": 200}	3da5769f-6b35-4d2f-b447-f60fe6b06402	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	{}	2
778f9fbe-3dbf-45eb-bf48-0be8b7141c16	assets	floor_plans/1759304144723_scaled_1000003211.jpg	98568fd9-dd57-4f17-9a61-76a6951f1fac	2025-10-01 07:35:51.011859+00	2025-10-01 07:35:51.011859+00	2025-10-01 07:35:51.011859+00	{"eTag": "\\"d052ab1a7131fbdd482256763c8dcd1c\\"", "size": 145306, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T07:35:50.994Z", "contentLength": 145306, "httpStatusCode": 200}	5ca6b190-d89e-444e-a365-50802fcc83eb	98568fd9-dd57-4f17-9a61-76a6951f1fac	{}	2
abe894f9-8b74-4df3-a6ba-8342bdf57771	assets	floor_plans/1760428597968_scaled_2025_10_14_3.56.24.png	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-14 07:56:39.200949+00	2025-10-14 07:56:39.200949+00	2025-10-14 07:56:39.200949+00	{"eTag": "\\"5fcdc349f3842272c52b75df5af75e66\\"", "size": 69285, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-14T07:56:39.192Z", "contentLength": 69285, "httpStatusCode": 200}	a29f6854-d899-4009-bf30-0ad3565b2c8b	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	{}	2
2eaa4f1c-66a7-4dc4-adf1-0b943da7b3a1	assets	floor_plans/1759304169935_scaled_1000003211.jpg	98568fd9-dd57-4f17-9a61-76a6951f1fac	2025-10-01 07:36:20.976023+00	2025-10-01 07:36:20.976023+00	2025-10-01 07:36:20.976023+00	{"eTag": "\\"d052ab1a7131fbdd482256763c8dcd1c\\"", "size": 145306, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T07:36:20.966Z", "contentLength": 145306, "httpStatusCode": 200}	920d95be-8a48-4352-b8f4-5c75421f9302	98568fd9-dd57-4f17-9a61-76a6951f1fac	{}	2
2044f7d6-c5bf-4469-85fe-745a4bf4c539	assets	photos/1759304205678_scaled_1000003213.jpg	98568fd9-dd57-4f17-9a61-76a6951f1fac	2025-10-01 07:36:45.140329+00	2025-10-01 07:36:45.140329+00	2025-10-01 07:36:45.140329+00	{"eTag": "\\"a826803d6300766f1b062eac23d5101b\\"", "size": 154478, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-10-01T07:36:45.123Z", "contentLength": 154478, "httpStatusCode": 200}	cf1392f2-f880-4d2a-aada-a45fdc9170ff	98568fd9-dd57-4f17-9a61-76a6951f1fac	{}	2
02cfc691-2c8c-43db-b300-e6d023e1cda5	assets	floor_plans/1760428714274_scaled_2025_10_14_3.58.14.png	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-14 07:58:35.69901+00	2025-10-14 07:58:35.69901+00	2025-10-14 07:58:35.69901+00	{"eTag": "\\"518ce38120391d0051429bd065acc90e\\"", "size": 135420, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-14T07:58:35.687Z", "contentLength": 135420, "httpStatusCode": 200}	3ca01364-d8f5-43e9-81d0-cc02396c9e25	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	{}	2
cc85367e-709b-4ce3-81c5-e888b8baae50	assets	floor_plans/1760428790367_scaled_2025_10_14_3.58.14.png	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-14 07:59:51.323378+00	2025-10-14 07:59:51.323378+00	2025-10-14 07:59:51.323378+00	{"eTag": "\\"518ce38120391d0051429bd065acc90e\\"", "size": 135420, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-14T07:59:51.307Z", "contentLength": 135420, "httpStatusCode": 200}	df539cd7-bb9d-4870-a883-bc369ca77ed4	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	{}	2
6ad5df89-5dcf-481c-84de-109d01bbce31	assets	floor_plans/1760428736671_scaled_2025_10_14_3.58.14.png	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-14 07:58:57.757129+00	2025-10-14 07:58:57.757129+00	2025-10-14 07:58:57.757129+00	{"eTag": "\\"518ce38120391d0051429bd065acc90e\\"", "size": 135420, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-14T07:58:57.745Z", "contentLength": 135420, "httpStatusCode": 200}	48f25a6a-5ead-440b-8cfd-b4246a53b224	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	{}	2
c5f448ba-b05b-45b2-ac6a-d1b9b4ad099c	assets	floor_plans/1760428824692_scaled_2025_10_14_3.58.14.png	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-14 08:00:25.984875+00	2025-10-14 08:00:25.984875+00	2025-10-14 08:00:25.984875+00	{"eTag": "\\"518ce38120391d0051429bd065acc90e\\"", "size": 135420, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-14T08:00:25.976Z", "contentLength": 135420, "httpStatusCode": 200}	174a4d06-af18-4c12-90df-aade160e6f63	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	{}	2
f9aaf65d-56dc-46aa-8e79-02b58982d82f	assets	floor_plans/1760428965062_scaled_2025_10_14_3.58.14.png	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-14 08:02:46.245802+00	2025-10-14 08:02:46.245802+00	2025-10-14 08:02:46.245802+00	{"eTag": "\\"518ce38120391d0051429bd065acc90e\\"", "size": 135420, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-14T08:02:46.229Z", "contentLength": 135420, "httpStatusCode": 200}	1d798dd1-5106-498b-8276-9f86b185cbdf	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	{}	2
2b359675-2b62-45d7-9fad-9274d0ee4898	assets	photos/1760428999857_scaled.png	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	2025-10-14 08:03:21.363763+00	2025-10-14 08:03:21.363763+00	2025-10-14 08:03:21.363763+00	{"eTag": "\\"d2c716840c3e485fbe1905dd77830911\\"", "size": 64243, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-10-14T08:03:21.354Z", "contentLength": 64243, "httpStatusCode": 200}	be10ee29-50e9-498e-9a42-dddccc21bdf0	581142f6-a7dd-41dc-8e01-cb0f2eeb54cb	{}	2
c6423f7f-ae3a-41e3-9038-a24302b862ce	assets	durable.png	\N	2025-09-25 05:36:41.40361+00	2025-09-25 05:36:41.40361+00	2025-09-25 05:36:41.40361+00	{"eTag": "\\"0c230fb01f9adc9257bb7512534f5f39\\"", "size": 2559, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:41.130Z", "contentLength": 2559, "httpStatusCode": 200}	88c9f79f-8f38-4c1a-b020-6f68facf0c40	\N	\N	1
ff27ab0d-7a74-48b8-9480-72fe1acdc534	assets	homeassistant_phone_dashboard.png	\N	2025-09-25 05:36:41.54768+00	2025-09-25 05:36:41.54768+00	2025-09-25 05:36:41.54768+00	{"eTag": "\\"1bc22d8447b9e36df103b407c21d2973\\"", "size": 39104, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:41.501Z", "contentLength": 39104, "httpStatusCode": 200}	abf102d2-66c5-4aaa-9bae-373de82b91b0	\N	\N	1
25a52c62-21de-4a3b-80f0-7e3577e68504	assets	LIGHT.jpeg	\N	2025-09-25 05:36:41.738863+00	2025-09-25 05:36:41.738863+00	2025-09-25 05:36:41.738863+00	{"eTag": "\\"6462ed282d97b948dd80ad3168c5eadb\\"", "size": 17563, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-09-25T05:36:41.543Z", "contentLength": 17563, "httpStatusCode": 200}	b07a71a0-8820-4187-8c3b-037ca1288728	\N	\N	1
\.


--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.prefixes (bucket_id, name, created_at, updated_at) FROM stdin;
assets	floor_plans	2025-10-01 05:48:46.152946+00	2025-10-01 05:48:46.152946+00
assets	photos	2025-10-01 06:16:19.360508+00	2025-10-01 06:16:19.360508+00
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: hooks; Type: TABLE DATA; Schema: supabase_functions; Owner: supabase_functions_admin
--

COPY supabase_functions.hooks (id, hook_table_id, hook_name, created_at, request_id) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: supabase_functions; Owner: supabase_functions_admin
--

COPY supabase_functions.migrations (version, inserted_at) FROM stdin;
initial	2025-09-17 02:52:54.791204+00
20210809183423_update_grants	2025-09-17 02:52:54.791204+00
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: supabase_admin
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 501, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: supabase_admin
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: hooks_id_seq; Type: SEQUENCE SET; Schema: supabase_functions; Owner: supabase_functions_admin
--

SELECT pg_catalog.setval('supabase_functions.hooks_id_seq', 1, false);


--
-- Name: extensions extensions_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: supabase_admin
--

ALTER TABLE ONLY _realtime.extensions
    ADD CONSTRAINT extensions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: supabase_admin
--

ALTER TABLE ONLY _realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: supabase_admin
--

ALTER TABLE ONLY _realtime.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: attendance_leave_requests attendance_leave_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.attendance_leave_requests
    ADD CONSTRAINT attendance_leave_requests_pkey PRIMARY KEY (id);


--
-- Name: attendance_records attendance_records_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT attendance_records_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: customers customers_user_id_key; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_user_id_key UNIQUE (user_id);


--
-- Name: employee_skills employee_skills_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.employee_skills
    ADD CONSTRAINT employee_skills_pkey PRIMARY KEY (id);


--
-- Name: employees employees_email_key; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_email_key UNIQUE (email);


--
-- Name: employees employees_employee_id_key; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_employee_id_key UNIQUE (employee_id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: floor_plan_permissions floor_plan_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.floor_plan_permissions
    ADD CONSTRAINT floor_plan_permissions_pkey PRIMARY KEY (id);


--
-- Name: floor_plans floor_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.floor_plans
    ADD CONSTRAINT floor_plans_pkey PRIMARY KEY (id);


--
-- Name: holidays holidays_date_key; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.holidays
    ADD CONSTRAINT holidays_date_key UNIQUE (date);


--
-- Name: holidays holidays_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.holidays
    ADD CONSTRAINT holidays_pkey PRIMARY KEY (id);


--
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: job_vacancies job_vacancies_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.job_vacancies
    ADD CONSTRAINT job_vacancies_pkey PRIMARY KEY (id);


--
-- Name: leave_balances leave_balances_employee_id_leave_type_year_key; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.leave_balances
    ADD CONSTRAINT leave_balances_employee_id_leave_type_year_key UNIQUE (employee_id, leave_type, year);


--
-- Name: leave_balances leave_balances_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.leave_balances
    ADD CONSTRAINT leave_balances_pkey PRIMARY KEY (id);


--
-- Name: leave_requests leave_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_pkey PRIMARY KEY (id);


--
-- Name: photo_records photo_records_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.photo_records
    ADD CONSTRAINT photo_records_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: project_clients project_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_clients
    ADD CONSTRAINT project_clients_pkey PRIMARY KEY (id);


--
-- Name: project_comments project_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_comments
    ADD CONSTRAINT project_comments_pkey PRIMARY KEY (id);


--
-- Name: project_members project_members_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_members
    ADD CONSTRAINT project_members_pkey PRIMARY KEY (id);


--
-- Name: project_members project_members_project_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_members
    ADD CONSTRAINT project_members_project_id_user_id_key UNIQUE (project_id, user_id);


--
-- Name: project_tasks project_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_tasks
    ADD CONSTRAINT project_tasks_pkey PRIMARY KEY (id);


--
-- Name: project_timeline project_timeline_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_timeline
    ADD CONSTRAINT project_timeline_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: system_settings system_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.system_settings
    ADD CONSTRAINT system_settings_pkey PRIMARY KEY (key);


--
-- Name: employee_skills unique_employee_skill; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.employee_skills
    ADD CONSTRAINT unique_employee_skill UNIQUE (employee_id, skill_name);


--
-- Name: user_profiles user_profiles_email_key; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_email_key UNIQUE (email);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);


--
-- Name: user_profiles user_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_user_id_key UNIQUE (user_id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: iceberg_namespaces iceberg_namespaces_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.iceberg_namespaces
    ADD CONSTRAINT iceberg_namespaces_pkey PRIMARY KEY (id);


--
-- Name: iceberg_tables iceberg_tables_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.iceberg_tables
    ADD CONSTRAINT iceberg_tables_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: prefixes prefixes_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT prefixes_pkey PRIMARY KEY (bucket_id, level, name);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: hooks hooks_pkey; Type: CONSTRAINT; Schema: supabase_functions; Owner: supabase_functions_admin
--

ALTER TABLE ONLY supabase_functions.hooks
    ADD CONSTRAINT hooks_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: supabase_functions; Owner: supabase_functions_admin
--

ALTER TABLE ONLY supabase_functions.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (version);


--
-- Name: extensions_tenant_external_id_index; Type: INDEX; Schema: _realtime; Owner: supabase_admin
--

CREATE INDEX extensions_tenant_external_id_index ON _realtime.extensions USING btree (tenant_external_id);


--
-- Name: extensions_tenant_external_id_type_index; Type: INDEX; Schema: _realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX extensions_tenant_external_id_type_index ON _realtime.extensions USING btree (tenant_external_id, type);


--
-- Name: tenants_external_id_index; Type: INDEX; Schema: _realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX tenants_external_id_index ON _realtime.tenants USING btree (external_id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: idx_attendance_leave_requests_created_at; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_attendance_leave_requests_created_at ON public.attendance_leave_requests USING btree (created_at DESC);


--
-- Name: idx_attendance_leave_requests_employee_id; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_attendance_leave_requests_employee_id ON public.attendance_leave_requests USING btree (employee_id);


--
-- Name: idx_attendance_leave_requests_request_date; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_attendance_leave_requests_request_date ON public.attendance_leave_requests USING btree (request_date DESC);


--
-- Name: idx_attendance_leave_requests_status; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_attendance_leave_requests_status ON public.attendance_leave_requests USING btree (status);


--
-- Name: idx_attendance_records_check_in_time; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_attendance_records_check_in_time ON public.attendance_records USING btree (check_in_time);


--
-- Name: idx_attendance_records_employee_email; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_attendance_records_employee_email ON public.attendance_records USING btree (employee_email);


--
-- Name: idx_attendance_records_employee_id; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_attendance_records_employee_id ON public.attendance_records USING btree (employee_id);


--
-- Name: idx_customers_company; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_customers_company ON public.customers USING btree (company);


--
-- Name: idx_customers_email; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_customers_email ON public.customers USING btree (email);


--
-- Name: idx_customers_user_id; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_customers_user_id ON public.customers USING btree (user_id);


--
-- Name: idx_employees_department; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_employees_department ON public.employees USING btree (department);


--
-- Name: idx_employees_email; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_employees_email ON public.employees USING btree (email);


--
-- Name: idx_employees_employee_id; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_employees_employee_id ON public.employees USING btree (employee_id);


--
-- Name: idx_employees_hire_date; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_employees_hire_date ON public.employees USING btree (hire_date DESC);


--
-- Name: idx_employees_manager_id; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_employees_manager_id ON public.employees USING btree (manager_id);


--
-- Name: idx_employees_position; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_employees_position ON public.employees USING btree ("position");


--
-- Name: idx_employees_role; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_employees_role ON public.employees USING btree (role);


--
-- Name: idx_employees_status; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_employees_status ON public.employees USING btree (status);


--
-- Name: idx_floor_plan_permissions_floor_plan_id; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_floor_plan_permissions_floor_plan_id ON public.floor_plan_permissions USING btree (floor_plan_id);


--
-- Name: idx_floor_plan_permissions_user_id; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_floor_plan_permissions_user_id ON public.floor_plan_permissions USING btree (user_id);


--
-- Name: idx_floor_plans_project_id; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_floor_plans_project_id ON public.floor_plans USING btree (project_id);


--
-- Name: idx_holidays_date; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_holidays_date ON public.holidays USING btree (date);


--
-- Name: idx_holidays_workday; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_holidays_workday ON public.holidays USING btree (is_workday) WHERE (is_workday = false);


--
-- Name: idx_holidays_year; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_holidays_year ON public.holidays USING btree (year);


--
-- Name: idx_job_vacancies_active; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_job_vacancies_active ON public.job_vacancies USING btree (is_active);


--
-- Name: idx_job_vacancies_created_at; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_job_vacancies_created_at ON public.job_vacancies USING btree (created_at DESC);


--
-- Name: idx_job_vacancies_department; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_job_vacancies_department ON public.job_vacancies USING btree (department);


--
-- Name: idx_job_vacancies_type; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_job_vacancies_type ON public.job_vacancies USING btree (type);


--
-- Name: idx_leave_balances_employee; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_leave_balances_employee ON public.leave_balances USING btree (employee_id);


--
-- Name: idx_leave_balances_year; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_leave_balances_year ON public.leave_balances USING btree (year);


--
-- Name: idx_leave_requests_created; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_leave_requests_created ON public.leave_requests USING btree (created_at DESC);


--
-- Name: idx_leave_requests_dates; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_leave_requests_dates ON public.leave_requests USING btree (start_date, end_date);


--
-- Name: idx_leave_requests_employee; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_leave_requests_employee ON public.leave_requests USING btree (employee_id);


--
-- Name: idx_leave_requests_status; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_leave_requests_status ON public.leave_requests USING btree (status);


--
-- Name: idx_project_clients_project_id; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_project_clients_project_id ON public.project_clients USING btree (project_id);


--
-- Name: idx_project_comments_parent_id; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_project_comments_parent_id ON public.project_comments USING btree (parent_id);


--
-- Name: idx_project_comments_project_id; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_project_comments_project_id ON public.project_comments USING btree (project_id);


--
-- Name: idx_project_members_project_id; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_project_members_project_id ON public.project_members USING btree (project_id);


--
-- Name: idx_project_members_user_id; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_project_members_user_id ON public.project_members USING btree (user_id);


--
-- Name: idx_project_tasks_assigned_to; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_project_tasks_assigned_to ON public.project_tasks USING btree (assigned_to);


--
-- Name: idx_project_tasks_next; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_project_tasks_next ON public.project_tasks USING btree (next_task_id);


--
-- Name: idx_project_tasks_previous; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_project_tasks_previous ON public.project_tasks USING btree (previous_task_id);


--
-- Name: idx_project_tasks_project_id; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_project_tasks_project_id ON public.project_tasks USING btree (project_id);


--
-- Name: idx_project_tasks_status; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_project_tasks_status ON public.project_tasks USING btree (status);


--
-- Name: idx_project_timeline_date; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_project_timeline_date ON public.project_timeline USING btree (milestone_date);


--
-- Name: idx_project_timeline_project_id; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_project_timeline_project_id ON public.project_timeline USING btree (project_id);


--
-- Name: idx_projects_owner_id; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_projects_owner_id ON public.projects USING btree (owner_id);


--
-- Name: idx_projects_status; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_projects_status ON public.projects USING btree (status);


--
-- Name: idx_user_profiles_display_name; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_user_profiles_display_name ON public.user_profiles USING btree (display_name);


--
-- Name: idx_user_profiles_email; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_user_profiles_email ON public.user_profiles USING btree (email);


--
-- Name: idx_user_profiles_user_id; Type: INDEX; Schema: public; Owner: supabase_admin
--

CREATE INDEX idx_user_profiles_user_id ON public.user_profiles USING btree (user_id);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: idx_iceberg_namespaces_bucket_id; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX idx_iceberg_namespaces_bucket_id ON storage.iceberg_namespaces USING btree (bucket_id, name);


--
-- Name: idx_iceberg_tables_namespace_id; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX idx_iceberg_tables_namespace_id ON storage.iceberg_tables USING btree (namespace_id, name);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_name_bucket_level_unique; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX idx_name_bucket_level_unique ON storage.objects USING btree (name COLLATE "C", bucket_id, level);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_lower_name ON storage.objects USING btree ((path_tokens[level]), lower(name) text_pattern_ops, bucket_id, level);


--
-- Name: idx_prefixes_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_prefixes_lower_name ON storage.prefixes USING btree (bucket_id, level, ((string_to_array(name, '/'::text))[level]), lower(name) text_pattern_ops);


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: objects_bucket_id_level_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX objects_bucket_id_level_idx ON storage.objects USING btree (bucket_id, level, name COLLATE "C");


--
-- Name: supabase_functions_hooks_h_table_id_h_name_idx; Type: INDEX; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE INDEX supabase_functions_hooks_h_table_id_h_name_idx ON supabase_functions.hooks USING btree (hook_table_id, hook_name);


--
-- Name: supabase_functions_hooks_request_id_idx; Type: INDEX; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE INDEX supabase_functions_hooks_request_id_idx ON supabase_functions.hooks USING btree (request_id);


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: supabase_auth_admin
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- Name: leave_balances trigger_leave_balances_updated_at; Type: TRIGGER; Schema: public; Owner: supabase_admin
--

CREATE TRIGGER trigger_leave_balances_updated_at BEFORE UPDATE ON public.leave_balances FOR EACH ROW EXECUTE FUNCTION public.update_leave_balances_updated_at();


--
-- Name: leave_requests trigger_leave_requests_updated_at; Type: TRIGGER; Schema: public; Owner: supabase_admin
--

CREATE TRIGGER trigger_leave_requests_updated_at BEFORE UPDATE ON public.leave_requests FOR EACH ROW EXECUTE FUNCTION public.update_leave_requests_updated_at();


--
-- Name: leave_requests trigger_update_leave_balance; Type: TRIGGER; Schema: public; Owner: supabase_admin
--

CREATE TRIGGER trigger_update_leave_balance AFTER INSERT OR UPDATE ON public.leave_requests FOR EACH ROW EXECUTE FUNCTION public.update_leave_balance_on_request_change();


--
-- Name: attendance_leave_requests update_attendance_leave_requests_updated_at; Type: TRIGGER; Schema: public; Owner: supabase_admin
--

CREATE TRIGGER update_attendance_leave_requests_updated_at BEFORE UPDATE ON public.attendance_leave_requests FOR EACH ROW EXECUTE FUNCTION public.update_attendance_leave_requests_updated_at();


--
-- Name: attendance_records update_attendance_records_updated_at; Type: TRIGGER; Schema: public; Owner: supabase_admin
--

CREATE TRIGGER update_attendance_records_updated_at BEFORE UPDATE ON public.attendance_records FOR EACH ROW EXECUTE FUNCTION public.update_attendance_records_updated_at();


--
-- Name: customers update_customers_updated_at; Type: TRIGGER; Schema: public; Owner: supabase_admin
--

CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: employees update_employees_updated_at; Type: TRIGGER; Schema: public; Owner: supabase_admin
--

CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON public.employees FOR EACH ROW EXECUTE FUNCTION public.update_employee_updated_at();


--
-- Name: project_clients update_project_clients_updated_at; Type: TRIGGER; Schema: public; Owner: supabase_admin
--

CREATE TRIGGER update_project_clients_updated_at BEFORE UPDATE ON public.project_clients FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: project_comments update_project_comments_updated_at; Type: TRIGGER; Schema: public; Owner: supabase_admin
--

CREATE TRIGGER update_project_comments_updated_at BEFORE UPDATE ON public.project_comments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: project_tasks update_project_tasks_updated_at; Type: TRIGGER; Schema: public; Owner: supabase_admin
--

CREATE TRIGGER update_project_tasks_updated_at BEFORE UPDATE ON public.project_tasks FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: project_timeline update_project_timeline_updated_at; Type: TRIGGER; Schema: public; Owner: supabase_admin
--

CREATE TRIGGER update_project_timeline_updated_at BEFORE UPDATE ON public.project_timeline FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: projects update_projects_updated_at; Type: TRIGGER; Schema: public; Owner: supabase_admin
--

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON public.projects FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: user_profiles update_user_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: supabase_admin
--

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION public.update_user_profiles_updated_at();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: objects objects_delete_delete_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_delete_delete_prefix AFTER DELETE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects objects_insert_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_insert_create_prefix BEFORE INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.objects_insert_prefix_trigger();


--
-- Name: objects objects_update_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_update_create_prefix BEFORE UPDATE ON storage.objects FOR EACH ROW WHEN (((new.name <> old.name) OR (new.bucket_id <> old.bucket_id))) EXECUTE FUNCTION storage.objects_update_prefix_trigger();


--
-- Name: prefixes prefixes_create_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_create_hierarchy BEFORE INSERT ON storage.prefixes FOR EACH ROW WHEN ((pg_trigger_depth() < 1)) EXECUTE FUNCTION storage.prefixes_insert_trigger();


--
-- Name: prefixes prefixes_delete_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_delete_hierarchy AFTER DELETE ON storage.prefixes FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: extensions extensions_tenant_external_id_fkey; Type: FK CONSTRAINT; Schema: _realtime; Owner: supabase_admin
--

ALTER TABLE ONLY _realtime.extensions
    ADD CONSTRAINT extensions_tenant_external_id_fkey FOREIGN KEY (tenant_external_id) REFERENCES _realtime.tenants(external_id) ON DELETE CASCADE;


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: attendance_leave_requests attendance_leave_requests_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.attendance_leave_requests
    ADD CONSTRAINT attendance_leave_requests_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: attendance_leave_requests attendance_leave_requests_reviewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.attendance_leave_requests
    ADD CONSTRAINT attendance_leave_requests_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.employees(id);


--
-- Name: attendance_records attendance_records_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT attendance_records_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: customers customers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: employee_skills employee_skills_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.employee_skills
    ADD CONSTRAINT employee_skills_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: employees employees_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: employees employees_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: employees employees_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.employees(id);


--
-- Name: floor_plan_permissions floor_plan_permissions_floor_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.floor_plan_permissions
    ADD CONSTRAINT floor_plan_permissions_floor_plan_id_fkey FOREIGN KEY (floor_plan_id) REFERENCES public.floor_plans(id);


--
-- Name: floor_plan_permissions floor_plan_permissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.floor_plan_permissions
    ADD CONSTRAINT floor_plan_permissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: floor_plans floor_plans_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.floor_plans
    ADD CONSTRAINT floor_plans_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE SET NULL;


--
-- Name: floor_plans floor_plans_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.floor_plans
    ADD CONSTRAINT floor_plans_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: images images_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES auth.users(id);


--
-- Name: leave_balances leave_balances_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.leave_balances
    ADD CONSTRAINT leave_balances_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: leave_requests leave_requests_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: leave_requests leave_requests_reviewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.employees(id) ON DELETE SET NULL;


--
-- Name: photo_records photo_records_floor_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.photo_records
    ADD CONSTRAINT photo_records_floor_plan_id_fkey FOREIGN KEY (floor_plan_id) REFERENCES public.floor_plans(id);


--
-- Name: photo_records photo_records_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.photo_records
    ADD CONSTRAINT photo_records_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id);


--
-- Name: project_clients project_clients_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_clients
    ADD CONSTRAINT project_clients_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_comments project_comments_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_comments
    ADD CONSTRAINT project_comments_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.project_comments(id) ON DELETE CASCADE;


--
-- Name: project_comments project_comments_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_comments
    ADD CONSTRAINT project_comments_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_comments project_comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_comments
    ADD CONSTRAINT project_comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: project_members project_members_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_members
    ADD CONSTRAINT project_members_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_members project_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_members
    ADD CONSTRAINT project_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: project_tasks project_tasks_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_tasks
    ADD CONSTRAINT project_tasks_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: project_tasks project_tasks_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_tasks
    ADD CONSTRAINT project_tasks_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: project_tasks project_tasks_next_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_tasks
    ADD CONSTRAINT project_tasks_next_task_id_fkey FOREIGN KEY (next_task_id) REFERENCES public.project_tasks(id) ON DELETE SET NULL;


--
-- Name: project_tasks project_tasks_previous_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_tasks
    ADD CONSTRAINT project_tasks_previous_task_id_fkey FOREIGN KEY (previous_task_id) REFERENCES public.project_tasks(id) ON DELETE SET NULL;


--
-- Name: project_tasks project_tasks_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_tasks
    ADD CONSTRAINT project_tasks_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_timeline project_timeline_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_timeline
    ADD CONSTRAINT project_timeline_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: project_timeline project_timeline_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.project_timeline
    ADD CONSTRAINT project_timeline_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: projects projects_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: user_profiles user_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: iceberg_namespaces iceberg_namespaces_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.iceberg_namespaces
    ADD CONSTRAINT iceberg_namespaces_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_analytics(id) ON DELETE CASCADE;


--
-- Name: iceberg_tables iceberg_tables_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.iceberg_tables
    ADD CONSTRAINT iceberg_tables_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_analytics(id) ON DELETE CASCADE;


--
-- Name: iceberg_tables iceberg_tables_namespace_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.iceberg_tables
    ADD CONSTRAINT iceberg_tables_namespace_id_fkey FOREIGN KEY (namespace_id) REFERENCES storage.iceberg_namespaces(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: prefixes prefixes_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT "prefixes_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: holidays Anyone can read holidays; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Anyone can read holidays" ON public.holidays FOR SELECT TO authenticated USING (true);


--
-- Name: job_vacancies Anyone can view active job vacancies; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Anyone can view active job vacancies" ON public.job_vacancies FOR SELECT USING ((is_active = true));


--
-- Name: employee_skills Authenticated users can manage employee skills; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Authenticated users can manage employee skills" ON public.employee_skills USING ((auth.role() = 'authenticated'::text));


--
-- Name: user_profiles Authenticated users can view all profiles; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Authenticated users can view all profiles" ON public.user_profiles FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: employees Boss can delete employees; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Boss can delete employees" ON public.employees FOR DELETE USING ((public.get_current_user_role() = 'boss'::text));


--
-- Name: employees Boss can update all employees; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Boss can update all employees" ON public.employees FOR UPDATE USING ((public.get_current_user_role() = 'boss'::text));


--
-- Name: attendance_leave_requests Employees can create own requests; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Employees can create own requests" ON public.attendance_leave_requests FOR INSERT WITH CHECK ((employee_id = auth.uid()));


--
-- Name: attendance_leave_requests Employees can delete own pending requests; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Employees can delete own pending requests" ON public.attendance_leave_requests FOR DELETE USING (((employee_id = auth.uid()) AND (status = 'pending'::text)));


--
-- Name: employees Employees can update own info; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Employees can update own info" ON public.employees FOR UPDATE USING ((id = auth.uid()));


--
-- Name: attendance_leave_requests Employees can update own pending requests; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Employees can update own pending requests" ON public.attendance_leave_requests FOR UPDATE USING (((employee_id = auth.uid()) AND (status = 'pending'::text)));


--
-- Name: customers Employees can view all customers; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Employees can view all customers" ON public.customers FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.employees
  WHERE ((employees.id = auth.uid()) AND (employees.status = '在職'::text)))));


--
-- Name: attendance_records Employees can view own attendance records; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Employees can view own attendance records" ON public.attendance_records FOR SELECT USING ((employee_email = (auth.jwt() ->> 'email'::text)));


--
-- Name: attendance_leave_requests Employees can view own requests; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Employees can view own requests" ON public.attendance_leave_requests FOR SELECT USING ((employee_id = auth.uid()));


--
-- Name: employees HR can update non-boss employees; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "HR can update non-boss employees" ON public.employees FOR UPDATE USING (((public.get_current_user_role() = 'hr'::text) AND (role <> 'boss'::text)));


--
-- Name: attendance_records Managers can delete attendance; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Managers can delete attendance" ON public.attendance_records FOR DELETE USING ((public.get_current_user_role() = ANY (ARRAY['boss'::text, 'hr'::text])));


--
-- Name: attendance_records Managers can insert any attendance; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Managers can insert any attendance" ON public.attendance_records FOR INSERT WITH CHECK ((public.get_current_user_role() = ANY (ARRAY['boss'::text, 'hr'::text])));


--
-- Name: employees Managers can insert employees; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Managers can insert employees" ON public.employees FOR INSERT WITH CHECK ((public.get_current_user_role() = ANY (ARRAY['boss'::text, 'hr'::text])));


--
-- Name: attendance_records Managers can update all attendance; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Managers can update all attendance" ON public.attendance_records FOR UPDATE USING ((public.get_current_user_role() = ANY (ARRAY['boss'::text, 'hr'::text])));


--
-- Name: attendance_leave_requests Managers can update requests; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Managers can update requests" ON public.attendance_leave_requests FOR UPDATE USING ((public.get_current_user_role() = ANY (ARRAY['boss'::text, 'hr'::text])));


--
-- Name: attendance_records Managers can view all attendance; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Managers can view all attendance" ON public.attendance_records FOR SELECT USING ((public.get_current_user_role() = ANY (ARRAY['boss'::text, 'hr'::text])));


--
-- Name: employees Managers can view all employees; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Managers can view all employees" ON public.employees FOR SELECT USING ((public.get_current_user_role() = ANY (ARRAY['boss'::text, 'hr'::text])));


--
-- Name: attendance_leave_requests Managers can view all requests; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Managers can view all requests" ON public.attendance_leave_requests FOR SELECT USING ((public.get_current_user_role() = ANY (ARRAY['boss'::text, 'hr'::text])));


--
-- Name: holidays Only admins can manage holidays; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Only admins can manage holidays" ON public.holidays TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.employees
  WHERE ((employees.id = auth.uid()) AND (employees.role = 'admin'::text)))));


--
-- Name: project_clients Owners and admins can manage clients; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Owners and admins can manage clients" ON public.project_clients USING (public.has_project_admin_access(project_id, auth.uid())) WITH CHECK (public.has_project_admin_access(project_id, auth.uid()));


--
-- Name: project_members Owners and admins can manage members; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Owners and admins can manage members" ON public.project_members USING (public.has_project_admin_access(project_id, auth.uid())) WITH CHECK (public.has_project_admin_access(project_id, auth.uid()));


--
-- Name: projects Owners and admins can update projects; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Owners and admins can update projects" ON public.projects FOR UPDATE USING (((owner_id = auth.uid()) OR public.has_project_admin_access(id, auth.uid()))) WITH CHECK (((owner_id = auth.uid()) OR public.has_project_admin_access(id, auth.uid())));


--
-- Name: projects Owners can delete their projects; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Owners can delete their projects" ON public.projects FOR DELETE USING ((owner_id = auth.uid()));


--
-- Name: project_comments Project members can add comments; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Project members can add comments" ON public.project_comments FOR INSERT WITH CHECK ((public.has_project_access(project_id, auth.uid()) AND (user_id = auth.uid())));


--
-- Name: project_tasks Project members can manage tasks; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Project members can manage tasks" ON public.project_tasks USING (public.has_project_access(project_id, auth.uid())) WITH CHECK (public.has_project_access(project_id, auth.uid()));


--
-- Name: project_timeline Project members can manage timeline; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Project members can manage timeline" ON public.project_timeline USING (public.has_project_access(project_id, auth.uid())) WITH CHECK (public.has_project_access(project_id, auth.uid()));


--
-- Name: project_clients Project members can view clients; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Project members can view clients" ON public.project_clients FOR SELECT USING (public.has_project_access(project_id, auth.uid()));


--
-- Name: project_comments Project members can view comments; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Project members can view comments" ON public.project_comments FOR SELECT USING (public.has_project_access(project_id, auth.uid()));


--
-- Name: project_members Project members can view other members; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Project members can view other members" ON public.project_members FOR SELECT USING (public.has_project_access(project_id, auth.uid()));


--
-- Name: project_tasks Project members can view tasks; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Project members can view tasks" ON public.project_tasks FOR SELECT USING (public.has_project_access(project_id, auth.uid()));


--
-- Name: project_timeline Project members can view timeline; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Project members can view timeline" ON public.project_timeline FOR SELECT USING (public.has_project_access(project_id, auth.uid()));


--
-- Name: project_members Project owners can delete members; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Project owners can delete members" ON public.project_members FOR DELETE USING ((EXISTS ( SELECT 1
   FROM public.projects p
  WHERE ((p.id = project_members.project_id) AND (p.owner_id = auth.uid())))));


--
-- Name: projects Project owners can delete their projects; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Project owners can delete their projects" ON public.projects FOR DELETE USING ((owner_id = auth.uid()));


--
-- Name: project_members Project owners can insert members; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Project owners can insert members" ON public.project_members FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM public.projects p
  WHERE ((p.id = project_members.project_id) AND (p.owner_id = auth.uid())))));


--
-- Name: project_clients Project owners can manage clients; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Project owners can manage clients" ON public.project_clients USING ((EXISTS ( SELECT 1
   FROM public.projects p
  WHERE ((p.id = project_clients.project_id) AND (p.owner_id = auth.uid())))));


--
-- Name: project_members Project owners can update members; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Project owners can update members" ON public.project_members FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM public.projects p
  WHERE ((p.id = project_members.project_id) AND (p.owner_id = auth.uid()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.projects p
  WHERE ((p.id = project_members.project_id) AND (p.owner_id = auth.uid())))));


--
-- Name: projects Project owners can update their projects; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Project owners can update their projects" ON public.projects FOR UPDATE USING ((owner_id = auth.uid())) WITH CHECK ((owner_id = auth.uid()));


--
-- Name: projects Users can create their own projects; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can create their own projects" ON public.projects FOR INSERT WITH CHECK ((owner_id = auth.uid()));


--
-- Name: project_comments Users can delete their own comments; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can delete their own comments" ON public.project_comments FOR DELETE USING ((user_id = auth.uid()));


--
-- Name: attendance_records Users can insert own attendance; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can insert own attendance" ON public.attendance_records FOR INSERT WITH CHECK ((employee_id = auth.uid()));


--
-- Name: customers Users can insert their own customer profile; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can insert their own customer profile" ON public.customers FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: projects Users can insert their own projects; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can insert their own projects" ON public.projects FOR INSERT WITH CHECK ((owner_id = auth.uid()));


--
-- Name: attendance_records Users can update own today attendance; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can update own today attendance" ON public.attendance_records FOR UPDATE USING (((employee_id = auth.uid()) AND (date(check_in_time) = CURRENT_DATE) AND (check_out_time IS NULL)));


--
-- Name: project_comments Users can update their own comments; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can update their own comments" ON public.project_comments FOR UPDATE USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: customers Users can update their own customer profile; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can update their own customer profile" ON public.customers FOR UPDATE USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));


--
-- Name: projects Users can view accessible projects; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can view accessible projects" ON public.projects FOR SELECT USING (((owner_id = auth.uid()) OR public.has_project_access(id, auth.uid())));


--
-- Name: user_profiles Users can view and update own profile; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can view and update own profile" ON public.user_profiles USING ((auth.uid() = user_id));


--
-- Name: project_members Users can view members of their projects; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can view members of their projects" ON public.project_members FOR SELECT USING (((EXISTS ( SELECT 1
   FROM public.projects p
  WHERE ((p.id = project_members.project_id) AND (p.owner_id = auth.uid())))) OR (user_id = auth.uid())));


--
-- Name: attendance_records Users can view own attendance; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can view own attendance" ON public.attendance_records FOR SELECT USING ((employee_id = auth.uid()));


--
-- Name: employees Users can view own profile; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can view own profile" ON public.employees FOR SELECT USING ((id = auth.uid()));


--
-- Name: customers Users can view their own customer profile; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can view their own customer profile" ON public.customers FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: attendance_leave_requests; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.attendance_leave_requests ENABLE ROW LEVEL SECURITY;

--
-- Name: attendance_records; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;

--
-- Name: customers; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

--
-- Name: employee_skills; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.employee_skills ENABLE ROW LEVEL SECURITY;

--
-- Name: employees; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;

--
-- Name: floor_plan_permissions; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.floor_plan_permissions ENABLE ROW LEVEL SECURITY;

--
-- Name: floor_plan_permissions floor_plan_permissions_manage_policy; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY floor_plan_permissions_manage_policy ON public.floor_plan_permissions TO authenticated USING (public.has_floor_plan_admin_access(floor_plan_id, auth.uid())) WITH CHECK (public.has_floor_plan_admin_access(floor_plan_id, auth.uid()));


--
-- Name: floor_plan_permissions floor_plan_permissions_select_policy; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY floor_plan_permissions_select_policy ON public.floor_plan_permissions FOR SELECT TO authenticated USING ((public.has_floor_plan_admin_access(floor_plan_id, auth.uid()) OR (user_id = auth.uid())));


--
-- Name: floor_plans; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.floor_plans ENABLE ROW LEVEL SECURITY;

--
-- Name: floor_plans floor_plans_delete_policy; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY floor_plans_delete_policy ON public.floor_plans FOR DELETE TO authenticated USING ((user_id = auth.uid()));


--
-- Name: floor_plans floor_plans_insert_policy; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY floor_plans_insert_policy ON public.floor_plans FOR INSERT TO authenticated WITH CHECK ((user_id = auth.uid()));


--
-- Name: floor_plans floor_plans_select_policy; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY floor_plans_select_policy ON public.floor_plans FOR SELECT TO authenticated USING (((user_id = auth.uid()) OR public.has_floor_plan_access(id, auth.uid())));


--
-- Name: floor_plans floor_plans_update_policy; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY floor_plans_update_policy ON public.floor_plans FOR UPDATE TO authenticated USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: holidays; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.holidays ENABLE ROW LEVEL SECURITY;

--
-- Name: job_vacancies; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.job_vacancies ENABLE ROW LEVEL SECURITY;

--
-- Name: leave_balances; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.leave_balances ENABLE ROW LEVEL SECURITY;

--
-- Name: leave_requests; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.leave_requests ENABLE ROW LEVEL SECURITY;

--
-- Name: photo_records; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.photo_records ENABLE ROW LEVEL SECURITY;

--
-- Name: photo_records photo_records_delete_policy; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY photo_records_delete_policy ON public.photo_records FOR DELETE TO authenticated USING ((user_id = auth.uid()));


--
-- Name: photo_records photo_records_insert_policy; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY photo_records_insert_policy ON public.photo_records FOR INSERT TO authenticated WITH CHECK (((user_id = auth.uid()) AND public.has_floor_plan_edit_access(floor_plan_id, auth.uid())));


--
-- Name: photo_records photo_records_select_policy; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY photo_records_select_policy ON public.photo_records FOR SELECT TO authenticated USING (((user_id = auth.uid()) OR public.has_floor_plan_access(floor_plan_id, auth.uid())));


--
-- Name: photo_records photo_records_update_policy; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY photo_records_update_policy ON public.photo_records FOR UPDATE TO authenticated USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: project_clients; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.project_clients ENABLE ROW LEVEL SECURITY;

--
-- Name: project_comments; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.project_comments ENABLE ROW LEVEL SECURITY;

--
-- Name: project_members; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.project_members ENABLE ROW LEVEL SECURITY;

--
-- Name: project_tasks; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.project_tasks ENABLE ROW LEVEL SECURITY;

--
-- Name: project_timeline; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.project_timeline ENABLE ROW LEVEL SECURITY;

--
-- Name: projects; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

--
-- Name: user_profiles; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: leave_requests 員工可取消待審核的請假; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "員工可取消待審核的請假" ON public.leave_requests FOR UPDATE USING (((employee_id = auth.uid()) AND (status = 'pending'::text)));


--
-- Name: leave_requests 員工可建立請假申請; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "員工可建立請假申請" ON public.leave_requests FOR INSERT WITH CHECK ((employee_id = auth.uid()));


--
-- Name: leave_balances 員工可查看自己的假別額度; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "員工可查看自己的假別額度" ON public.leave_balances FOR SELECT USING ((employee_id = auth.uid()));


--
-- Name: leave_requests 員工可查看自己的請假申請; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "員工可查看自己的請假申請" ON public.leave_requests FOR SELECT USING ((employee_id = auth.uid()));


--
-- Name: leave_balances 服務角色可管理假別額度; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "服務角色可管理假別額度" ON public.leave_balances USING ((auth.role() = 'service_role'::text));


--
-- Name: leave_requests 管理者可審核請假申請; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "管理者可審核請假申請" ON public.leave_requests FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM public.employees
  WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['boss'::text, 'hr'::text]))))));


--
-- Name: leave_balances 管理者可查看所有假別額度; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "管理者可查看所有假別額度" ON public.leave_balances FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.employees
  WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['boss'::text, 'hr'::text]))))));


--
-- Name: leave_requests 管理者可查看所有請假申請; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "管理者可查看所有請假申請" ON public.leave_requests FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.employees
  WHERE ((employees.id = auth.uid()) AND (employees.role = ANY (ARRAY['boss'::text, 'hr'::text]))))));


--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: objects Give anon users access to JPG images in folder 1bqp9qb_0; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Give anon users access to JPG images in folder 1bqp9qb_0" ON storage.objects FOR SELECT USING (((bucket_id = 'assets'::text) AND (storage.extension(name) = 'jpg'::text) AND (lower((storage.foldername(name))[1]) = 'public'::text) AND (auth.role() = 'anon'::text)));


--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: iceberg_namespaces; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.iceberg_namespaces ENABLE ROW LEVEL SECURITY;

--
-- Name: iceberg_tables; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.iceberg_tables ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: prefixes; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.prefixes ENABLE ROW LEVEL SECURITY;

--
-- Name: objects public access 1bqp9qb_0; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "public access 1bqp9qb_0" ON storage.objects FOR INSERT WITH CHECK ((bucket_id = 'assets'::text));


--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT ALL ON SCHEMA auth TO postgres;


--
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- Name: SCHEMA net; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA net TO supabase_functions_admin;
GRANT USAGE ON SCHEMA net TO postgres;
GRANT USAGE ON SCHEMA net TO anon;
GRANT USAGE ON SCHEMA net TO authenticated;
GRANT USAGE ON SCHEMA net TO service_role;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: SCHEMA realtime; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA realtime TO postgres;
GRANT USAGE ON SCHEMA realtime TO anon;
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT USAGE ON SCHEMA realtime TO service_role;
GRANT ALL ON SCHEMA realtime TO supabase_realtime_admin;


--
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT ALL ON SCHEMA storage TO postgres;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin;
GRANT ALL ON SCHEMA storage TO dashboard_user;


--
-- Name: SCHEMA supabase_functions; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA supabase_functions TO postgres;
GRANT USAGE ON SCHEMA supabase_functions TO anon;
GRANT USAGE ON SCHEMA supabase_functions TO authenticated;
GRANT USAGE ON SCHEMA supabase_functions TO service_role;
GRANT ALL ON SCHEMA supabase_functions TO supabase_functions_admin;


--
-- Name: SCHEMA vault; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA vault TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;


--
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;


--
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;


--
-- Name: FUNCTION algorithm_sign(signables text, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.algorithm_sign(signables text, secret text, algorithm text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.algorithm_sign(signables text, secret text, algorithm text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.grant_pg_cron_access() FROM postgres;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_net_access(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.grant_pg_net_access() FROM postgres;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pg_stat_statements_reset(userid oid, dbid oid, queryid bigint); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_ddl_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_drop_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION sign(payload json, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.sign(payload json, secret text, algorithm text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.sign(payload json, secret text, algorithm text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION try_cast_double(inp text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.try_cast_double(inp text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.try_cast_double(inp text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION url_decode(data text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.url_decode(data text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.url_decode(data text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION url_encode(data bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.url_encode(data bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.url_encode(data bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION verify(token text, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.verify(token text, secret text, algorithm text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.verify(token text, secret text, algorithm text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION graphql("operationName" text, query text, variables jsonb, extensions jsonb); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO postgres;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO anon;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO authenticated;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO service_role;


--
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO postgres;


--
-- Name: FUNCTION get_current_user_role(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.get_current_user_role() TO postgres;
GRANT ALL ON FUNCTION public.get_current_user_role() TO anon;
GRANT ALL ON FUNCTION public.get_current_user_role() TO authenticated;
GRANT ALL ON FUNCTION public.get_current_user_role() TO service_role;


--
-- Name: FUNCTION get_employee_leave_balance(p_employee_id uuid, p_year integer); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.get_employee_leave_balance(p_employee_id uuid, p_year integer) TO postgres;
GRANT ALL ON FUNCTION public.get_employee_leave_balance(p_employee_id uuid, p_year integer) TO anon;
GRANT ALL ON FUNCTION public.get_employee_leave_balance(p_employee_id uuid, p_year integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_employee_leave_balance(p_employee_id uuid, p_year integer) TO service_role;


--
-- Name: FUNCTION get_floor_plan_permissions(p_floor_plan_id uuid); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.get_floor_plan_permissions(p_floor_plan_id uuid) TO postgres;
GRANT ALL ON FUNCTION public.get_floor_plan_permissions(p_floor_plan_id uuid) TO anon;
GRANT ALL ON FUNCTION public.get_floor_plan_permissions(p_floor_plan_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.get_floor_plan_permissions(p_floor_plan_id uuid) TO service_role;


--
-- Name: FUNCTION get_project_statistics(p_project_id uuid); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.get_project_statistics(p_project_id uuid) TO postgres;
GRANT ALL ON FUNCTION public.get_project_statistics(p_project_id uuid) TO anon;
GRANT ALL ON FUNCTION public.get_project_statistics(p_project_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.get_project_statistics(p_project_id uuid) TO service_role;


--
-- Name: FUNCTION get_user_role(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.get_user_role() TO postgres;
GRANT ALL ON FUNCTION public.get_user_role() TO anon;
GRANT ALL ON FUNCTION public.get_user_role() TO authenticated;
GRANT ALL ON FUNCTION public.get_user_role() TO service_role;


--
-- Name: FUNCTION handle_new_user(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.handle_new_user() TO postgres;
GRANT ALL ON FUNCTION public.handle_new_user() TO anon;
GRANT ALL ON FUNCTION public.handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION public.handle_new_user() TO service_role;


--
-- Name: FUNCTION has_floor_plan_access(p_floor_plan_id uuid, p_user_id uuid); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.has_floor_plan_access(p_floor_plan_id uuid, p_user_id uuid) TO postgres;
GRANT ALL ON FUNCTION public.has_floor_plan_access(p_floor_plan_id uuid, p_user_id uuid) TO anon;
GRANT ALL ON FUNCTION public.has_floor_plan_access(p_floor_plan_id uuid, p_user_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.has_floor_plan_access(p_floor_plan_id uuid, p_user_id uuid) TO service_role;


--
-- Name: FUNCTION has_floor_plan_admin_access(p_floor_plan_id uuid, p_user_id uuid); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.has_floor_plan_admin_access(p_floor_plan_id uuid, p_user_id uuid) TO postgres;
GRANT ALL ON FUNCTION public.has_floor_plan_admin_access(p_floor_plan_id uuid, p_user_id uuid) TO anon;
GRANT ALL ON FUNCTION public.has_floor_plan_admin_access(p_floor_plan_id uuid, p_user_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.has_floor_plan_admin_access(p_floor_plan_id uuid, p_user_id uuid) TO service_role;


--
-- Name: FUNCTION has_floor_plan_edit_access(p_floor_plan_id uuid, p_user_id uuid); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.has_floor_plan_edit_access(p_floor_plan_id uuid, p_user_id uuid) TO postgres;
GRANT ALL ON FUNCTION public.has_floor_plan_edit_access(p_floor_plan_id uuid, p_user_id uuid) TO anon;
GRANT ALL ON FUNCTION public.has_floor_plan_edit_access(p_floor_plan_id uuid, p_user_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.has_floor_plan_edit_access(p_floor_plan_id uuid, p_user_id uuid) TO service_role;


--
-- Name: FUNCTION has_project_access(p_project_id uuid, p_user_id uuid); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.has_project_access(p_project_id uuid, p_user_id uuid) TO postgres;
GRANT ALL ON FUNCTION public.has_project_access(p_project_id uuid, p_user_id uuid) TO anon;
GRANT ALL ON FUNCTION public.has_project_access(p_project_id uuid, p_user_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.has_project_access(p_project_id uuid, p_user_id uuid) TO service_role;


--
-- Name: FUNCTION has_project_admin_access(p_project_id uuid, p_user_id uuid); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.has_project_admin_access(p_project_id uuid, p_user_id uuid) TO postgres;
GRANT ALL ON FUNCTION public.has_project_admin_access(p_project_id uuid, p_user_id uuid) TO anon;
GRANT ALL ON FUNCTION public.has_project_admin_access(p_project_id uuid, p_user_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.has_project_admin_access(p_project_id uuid, p_user_id uuid) TO service_role;


--
-- Name: FUNCTION initialize_leave_balance(p_employee_id uuid, p_leave_type text, p_year integer, p_total_days numeric); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.initialize_leave_balance(p_employee_id uuid, p_leave_type text, p_year integer, p_total_days numeric) TO postgres;
GRANT ALL ON FUNCTION public.initialize_leave_balance(p_employee_id uuid, p_leave_type text, p_year integer, p_total_days numeric) TO anon;
GRANT ALL ON FUNCTION public.initialize_leave_balance(p_employee_id uuid, p_leave_type text, p_year integer, p_total_days numeric) TO authenticated;
GRANT ALL ON FUNCTION public.initialize_leave_balance(p_employee_id uuid, p_leave_type text, p_year integer, p_total_days numeric) TO service_role;


--
-- Name: FUNCTION is_boss(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.is_boss() TO postgres;
GRANT ALL ON FUNCTION public.is_boss() TO anon;
GRANT ALL ON FUNCTION public.is_boss() TO authenticated;
GRANT ALL ON FUNCTION public.is_boss() TO service_role;


--
-- Name: FUNCTION is_boss_or_hr(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.is_boss_or_hr() TO postgres;
GRANT ALL ON FUNCTION public.is_boss_or_hr() TO anon;
GRANT ALL ON FUNCTION public.is_boss_or_hr() TO authenticated;
GRANT ALL ON FUNCTION public.is_boss_or_hr() TO service_role;


--
-- Name: FUNCTION is_hr(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.is_hr() TO postgres;
GRANT ALL ON FUNCTION public.is_hr() TO anon;
GRANT ALL ON FUNCTION public.is_hr() TO authenticated;
GRANT ALL ON FUNCTION public.is_hr() TO service_role;


--
-- Name: FUNCTION update_attendance_leave_requests_updated_at(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.update_attendance_leave_requests_updated_at() TO postgres;
GRANT ALL ON FUNCTION public.update_attendance_leave_requests_updated_at() TO anon;
GRANT ALL ON FUNCTION public.update_attendance_leave_requests_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.update_attendance_leave_requests_updated_at() TO service_role;


--
-- Name: FUNCTION update_attendance_records_updated_at(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.update_attendance_records_updated_at() TO postgres;
GRANT ALL ON FUNCTION public.update_attendance_records_updated_at() TO anon;
GRANT ALL ON FUNCTION public.update_attendance_records_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.update_attendance_records_updated_at() TO service_role;


--
-- Name: FUNCTION update_employee_updated_at(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.update_employee_updated_at() TO postgres;
GRANT ALL ON FUNCTION public.update_employee_updated_at() TO anon;
GRANT ALL ON FUNCTION public.update_employee_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.update_employee_updated_at() TO service_role;


--
-- Name: FUNCTION update_leave_balance_on_request_change(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.update_leave_balance_on_request_change() TO postgres;
GRANT ALL ON FUNCTION public.update_leave_balance_on_request_change() TO anon;
GRANT ALL ON FUNCTION public.update_leave_balance_on_request_change() TO authenticated;
GRANT ALL ON FUNCTION public.update_leave_balance_on_request_change() TO service_role;


--
-- Name: FUNCTION update_leave_balances_updated_at(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.update_leave_balances_updated_at() TO postgres;
GRANT ALL ON FUNCTION public.update_leave_balances_updated_at() TO anon;
GRANT ALL ON FUNCTION public.update_leave_balances_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.update_leave_balances_updated_at() TO service_role;


--
-- Name: FUNCTION update_leave_requests_updated_at(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.update_leave_requests_updated_at() TO postgres;
GRANT ALL ON FUNCTION public.update_leave_requests_updated_at() TO anon;
GRANT ALL ON FUNCTION public.update_leave_requests_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.update_leave_requests_updated_at() TO service_role;


--
-- Name: FUNCTION update_updated_at_column(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.update_updated_at_column() TO postgres;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO anon;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO authenticated;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO service_role;


--
-- Name: FUNCTION update_user_profiles_updated_at(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.update_user_profiles_updated_at() TO postgres;
GRANT ALL ON FUNCTION public.update_user_profiles_updated_at() TO anon;
GRANT ALL ON FUNCTION public.update_user_profiles_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.update_user_profiles_updated_at() TO service_role;


--
-- Name: FUNCTION apply_rls(wal jsonb, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO postgres;
GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO dashboard_user;


--
-- Name: FUNCTION build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO postgres;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO anon;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO service_role;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION "cast"(val text, type_ regtype); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO dashboard_user;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO anon;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO authenticated;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO service_role;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO supabase_realtime_admin;


--
-- Name: FUNCTION check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO service_role;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO supabase_realtime_admin;


--
-- Name: FUNCTION is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO anon;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO service_role;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION quote_wal2json(entity regclass); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO anon;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO authenticated;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO service_role;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO supabase_realtime_admin;


--
-- Name: FUNCTION send(payload jsonb, event text, topic text, private boolean); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO postgres;
GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO dashboard_user;


--
-- Name: FUNCTION subscription_check_filters(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO anon;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO authenticated;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO service_role;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO supabase_realtime_admin;


--
-- Name: FUNCTION to_regrole(role_name text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO anon;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO authenticated;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO service_role;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO supabase_realtime_admin;


--
-- Name: FUNCTION topic(); Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON FUNCTION realtime.topic() TO postgres;
GRANT ALL ON FUNCTION realtime.topic() TO dashboard_user;


--
-- Name: FUNCTION http_request(); Type: ACL; Schema: supabase_functions; Owner: supabase_functions_admin
--

REVOKE ALL ON FUNCTION supabase_functions.http_request() FROM PUBLIC;
GRANT ALL ON FUNCTION supabase_functions.http_request() TO anon;
GRANT ALL ON FUNCTION supabase_functions.http_request() TO authenticated;
GRANT ALL ON FUNCTION supabase_functions.http_request() TO service_role;
GRANT ALL ON FUNCTION supabase_functions.http_request() TO postgres;


--
-- Name: FUNCTION _crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION create_secret(new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;


--
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.flow_state TO dashboard_user;


--
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.identities TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;


--
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;


--
-- Name: TABLE one_time_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.one_time_tokens TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;


--
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.schema_migrations TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.schema_migrations TO postgres;
GRANT SELECT ON TABLE auth.schema_migrations TO postgres WITH GRANT OPTION;


--
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;


--
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;


--
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;


--
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON TABLE extensions.pg_stat_statements TO postgres WITH GRANT OPTION;


--
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON TABLE extensions.pg_stat_statements_info TO postgres WITH GRANT OPTION;


--
-- Name: TABLE attendance_leave_requests; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.attendance_leave_requests TO postgres;
GRANT ALL ON TABLE public.attendance_leave_requests TO anon;
GRANT ALL ON TABLE public.attendance_leave_requests TO authenticated;
GRANT ALL ON TABLE public.attendance_leave_requests TO service_role;


--
-- Name: TABLE attendance_records; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.attendance_records TO postgres;
GRANT ALL ON TABLE public.attendance_records TO anon;
GRANT ALL ON TABLE public.attendance_records TO authenticated;
GRANT ALL ON TABLE public.attendance_records TO service_role;


--
-- Name: TABLE customers; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.customers TO postgres;
GRANT ALL ON TABLE public.customers TO anon;
GRANT ALL ON TABLE public.customers TO authenticated;
GRANT ALL ON TABLE public.customers TO service_role;


--
-- Name: TABLE employee_skills; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.employee_skills TO postgres;
GRANT ALL ON TABLE public.employee_skills TO anon;
GRANT ALL ON TABLE public.employee_skills TO authenticated;
GRANT ALL ON TABLE public.employee_skills TO service_role;


--
-- Name: TABLE employees; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.employees TO postgres;
GRANT ALL ON TABLE public.employees TO anon;
GRANT ALL ON TABLE public.employees TO authenticated;
GRANT ALL ON TABLE public.employees TO service_role;


--
-- Name: TABLE floor_plan_permissions; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.floor_plan_permissions TO postgres;
GRANT ALL ON TABLE public.floor_plan_permissions TO anon;
GRANT ALL ON TABLE public.floor_plan_permissions TO authenticated;
GRANT ALL ON TABLE public.floor_plan_permissions TO service_role;


--
-- Name: TABLE floor_plans; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.floor_plans TO postgres;
GRANT ALL ON TABLE public.floor_plans TO anon;
GRANT ALL ON TABLE public.floor_plans TO authenticated;
GRANT ALL ON TABLE public.floor_plans TO service_role;


--
-- Name: TABLE holidays; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.holidays TO postgres;
GRANT ALL ON TABLE public.holidays TO anon;
GRANT ALL ON TABLE public.holidays TO authenticated;
GRANT ALL ON TABLE public.holidays TO service_role;


--
-- Name: TABLE images; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.images TO postgres;
GRANT ALL ON TABLE public.images TO anon;
GRANT ALL ON TABLE public.images TO authenticated;
GRANT ALL ON TABLE public.images TO service_role;


--
-- Name: TABLE job_vacancies; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.job_vacancies TO postgres;
GRANT ALL ON TABLE public.job_vacancies TO anon;
GRANT ALL ON TABLE public.job_vacancies TO authenticated;
GRANT ALL ON TABLE public.job_vacancies TO service_role;


--
-- Name: TABLE leave_balances; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.leave_balances TO postgres;
GRANT ALL ON TABLE public.leave_balances TO anon;
GRANT ALL ON TABLE public.leave_balances TO authenticated;
GRANT ALL ON TABLE public.leave_balances TO service_role;


--
-- Name: TABLE leave_requests; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.leave_requests TO postgres;
GRANT ALL ON TABLE public.leave_requests TO anon;
GRANT ALL ON TABLE public.leave_requests TO authenticated;
GRANT ALL ON TABLE public.leave_requests TO service_role;


--
-- Name: TABLE photo_records; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.photo_records TO postgres;
GRANT ALL ON TABLE public.photo_records TO anon;
GRANT ALL ON TABLE public.photo_records TO authenticated;
GRANT ALL ON TABLE public.photo_records TO service_role;


--
-- Name: TABLE profiles; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.profiles TO postgres;
GRANT ALL ON TABLE public.profiles TO anon;
GRANT ALL ON TABLE public.profiles TO authenticated;
GRANT ALL ON TABLE public.profiles TO service_role;


--
-- Name: TABLE project_clients; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.project_clients TO postgres;
GRANT ALL ON TABLE public.project_clients TO anon;
GRANT ALL ON TABLE public.project_clients TO authenticated;
GRANT ALL ON TABLE public.project_clients TO service_role;


--
-- Name: TABLE project_comments; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.project_comments TO postgres;
GRANT ALL ON TABLE public.project_comments TO anon;
GRANT ALL ON TABLE public.project_comments TO authenticated;
GRANT ALL ON TABLE public.project_comments TO service_role;


--
-- Name: TABLE project_members; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.project_members TO postgres;
GRANT ALL ON TABLE public.project_members TO anon;
GRANT ALL ON TABLE public.project_members TO authenticated;
GRANT ALL ON TABLE public.project_members TO service_role;


--
-- Name: TABLE project_tasks; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.project_tasks TO postgres;
GRANT ALL ON TABLE public.project_tasks TO anon;
GRANT ALL ON TABLE public.project_tasks TO authenticated;
GRANT ALL ON TABLE public.project_tasks TO service_role;


--
-- Name: TABLE project_timeline; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.project_timeline TO postgres;
GRANT ALL ON TABLE public.project_timeline TO anon;
GRANT ALL ON TABLE public.project_timeline TO authenticated;
GRANT ALL ON TABLE public.project_timeline TO service_role;


--
-- Name: TABLE projects; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.projects TO postgres;
GRANT ALL ON TABLE public.projects TO anon;
GRANT ALL ON TABLE public.projects TO authenticated;
GRANT ALL ON TABLE public.projects TO service_role;


--
-- Name: TABLE system_settings; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.system_settings TO postgres;
GRANT ALL ON TABLE public.system_settings TO anon;
GRANT ALL ON TABLE public.system_settings TO authenticated;
GRANT ALL ON TABLE public.system_settings TO service_role;


--
-- Name: TABLE user_profiles; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public.user_profiles TO postgres;
GRANT ALL ON TABLE public.user_profiles TO anon;
GRANT ALL ON TABLE public.user_profiles TO authenticated;
GRANT ALL ON TABLE public.user_profiles TO service_role;


--
-- Name: TABLE messages; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON TABLE realtime.messages TO postgres;
GRANT ALL ON TABLE realtime.messages TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO service_role;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.schema_migrations TO postgres;
GRANT ALL ON TABLE realtime.schema_migrations TO dashboard_user;
GRANT SELECT ON TABLE realtime.schema_migrations TO anon;
GRANT SELECT ON TABLE realtime.schema_migrations TO authenticated;
GRANT SELECT ON TABLE realtime.schema_migrations TO service_role;
GRANT ALL ON TABLE realtime.schema_migrations TO supabase_realtime_admin;


--
-- Name: TABLE subscription; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.subscription TO postgres;
GRANT ALL ON TABLE realtime.subscription TO dashboard_user;
GRANT SELECT ON TABLE realtime.subscription TO anon;
GRANT SELECT ON TABLE realtime.subscription TO authenticated;
GRANT SELECT ON TABLE realtime.subscription TO service_role;
GRANT ALL ON TABLE realtime.subscription TO supabase_realtime_admin;


--
-- Name: SEQUENCE subscription_id_seq; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO service_role;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO supabase_realtime_admin;


--
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.buckets TO anon;
GRANT ALL ON TABLE storage.buckets TO authenticated;
GRANT ALL ON TABLE storage.buckets TO service_role;
GRANT ALL ON TABLE storage.buckets TO postgres;


--
-- Name: TABLE buckets_analytics; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.buckets_analytics TO service_role;
GRANT ALL ON TABLE storage.buckets_analytics TO authenticated;
GRANT ALL ON TABLE storage.buckets_analytics TO anon;


--
-- Name: TABLE iceberg_namespaces; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.iceberg_namespaces TO service_role;
GRANT SELECT ON TABLE storage.iceberg_namespaces TO authenticated;
GRANT SELECT ON TABLE storage.iceberg_namespaces TO anon;


--
-- Name: TABLE iceberg_tables; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.iceberg_tables TO service_role;
GRANT SELECT ON TABLE storage.iceberg_tables TO authenticated;
GRANT SELECT ON TABLE storage.iceberg_tables TO anon;


--
-- Name: TABLE migrations; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.migrations TO anon;
GRANT ALL ON TABLE storage.migrations TO authenticated;
GRANT ALL ON TABLE storage.migrations TO service_role;
GRANT ALL ON TABLE storage.migrations TO postgres;


--
-- Name: TABLE objects; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.objects TO anon;
GRANT ALL ON TABLE storage.objects TO authenticated;
GRANT ALL ON TABLE storage.objects TO service_role;
GRANT ALL ON TABLE storage.objects TO postgres;


--
-- Name: TABLE prefixes; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.prefixes TO service_role;
GRANT ALL ON TABLE storage.prefixes TO authenticated;
GRANT ALL ON TABLE storage.prefixes TO anon;


--
-- Name: TABLE s3_multipart_uploads; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO anon;


--
-- Name: TABLE s3_multipart_uploads_parts; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads_parts TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO anon;


--
-- Name: TABLE hooks; Type: ACL; Schema: supabase_functions; Owner: supabase_functions_admin
--

GRANT ALL ON TABLE supabase_functions.hooks TO anon;
GRANT ALL ON TABLE supabase_functions.hooks TO authenticated;
GRANT ALL ON TABLE supabase_functions.hooks TO service_role;


--
-- Name: SEQUENCE hooks_id_seq; Type: ACL; Schema: supabase_functions; Owner: supabase_functions_admin
--

GRANT ALL ON SEQUENCE supabase_functions.hooks_id_seq TO anon;
GRANT ALL ON SEQUENCE supabase_functions.hooks_id_seq TO authenticated;
GRANT ALL ON SEQUENCE supabase_functions.hooks_id_seq TO service_role;


--
-- Name: TABLE migrations; Type: ACL; Schema: supabase_functions; Owner: supabase_functions_admin
--

GRANT ALL ON TABLE supabase_functions.migrations TO anon;
GRANT ALL ON TABLE supabase_functions.migrations TO authenticated;
GRANT ALL ON TABLE supabase_functions.migrations TO service_role;


--
-- Name: TABLE secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,DELETE ON TABLE vault.secrets TO postgres WITH GRANT OPTION;


--
-- Name: TABLE decrypted_secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,DELETE ON TABLE vault.decrypted_secrets TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON SEQUENCES  TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON FUNCTIONS  TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON TABLES  TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: supabase_functions; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA supabase_functions GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA supabase_functions GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA supabase_functions GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA supabase_functions GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: supabase_functions; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA supabase_functions GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA supabase_functions GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA supabase_functions GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA supabase_functions GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: supabase_functions; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA supabase_functions GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA supabase_functions GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA supabase_functions GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA supabase_functions GRANT ALL ON TABLES  TO service_role;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


ALTER EVENT TRIGGER issue_graphql_placeholder OWNER TO supabase_admin;

--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


ALTER EVENT TRIGGER issue_pg_cron_access OWNER TO supabase_admin;

--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


ALTER EVENT TRIGGER issue_pg_graphql_access OWNER TO supabase_admin;

--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: postgres
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


ALTER EVENT TRIGGER issue_pg_net_access OWNER TO postgres;

--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


ALTER EVENT TRIGGER pgrst_ddl_watch OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


ALTER EVENT TRIGGER pgrst_drop_watch OWNER TO supabase_admin;

--
-- PostgreSQL database dump complete
--

