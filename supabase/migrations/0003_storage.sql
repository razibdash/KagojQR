-- Private "documents" bucket. Path: {owner_id}/{doc_type}/{filename}

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'documents', 'documents', false,
  10 * 1024 * 1024,  -- 10 MB
  array['image/jpeg', 'image/png', 'image/webp', 'application/pdf']
)
on conflict (id) do update
  set public = false,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Owner may upload / read / update / delete only inside their own folder.
-- (storage.foldername(name))[1] is the first path segment = owner_id.
create policy documents_bucket_select_own on storage.objects
  for select to authenticated
  using (bucket_id = 'documents'
         and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy documents_bucket_insert_own on storage.objects
  for insert to authenticated
  with check (bucket_id = 'documents'
              and (storage.foldername(name))[1] = (select auth.uid())::text
              and (storage.foldername(name))[2] in ('license', 'passport', 'car_paper'));

create policy documents_bucket_update_own on storage.objects
  for update to authenticated
  using (bucket_id = 'documents'
         and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'documents'
              and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy documents_bucket_delete_own on storage.objects
  for delete to authenticated
  using (bucket_id = 'documents'
         and (storage.foldername(name))[1] = (select auth.uid())::text);
