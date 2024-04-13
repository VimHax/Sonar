-- Add buckets

insert into storage.buckets
  (id, name, public, allowed_mime_types)
values
  ('audio', 'audio', true, '{"audio/*"}'),
  ('thumbnail', 'thumbnail', true, '{"image/*"}');

-- Enable Realtime

alter
  publication supabase_realtime add table intros;

alter
  publication supabase_realtime add table members;

alter
  publication supabase_realtime add table sounds;
