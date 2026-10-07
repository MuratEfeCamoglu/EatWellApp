-- Acceptance test for CLAUDE.md §13 Aşama B1, runnable without Docker
-- against the real project:
--   npx supabase db query --project-ref <ref> -f supabase/tests/rls_test.sql
-- Everything happens inside one transaction that ends in ROLLBACK, so the
-- two throwaway users and their rows never persist. Any failed check
-- raises an exception (and the whole script errors out); success returns
-- a single row 'ALL PASSED'.

begin;

-- Two throwaway users (rolled back at the end).
insert into auth.users (instance_id, id, aud, role, email)
values
  ('00000000-0000-0000-0000-000000000000', 'aaaaaaaa-0000-4000-8000-000000000001',
   'authenticated', 'authenticated', 'rls-test-a@denge.invalid'),
  ('00000000-0000-0000-0000-000000000000', 'bbbbbbbb-0000-4000-8000-000000000002',
   'authenticated', 'authenticated', 'rls-test-b@denge.invalid');

create temp table _result (msg text) on commit drop;
grant all on _result to authenticated, anon;

-- ---------------------------------------------------------------- user A
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);

insert into public.food_log_entries
  (id, created_at, updated_at, date, meal, food_name, serving_label, amount,
   kcal, protein_g, carbs_g, fat_g, source, logged_at)
values
  ('a0000000-0000-4000-8000-000000000001', 1000, 1000, '2026-10-07', 'lunch',
   'Menemen', '1 porsiyon', 1, 120, 6.5, 5.5, 8.2, 'catalog', 1000);

insert into public.weight_entries (id, created_at, updated_at, date, kg, measured_at)
values ('a0000000-0000-4000-8000-000000000002', 1000, 1000, '2026-10-07', 70, 1000);

insert into public.custom_foods
  (id, created_at, updated_at, name, serving_label, kcal_per_serving,
   protein_g, carbs_g, fat_g, category)
values ('a0000000-0000-4000-8000-000000000003', 1000, 1000, 'Annemin böreği',
        '1 dilim', 310, 9, 30, 17, 'hamurIsi');

insert into public.profiles (created_at, updated_at, name, calorie_goal)
values (1000, 1000, 'Test A', 1800);

select public.upsert_water('a0000000-0000-4000-8000-000000000004', '2026-10-07', 3, 1000, 1000);

do $$
declare
  r record;
  n int;
  stored_id text;
begin
  -- user_id defaulted to the caller
  select user_id, server_updated_at into r from public.food_log_entries;
  if r.user_id <> 'aaaaaaaa-0000-4000-8000-000000000001' then
    raise exception 'FAIL: user_id was not defaulted to auth.uid()';
  end if;
  if r.server_updated_at < 1700000000000 then
    raise exception 'FAIL: server_updated_at was not stamped by the server';
  end if;

  -- last write wins: an older updated_at is ignored...
  update public.food_log_entries set kcal = 999, updated_at = 500
  where id = 'a0000000-0000-4000-8000-000000000001';
  select kcal into n from public.food_log_entries;
  if n <> 120 then raise exception 'FAIL: stale update overwrote newer data'; end if;

  -- ...a newer one applies and moves the pull cursor forward.
  update public.food_log_entries set kcal = 180, amount = 1.5, updated_at = 2000
  where id = 'a0000000-0000-4000-8000-000000000001';
  select kcal, server_updated_at into r from public.food_log_entries;
  if r.kcal <> 180 then raise exception 'FAIL: newer update was not applied'; end if;

  -- soft delete is just an update
  update public.food_log_entries set deleted_at = 3000, updated_at = 3000
  where id = 'a0000000-0000-4000-8000-000000000001';
  select deleted_at into n from public.food_log_entries;
  if n <> 3000 then raise exception 'FAIL: soft delete failed'; end if;

  -- physical delete is not allowed for clients: no DELETE privilege at
  -- all (and no policy either)
  begin
    delete from public.weight_entries;
    raise exception 'FAIL: client could physically delete a row';
  exception
    when raise_exception then raise;
    when insufficient_privilege then null;
  end;

  -- water: a second device's different id for the same day merges into
  -- one row; newer wins, older is ignored
  perform public.upsert_water('a0000000-0000-4000-8000-000000000005', '2026-10-07', 6, 1500, 2000);
  perform public.upsert_water('a0000000-0000-4000-8000-000000000006', '2026-10-07', 1, 1200, 1200);
  select count(*) into n from public.water_logs;
  if n <> 1 then raise exception 'FAIL: same-day water produced % rows', n; end if;
  select glasses into n from public.water_logs;
  if n <> 6 then raise exception 'FAIL: water last-write-wins broken (glasses=%)', n; end if;
  select (public.upsert_water('a0000000-0000-4000-8000-000000000007', '2026-10-07', 7, 1, 2500)).id::text
    into stored_id;
  if stored_id <> 'a0000000-0000-4000-8000-000000000004' then
    raise exception 'FAIL: upsert_water did not return the stored row id';
  end if;

  -- a client can't move a row to another user
  update public.custom_foods set user_id = 'bbbbbbbb-0000-4000-8000-000000000002', updated_at = 5000
  where id = 'a0000000-0000-4000-8000-000000000003';
  select count(*) into n from public.custom_foods
  where user_id = 'aaaaaaaa-0000-4000-8000-000000000001';
  if n <> 1 then raise exception 'FAIL: row owner could be changed'; end if;
exception
  when raise_exception then raise;
  when others then
    -- the owner-change attempt may also be rejected by RLS WITH CHECK,
    -- which is just as good; anything else is a real failure
    if sqlerrm not like '%row-level security%' then raise; end if;
end;
$$;

-- Profile upsert exactly as the app sends it (ProfileSnapshot.toRow +
-- PostgREST upsert = INSERT ... ON CONFLICT (user_id) DO UPDATE).
insert into public.profiles as p
  (user_id, created_at, updated_at, name, email, gender, age, height_cm,
   weight_kg, activity_level, weight_goal, goal_weight_kg, weekly_pace_kg,
   calorie_goal, protein_goal_g, carbs_goal_g, fat_goal_g, allergies,
   allergy_note, consent_version, consent_at)
values
  ('aaaaaaaa-0000-4000-8000-000000000001', 1000, 5000, 'Ayşe', 'a@x.invalid',
   'female', 27, 168, 70.5, 'moderate', 'lose', 64, 0.5, 1704, 126, 185, 51,
   array['gluten', 'milk'], 'çilek', '2026-10-placeholder', 900)
on conflict (user_id) do update set
  updated_at = excluded.updated_at, weight_kg = excluded.weight_kg,
  calorie_goal = excluded.calorie_goal, allergies = excluded.allergies;

-- an older copy from another device must not win
insert into public.profiles as p (user_id, created_at, updated_at, calorie_goal)
values ('aaaaaaaa-0000-4000-8000-000000000001', 1000, 4000, 1)
on conflict (user_id) do update set
  updated_at = excluded.updated_at, calorie_goal = excluded.calorie_goal;

do $$
declare r record;
begin
  select calorie_goal, weight_kg, allergies, updated_at into r from public.profiles;
  if r.calorie_goal <> 1704 or r.weight_kg <> 70.5 or r.updated_at <> 5000
     or r.allergies <> array['gluten', 'milk'] then
    raise exception 'FAIL: profile upsert / last-write-wins (got %)', r;
  end if;
end;
$$;

-- ---------------------------------------------------------------- user B
select set_config('request.jwt.claims',
  '{"sub":"bbbbbbbb-0000-4000-8000-000000000002","role":"authenticated"}', true);

do $$
declare
  n int;
begin
  -- B sees none of A's rows
  if (select count(*) from public.food_log_entries) <> 0 then raise exception 'FAIL: B can read A food log'; end if;
  if (select count(*) from public.water_logs) <> 0 then raise exception 'FAIL: B can read A water'; end if;
  if (select count(*) from public.weight_entries) <> 0 then raise exception 'FAIL: B can read A weight'; end if;
  if (select count(*) from public.custom_foods) <> 0 then raise exception 'FAIL: B can read A custom foods'; end if;
  if (select count(*) from public.profiles) <> 0 then raise exception 'FAIL: B can read A profile'; end if;

  -- B can't change A's rows
  update public.food_log_entries set kcal = 1, updated_at = 99999;
  get diagnostics n = row_count;
  if n <> 0 then raise exception 'FAIL: B updated A rows'; end if;

  -- B can't insert rows owned by A
  begin
    insert into public.weight_entries (id, user_id, created_at, updated_at, date, kg, measured_at)
    values ('b0000000-0000-4000-8000-000000000001', 'aaaaaaaa-0000-4000-8000-000000000001',
            1, 1, '2026-10-07', 80, 1);
    raise exception 'FAIL: B inserted a row owned by A';
  exception
    when raise_exception then raise;
    when others then null; -- rejected by RLS, as expected
  end;

  -- B's own water for the same day is a separate row
  perform public.upsert_water('b0000000-0000-4000-8000-000000000002', '2026-10-07', 2, 1, 1);
  if (select count(*) from public.water_logs) <> 1 then raise exception 'FAIL: B water not isolated'; end if;
end;
$$;

-- ---------------------------------------------------------------- anon
select set_config('request.jwt.claims', '{"role":"anon"}', true);
set local role anon;

do $$
begin
  begin
    perform count(*) from public.food_log_entries;
    raise exception 'FAIL: anon can read food_log_entries';
  exception
    when raise_exception then raise;
    when insufficient_privilege then null;
  end;
  begin
    perform public.delete_my_account();
    raise exception 'FAIL: anon can call delete_my_account';
  exception
    when raise_exception then raise;
    when insufficient_privilege then null;
  end;
end;
$$;

-- ---------------------------------------------------- account deletion (A)
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","role":"authenticated"}', true);
select public.delete_my_account();

reset role;
do $$
begin
  if exists (select 1 from auth.users where id = 'aaaaaaaa-0000-4000-8000-000000000001') then
    raise exception 'FAIL: delete_my_account left the auth user';
  end if;
  if (select count(*) from public.food_log_entries where user_id = 'aaaaaaaa-0000-4000-8000-000000000001')
     + (select count(*) from public.water_logs where user_id = 'aaaaaaaa-0000-4000-8000-000000000001')
     + (select count(*) from public.weight_entries where user_id = 'aaaaaaaa-0000-4000-8000-000000000001')
     + (select count(*) from public.custom_foods where user_id = 'aaaaaaaa-0000-4000-8000-000000000001')
     + (select count(*) from public.profiles where user_id = 'aaaaaaaa-0000-4000-8000-000000000001') <> 0 then
    raise exception 'FAIL: delete_my_account left data behind';
  end if;
  if (select count(*) from public.water_logs where user_id = 'bbbbbbbb-0000-4000-8000-000000000002') <> 1 then
    raise exception 'FAIL: deleting A touched B''s data';
  end if;
end;
$$;

insert into _result values ('ALL PASSED');
select msg from _result;

rollback;
