-- =====================================================================
-- VIRAASA – Supabase setup / repair script
-- Run once: Supabase Dashboard -> SQL Editor -> New query -> paste -> RUN
-- Safe to run again. It does NOT delete any data.
-- =====================================================================

-- 1) Storage buckets: public, no file-type restriction (this is what blocks WAV/MP3/M4A
--    audio when a bucket was created with an "Allowed MIME types" list), size limits set.
--    NOTE: Supabase FREE plan can never exceed 50 MB per file (global limit).
--    On a Pro plan you can raise 52428800 below, and also raise the global limit in
--    Storage -> Settings.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('images', 'images', true, 10485760, null),
  ('videos', 'videos', true, 52428800, null),
  ('audio',  'audio',  true, 52428800, null)
on conflict (id) do update
  set public = true,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = null;

-- 2) Make sure every column the admin panel / website uses exists.
alter table public.heritage_places
  add column if not exists video_en text,  add column if not exists video_gu text,  add column if not exists video_hi text,
  add column if not exists audio_en text,  add column if not exists audio_gu text,  add column if not exists audio_hi text,
  add column if not exists audio_cover_en text, add column if not exists audio_cover_gu text, add column if not exists audio_cover_hi text,
  add column if not exists image_url text,
  add column if not exists important_facts_en text, add column if not exists important_facts_gu text, add column if not exists important_facts_hi text,
  add column if not exists why_it_matters_en text,  add column if not exists why_it_matters_gu text,  add column if not exists why_it_matters_hi text,
  add column if not exists connection_title_en text, add column if not exists connection_title_gu text, add column if not exists connection_title_hi text,
  add column if not exists connection_text_en text,  add column if not exists connection_text_gu text,  add column if not exists connection_text_hi text;

-- 3) (OPTIONAL – only if "TEST STORAGE" in the admin Settings reports a permissions error)
--    Replace viraasa_admins / email with the table where your admin e-mails are stored,
--    remove the leading "--" on the lines below, and run.
--
-- drop policy if exists "viraasa public read"  on storage.objects;
-- drop policy if exists "viraasa admin write"  on storage.objects;
-- create policy "viraasa public read" on storage.objects for select
--   using (bucket_id in ('images','videos','audio'));
-- create policy "viraasa admin write" on storage.objects for all to authenticated
--   using      (bucket_id in ('images','videos','audio') and exists (select 1 from public.viraasa_admins a where a.email = auth.jwt()->>'email'))
--   with check (bucket_id in ('images','videos','audio') and exists (select 1 from public.viraasa_admins a where a.email = auth.jwt()->>'email'));
