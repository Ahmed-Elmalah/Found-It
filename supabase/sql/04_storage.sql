-- =====================================================================
-- FOUND IT - 04: Storage bucket for report photos
--
-- Bucket: report-images (public = anyone with the URL can view a photo)
-- Max 10 MB per file, JPG / PNG only.
-- Folder rule: every user uploads ONLY inside a folder named with
-- their own user id:   report-images/<user_id>/<file name>.jpg
-- =====================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('report-images', 'report-images', true, 10485760, array['image/jpeg', 'image/png'])
on conflict (id) do update
  set public             = excluded.public,
      file_size_limit    = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;


-- read (needed for upsert / list). Viewing by public URL needs no policy.
drop policy if exists "report-images: read" on storage.objects;
create policy "report-images: read"
  on storage.objects for select
  to authenticated
  using (bucket_id = 'report-images');

-- upload only into your own folder
drop policy if exists "report-images: upload own folder" on storage.objects;
create policy "report-images: upload own folder"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'report-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- replace only your own files
drop policy if exists "report-images: update own folder" on storage.objects;
create policy "report-images: update own folder"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'report-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'report-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- delete only your own files
drop policy if exists "report-images: delete own folder" on storage.objects;
create policy "report-images: delete own folder"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'report-images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
