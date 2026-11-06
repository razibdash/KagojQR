-- Row Level Security for every table.

alter table public.profiles       enable row level security;
alter table public.documents      enable row level security;
alter table public.qr_tokens      enable row level security;
alter table public.access_logs    enable row level security;
alter table public.pin_attempts   enable row level security;
alter table public.notifications  enable row level security;

-- ---------------------------------------------------------------- profiles
create policy profiles_select_own on public.profiles
  for select to authenticated using (id = (select auth.uid()));
create policy profiles_insert_own on public.profiles
  for insert to authenticated with check (id = (select auth.uid()));
create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));
create policy profiles_delete_own on public.profiles
  for delete to authenticated using (id = (select auth.uid()));

-- --------------------------------------------------------------- documents
create policy documents_select_own on public.documents
  for select to authenticated using (owner_id = (select auth.uid()));
create policy documents_insert_own on public.documents
  for insert to authenticated with check (owner_id = (select auth.uid()));
create policy documents_update_own on public.documents
  for update to authenticated
  using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy documents_delete_own on public.documents
  for delete to authenticated using (owner_id = (select auth.uid()));

-- --------------------------------------------------------------- qr_tokens
create policy qr_tokens_select_own on public.qr_tokens
  for select to authenticated using (owner_id = (select auth.uid()));
create policy qr_tokens_insert_own on public.qr_tokens
  for insert to authenticated with check (owner_id = (select auth.uid()));
create policy qr_tokens_update_own on public.qr_tokens
  for update to authenticated
  using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy qr_tokens_delete_own on public.qr_tokens
  for delete to authenticated using (owner_id = (select auth.uid()));

-- ------------------------------------------------------------- access_logs
-- Owner may only SELECT logs of their own tokens. No insert/update/delete
-- policies: writes happen only via the Edge Function (service role bypasses RLS).
create policy access_logs_select_own on public.access_logs
  for select to authenticated
  using (exists (
    select 1 from public.qr_tokens t
    where t.id = access_logs.token_id
      and t.owner_id = (select auth.uid())
  ));

-- ----------------------------------------------------------- notifications
-- Owner can read, mark read, and delete. Inserts only via service role.
create policy notifications_select_own on public.notifications
  for select to authenticated using (owner_id = (select auth.uid()));
create policy notifications_update_own on public.notifications
  for update to authenticated
  using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy notifications_delete_own on public.notifications
  for delete to authenticated using (owner_id = (select auth.uid()));

-- ------------------------------------------------------------ pin_attempts
-- Intentionally NO policies: only the service role can touch this table.

-- Defence in depth: anon role gets nothing on these tables.
revoke all on public.profiles, public.documents, public.qr_tokens,
              public.access_logs, public.pin_attempts, public.notifications
  from anon;

-- Owners must never read the PIN hash from the client, and must not be able
-- to set a hash of their own choosing (PIN is hashed server-side only).
revoke select (pin_hash) on public.qr_tokens from authenticated;
revoke insert (pin_hash), update (pin_hash) on public.qr_tokens from authenticated;
