create extension if not exists "pgcrypto";

create table if not exists public.settings (
  key text primary key,
  value text not null default '',
  updated_at timestamptz not null default now()
);

create table if not exists public.foods (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.draw_records (
  id uuid primary key default gen_random_uuid(),
  food text not null,
  shop text not null default '',
  rating integer not null default 0 check (rating between 0 and 5),
  photo_url text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.checkins (
  id uuid primary key default gen_random_uuid(),
  food text not null,
  shop text not null,
  rating integer not null check (rating between 1 and 5),
  photo_url text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.checkin_likes (
  id uuid primary key default gen_random_uuid(),
  checkin_id uuid not null references public.checkins(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.checkin_comments (
  id uuid primary key default gen_random_uuid(),
  checkin_id uuid not null references public.checkins(id) on delete cascade,
  content text not null check (char_length(content) between 1 and 40),
  created_at timestamptz not null default now()
);

alter table public.settings enable row level security;
alter table public.foods enable row level security;
alter table public.draw_records enable row level security;
alter table public.checkins enable row level security;
alter table public.checkin_likes enable row level security;
alter table public.checkin_comments enable row level security;

drop policy if exists "public read settings" on public.settings;
drop policy if exists "public write settings" on public.settings;
drop policy if exists "public read foods" on public.foods;
drop policy if exists "public write foods" on public.foods;
drop policy if exists "public read draw records" on public.draw_records;
drop policy if exists "public write draw records" on public.draw_records;
drop policy if exists "public read checkins" on public.checkins;
drop policy if exists "public write checkins" on public.checkins;
drop policy if exists "public read checkin likes" on public.checkin_likes;
drop policy if exists "public write checkin likes" on public.checkin_likes;
drop policy if exists "public read checkin comments" on public.checkin_comments;
drop policy if exists "public write checkin comments" on public.checkin_comments;

create policy "public read settings" on public.settings for select using (true);
create policy "public write settings" on public.settings for all using (true) with check (true);
create policy "public read foods" on public.foods for select using (true);
create policy "public write foods" on public.foods for all using (true) with check (true);
create policy "public read draw records" on public.draw_records for select using (true);
create policy "public write draw records" on public.draw_records for all using (true) with check (true);
create policy "public read checkins" on public.checkins for select using (true);
create policy "public write checkins" on public.checkins for all using (true) with check (true);
create policy "public read checkin likes" on public.checkin_likes for select using (true);
create policy "public write checkin likes" on public.checkin_likes for all using (true) with check (true);
create policy "public read checkin comments" on public.checkin_comments for select using (true);
create policy "public write checkin comments" on public.checkin_comments for all using (true) with check (true);

insert into storage.buckets (id, name, public)
values ('food-photos', 'food-photos', true)
on conflict (id) do update set public = true;

drop policy if exists "public read food photos" on storage.objects;
drop policy if exists "public upload food photos" on storage.objects;
drop policy if exists "public update food photos" on storage.objects;
drop policy if exists "public delete food photos" on storage.objects;

create policy "public read food photos"
on storage.objects for select
using (bucket_id = 'food-photos');

create policy "public upload food photos"
on storage.objects for insert
with check (bucket_id = 'food-photos');

create policy "public update food photos"
on storage.objects for update
using (bucket_id = 'food-photos')
with check (bucket_id = 'food-photos');

create policy "public delete food photos"
on storage.objects for delete
using (bucket_id = 'food-photos');
