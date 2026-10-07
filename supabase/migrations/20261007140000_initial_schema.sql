-- Denge cloud schema v1 (CLAUDE.md §13.2).
--
-- Mirrors the on-device drift tables. Every instant is UTC milliseconds
-- (bigint), exactly like the app, so no conversion happens during sync.
-- Rows are never physically deleted by clients: deletion is `deleted_at`
-- (soft delete) so it can propagate to other devices; only
-- delete_my_account() removes data for real.

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

-- Server clock in UTC ms. clock_timestamp() (not now()) so rows written in
-- one transaction still get increasing values for the pull cursor.
create or replace function public.now_ms()
returns bigint
language sql
volatile
set search_path = ''
as $$ select (extract(epoch from clock_timestamp()) * 1000)::bigint $$;

-- BEFORE INSERT/UPDATE on every synced table:
--  * stamps server_updated_at (clients can't choose it, so the pull cursor
--    never depends on a phone's clock);
--  * last write wins: an UPDATE carrying an older updated_at than the
--    stored row is ignored, so a stale device can't overwrite newer data;
--  * the owner of a row can never change.
create or replace function public.sync_row_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' then
    if new.updated_at < old.updated_at then
      return old;
    end if;
    new.user_id := old.user_id;
    new.created_at := old.created_at;
  end if;
  new.server_updated_at := public.now_ms();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table public.food_log_entries (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  created_at bigint not null,
  updated_at bigint not null,
  deleted_at bigint,
  server_updated_at bigint not null default public.now_ms(),
  date text not null check (date ~ '^\d{4}-\d{2}-\d{2}$'),
  meal text not null check (meal in ('breakfast', 'lunch', 'dinner', 'snack')),
  food_name text not null,
  brand text not null default '',
  serving_label text not null,
  amount double precision not null check (amount > 0),
  kcal integer not null check (kcal >= 0),
  protein_g double precision not null check (protein_g >= 0),
  carbs_g double precision not null check (carbs_g >= 0),
  fat_g double precision not null check (fat_g >= 0),
  source text not null check (source in ('catalog', 'recipe', 'barcode', 'photo', 'custom')),
  source_ref text,
  logged_at bigint not null
);

create table public.water_logs (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  created_at bigint not null,
  updated_at bigint not null,
  deleted_at bigint,
  server_updated_at bigint not null default public.now_ms(),
  date text not null check (date ~ '^\d{4}-\d{2}-\d{2}$'),
  glasses integer not null check (glasses between 0 and 50),
  -- One row per user and day; two devices may have created the same day
  -- with different ids, so writes go through upsert_water().
  unique (user_id, date)
);

create table public.weight_entries (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  created_at bigint not null,
  updated_at bigint not null,
  deleted_at bigint,
  server_updated_at bigint not null default public.now_ms(),
  date text not null check (date ~ '^\d{4}-\d{2}-\d{2}$'),
  kg double precision not null check (kg between 25 and 300),
  measured_at bigint not null
);

create table public.custom_foods (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  created_at bigint not null,
  updated_at bigint not null,
  deleted_at bigint,
  server_updated_at bigint not null default public.now_ms(),
  name text not null check (char_length(btrim(name)) >= 2),
  brand text not null default '',
  serving_label text not null,
  kcal_per_serving integer not null check (kcal_per_serving between 0 and 5000),
  protein_g double precision not null check (protein_g >= 0),
  carbs_g double precision not null check (carbs_g >= 0),
  fat_g double precision not null check (fat_g >= 0),
  category text not null,
  barcode text
);

-- Cloud copy of the profile the app keeps in shared_preferences. Nullable
-- columns: older installs may not know every answer yet.
create table public.profiles (
  user_id uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  created_at bigint not null,
  updated_at bigint not null,
  server_updated_at bigint not null default public.now_ms(),
  name text not null default '',
  email text not null default '',
  gender text check (gender in ('female', 'male')),
  age integer check (age between 13 and 100),
  height_cm double precision check (height_cm between 100 and 250),
  activity_level text check (activity_level in ('sedentary', 'light', 'moderate', 'active')),
  weight_goal text check (weight_goal in ('lose', 'maintain', 'gain')),
  goal_weight_kg double precision check (goal_weight_kg between 30 and 300),
  weekly_pace_kg double precision check (weekly_pace_kg between 0 and 2),
  calorie_goal integer check (calorie_goal between 0 and 6000),
  protein_goal_g integer check (protein_goal_g between 0 and 1000),
  carbs_goal_g integer check (carbs_goal_g between 0 and 1000),
  fat_goal_g integer check (fat_goal_g between 0 and 1000),
  allergies text[] not null default '{}',
  allergy_note text not null default '',
  consent_version text,
  consent_at bigint
);

-- profiles has no id / deleted_at, so it gets its own guard.
create or replace function public.profile_row_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' then
    if new.updated_at < old.updated_at then
      return old;
    end if;
    new.user_id := old.user_id;
    new.created_at := old.created_at;
  end if;
  new.server_updated_at := public.now_ms();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Triggers and pull-cursor indexes
-- ---------------------------------------------------------------------------

create trigger food_log_entries_sync before insert or update on public.food_log_entries
  for each row execute function public.sync_row_guard();
create trigger water_logs_sync before insert or update on public.water_logs
  for each row execute function public.sync_row_guard();
create trigger weight_entries_sync before insert or update on public.weight_entries
  for each row execute function public.sync_row_guard();
create trigger custom_foods_sync before insert or update on public.custom_foods
  for each row execute function public.sync_row_guard();
create trigger profiles_sync before insert or update on public.profiles
  for each row execute function public.profile_row_guard();

create index food_log_entries_pull on public.food_log_entries (user_id, server_updated_at);
create index water_logs_pull on public.water_logs (user_id, server_updated_at);
create index weight_entries_pull on public.weight_entries (user_id, server_updated_at);
create index custom_foods_pull on public.custom_foods (user_id, server_updated_at);

-- ---------------------------------------------------------------------------
-- Row Level Security: a signed-in user only ever sees and writes their own
-- rows. No DELETE policy on purpose (soft delete only). Anonymous visitors
-- get nothing.
-- ---------------------------------------------------------------------------

do $$
declare
  t text;
begin
  foreach t in array array['food_log_entries', 'water_logs', 'weight_entries', 'custom_foods', 'profiles']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon, authenticated', t);
    execute format('grant select, insert, update on public.%I to authenticated', t);
    execute format(
      'create policy %I on public.%I for select to authenticated using (user_id = (select auth.uid()))',
      t || '_select_own', t);
    execute format(
      'create policy %I on public.%I for insert to authenticated with check (user_id = (select auth.uid()))',
      t || '_insert_own', t);
    execute format(
      'create policy %I on public.%I for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()))',
      t || '_update_own', t);
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- RPCs
-- ---------------------------------------------------------------------------

-- Writes a day's water for the caller, resolving the (user_id, date)
-- uniqueness with last-write-wins, and returns the row that is now stored
-- (its id may differ from p_id; the app then adopts the server's id).
-- security invoker: RLS still applies.
create or replace function public.upsert_water(
  p_id uuid,
  p_date text,
  p_glasses integer,
  p_created_at bigint,
  p_updated_at bigint,
  p_deleted_at bigint default null
)
returns public.water_logs
language plpgsql
security invoker
set search_path = ''
as $$
declare
  result public.water_logs;
begin
  insert into public.water_logs (id, user_id, created_at, updated_at, deleted_at, date, glasses)
  values (p_id, auth.uid(), p_created_at, p_updated_at, p_deleted_at, p_date, p_glasses)
  on conflict (user_id, date) do update
    set glasses = excluded.glasses,
        updated_at = excluded.updated_at,
        deleted_at = excluded.deleted_at
    where public.water_logs.updated_at <= excluded.updated_at;

  select * into result
  from public.water_logs
  where user_id = auth.uid() and date = p_date;
  return result;
end;
$$;

-- Deletes the caller's account; every table cascades from auth.users.
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'not signed in';
  end if;
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.upsert_water(uuid, text, integer, bigint, bigint, bigint) from public, anon;
grant execute on function public.upsert_water(uuid, text, integer, bigint, bigint, bigint) to authenticated;
revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
revoke all on function public.now_ms() from public, anon;
grant execute on function public.now_ms() to authenticated;
