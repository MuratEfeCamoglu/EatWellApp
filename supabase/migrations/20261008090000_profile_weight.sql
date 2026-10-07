-- Current weight on the cloud profile, so a second device shows the right
-- weight (and goal suggestions) right after sign-in, before the full weight
-- history is synced (CLAUDE.md §13.6, B3). Additive and nullable.
alter table public.profiles
  add column weight_kg double precision check (weight_kg between 25 and 300);
