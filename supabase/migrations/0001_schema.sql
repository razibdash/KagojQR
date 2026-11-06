-- KagojQR schema: tables, constraints, signup trigger.
-- RLS lives in 0002_rls.sql, storage in 0003_storage.sql.

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------- profiles
create table public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  full_name   text,
  email       text,
  created_at  timestamptz not null default now()
);

-- Auto-create a profile row when a user signs up (Google login).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name'),
    new.email
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- --------------------------------------------------------------- documents
create table public.documents (
  id           uuid primary key default gen_random_uuid(),
  owner_id     uuid not null references public.profiles (id) on delete cascade,
  doc_type     text not null check (doc_type in ('license', 'passport', 'car_paper')),
  file_path    text not null,  -- storage path: {owner_id}/{doc_type}/{filename}
  expiry_date  date,
  created_at   timestamptz not null default now(),
  -- The path must live inside the owner's own folder.
  constraint documents_path_in_owner_folder
    check (file_path like owner_id::text || '/%')
);
create index documents_owner_idx on public.documents (owner_id);

-- --------------------------------------------------------------- qr_tokens
create table public.qr_tokens (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null references public.profiles (id) on delete cascade,
  -- 32+ random chars. Default = 48 hex chars (192 bits) from a CSPRNG.
  token       text not null unique
              default encode(gen_random_bytes(24), 'hex')
              check (char_length(token) >= 32),
  pin_hash    text,  -- bcrypt hash, set via Edge Function / RPC only
  is_active   boolean not null default true,
  expires_at  timestamptz,
  created_at  timestamptz not null default now()
);
create index qr_tokens_owner_idx on public.qr_tokens (owner_id);

-- ------------------------------------------------------------- access_logs
create table public.access_logs (
  id                uuid primary key default gen_random_uuid(),
  token_id          uuid not null references public.qr_tokens (id) on delete cascade,
  viewer_name       text,
  viewer_police_id  text,
  viewer_ip         text,
  user_agent        text,
  doc_type          text,
  viewed_at         timestamptz not null default now()
);
create index access_logs_token_idx on public.access_logs (token_id, viewed_at desc);

-- ---------------------------------------------------- failed PIN attempts
-- Used by the Edge Function for rate limiting (5 failures / IP+token / 10 min).
-- Service role only: RLS enabled with no policies = no client access.
create table public.pin_attempts (
  id            bigint generated always as identity primary key,
  token_id      uuid not null references public.qr_tokens (id) on delete cascade,
  viewer_ip     text not null,
  attempted_at  timestamptz not null default now()
);
create index pin_attempts_lookup_idx
  on public.pin_attempts (token_id, viewer_ip, attempted_at desc);

-- ----------------------------------------------------------- notifications
-- In-app owner notifications (FCM push is a later phase).
create table public.notifications (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null references public.profiles (id) on delete cascade,
  title       text not null,
  body        text,
  is_read     boolean not null default false,
  created_at  timestamptz not null default now()
);
create index notifications_owner_idx on public.notifications (owner_id, created_at desc);
